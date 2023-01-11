
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
  80004c:	e8 39 15 00 00       	call   80158a <readn>
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
  800068:	68 a0 27 80 00       	push   $0x8027a0
  80006d:	6a 15                	push   $0x15
  80006f:	68 cf 27 80 00       	push   $0x8027cf
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 e1 27 80 00       	push   $0x8027e1
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 c7 1f 00 00       	call   802058 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 e5 27 80 00       	push   $0x8027e5
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 cf 27 80 00       	push   $0x8027cf
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 b4 0f 00 00       	call   801066 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 ee 27 80 00       	push   $0x8027ee
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 cf 27 80 00       	push   $0x8027cf
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 e8 12 00 00       	call   8013bd <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 dd 12 00 00       	call   8013bd <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 c7 12 00 00       	call   8013bd <close>
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
  800106:	e8 7f 14 00 00       	call   80158a <readn>
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
  800126:	68 f7 27 80 00       	push   $0x8027f7
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 cf 27 80 00       	push   $0x8027cf
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
  800149:	e8 85 14 00 00       	call   8015d3 <write>
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
  800168:	68 13 28 80 00       	push   $0x802813
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 cf 27 80 00       	push   $0x8027cf
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
  800180:	c7 05 00 30 80 00 2d 	movl   $0x80282d,0x803000
  800187:	28 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 c5 1e 00 00       	call   802058 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 e5 27 80 00       	push   $0x8027e5
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 cf 27 80 00       	push   $0x8027cf
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 b2 0e 00 00       	call   801066 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 ee 27 80 00       	push   $0x8027ee
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 cf 27 80 00       	push   $0x8027cf
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 e4 11 00 00       	call   8013bd <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 ce 11 00 00       	call   8013bd <close>

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
  800205:	e8 c9 13 00 00       	call   8015d3 <write>
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
  800221:	68 38 28 80 00       	push   $0x802838
  800226:	6a 4a                	push   $0x4a
  800228:	68 cf 27 80 00       	push   $0x8027cf
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
  800284:	e8 5f 11 00 00       	call   8013e8 <close_all>
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
  8002b6:	68 5c 28 80 00       	push   $0x80285c
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 e3 27 80 00 	movl   $0x8027e3,(%esp)
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
  8003d4:	e8 27 21 00 00       	call   802500 <__udivdi3>
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
  800417:	e8 14 22 00 00       	call   802630 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 7f 28 80 00 	movsbl 0x80287f(%eax),%eax
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
  80051b:	ff 24 85 c0 29 80 00 	jmp    *0x8029c0(,%eax,4)
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
  8005df:	8b 14 85 20 2b 80 00 	mov    0x802b20(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 97 28 80 00       	push   $0x802897
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
  800603:	68 11 2d 80 00       	push   $0x802d11
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
  800627:	b8 90 28 80 00       	mov    $0x802890,%eax
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
  800ca2:	68 7f 2b 80 00       	push   $0x802b7f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 9c 2b 80 00       	push   $0x802b9c
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
  800d23:	68 7f 2b 80 00       	push   $0x802b7f
  800d28:	6a 23                	push   $0x23
  800d2a:	68 9c 2b 80 00       	push   $0x802b9c
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
  800d65:	68 7f 2b 80 00       	push   $0x802b7f
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 9c 2b 80 00       	push   $0x802b9c
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
  800da7:	68 7f 2b 80 00       	push   $0x802b7f
  800dac:	6a 23                	push   $0x23
  800dae:	68 9c 2b 80 00       	push   $0x802b9c
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
  800de9:	68 7f 2b 80 00       	push   $0x802b7f
  800dee:	6a 23                	push   $0x23
  800df0:	68 9c 2b 80 00       	push   $0x802b9c
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
  800e2b:	68 7f 2b 80 00       	push   $0x802b7f
  800e30:	6a 23                	push   $0x23
  800e32:	68 9c 2b 80 00       	push   $0x802b9c
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
  800e6d:	68 7f 2b 80 00       	push   $0x802b7f
  800e72:	6a 23                	push   $0x23
  800e74:	68 9c 2b 80 00       	push   $0x802b9c
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
  800ed1:	68 7f 2b 80 00       	push   $0x802b7f
  800ed6:	6a 23                	push   $0x23
  800ed8:	68 9c 2b 80 00       	push   $0x802b9c
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
  800f32:	68 7f 2b 80 00       	push   $0x802b7f
  800f37:	6a 23                	push   $0x23
  800f39:	68 9c 2b 80 00       	push   $0x802b9c
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

00800f4b <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f59:	b8 10 00 00 00       	mov    $0x10,%eax
  800f5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f61:	8b 55 08             	mov    0x8(%ebp),%edx
  800f64:	89 df                	mov    %ebx,%edi
  800f66:	89 de                	mov    %ebx,%esi
  800f68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	7e 17                	jle    800f85 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	50                   	push   %eax
  800f72:	6a 10                	push   $0x10
  800f74:	68 7f 2b 80 00       	push   $0x802b7f
  800f79:	6a 23                	push   $0x23
  800f7b:	68 9c 2b 80 00       	push   $0x802b9c
  800f80:	e8 13 f3 ff ff       	call   800298 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800f85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f95:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800f97:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f9b:	75 25                	jne    800fc2 <pgfault+0x35>
  800f9d:	89 d8                	mov    %ebx,%eax
  800f9f:	c1 e8 0c             	shr    $0xc,%eax
  800fa2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa9:	f6 c4 08             	test   $0x8,%ah
  800fac:	75 14                	jne    800fc2 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	68 ac 2b 80 00       	push   $0x802bac
  800fb6:	6a 1e                	push   $0x1e
  800fb8:	68 40 2c 80 00       	push   $0x802c40
  800fbd:	e8 d6 f2 ff ff       	call   800298 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800fc2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800fc8:	e8 ee fc ff ff       	call   800cbb <sys_getenvid>
  800fcd:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	6a 07                	push   $0x7
  800fd4:	68 00 f0 7f 00       	push   $0x7ff000
  800fd9:	50                   	push   %eax
  800fda:	e8 1a fd ff ff       	call   800cf9 <sys_page_alloc>
	if (r < 0)
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	79 12                	jns    800ff8 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800fe6:	50                   	push   %eax
  800fe7:	68 d8 2b 80 00       	push   $0x802bd8
  800fec:	6a 33                	push   $0x33
  800fee:	68 40 2c 80 00       	push   $0x802c40
  800ff3:	e8 a0 f2 ff ff       	call   800298 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ff8:	83 ec 04             	sub    $0x4,%esp
  800ffb:	68 00 10 00 00       	push   $0x1000
  801000:	53                   	push   %ebx
  801001:	68 00 f0 7f 00       	push   $0x7ff000
  801006:	e8 e5 fa ff ff       	call   800af0 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  80100b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801012:	53                   	push   %ebx
  801013:	56                   	push   %esi
  801014:	68 00 f0 7f 00       	push   $0x7ff000
  801019:	56                   	push   %esi
  80101a:	e8 1d fd ff ff       	call   800d3c <sys_page_map>
	if (r < 0)
  80101f:	83 c4 20             	add    $0x20,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	79 12                	jns    801038 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  801026:	50                   	push   %eax
  801027:	68 fc 2b 80 00       	push   $0x802bfc
  80102c:	6a 3b                	push   $0x3b
  80102e:	68 40 2c 80 00       	push   $0x802c40
  801033:	e8 60 f2 ff ff       	call   800298 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  801038:	83 ec 08             	sub    $0x8,%esp
  80103b:	68 00 f0 7f 00       	push   $0x7ff000
  801040:	56                   	push   %esi
  801041:	e8 38 fd ff ff       	call   800d7e <sys_page_unmap>
	if (r < 0)
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 12                	jns    80105f <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  80104d:	50                   	push   %eax
  80104e:	68 20 2c 80 00       	push   $0x802c20
  801053:	6a 40                	push   $0x40
  801055:	68 40 2c 80 00       	push   $0x802c40
  80105a:	e8 39 f2 ff ff       	call   800298 <_panic>
}
  80105f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
  80106c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  80106f:	68 8d 0f 80 00       	push   $0x800f8d
  801074:	e8 e8 12 00 00       	call   802361 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801079:	b8 07 00 00 00       	mov    $0x7,%eax
  80107e:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	0f 88 64 01 00 00    	js     8011ef <fork+0x189>
  80108b:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801090:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  801095:	85 c0                	test   %eax,%eax
  801097:	75 21                	jne    8010ba <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801099:	e8 1d fc ff ff       	call   800cbb <sys_getenvid>
  80109e:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010a3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010a6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010ab:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  8010b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b5:	e9 3f 01 00 00       	jmp    8011f9 <fork+0x193>
  8010ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010bd:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8010bf:	89 d8                	mov    %ebx,%eax
  8010c1:	c1 e8 16             	shr    $0x16,%eax
  8010c4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010cb:	a8 01                	test   $0x1,%al
  8010cd:	0f 84 bd 00 00 00    	je     801190 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  8010d3:	89 d8                	mov    %ebx,%eax
  8010d5:	c1 e8 0c             	shr    $0xc,%eax
  8010d8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010df:	f6 c2 01             	test   $0x1,%dl
  8010e2:	0f 84 a8 00 00 00    	je     801190 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  8010e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ef:	a8 04                	test   $0x4,%al
  8010f1:	0f 84 99 00 00 00    	je     801190 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  8010f7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010fe:	f6 c4 04             	test   $0x4,%ah
  801101:	74 17                	je     80111a <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	68 07 0e 00 00       	push   $0xe07
  80110b:	53                   	push   %ebx
  80110c:	57                   	push   %edi
  80110d:	53                   	push   %ebx
  80110e:	6a 00                	push   $0x0
  801110:	e8 27 fc ff ff       	call   800d3c <sys_page_map>
  801115:	83 c4 20             	add    $0x20,%esp
  801118:	eb 76                	jmp    801190 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80111a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801121:	a8 02                	test   $0x2,%al
  801123:	75 0c                	jne    801131 <fork+0xcb>
  801125:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80112c:	f6 c4 08             	test   $0x8,%ah
  80112f:	74 3f                	je     801170 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	68 05 08 00 00       	push   $0x805
  801139:	53                   	push   %ebx
  80113a:	57                   	push   %edi
  80113b:	53                   	push   %ebx
  80113c:	6a 00                	push   $0x0
  80113e:	e8 f9 fb ff ff       	call   800d3c <sys_page_map>
		if (r < 0)
  801143:	83 c4 20             	add    $0x20,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	0f 88 a5 00 00 00    	js     8011f3 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80114e:	83 ec 0c             	sub    $0xc,%esp
  801151:	68 05 08 00 00       	push   $0x805
  801156:	53                   	push   %ebx
  801157:	6a 00                	push   $0x0
  801159:	53                   	push   %ebx
  80115a:	6a 00                	push   $0x0
  80115c:	e8 db fb ff ff       	call   800d3c <sys_page_map>
  801161:	83 c4 20             	add    $0x20,%esp
  801164:	85 c0                	test   %eax,%eax
  801166:	b9 00 00 00 00       	mov    $0x0,%ecx
  80116b:	0f 4f c1             	cmovg  %ecx,%eax
  80116e:	eb 1c                	jmp    80118c <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801170:	83 ec 0c             	sub    $0xc,%esp
  801173:	6a 05                	push   $0x5
  801175:	53                   	push   %ebx
  801176:	57                   	push   %edi
  801177:	53                   	push   %ebx
  801178:	6a 00                	push   $0x0
  80117a:	e8 bd fb ff ff       	call   800d3c <sys_page_map>
  80117f:	83 c4 20             	add    $0x20,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	b9 00 00 00 00       	mov    $0x0,%ecx
  801189:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 67                	js     8011f7 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801190:	83 c6 01             	add    $0x1,%esi
  801193:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801199:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80119f:	0f 85 1a ff ff ff    	jne    8010bf <fork+0x59>
  8011a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	6a 07                	push   $0x7
  8011ad:	68 00 f0 bf ee       	push   $0xeebff000
  8011b2:	57                   	push   %edi
  8011b3:	e8 41 fb ff ff       	call   800cf9 <sys_page_alloc>
	if (r < 0)
  8011b8:	83 c4 10             	add    $0x10,%esp
		return r;
  8011bb:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 38                	js     8011f9 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011c1:	83 ec 08             	sub    $0x8,%esp
  8011c4:	68 a8 23 80 00       	push   $0x8023a8
  8011c9:	57                   	push   %edi
  8011ca:	e8 75 fc ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8011cf:	83 c4 10             	add    $0x10,%esp
		return r;
  8011d2:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 21                	js     8011f9 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	6a 02                	push   $0x2
  8011dd:	57                   	push   %edi
  8011de:	e8 dd fb ff ff       	call   800dc0 <sys_env_set_status>
	if (r < 0)
  8011e3:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	0f 48 f8             	cmovs  %eax,%edi
  8011eb:	89 fa                	mov    %edi,%edx
  8011ed:	eb 0a                	jmp    8011f9 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	eb 06                	jmp    8011f9 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8011f3:	89 c2                	mov    %eax,%edx
  8011f5:	eb 02                	jmp    8011f9 <fork+0x193>
  8011f7:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8011f9:	89 d0                	mov    %edx,%eax
  8011fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <sfork>:

// Challenge!
int
sfork(void)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801209:	68 4b 2c 80 00       	push   $0x802c4b
  80120e:	68 c9 00 00 00       	push   $0xc9
  801213:	68 40 2c 80 00       	push   $0x802c40
  801218:	e8 7b f0 ff ff       	call   800298 <_panic>

0080121d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801220:	8b 45 08             	mov    0x8(%ebp),%eax
  801223:	05 00 00 00 30       	add    $0x30000000,%eax
  801228:	c1 e8 0c             	shr    $0xc,%eax
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801230:	8b 45 08             	mov    0x8(%ebp),%eax
  801233:	05 00 00 00 30       	add    $0x30000000,%eax
  801238:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80123d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124f:	89 c2                	mov    %eax,%edx
  801251:	c1 ea 16             	shr    $0x16,%edx
  801254:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125b:	f6 c2 01             	test   $0x1,%dl
  80125e:	74 11                	je     801271 <fd_alloc+0x2d>
  801260:	89 c2                	mov    %eax,%edx
  801262:	c1 ea 0c             	shr    $0xc,%edx
  801265:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126c:	f6 c2 01             	test   $0x1,%dl
  80126f:	75 09                	jne    80127a <fd_alloc+0x36>
			*fd_store = fd;
  801271:	89 01                	mov    %eax,(%ecx)
			return 0;
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
  801278:	eb 17                	jmp    801291 <fd_alloc+0x4d>
  80127a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80127f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801284:	75 c9                	jne    80124f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801286:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80128c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801299:	83 f8 1f             	cmp    $0x1f,%eax
  80129c:	77 36                	ja     8012d4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80129e:	c1 e0 0c             	shl    $0xc,%eax
  8012a1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	c1 ea 16             	shr    $0x16,%edx
  8012ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b2:	f6 c2 01             	test   $0x1,%dl
  8012b5:	74 24                	je     8012db <fd_lookup+0x48>
  8012b7:	89 c2                	mov    %eax,%edx
  8012b9:	c1 ea 0c             	shr    $0xc,%edx
  8012bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c3:	f6 c2 01             	test   $0x1,%dl
  8012c6:	74 1a                	je     8012e2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012cb:	89 02                	mov    %eax,(%edx)
	return 0;
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d2:	eb 13                	jmp    8012e7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d9:	eb 0c                	jmp    8012e7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e0:	eb 05                	jmp    8012e7 <fd_lookup+0x54>
  8012e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f2:	ba e4 2c 80 00       	mov    $0x802ce4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f7:	eb 13                	jmp    80130c <dev_lookup+0x23>
  8012f9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012fc:	39 08                	cmp    %ecx,(%eax)
  8012fe:	75 0c                	jne    80130c <dev_lookup+0x23>
			*dev = devtab[i];
  801300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801303:	89 01                	mov    %eax,(%ecx)
			return 0;
  801305:	b8 00 00 00 00       	mov    $0x0,%eax
  80130a:	eb 2e                	jmp    80133a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80130c:	8b 02                	mov    (%edx),%eax
  80130e:	85 c0                	test   %eax,%eax
  801310:	75 e7                	jne    8012f9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801312:	a1 08 40 80 00       	mov    0x804008,%eax
  801317:	8b 40 48             	mov    0x48(%eax),%eax
  80131a:	83 ec 04             	sub    $0x4,%esp
  80131d:	51                   	push   %ecx
  80131e:	50                   	push   %eax
  80131f:	68 64 2c 80 00       	push   $0x802c64
  801324:	e8 48 f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  801329:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
  801341:	83 ec 10             	sub    $0x10,%esp
  801344:	8b 75 08             	mov    0x8(%ebp),%esi
  801347:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801354:	c1 e8 0c             	shr    $0xc,%eax
  801357:	50                   	push   %eax
  801358:	e8 36 ff ff ff       	call   801293 <fd_lookup>
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	85 c0                	test   %eax,%eax
  801362:	78 05                	js     801369 <fd_close+0x2d>
	    || fd != fd2)
  801364:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801367:	74 0c                	je     801375 <fd_close+0x39>
		return (must_exist ? r : 0);
  801369:	84 db                	test   %bl,%bl
  80136b:	ba 00 00 00 00       	mov    $0x0,%edx
  801370:	0f 44 c2             	cmove  %edx,%eax
  801373:	eb 41                	jmp    8013b6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	ff 36                	pushl  (%esi)
  80137e:	e8 66 ff ff ff       	call   8012e9 <dev_lookup>
  801383:	89 c3                	mov    %eax,%ebx
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 1a                	js     8013a6 <fd_close+0x6a>
		if (dev->dev_close)
  80138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801392:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801397:	85 c0                	test   %eax,%eax
  801399:	74 0b                	je     8013a6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80139b:	83 ec 0c             	sub    $0xc,%esp
  80139e:	56                   	push   %esi
  80139f:	ff d0                	call   *%eax
  8013a1:	89 c3                	mov    %eax,%ebx
  8013a3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	56                   	push   %esi
  8013aa:	6a 00                	push   $0x0
  8013ac:	e8 cd f9 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	89 d8                	mov    %ebx,%eax
}
  8013b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5e                   	pop    %esi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c6:	50                   	push   %eax
  8013c7:	ff 75 08             	pushl  0x8(%ebp)
  8013ca:	e8 c4 fe ff ff       	call   801293 <fd_lookup>
  8013cf:	83 c4 08             	add    $0x8,%esp
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 10                	js     8013e6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013d6:	83 ec 08             	sub    $0x8,%esp
  8013d9:	6a 01                	push   $0x1
  8013db:	ff 75 f4             	pushl  -0xc(%ebp)
  8013de:	e8 59 ff ff ff       	call   80133c <fd_close>
  8013e3:	83 c4 10             	add    $0x10,%esp
}
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    

008013e8 <close_all>:

void
close_all(void)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f4:	83 ec 0c             	sub    $0xc,%esp
  8013f7:	53                   	push   %ebx
  8013f8:	e8 c0 ff ff ff       	call   8013bd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fd:	83 c3 01             	add    $0x1,%ebx
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	83 fb 20             	cmp    $0x20,%ebx
  801406:	75 ec                	jne    8013f4 <close_all+0xc>
		close(i);
}
  801408:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	57                   	push   %edi
  801411:	56                   	push   %esi
  801412:	53                   	push   %ebx
  801413:	83 ec 2c             	sub    $0x2c,%esp
  801416:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801419:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	ff 75 08             	pushl  0x8(%ebp)
  801420:	e8 6e fe ff ff       	call   801293 <fd_lookup>
  801425:	83 c4 08             	add    $0x8,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	0f 88 c1 00 00 00    	js     8014f1 <dup+0xe4>
		return r;
	close(newfdnum);
  801430:	83 ec 0c             	sub    $0xc,%esp
  801433:	56                   	push   %esi
  801434:	e8 84 ff ff ff       	call   8013bd <close>

	newfd = INDEX2FD(newfdnum);
  801439:	89 f3                	mov    %esi,%ebx
  80143b:	c1 e3 0c             	shl    $0xc,%ebx
  80143e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801444:	83 c4 04             	add    $0x4,%esp
  801447:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144a:	e8 de fd ff ff       	call   80122d <fd2data>
  80144f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801451:	89 1c 24             	mov    %ebx,(%esp)
  801454:	e8 d4 fd ff ff       	call   80122d <fd2data>
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145f:	89 f8                	mov    %edi,%eax
  801461:	c1 e8 16             	shr    $0x16,%eax
  801464:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146b:	a8 01                	test   $0x1,%al
  80146d:	74 37                	je     8014a6 <dup+0x99>
  80146f:	89 f8                	mov    %edi,%eax
  801471:	c1 e8 0c             	shr    $0xc,%eax
  801474:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147b:	f6 c2 01             	test   $0x1,%dl
  80147e:	74 26                	je     8014a6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801480:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801487:	83 ec 0c             	sub    $0xc,%esp
  80148a:	25 07 0e 00 00       	and    $0xe07,%eax
  80148f:	50                   	push   %eax
  801490:	ff 75 d4             	pushl  -0x2c(%ebp)
  801493:	6a 00                	push   $0x0
  801495:	57                   	push   %edi
  801496:	6a 00                	push   $0x0
  801498:	e8 9f f8 ff ff       	call   800d3c <sys_page_map>
  80149d:	89 c7                	mov    %eax,%edi
  80149f:	83 c4 20             	add    $0x20,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 2e                	js     8014d4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014a9:	89 d0                	mov    %edx,%eax
  8014ab:	c1 e8 0c             	shr    $0xc,%eax
  8014ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b5:	83 ec 0c             	sub    $0xc,%esp
  8014b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014bd:	50                   	push   %eax
  8014be:	53                   	push   %ebx
  8014bf:	6a 00                	push   $0x0
  8014c1:	52                   	push   %edx
  8014c2:	6a 00                	push   $0x0
  8014c4:	e8 73 f8 ff ff       	call   800d3c <sys_page_map>
  8014c9:	89 c7                	mov    %eax,%edi
  8014cb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ce:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d0:	85 ff                	test   %edi,%edi
  8014d2:	79 1d                	jns    8014f1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	53                   	push   %ebx
  8014d8:	6a 00                	push   $0x0
  8014da:	e8 9f f8 ff ff       	call   800d7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014df:	83 c4 08             	add    $0x8,%esp
  8014e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e5:	6a 00                	push   $0x0
  8014e7:	e8 92 f8 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	89 f8                	mov    %edi,%eax
}
  8014f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5f                   	pop    %edi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    

008014f9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	53                   	push   %ebx
  8014fd:	83 ec 14             	sub    $0x14,%esp
  801500:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801503:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801506:	50                   	push   %eax
  801507:	53                   	push   %ebx
  801508:	e8 86 fd ff ff       	call   801293 <fd_lookup>
  80150d:	83 c4 08             	add    $0x8,%esp
  801510:	89 c2                	mov    %eax,%edx
  801512:	85 c0                	test   %eax,%eax
  801514:	78 6d                	js     801583 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151c:	50                   	push   %eax
  80151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801520:	ff 30                	pushl  (%eax)
  801522:	e8 c2 fd ff ff       	call   8012e9 <dev_lookup>
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 4c                	js     80157a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801531:	8b 42 08             	mov    0x8(%edx),%eax
  801534:	83 e0 03             	and    $0x3,%eax
  801537:	83 f8 01             	cmp    $0x1,%eax
  80153a:	75 21                	jne    80155d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80153c:	a1 08 40 80 00       	mov    0x804008,%eax
  801541:	8b 40 48             	mov    0x48(%eax),%eax
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	53                   	push   %ebx
  801548:	50                   	push   %eax
  801549:	68 a8 2c 80 00       	push   $0x802ca8
  80154e:	e8 1e ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80155b:	eb 26                	jmp    801583 <read+0x8a>
	}
	if (!dev->dev_read)
  80155d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801560:	8b 40 08             	mov    0x8(%eax),%eax
  801563:	85 c0                	test   %eax,%eax
  801565:	74 17                	je     80157e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	ff 75 10             	pushl  0x10(%ebp)
  80156d:	ff 75 0c             	pushl  0xc(%ebp)
  801570:	52                   	push   %edx
  801571:	ff d0                	call   *%eax
  801573:	89 c2                	mov    %eax,%edx
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	eb 09                	jmp    801583 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	eb 05                	jmp    801583 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80157e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801583:	89 d0                	mov    %edx,%eax
  801585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	57                   	push   %edi
  80158e:	56                   	push   %esi
  80158f:	53                   	push   %ebx
  801590:	83 ec 0c             	sub    $0xc,%esp
  801593:	8b 7d 08             	mov    0x8(%ebp),%edi
  801596:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801599:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159e:	eb 21                	jmp    8015c1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	89 f0                	mov    %esi,%eax
  8015a5:	29 d8                	sub    %ebx,%eax
  8015a7:	50                   	push   %eax
  8015a8:	89 d8                	mov    %ebx,%eax
  8015aa:	03 45 0c             	add    0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	57                   	push   %edi
  8015af:	e8 45 ff ff ff       	call   8014f9 <read>
		if (m < 0)
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 10                	js     8015cb <readn+0x41>
			return m;
		if (m == 0)
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	74 0a                	je     8015c9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bf:	01 c3                	add    %eax,%ebx
  8015c1:	39 f3                	cmp    %esi,%ebx
  8015c3:	72 db                	jb     8015a0 <readn+0x16>
  8015c5:	89 d8                	mov    %ebx,%eax
  8015c7:	eb 02                	jmp    8015cb <readn+0x41>
  8015c9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ce:	5b                   	pop    %ebx
  8015cf:	5e                   	pop    %esi
  8015d0:	5f                   	pop    %edi
  8015d1:	5d                   	pop    %ebp
  8015d2:	c3                   	ret    

008015d3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 14             	sub    $0x14,%esp
  8015da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	53                   	push   %ebx
  8015e2:	e8 ac fc ff ff       	call   801293 <fd_lookup>
  8015e7:	83 c4 08             	add    $0x8,%esp
  8015ea:	89 c2                	mov    %eax,%edx
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 68                	js     801658 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fa:	ff 30                	pushl  (%eax)
  8015fc:	e8 e8 fc ff ff       	call   8012e9 <dev_lookup>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 47                	js     80164f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801608:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160f:	75 21                	jne    801632 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801611:	a1 08 40 80 00       	mov    0x804008,%eax
  801616:	8b 40 48             	mov    0x48(%eax),%eax
  801619:	83 ec 04             	sub    $0x4,%esp
  80161c:	53                   	push   %ebx
  80161d:	50                   	push   %eax
  80161e:	68 c4 2c 80 00       	push   $0x802cc4
  801623:	e8 49 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801630:	eb 26                	jmp    801658 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801632:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801635:	8b 52 0c             	mov    0xc(%edx),%edx
  801638:	85 d2                	test   %edx,%edx
  80163a:	74 17                	je     801653 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	ff 75 10             	pushl  0x10(%ebp)
  801642:	ff 75 0c             	pushl  0xc(%ebp)
  801645:	50                   	push   %eax
  801646:	ff d2                	call   *%edx
  801648:	89 c2                	mov    %eax,%edx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	eb 09                	jmp    801658 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164f:	89 c2                	mov    %eax,%edx
  801651:	eb 05                	jmp    801658 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801653:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801658:	89 d0                	mov    %edx,%eax
  80165a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <seek>:

int
seek(int fdnum, off_t offset)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801665:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	ff 75 08             	pushl  0x8(%ebp)
  80166c:	e8 22 fc ff ff       	call   801293 <fd_lookup>
  801671:	83 c4 08             	add    $0x8,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	78 0e                	js     801686 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801678:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80167b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801681:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	53                   	push   %ebx
  80168c:	83 ec 14             	sub    $0x14,%esp
  80168f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801692:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	53                   	push   %ebx
  801697:	e8 f7 fb ff ff       	call   801293 <fd_lookup>
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	89 c2                	mov    %eax,%edx
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 65                	js     80170a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ab:	50                   	push   %eax
  8016ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016af:	ff 30                	pushl  (%eax)
  8016b1:	e8 33 fc ff ff       	call   8012e9 <dev_lookup>
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 44                	js     801701 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c4:	75 21                	jne    8016e7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016cb:	8b 40 48             	mov    0x48(%eax),%eax
  8016ce:	83 ec 04             	sub    $0x4,%esp
  8016d1:	53                   	push   %ebx
  8016d2:	50                   	push   %eax
  8016d3:	68 84 2c 80 00       	push   $0x802c84
  8016d8:	e8 94 ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e5:	eb 23                	jmp    80170a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ea:	8b 52 18             	mov    0x18(%edx),%edx
  8016ed:	85 d2                	test   %edx,%edx
  8016ef:	74 14                	je     801705 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016f1:	83 ec 08             	sub    $0x8,%esp
  8016f4:	ff 75 0c             	pushl  0xc(%ebp)
  8016f7:	50                   	push   %eax
  8016f8:	ff d2                	call   *%edx
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	eb 09                	jmp    80170a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801701:	89 c2                	mov    %eax,%edx
  801703:	eb 05                	jmp    80170a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801705:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80170a:	89 d0                	mov    %edx,%eax
  80170c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	53                   	push   %ebx
  801715:	83 ec 14             	sub    $0x14,%esp
  801718:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	ff 75 08             	pushl  0x8(%ebp)
  801722:	e8 6c fb ff ff       	call   801293 <fd_lookup>
  801727:	83 c4 08             	add    $0x8,%esp
  80172a:	89 c2                	mov    %eax,%edx
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 58                	js     801788 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801730:	83 ec 08             	sub    $0x8,%esp
  801733:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173a:	ff 30                	pushl  (%eax)
  80173c:	e8 a8 fb ff ff       	call   8012e9 <dev_lookup>
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	85 c0                	test   %eax,%eax
  801746:	78 37                	js     80177f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801748:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80174f:	74 32                	je     801783 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801751:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801754:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80175b:	00 00 00 
	stat->st_isdir = 0;
  80175e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801765:	00 00 00 
	stat->st_dev = dev;
  801768:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80176e:	83 ec 08             	sub    $0x8,%esp
  801771:	53                   	push   %ebx
  801772:	ff 75 f0             	pushl  -0x10(%ebp)
  801775:	ff 50 14             	call   *0x14(%eax)
  801778:	89 c2                	mov    %eax,%edx
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	eb 09                	jmp    801788 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177f:	89 c2                	mov    %eax,%edx
  801781:	eb 05                	jmp    801788 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801783:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801788:	89 d0                	mov    %edx,%eax
  80178a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	56                   	push   %esi
  801793:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801794:	83 ec 08             	sub    $0x8,%esp
  801797:	6a 00                	push   $0x0
  801799:	ff 75 08             	pushl  0x8(%ebp)
  80179c:	e8 d6 01 00 00       	call   801977 <open>
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 1b                	js     8017c5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	ff 75 0c             	pushl  0xc(%ebp)
  8017b0:	50                   	push   %eax
  8017b1:	e8 5b ff ff ff       	call   801711 <fstat>
  8017b6:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b8:	89 1c 24             	mov    %ebx,(%esp)
  8017bb:	e8 fd fb ff ff       	call   8013bd <close>
	return r;
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	89 f0                	mov    %esi,%eax
}
  8017c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	89 c6                	mov    %eax,%esi
  8017d3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017dc:	75 12                	jne    8017f0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017de:	83 ec 0c             	sub    $0xc,%esp
  8017e1:	6a 01                	push   $0x1
  8017e3:	e8 9f 0c 00 00       	call   802487 <ipc_find_env>
  8017e8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ed:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f0:	6a 07                	push   $0x7
  8017f2:	68 00 50 80 00       	push   $0x805000
  8017f7:	56                   	push   %esi
  8017f8:	ff 35 00 40 80 00    	pushl  0x804000
  8017fe:	e8 30 0c 00 00       	call   802433 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801803:	83 c4 0c             	add    $0xc,%esp
  801806:	6a 00                	push   $0x0
  801808:	53                   	push   %ebx
  801809:	6a 00                	push   $0x0
  80180b:	e8 bc 0b 00 00       	call   8023cc <ipc_recv>
}
  801810:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801813:	5b                   	pop    %ebx
  801814:	5e                   	pop    %esi
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    

00801817 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	8b 40 0c             	mov    0xc(%eax),%eax
  801823:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801830:	ba 00 00 00 00       	mov    $0x0,%edx
  801835:	b8 02 00 00 00       	mov    $0x2,%eax
  80183a:	e8 8d ff ff ff       	call   8017cc <fsipc>
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801847:	8b 45 08             	mov    0x8(%ebp),%eax
  80184a:	8b 40 0c             	mov    0xc(%eax),%eax
  80184d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 06 00 00 00       	mov    $0x6,%eax
  80185c:	e8 6b ff ff ff       	call   8017cc <fsipc>
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	83 ec 04             	sub    $0x4,%esp
  80186a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	8b 40 0c             	mov    0xc(%eax),%eax
  801873:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
  80187d:	b8 05 00 00 00       	mov    $0x5,%eax
  801882:	e8 45 ff ff ff       	call   8017cc <fsipc>
  801887:	85 c0                	test   %eax,%eax
  801889:	78 2c                	js     8018b7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	68 00 50 80 00       	push   $0x805000
  801893:	53                   	push   %ebx
  801894:	e8 5d f0 ff ff       	call   8008f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801899:	a1 80 50 80 00       	mov    0x805080,%eax
  80189e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a4:	a1 84 50 80 00       	mov    0x805084,%eax
  8018a9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8018c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8018cb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018d1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018d6:	50                   	push   %eax
  8018d7:	ff 75 0c             	pushl  0xc(%ebp)
  8018da:	68 08 50 80 00       	push   $0x805008
  8018df:	e8 a4 f1 ff ff       	call   800a88 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e9:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ee:	e8 d9 fe ff ff       	call   8017cc <fsipc>

}
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    

008018f5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	56                   	push   %esi
  8018f9:	53                   	push   %ebx
  8018fa:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	8b 40 0c             	mov    0xc(%eax),%eax
  801903:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801908:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80190e:	ba 00 00 00 00       	mov    $0x0,%edx
  801913:	b8 03 00 00 00       	mov    $0x3,%eax
  801918:	e8 af fe ff ff       	call   8017cc <fsipc>
  80191d:	89 c3                	mov    %eax,%ebx
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 4b                	js     80196e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801923:	39 c6                	cmp    %eax,%esi
  801925:	73 16                	jae    80193d <devfile_read+0x48>
  801927:	68 f8 2c 80 00       	push   $0x802cf8
  80192c:	68 ff 2c 80 00       	push   $0x802cff
  801931:	6a 7c                	push   $0x7c
  801933:	68 14 2d 80 00       	push   $0x802d14
  801938:	e8 5b e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  80193d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801942:	7e 16                	jle    80195a <devfile_read+0x65>
  801944:	68 1f 2d 80 00       	push   $0x802d1f
  801949:	68 ff 2c 80 00       	push   $0x802cff
  80194e:	6a 7d                	push   $0x7d
  801950:	68 14 2d 80 00       	push   $0x802d14
  801955:	e8 3e e9 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80195a:	83 ec 04             	sub    $0x4,%esp
  80195d:	50                   	push   %eax
  80195e:	68 00 50 80 00       	push   $0x805000
  801963:	ff 75 0c             	pushl  0xc(%ebp)
  801966:	e8 1d f1 ff ff       	call   800a88 <memmove>
	return r;
  80196b:	83 c4 10             	add    $0x10,%esp
}
  80196e:	89 d8                	mov    %ebx,%eax
  801970:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801973:	5b                   	pop    %ebx
  801974:	5e                   	pop    %esi
  801975:	5d                   	pop    %ebp
  801976:	c3                   	ret    

00801977 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	53                   	push   %ebx
  80197b:	83 ec 20             	sub    $0x20,%esp
  80197e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801981:	53                   	push   %ebx
  801982:	e8 36 ef ff ff       	call   8008bd <strlen>
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80198f:	7f 67                	jg     8019f8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801997:	50                   	push   %eax
  801998:	e8 a7 f8 ff ff       	call   801244 <fd_alloc>
  80199d:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	78 57                	js     8019fd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	53                   	push   %ebx
  8019aa:	68 00 50 80 00       	push   $0x805000
  8019af:	e8 42 ef ff ff       	call   8008f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c4:	e8 03 fe ff ff       	call   8017cc <fsipc>
  8019c9:	89 c3                	mov    %eax,%ebx
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	79 14                	jns    8019e6 <open+0x6f>
		fd_close(fd, 0);
  8019d2:	83 ec 08             	sub    $0x8,%esp
  8019d5:	6a 00                	push   $0x0
  8019d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019da:	e8 5d f9 ff ff       	call   80133c <fd_close>
		return r;
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	89 da                	mov    %ebx,%edx
  8019e4:	eb 17                	jmp    8019fd <open+0x86>
	}

	return fd2num(fd);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ec:	e8 2c f8 ff ff       	call   80121d <fd2num>
  8019f1:	89 c2                	mov    %eax,%edx
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	eb 05                	jmp    8019fd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019f8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019fd:	89 d0                	mov    %edx,%eax
  8019ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a02:	c9                   	leave  
  801a03:	c3                   	ret    

00801a04 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a14:	e8 b3 fd ff ff       	call   8017cc <fsipc>
}
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a21:	68 2b 2d 80 00       	push   $0x802d2b
  801a26:	ff 75 0c             	pushl  0xc(%ebp)
  801a29:	e8 c8 ee ff ff       	call   8008f6 <strcpy>
	return 0;
}
  801a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	53                   	push   %ebx
  801a39:	83 ec 10             	sub    $0x10,%esp
  801a3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a3f:	53                   	push   %ebx
  801a40:	e8 7b 0a 00 00       	call   8024c0 <pageref>
  801a45:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a48:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a4d:	83 f8 01             	cmp    $0x1,%eax
  801a50:	75 10                	jne    801a62 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a52:	83 ec 0c             	sub    $0xc,%esp
  801a55:	ff 73 0c             	pushl  0xc(%ebx)
  801a58:	e8 c0 02 00 00       	call   801d1d <nsipc_close>
  801a5d:	89 c2                	mov    %eax,%edx
  801a5f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a62:	89 d0                	mov    %edx,%eax
  801a64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    

00801a69 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a6f:	6a 00                	push   $0x0
  801a71:	ff 75 10             	pushl  0x10(%ebp)
  801a74:	ff 75 0c             	pushl  0xc(%ebp)
  801a77:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7a:	ff 70 0c             	pushl  0xc(%eax)
  801a7d:	e8 78 03 00 00       	call   801dfa <nsipc_send>
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a8a:	6a 00                	push   $0x0
  801a8c:	ff 75 10             	pushl  0x10(%ebp)
  801a8f:	ff 75 0c             	pushl  0xc(%ebp)
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	ff 70 0c             	pushl  0xc(%eax)
  801a98:	e8 f1 02 00 00       	call   801d8e <nsipc_recv>
}
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aa5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801aa8:	52                   	push   %edx
  801aa9:	50                   	push   %eax
  801aaa:	e8 e4 f7 ff ff       	call   801293 <fd_lookup>
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 17                	js     801acd <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab9:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801abf:	39 08                	cmp    %ecx,(%eax)
  801ac1:	75 05                	jne    801ac8 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ac3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac6:	eb 05                	jmp    801acd <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ac8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 1c             	sub    $0x1c,%esp
  801ad7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ad9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adc:	50                   	push   %eax
  801add:	e8 62 f7 ff ff       	call   801244 <fd_alloc>
  801ae2:	89 c3                	mov    %eax,%ebx
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 1b                	js     801b06 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801aeb:	83 ec 04             	sub    $0x4,%esp
  801aee:	68 07 04 00 00       	push   $0x407
  801af3:	ff 75 f4             	pushl  -0xc(%ebp)
  801af6:	6a 00                	push   $0x0
  801af8:	e8 fc f1 ff ff       	call   800cf9 <sys_page_alloc>
  801afd:	89 c3                	mov    %eax,%ebx
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	85 c0                	test   %eax,%eax
  801b04:	79 10                	jns    801b16 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b06:	83 ec 0c             	sub    $0xc,%esp
  801b09:	56                   	push   %esi
  801b0a:	e8 0e 02 00 00       	call   801d1d <nsipc_close>
		return r;
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	89 d8                	mov    %ebx,%eax
  801b14:	eb 24                	jmp    801b3a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b16:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b24:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b2b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b2e:	83 ec 0c             	sub    $0xc,%esp
  801b31:	50                   	push   %eax
  801b32:	e8 e6 f6 ff ff       	call   80121d <fd2num>
  801b37:	83 c4 10             	add    $0x10,%esp
}
  801b3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b47:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4a:	e8 50 ff ff ff       	call   801a9f <fd2sockid>
		return r;
  801b4f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 1f                	js     801b74 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b55:	83 ec 04             	sub    $0x4,%esp
  801b58:	ff 75 10             	pushl  0x10(%ebp)
  801b5b:	ff 75 0c             	pushl  0xc(%ebp)
  801b5e:	50                   	push   %eax
  801b5f:	e8 12 01 00 00       	call   801c76 <nsipc_accept>
  801b64:	83 c4 10             	add    $0x10,%esp
		return r;
  801b67:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 07                	js     801b74 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b6d:	e8 5d ff ff ff       	call   801acf <alloc_sockfd>
  801b72:	89 c1                	mov    %eax,%ecx
}
  801b74:	89 c8                	mov    %ecx,%eax
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    

00801b78 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b81:	e8 19 ff ff ff       	call   801a9f <fd2sockid>
  801b86:	85 c0                	test   %eax,%eax
  801b88:	78 12                	js     801b9c <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b8a:	83 ec 04             	sub    $0x4,%esp
  801b8d:	ff 75 10             	pushl  0x10(%ebp)
  801b90:	ff 75 0c             	pushl  0xc(%ebp)
  801b93:	50                   	push   %eax
  801b94:	e8 2d 01 00 00       	call   801cc6 <nsipc_bind>
  801b99:	83 c4 10             	add    $0x10,%esp
}
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <shutdown>:

int
shutdown(int s, int how)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba7:	e8 f3 fe ff ff       	call   801a9f <fd2sockid>
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 0f                	js     801bbf <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bb0:	83 ec 08             	sub    $0x8,%esp
  801bb3:	ff 75 0c             	pushl  0xc(%ebp)
  801bb6:	50                   	push   %eax
  801bb7:	e8 3f 01 00 00       	call   801cfb <nsipc_shutdown>
  801bbc:	83 c4 10             	add    $0x10,%esp
}
  801bbf:	c9                   	leave  
  801bc0:	c3                   	ret    

00801bc1 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bca:	e8 d0 fe ff ff       	call   801a9f <fd2sockid>
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	78 12                	js     801be5 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801bd3:	83 ec 04             	sub    $0x4,%esp
  801bd6:	ff 75 10             	pushl  0x10(%ebp)
  801bd9:	ff 75 0c             	pushl  0xc(%ebp)
  801bdc:	50                   	push   %eax
  801bdd:	e8 55 01 00 00       	call   801d37 <nsipc_connect>
  801be2:	83 c4 10             	add    $0x10,%esp
}
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <listen>:

int
listen(int s, int backlog)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bed:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf0:	e8 aa fe ff ff       	call   801a9f <fd2sockid>
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	78 0f                	js     801c08 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bf9:	83 ec 08             	sub    $0x8,%esp
  801bfc:	ff 75 0c             	pushl  0xc(%ebp)
  801bff:	50                   	push   %eax
  801c00:	e8 67 01 00 00       	call   801d6c <nsipc_listen>
  801c05:	83 c4 10             	add    $0x10,%esp
}
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c10:	ff 75 10             	pushl  0x10(%ebp)
  801c13:	ff 75 0c             	pushl  0xc(%ebp)
  801c16:	ff 75 08             	pushl  0x8(%ebp)
  801c19:	e8 3a 02 00 00       	call   801e58 <nsipc_socket>
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	85 c0                	test   %eax,%eax
  801c23:	78 05                	js     801c2a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c25:	e8 a5 fe ff ff       	call   801acf <alloc_sockfd>
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	53                   	push   %ebx
  801c30:	83 ec 04             	sub    $0x4,%esp
  801c33:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c35:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c3c:	75 12                	jne    801c50 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c3e:	83 ec 0c             	sub    $0xc,%esp
  801c41:	6a 02                	push   $0x2
  801c43:	e8 3f 08 00 00       	call   802487 <ipc_find_env>
  801c48:	a3 04 40 80 00       	mov    %eax,0x804004
  801c4d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c50:	6a 07                	push   $0x7
  801c52:	68 00 60 80 00       	push   $0x806000
  801c57:	53                   	push   %ebx
  801c58:	ff 35 04 40 80 00    	pushl  0x804004
  801c5e:	e8 d0 07 00 00       	call   802433 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c63:	83 c4 0c             	add    $0xc,%esp
  801c66:	6a 00                	push   $0x0
  801c68:	6a 00                	push   $0x0
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 5b 07 00 00       	call   8023cc <ipc_recv>
}
  801c71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    

00801c76 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c86:	8b 06                	mov    (%esi),%eax
  801c88:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c92:	e8 95 ff ff ff       	call   801c2c <nsipc>
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	78 20                	js     801cbd <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c9d:	83 ec 04             	sub    $0x4,%esp
  801ca0:	ff 35 10 60 80 00    	pushl  0x806010
  801ca6:	68 00 60 80 00       	push   $0x806000
  801cab:	ff 75 0c             	pushl  0xc(%ebp)
  801cae:	e8 d5 ed ff ff       	call   800a88 <memmove>
		*addrlen = ret->ret_addrlen;
  801cb3:	a1 10 60 80 00       	mov    0x806010,%eax
  801cb8:	89 06                	mov    %eax,(%esi)
  801cba:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cbd:	89 d8                	mov    %ebx,%eax
  801cbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5e                   	pop    %esi
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    

00801cc6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	53                   	push   %ebx
  801cca:	83 ec 08             	sub    $0x8,%esp
  801ccd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cd8:	53                   	push   %ebx
  801cd9:	ff 75 0c             	pushl  0xc(%ebp)
  801cdc:	68 04 60 80 00       	push   $0x806004
  801ce1:	e8 a2 ed ff ff       	call   800a88 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ce6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cec:	b8 02 00 00 00       	mov    $0x2,%eax
  801cf1:	e8 36 ff ff ff       	call   801c2c <nsipc>
}
  801cf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d11:	b8 03 00 00 00       	mov    $0x3,%eax
  801d16:	e8 11 ff ff ff       	call   801c2c <nsipc>
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <nsipc_close>:

int
nsipc_close(int s)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d2b:	b8 04 00 00 00       	mov    $0x4,%eax
  801d30:	e8 f7 fe ff ff       	call   801c2c <nsipc>
}
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	53                   	push   %ebx
  801d3b:	83 ec 08             	sub    $0x8,%esp
  801d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d41:	8b 45 08             	mov    0x8(%ebp),%eax
  801d44:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d49:	53                   	push   %ebx
  801d4a:	ff 75 0c             	pushl  0xc(%ebp)
  801d4d:	68 04 60 80 00       	push   $0x806004
  801d52:	e8 31 ed ff ff       	call   800a88 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d57:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d5d:	b8 05 00 00 00       	mov    $0x5,%eax
  801d62:	e8 c5 fe ff ff       	call   801c2c <nsipc>
}
  801d67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d72:	8b 45 08             	mov    0x8(%ebp),%eax
  801d75:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d82:	b8 06 00 00 00       	mov    $0x6,%eax
  801d87:	e8 a0 fe ff ff       	call   801c2c <nsipc>
}
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	56                   	push   %esi
  801d92:	53                   	push   %ebx
  801d93:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d96:	8b 45 08             	mov    0x8(%ebp),%eax
  801d99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d9e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801da4:	8b 45 14             	mov    0x14(%ebp),%eax
  801da7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dac:	b8 07 00 00 00       	mov    $0x7,%eax
  801db1:	e8 76 fe ff ff       	call   801c2c <nsipc>
  801db6:	89 c3                	mov    %eax,%ebx
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 35                	js     801df1 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801dbc:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801dc1:	7f 04                	jg     801dc7 <nsipc_recv+0x39>
  801dc3:	39 c6                	cmp    %eax,%esi
  801dc5:	7d 16                	jge    801ddd <nsipc_recv+0x4f>
  801dc7:	68 37 2d 80 00       	push   $0x802d37
  801dcc:	68 ff 2c 80 00       	push   $0x802cff
  801dd1:	6a 62                	push   $0x62
  801dd3:	68 4c 2d 80 00       	push   $0x802d4c
  801dd8:	e8 bb e4 ff ff       	call   800298 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ddd:	83 ec 04             	sub    $0x4,%esp
  801de0:	50                   	push   %eax
  801de1:	68 00 60 80 00       	push   $0x806000
  801de6:	ff 75 0c             	pushl  0xc(%ebp)
  801de9:	e8 9a ec ff ff       	call   800a88 <memmove>
  801dee:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801df1:	89 d8                	mov    %ebx,%eax
  801df3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df6:	5b                   	pop    %ebx
  801df7:	5e                   	pop    %esi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    

00801dfa <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	53                   	push   %ebx
  801dfe:	83 ec 04             	sub    $0x4,%esp
  801e01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e04:	8b 45 08             	mov    0x8(%ebp),%eax
  801e07:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e0c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e12:	7e 16                	jle    801e2a <nsipc_send+0x30>
  801e14:	68 58 2d 80 00       	push   $0x802d58
  801e19:	68 ff 2c 80 00       	push   $0x802cff
  801e1e:	6a 6d                	push   $0x6d
  801e20:	68 4c 2d 80 00       	push   $0x802d4c
  801e25:	e8 6e e4 ff ff       	call   800298 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e2a:	83 ec 04             	sub    $0x4,%esp
  801e2d:	53                   	push   %ebx
  801e2e:	ff 75 0c             	pushl  0xc(%ebp)
  801e31:	68 0c 60 80 00       	push   $0x80600c
  801e36:	e8 4d ec ff ff       	call   800a88 <memmove>
	nsipcbuf.send.req_size = size;
  801e3b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e41:	8b 45 14             	mov    0x14(%ebp),%eax
  801e44:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e49:	b8 08 00 00 00       	mov    $0x8,%eax
  801e4e:	e8 d9 fd ff ff       	call   801c2c <nsipc>
}
  801e53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    

00801e58 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e61:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e69:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e6e:	8b 45 10             	mov    0x10(%ebp),%eax
  801e71:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e76:	b8 09 00 00 00       	mov    $0x9,%eax
  801e7b:	e8 ac fd ff ff       	call   801c2c <nsipc>
}
  801e80:	c9                   	leave  
  801e81:	c3                   	ret    

00801e82 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	56                   	push   %esi
  801e86:	53                   	push   %ebx
  801e87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e8a:	83 ec 0c             	sub    $0xc,%esp
  801e8d:	ff 75 08             	pushl  0x8(%ebp)
  801e90:	e8 98 f3 ff ff       	call   80122d <fd2data>
  801e95:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e97:	83 c4 08             	add    $0x8,%esp
  801e9a:	68 64 2d 80 00       	push   $0x802d64
  801e9f:	53                   	push   %ebx
  801ea0:	e8 51 ea ff ff       	call   8008f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ea5:	8b 46 04             	mov    0x4(%esi),%eax
  801ea8:	2b 06                	sub    (%esi),%eax
  801eaa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801eb0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eb7:	00 00 00 
	stat->st_dev = &devpipe;
  801eba:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ec1:	30 80 00 
	return 0;
}
  801ec4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ecc:	5b                   	pop    %ebx
  801ecd:	5e                   	pop    %esi
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 0c             	sub    $0xc,%esp
  801ed7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eda:	53                   	push   %ebx
  801edb:	6a 00                	push   $0x0
  801edd:	e8 9c ee ff ff       	call   800d7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ee2:	89 1c 24             	mov    %ebx,(%esp)
  801ee5:	e8 43 f3 ff ff       	call   80122d <fd2data>
  801eea:	83 c4 08             	add    $0x8,%esp
  801eed:	50                   	push   %eax
  801eee:	6a 00                	push   $0x0
  801ef0:	e8 89 ee ff ff       	call   800d7e <sys_page_unmap>
}
  801ef5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	57                   	push   %edi
  801efe:	56                   	push   %esi
  801eff:	53                   	push   %ebx
  801f00:	83 ec 1c             	sub    $0x1c,%esp
  801f03:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f06:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f08:	a1 08 40 80 00       	mov    0x804008,%eax
  801f0d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f10:	83 ec 0c             	sub    $0xc,%esp
  801f13:	ff 75 e0             	pushl  -0x20(%ebp)
  801f16:	e8 a5 05 00 00       	call   8024c0 <pageref>
  801f1b:	89 c3                	mov    %eax,%ebx
  801f1d:	89 3c 24             	mov    %edi,(%esp)
  801f20:	e8 9b 05 00 00       	call   8024c0 <pageref>
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	39 c3                	cmp    %eax,%ebx
  801f2a:	0f 94 c1             	sete   %cl
  801f2d:	0f b6 c9             	movzbl %cl,%ecx
  801f30:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f33:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f39:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f3c:	39 ce                	cmp    %ecx,%esi
  801f3e:	74 1b                	je     801f5b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f40:	39 c3                	cmp    %eax,%ebx
  801f42:	75 c4                	jne    801f08 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f44:	8b 42 58             	mov    0x58(%edx),%eax
  801f47:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f4a:	50                   	push   %eax
  801f4b:	56                   	push   %esi
  801f4c:	68 6b 2d 80 00       	push   $0x802d6b
  801f51:	e8 1b e4 ff ff       	call   800371 <cprintf>
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	eb ad                	jmp    801f08 <_pipeisclosed+0xe>
	}
}
  801f5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f61:	5b                   	pop    %ebx
  801f62:	5e                   	pop    %esi
  801f63:	5f                   	pop    %edi
  801f64:	5d                   	pop    %ebp
  801f65:	c3                   	ret    

00801f66 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	57                   	push   %edi
  801f6a:	56                   	push   %esi
  801f6b:	53                   	push   %ebx
  801f6c:	83 ec 28             	sub    $0x28,%esp
  801f6f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f72:	56                   	push   %esi
  801f73:	e8 b5 f2 ff ff       	call   80122d <fd2data>
  801f78:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	bf 00 00 00 00       	mov    $0x0,%edi
  801f82:	eb 4b                	jmp    801fcf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f84:	89 da                	mov    %ebx,%edx
  801f86:	89 f0                	mov    %esi,%eax
  801f88:	e8 6d ff ff ff       	call   801efa <_pipeisclosed>
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	75 48                	jne    801fd9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f91:	e8 44 ed ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f96:	8b 43 04             	mov    0x4(%ebx),%eax
  801f99:	8b 0b                	mov    (%ebx),%ecx
  801f9b:	8d 51 20             	lea    0x20(%ecx),%edx
  801f9e:	39 d0                	cmp    %edx,%eax
  801fa0:	73 e2                	jae    801f84 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fa9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fac:	89 c2                	mov    %eax,%edx
  801fae:	c1 fa 1f             	sar    $0x1f,%edx
  801fb1:	89 d1                	mov    %edx,%ecx
  801fb3:	c1 e9 1b             	shr    $0x1b,%ecx
  801fb6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fb9:	83 e2 1f             	and    $0x1f,%edx
  801fbc:	29 ca                	sub    %ecx,%edx
  801fbe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fc2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fc6:	83 c0 01             	add    $0x1,%eax
  801fc9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fcc:	83 c7 01             	add    $0x1,%edi
  801fcf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fd2:	75 c2                	jne    801f96 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fd4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fd7:	eb 05                	jmp    801fde <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fd9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe1:	5b                   	pop    %ebx
  801fe2:	5e                   	pop    %esi
  801fe3:	5f                   	pop    %edi
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    

00801fe6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	57                   	push   %edi
  801fea:	56                   	push   %esi
  801feb:	53                   	push   %ebx
  801fec:	83 ec 18             	sub    $0x18,%esp
  801fef:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ff2:	57                   	push   %edi
  801ff3:	e8 35 f2 ff ff       	call   80122d <fd2data>
  801ff8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	bb 00 00 00 00       	mov    $0x0,%ebx
  802002:	eb 3d                	jmp    802041 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802004:	85 db                	test   %ebx,%ebx
  802006:	74 04                	je     80200c <devpipe_read+0x26>
				return i;
  802008:	89 d8                	mov    %ebx,%eax
  80200a:	eb 44                	jmp    802050 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80200c:	89 f2                	mov    %esi,%edx
  80200e:	89 f8                	mov    %edi,%eax
  802010:	e8 e5 fe ff ff       	call   801efa <_pipeisclosed>
  802015:	85 c0                	test   %eax,%eax
  802017:	75 32                	jne    80204b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802019:	e8 bc ec ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80201e:	8b 06                	mov    (%esi),%eax
  802020:	3b 46 04             	cmp    0x4(%esi),%eax
  802023:	74 df                	je     802004 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802025:	99                   	cltd   
  802026:	c1 ea 1b             	shr    $0x1b,%edx
  802029:	01 d0                	add    %edx,%eax
  80202b:	83 e0 1f             	and    $0x1f,%eax
  80202e:	29 d0                	sub    %edx,%eax
  802030:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802035:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802038:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80203b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80203e:	83 c3 01             	add    $0x1,%ebx
  802041:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802044:	75 d8                	jne    80201e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802046:	8b 45 10             	mov    0x10(%ebp),%eax
  802049:	eb 05                	jmp    802050 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80204b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    

00802058 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	56                   	push   %esi
  80205c:	53                   	push   %ebx
  80205d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802060:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802063:	50                   	push   %eax
  802064:	e8 db f1 ff ff       	call   801244 <fd_alloc>
  802069:	83 c4 10             	add    $0x10,%esp
  80206c:	89 c2                	mov    %eax,%edx
  80206e:	85 c0                	test   %eax,%eax
  802070:	0f 88 2c 01 00 00    	js     8021a2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802076:	83 ec 04             	sub    $0x4,%esp
  802079:	68 07 04 00 00       	push   $0x407
  80207e:	ff 75 f4             	pushl  -0xc(%ebp)
  802081:	6a 00                	push   $0x0
  802083:	e8 71 ec ff ff       	call   800cf9 <sys_page_alloc>
  802088:	83 c4 10             	add    $0x10,%esp
  80208b:	89 c2                	mov    %eax,%edx
  80208d:	85 c0                	test   %eax,%eax
  80208f:	0f 88 0d 01 00 00    	js     8021a2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802095:	83 ec 0c             	sub    $0xc,%esp
  802098:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80209b:	50                   	push   %eax
  80209c:	e8 a3 f1 ff ff       	call   801244 <fd_alloc>
  8020a1:	89 c3                	mov    %eax,%ebx
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	0f 88 e2 00 00 00    	js     802190 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ae:	83 ec 04             	sub    $0x4,%esp
  8020b1:	68 07 04 00 00       	push   $0x407
  8020b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b9:	6a 00                	push   $0x0
  8020bb:	e8 39 ec ff ff       	call   800cf9 <sys_page_alloc>
  8020c0:	89 c3                	mov    %eax,%ebx
  8020c2:	83 c4 10             	add    $0x10,%esp
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	0f 88 c3 00 00 00    	js     802190 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020cd:	83 ec 0c             	sub    $0xc,%esp
  8020d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d3:	e8 55 f1 ff ff       	call   80122d <fd2data>
  8020d8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020da:	83 c4 0c             	add    $0xc,%esp
  8020dd:	68 07 04 00 00       	push   $0x407
  8020e2:	50                   	push   %eax
  8020e3:	6a 00                	push   $0x0
  8020e5:	e8 0f ec ff ff       	call   800cf9 <sys_page_alloc>
  8020ea:	89 c3                	mov    %eax,%ebx
  8020ec:	83 c4 10             	add    $0x10,%esp
  8020ef:	85 c0                	test   %eax,%eax
  8020f1:	0f 88 89 00 00 00    	js     802180 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f7:	83 ec 0c             	sub    $0xc,%esp
  8020fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8020fd:	e8 2b f1 ff ff       	call   80122d <fd2data>
  802102:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802109:	50                   	push   %eax
  80210a:	6a 00                	push   $0x0
  80210c:	56                   	push   %esi
  80210d:	6a 00                	push   $0x0
  80210f:	e8 28 ec ff ff       	call   800d3c <sys_page_map>
  802114:	89 c3                	mov    %eax,%ebx
  802116:	83 c4 20             	add    $0x20,%esp
  802119:	85 c0                	test   %eax,%eax
  80211b:	78 55                	js     802172 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80211d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802123:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802126:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802132:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802138:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80213b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80213d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802140:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802147:	83 ec 0c             	sub    $0xc,%esp
  80214a:	ff 75 f4             	pushl  -0xc(%ebp)
  80214d:	e8 cb f0 ff ff       	call   80121d <fd2num>
  802152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802155:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802157:	83 c4 04             	add    $0x4,%esp
  80215a:	ff 75 f0             	pushl  -0x10(%ebp)
  80215d:	e8 bb f0 ff ff       	call   80121d <fd2num>
  802162:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802165:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802168:	83 c4 10             	add    $0x10,%esp
  80216b:	ba 00 00 00 00       	mov    $0x0,%edx
  802170:	eb 30                	jmp    8021a2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802172:	83 ec 08             	sub    $0x8,%esp
  802175:	56                   	push   %esi
  802176:	6a 00                	push   $0x0
  802178:	e8 01 ec ff ff       	call   800d7e <sys_page_unmap>
  80217d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802180:	83 ec 08             	sub    $0x8,%esp
  802183:	ff 75 f0             	pushl  -0x10(%ebp)
  802186:	6a 00                	push   $0x0
  802188:	e8 f1 eb ff ff       	call   800d7e <sys_page_unmap>
  80218d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802190:	83 ec 08             	sub    $0x8,%esp
  802193:	ff 75 f4             	pushl  -0xc(%ebp)
  802196:	6a 00                	push   $0x0
  802198:	e8 e1 eb ff ff       	call   800d7e <sys_page_unmap>
  80219d:	83 c4 10             	add    $0x10,%esp
  8021a0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021a2:	89 d0                	mov    %edx,%eax
  8021a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5d                   	pop    %ebp
  8021aa:	c3                   	ret    

008021ab <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b4:	50                   	push   %eax
  8021b5:	ff 75 08             	pushl  0x8(%ebp)
  8021b8:	e8 d6 f0 ff ff       	call   801293 <fd_lookup>
  8021bd:	83 c4 10             	add    $0x10,%esp
  8021c0:	85 c0                	test   %eax,%eax
  8021c2:	78 18                	js     8021dc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021c4:	83 ec 0c             	sub    $0xc,%esp
  8021c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ca:	e8 5e f0 ff ff       	call   80122d <fd2data>
	return _pipeisclosed(fd, p);
  8021cf:	89 c2                	mov    %eax,%edx
  8021d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d4:	e8 21 fd ff ff       	call   801efa <_pipeisclosed>
  8021d9:	83 c4 10             	add    $0x10,%esp
}
  8021dc:	c9                   	leave  
  8021dd:	c3                   	ret    

008021de <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    

008021e8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021ee:	68 7e 2d 80 00       	push   $0x802d7e
  8021f3:	ff 75 0c             	pushl  0xc(%ebp)
  8021f6:	e8 fb e6 ff ff       	call   8008f6 <strcpy>
	return 0;
}
  8021fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802200:	c9                   	leave  
  802201:	c3                   	ret    

00802202 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	57                   	push   %edi
  802206:	56                   	push   %esi
  802207:	53                   	push   %ebx
  802208:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80220e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802213:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802219:	eb 2d                	jmp    802248 <devcons_write+0x46>
		m = n - tot;
  80221b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80221e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802220:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802223:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802228:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80222b:	83 ec 04             	sub    $0x4,%esp
  80222e:	53                   	push   %ebx
  80222f:	03 45 0c             	add    0xc(%ebp),%eax
  802232:	50                   	push   %eax
  802233:	57                   	push   %edi
  802234:	e8 4f e8 ff ff       	call   800a88 <memmove>
		sys_cputs(buf, m);
  802239:	83 c4 08             	add    $0x8,%esp
  80223c:	53                   	push   %ebx
  80223d:	57                   	push   %edi
  80223e:	e8 fa e9 ff ff       	call   800c3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802243:	01 de                	add    %ebx,%esi
  802245:	83 c4 10             	add    $0x10,%esp
  802248:	89 f0                	mov    %esi,%eax
  80224a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80224d:	72 cc                	jb     80221b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80224f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802252:	5b                   	pop    %ebx
  802253:	5e                   	pop    %esi
  802254:	5f                   	pop    %edi
  802255:	5d                   	pop    %ebp
  802256:	c3                   	ret    

00802257 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	83 ec 08             	sub    $0x8,%esp
  80225d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802262:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802266:	74 2a                	je     802292 <devcons_read+0x3b>
  802268:	eb 05                	jmp    80226f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80226a:	e8 6b ea ff ff       	call   800cda <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80226f:	e8 e7 e9 ff ff       	call   800c5b <sys_cgetc>
  802274:	85 c0                	test   %eax,%eax
  802276:	74 f2                	je     80226a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802278:	85 c0                	test   %eax,%eax
  80227a:	78 16                	js     802292 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80227c:	83 f8 04             	cmp    $0x4,%eax
  80227f:	74 0c                	je     80228d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802281:	8b 55 0c             	mov    0xc(%ebp),%edx
  802284:	88 02                	mov    %al,(%edx)
	return 1;
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	eb 05                	jmp    802292 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80228d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802292:	c9                   	leave  
  802293:	c3                   	ret    

00802294 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80229a:	8b 45 08             	mov    0x8(%ebp),%eax
  80229d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022a0:	6a 01                	push   $0x1
  8022a2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a5:	50                   	push   %eax
  8022a6:	e8 92 e9 ff ff       	call   800c3d <sys_cputs>
}
  8022ab:	83 c4 10             	add    $0x10,%esp
  8022ae:	c9                   	leave  
  8022af:	c3                   	ret    

008022b0 <getchar>:

int
getchar(void)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022b6:	6a 01                	push   $0x1
  8022b8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022bb:	50                   	push   %eax
  8022bc:	6a 00                	push   $0x0
  8022be:	e8 36 f2 ff ff       	call   8014f9 <read>
	if (r < 0)
  8022c3:	83 c4 10             	add    $0x10,%esp
  8022c6:	85 c0                	test   %eax,%eax
  8022c8:	78 0f                	js     8022d9 <getchar+0x29>
		return r;
	if (r < 1)
  8022ca:	85 c0                	test   %eax,%eax
  8022cc:	7e 06                	jle    8022d4 <getchar+0x24>
		return -E_EOF;
	return c;
  8022ce:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022d2:	eb 05                	jmp    8022d9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022d4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022d9:	c9                   	leave  
  8022da:	c3                   	ret    

008022db <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e4:	50                   	push   %eax
  8022e5:	ff 75 08             	pushl  0x8(%ebp)
  8022e8:	e8 a6 ef ff ff       	call   801293 <fd_lookup>
  8022ed:	83 c4 10             	add    $0x10,%esp
  8022f0:	85 c0                	test   %eax,%eax
  8022f2:	78 11                	js     802305 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022fd:	39 10                	cmp    %edx,(%eax)
  8022ff:	0f 94 c0             	sete   %al
  802302:	0f b6 c0             	movzbl %al,%eax
}
  802305:	c9                   	leave  
  802306:	c3                   	ret    

00802307 <opencons>:

int
opencons(void)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80230d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802310:	50                   	push   %eax
  802311:	e8 2e ef ff ff       	call   801244 <fd_alloc>
  802316:	83 c4 10             	add    $0x10,%esp
		return r;
  802319:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80231b:	85 c0                	test   %eax,%eax
  80231d:	78 3e                	js     80235d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80231f:	83 ec 04             	sub    $0x4,%esp
  802322:	68 07 04 00 00       	push   $0x407
  802327:	ff 75 f4             	pushl  -0xc(%ebp)
  80232a:	6a 00                	push   $0x0
  80232c:	e8 c8 e9 ff ff       	call   800cf9 <sys_page_alloc>
  802331:	83 c4 10             	add    $0x10,%esp
		return r;
  802334:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802336:	85 c0                	test   %eax,%eax
  802338:	78 23                	js     80235d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80233a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802343:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802345:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802348:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80234f:	83 ec 0c             	sub    $0xc,%esp
  802352:	50                   	push   %eax
  802353:	e8 c5 ee ff ff       	call   80121d <fd2num>
  802358:	89 c2                	mov    %eax,%edx
  80235a:	83 c4 10             	add    $0x10,%esp
}
  80235d:	89 d0                	mov    %edx,%eax
  80235f:	c9                   	leave  
  802360:	c3                   	ret    

00802361 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802361:	55                   	push   %ebp
  802362:	89 e5                	mov    %esp,%ebp
  802364:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802367:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80236e:	75 2e                	jne    80239e <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802370:	e8 46 e9 ff ff       	call   800cbb <sys_getenvid>
  802375:	83 ec 04             	sub    $0x4,%esp
  802378:	68 07 0e 00 00       	push   $0xe07
  80237d:	68 00 f0 bf ee       	push   $0xeebff000
  802382:	50                   	push   %eax
  802383:	e8 71 e9 ff ff       	call   800cf9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802388:	e8 2e e9 ff ff       	call   800cbb <sys_getenvid>
  80238d:	83 c4 08             	add    $0x8,%esp
  802390:	68 a8 23 80 00       	push   $0x8023a8
  802395:	50                   	push   %eax
  802396:	e8 a9 ea ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
  80239b:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80239e:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a1:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023a6:	c9                   	leave  
  8023a7:	c3                   	ret    

008023a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023a9:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023b0:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8023b3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8023b7:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8023bb:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8023be:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8023c1:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8023c2:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8023c5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8023c6:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8023c7:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8023cb:	c3                   	ret    

008023cc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	56                   	push   %esi
  8023d0:	53                   	push   %ebx
  8023d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8023d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8023da:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8023dc:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023e1:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8023e4:	83 ec 0c             	sub    $0xc,%esp
  8023e7:	50                   	push   %eax
  8023e8:	e8 bc ea ff ff       	call   800ea9 <sys_ipc_recv>

	if (from_env_store != NULL)
  8023ed:	83 c4 10             	add    $0x10,%esp
  8023f0:	85 f6                	test   %esi,%esi
  8023f2:	74 14                	je     802408 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8023f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	78 09                	js     802406 <ipc_recv+0x3a>
  8023fd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802403:	8b 52 74             	mov    0x74(%edx),%edx
  802406:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802408:	85 db                	test   %ebx,%ebx
  80240a:	74 14                	je     802420 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80240c:	ba 00 00 00 00       	mov    $0x0,%edx
  802411:	85 c0                	test   %eax,%eax
  802413:	78 09                	js     80241e <ipc_recv+0x52>
  802415:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80241b:	8b 52 78             	mov    0x78(%edx),%edx
  80241e:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802420:	85 c0                	test   %eax,%eax
  802422:	78 08                	js     80242c <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802424:	a1 08 40 80 00       	mov    0x804008,%eax
  802429:	8b 40 70             	mov    0x70(%eax),%eax
}
  80242c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80242f:	5b                   	pop    %ebx
  802430:	5e                   	pop    %esi
  802431:	5d                   	pop    %ebp
  802432:	c3                   	ret    

00802433 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802433:	55                   	push   %ebp
  802434:	89 e5                	mov    %esp,%ebp
  802436:	57                   	push   %edi
  802437:	56                   	push   %esi
  802438:	53                   	push   %ebx
  802439:	83 ec 0c             	sub    $0xc,%esp
  80243c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80243f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802442:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802445:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802447:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80244c:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80244f:	ff 75 14             	pushl  0x14(%ebp)
  802452:	53                   	push   %ebx
  802453:	56                   	push   %esi
  802454:	57                   	push   %edi
  802455:	e8 2c ea ff ff       	call   800e86 <sys_ipc_try_send>

		if (err < 0) {
  80245a:	83 c4 10             	add    $0x10,%esp
  80245d:	85 c0                	test   %eax,%eax
  80245f:	79 1e                	jns    80247f <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802461:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802464:	75 07                	jne    80246d <ipc_send+0x3a>
				sys_yield();
  802466:	e8 6f e8 ff ff       	call   800cda <sys_yield>
  80246b:	eb e2                	jmp    80244f <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80246d:	50                   	push   %eax
  80246e:	68 8a 2d 80 00       	push   $0x802d8a
  802473:	6a 49                	push   $0x49
  802475:	68 97 2d 80 00       	push   $0x802d97
  80247a:	e8 19 de ff ff       	call   800298 <_panic>
		}

	} while (err < 0);

}
  80247f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802482:	5b                   	pop    %ebx
  802483:	5e                   	pop    %esi
  802484:	5f                   	pop    %edi
  802485:	5d                   	pop    %ebp
  802486:	c3                   	ret    

00802487 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802487:	55                   	push   %ebp
  802488:	89 e5                	mov    %esp,%ebp
  80248a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80248d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802492:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802495:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80249b:	8b 52 50             	mov    0x50(%edx),%edx
  80249e:	39 ca                	cmp    %ecx,%edx
  8024a0:	75 0d                	jne    8024af <ipc_find_env+0x28>
			return envs[i].env_id;
  8024a2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024aa:	8b 40 48             	mov    0x48(%eax),%eax
  8024ad:	eb 0f                	jmp    8024be <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024af:	83 c0 01             	add    $0x1,%eax
  8024b2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024b7:	75 d9                	jne    802492 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    

008024c0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024c6:	89 d0                	mov    %edx,%eax
  8024c8:	c1 e8 16             	shr    $0x16,%eax
  8024cb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024d2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024d7:	f6 c1 01             	test   $0x1,%cl
  8024da:	74 1d                	je     8024f9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024dc:	c1 ea 0c             	shr    $0xc,%edx
  8024df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024e6:	f6 c2 01             	test   $0x1,%dl
  8024e9:	74 0e                	je     8024f9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024eb:	c1 ea 0c             	shr    $0xc,%edx
  8024ee:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024f5:	ef 
  8024f6:	0f b7 c0             	movzwl %ax,%eax
}
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    
  8024fb:	66 90                	xchg   %ax,%ax
  8024fd:	66 90                	xchg   %ax,%ax
  8024ff:	90                   	nop

00802500 <__udivdi3>:
  802500:	55                   	push   %ebp
  802501:	57                   	push   %edi
  802502:	56                   	push   %esi
  802503:	53                   	push   %ebx
  802504:	83 ec 1c             	sub    $0x1c,%esp
  802507:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80250b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80250f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802513:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802517:	85 f6                	test   %esi,%esi
  802519:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80251d:	89 ca                	mov    %ecx,%edx
  80251f:	89 f8                	mov    %edi,%eax
  802521:	75 3d                	jne    802560 <__udivdi3+0x60>
  802523:	39 cf                	cmp    %ecx,%edi
  802525:	0f 87 c5 00 00 00    	ja     8025f0 <__udivdi3+0xf0>
  80252b:	85 ff                	test   %edi,%edi
  80252d:	89 fd                	mov    %edi,%ebp
  80252f:	75 0b                	jne    80253c <__udivdi3+0x3c>
  802531:	b8 01 00 00 00       	mov    $0x1,%eax
  802536:	31 d2                	xor    %edx,%edx
  802538:	f7 f7                	div    %edi
  80253a:	89 c5                	mov    %eax,%ebp
  80253c:	89 c8                	mov    %ecx,%eax
  80253e:	31 d2                	xor    %edx,%edx
  802540:	f7 f5                	div    %ebp
  802542:	89 c1                	mov    %eax,%ecx
  802544:	89 d8                	mov    %ebx,%eax
  802546:	89 cf                	mov    %ecx,%edi
  802548:	f7 f5                	div    %ebp
  80254a:	89 c3                	mov    %eax,%ebx
  80254c:	89 d8                	mov    %ebx,%eax
  80254e:	89 fa                	mov    %edi,%edx
  802550:	83 c4 1c             	add    $0x1c,%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5f                   	pop    %edi
  802556:	5d                   	pop    %ebp
  802557:	c3                   	ret    
  802558:	90                   	nop
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	39 ce                	cmp    %ecx,%esi
  802562:	77 74                	ja     8025d8 <__udivdi3+0xd8>
  802564:	0f bd fe             	bsr    %esi,%edi
  802567:	83 f7 1f             	xor    $0x1f,%edi
  80256a:	0f 84 98 00 00 00    	je     802608 <__udivdi3+0x108>
  802570:	bb 20 00 00 00       	mov    $0x20,%ebx
  802575:	89 f9                	mov    %edi,%ecx
  802577:	89 c5                	mov    %eax,%ebp
  802579:	29 fb                	sub    %edi,%ebx
  80257b:	d3 e6                	shl    %cl,%esi
  80257d:	89 d9                	mov    %ebx,%ecx
  80257f:	d3 ed                	shr    %cl,%ebp
  802581:	89 f9                	mov    %edi,%ecx
  802583:	d3 e0                	shl    %cl,%eax
  802585:	09 ee                	or     %ebp,%esi
  802587:	89 d9                	mov    %ebx,%ecx
  802589:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80258d:	89 d5                	mov    %edx,%ebp
  80258f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802593:	d3 ed                	shr    %cl,%ebp
  802595:	89 f9                	mov    %edi,%ecx
  802597:	d3 e2                	shl    %cl,%edx
  802599:	89 d9                	mov    %ebx,%ecx
  80259b:	d3 e8                	shr    %cl,%eax
  80259d:	09 c2                	or     %eax,%edx
  80259f:	89 d0                	mov    %edx,%eax
  8025a1:	89 ea                	mov    %ebp,%edx
  8025a3:	f7 f6                	div    %esi
  8025a5:	89 d5                	mov    %edx,%ebp
  8025a7:	89 c3                	mov    %eax,%ebx
  8025a9:	f7 64 24 0c          	mull   0xc(%esp)
  8025ad:	39 d5                	cmp    %edx,%ebp
  8025af:	72 10                	jb     8025c1 <__udivdi3+0xc1>
  8025b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025b5:	89 f9                	mov    %edi,%ecx
  8025b7:	d3 e6                	shl    %cl,%esi
  8025b9:	39 c6                	cmp    %eax,%esi
  8025bb:	73 07                	jae    8025c4 <__udivdi3+0xc4>
  8025bd:	39 d5                	cmp    %edx,%ebp
  8025bf:	75 03                	jne    8025c4 <__udivdi3+0xc4>
  8025c1:	83 eb 01             	sub    $0x1,%ebx
  8025c4:	31 ff                	xor    %edi,%edi
  8025c6:	89 d8                	mov    %ebx,%eax
  8025c8:	89 fa                	mov    %edi,%edx
  8025ca:	83 c4 1c             	add    $0x1c,%esp
  8025cd:	5b                   	pop    %ebx
  8025ce:	5e                   	pop    %esi
  8025cf:	5f                   	pop    %edi
  8025d0:	5d                   	pop    %ebp
  8025d1:	c3                   	ret    
  8025d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025d8:	31 ff                	xor    %edi,%edi
  8025da:	31 db                	xor    %ebx,%ebx
  8025dc:	89 d8                	mov    %ebx,%eax
  8025de:	89 fa                	mov    %edi,%edx
  8025e0:	83 c4 1c             	add    $0x1c,%esp
  8025e3:	5b                   	pop    %ebx
  8025e4:	5e                   	pop    %esi
  8025e5:	5f                   	pop    %edi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	90                   	nop
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	89 d8                	mov    %ebx,%eax
  8025f2:	f7 f7                	div    %edi
  8025f4:	31 ff                	xor    %edi,%edi
  8025f6:	89 c3                	mov    %eax,%ebx
  8025f8:	89 d8                	mov    %ebx,%eax
  8025fa:	89 fa                	mov    %edi,%edx
  8025fc:	83 c4 1c             	add    $0x1c,%esp
  8025ff:	5b                   	pop    %ebx
  802600:	5e                   	pop    %esi
  802601:	5f                   	pop    %edi
  802602:	5d                   	pop    %ebp
  802603:	c3                   	ret    
  802604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802608:	39 ce                	cmp    %ecx,%esi
  80260a:	72 0c                	jb     802618 <__udivdi3+0x118>
  80260c:	31 db                	xor    %ebx,%ebx
  80260e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802612:	0f 87 34 ff ff ff    	ja     80254c <__udivdi3+0x4c>
  802618:	bb 01 00 00 00       	mov    $0x1,%ebx
  80261d:	e9 2a ff ff ff       	jmp    80254c <__udivdi3+0x4c>
  802622:	66 90                	xchg   %ax,%ax
  802624:	66 90                	xchg   %ax,%ax
  802626:	66 90                	xchg   %ax,%ax
  802628:	66 90                	xchg   %ax,%ax
  80262a:	66 90                	xchg   %ax,%ax
  80262c:	66 90                	xchg   %ax,%ax
  80262e:	66 90                	xchg   %ax,%ax

00802630 <__umoddi3>:
  802630:	55                   	push   %ebp
  802631:	57                   	push   %edi
  802632:	56                   	push   %esi
  802633:	53                   	push   %ebx
  802634:	83 ec 1c             	sub    $0x1c,%esp
  802637:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80263b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80263f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802643:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802647:	85 d2                	test   %edx,%edx
  802649:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80264d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802651:	89 f3                	mov    %esi,%ebx
  802653:	89 3c 24             	mov    %edi,(%esp)
  802656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80265a:	75 1c                	jne    802678 <__umoddi3+0x48>
  80265c:	39 f7                	cmp    %esi,%edi
  80265e:	76 50                	jbe    8026b0 <__umoddi3+0x80>
  802660:	89 c8                	mov    %ecx,%eax
  802662:	89 f2                	mov    %esi,%edx
  802664:	f7 f7                	div    %edi
  802666:	89 d0                	mov    %edx,%eax
  802668:	31 d2                	xor    %edx,%edx
  80266a:	83 c4 1c             	add    $0x1c,%esp
  80266d:	5b                   	pop    %ebx
  80266e:	5e                   	pop    %esi
  80266f:	5f                   	pop    %edi
  802670:	5d                   	pop    %ebp
  802671:	c3                   	ret    
  802672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802678:	39 f2                	cmp    %esi,%edx
  80267a:	89 d0                	mov    %edx,%eax
  80267c:	77 52                	ja     8026d0 <__umoddi3+0xa0>
  80267e:	0f bd ea             	bsr    %edx,%ebp
  802681:	83 f5 1f             	xor    $0x1f,%ebp
  802684:	75 5a                	jne    8026e0 <__umoddi3+0xb0>
  802686:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80268a:	0f 82 e0 00 00 00    	jb     802770 <__umoddi3+0x140>
  802690:	39 0c 24             	cmp    %ecx,(%esp)
  802693:	0f 86 d7 00 00 00    	jbe    802770 <__umoddi3+0x140>
  802699:	8b 44 24 08          	mov    0x8(%esp),%eax
  80269d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026a1:	83 c4 1c             	add    $0x1c,%esp
  8026a4:	5b                   	pop    %ebx
  8026a5:	5e                   	pop    %esi
  8026a6:	5f                   	pop    %edi
  8026a7:	5d                   	pop    %ebp
  8026a8:	c3                   	ret    
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	85 ff                	test   %edi,%edi
  8026b2:	89 fd                	mov    %edi,%ebp
  8026b4:	75 0b                	jne    8026c1 <__umoddi3+0x91>
  8026b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026bb:	31 d2                	xor    %edx,%edx
  8026bd:	f7 f7                	div    %edi
  8026bf:	89 c5                	mov    %eax,%ebp
  8026c1:	89 f0                	mov    %esi,%eax
  8026c3:	31 d2                	xor    %edx,%edx
  8026c5:	f7 f5                	div    %ebp
  8026c7:	89 c8                	mov    %ecx,%eax
  8026c9:	f7 f5                	div    %ebp
  8026cb:	89 d0                	mov    %edx,%eax
  8026cd:	eb 99                	jmp    802668 <__umoddi3+0x38>
  8026cf:	90                   	nop
  8026d0:	89 c8                	mov    %ecx,%eax
  8026d2:	89 f2                	mov    %esi,%edx
  8026d4:	83 c4 1c             	add    $0x1c,%esp
  8026d7:	5b                   	pop    %ebx
  8026d8:	5e                   	pop    %esi
  8026d9:	5f                   	pop    %edi
  8026da:	5d                   	pop    %ebp
  8026db:	c3                   	ret    
  8026dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	8b 34 24             	mov    (%esp),%esi
  8026e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026e8:	89 e9                	mov    %ebp,%ecx
  8026ea:	29 ef                	sub    %ebp,%edi
  8026ec:	d3 e0                	shl    %cl,%eax
  8026ee:	89 f9                	mov    %edi,%ecx
  8026f0:	89 f2                	mov    %esi,%edx
  8026f2:	d3 ea                	shr    %cl,%edx
  8026f4:	89 e9                	mov    %ebp,%ecx
  8026f6:	09 c2                	or     %eax,%edx
  8026f8:	89 d8                	mov    %ebx,%eax
  8026fa:	89 14 24             	mov    %edx,(%esp)
  8026fd:	89 f2                	mov    %esi,%edx
  8026ff:	d3 e2                	shl    %cl,%edx
  802701:	89 f9                	mov    %edi,%ecx
  802703:	89 54 24 04          	mov    %edx,0x4(%esp)
  802707:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80270b:	d3 e8                	shr    %cl,%eax
  80270d:	89 e9                	mov    %ebp,%ecx
  80270f:	89 c6                	mov    %eax,%esi
  802711:	d3 e3                	shl    %cl,%ebx
  802713:	89 f9                	mov    %edi,%ecx
  802715:	89 d0                	mov    %edx,%eax
  802717:	d3 e8                	shr    %cl,%eax
  802719:	89 e9                	mov    %ebp,%ecx
  80271b:	09 d8                	or     %ebx,%eax
  80271d:	89 d3                	mov    %edx,%ebx
  80271f:	89 f2                	mov    %esi,%edx
  802721:	f7 34 24             	divl   (%esp)
  802724:	89 d6                	mov    %edx,%esi
  802726:	d3 e3                	shl    %cl,%ebx
  802728:	f7 64 24 04          	mull   0x4(%esp)
  80272c:	39 d6                	cmp    %edx,%esi
  80272e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802732:	89 d1                	mov    %edx,%ecx
  802734:	89 c3                	mov    %eax,%ebx
  802736:	72 08                	jb     802740 <__umoddi3+0x110>
  802738:	75 11                	jne    80274b <__umoddi3+0x11b>
  80273a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80273e:	73 0b                	jae    80274b <__umoddi3+0x11b>
  802740:	2b 44 24 04          	sub    0x4(%esp),%eax
  802744:	1b 14 24             	sbb    (%esp),%edx
  802747:	89 d1                	mov    %edx,%ecx
  802749:	89 c3                	mov    %eax,%ebx
  80274b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80274f:	29 da                	sub    %ebx,%edx
  802751:	19 ce                	sbb    %ecx,%esi
  802753:	89 f9                	mov    %edi,%ecx
  802755:	89 f0                	mov    %esi,%eax
  802757:	d3 e0                	shl    %cl,%eax
  802759:	89 e9                	mov    %ebp,%ecx
  80275b:	d3 ea                	shr    %cl,%edx
  80275d:	89 e9                	mov    %ebp,%ecx
  80275f:	d3 ee                	shr    %cl,%esi
  802761:	09 d0                	or     %edx,%eax
  802763:	89 f2                	mov    %esi,%edx
  802765:	83 c4 1c             	add    $0x1c,%esp
  802768:	5b                   	pop    %ebx
  802769:	5e                   	pop    %esi
  80276a:	5f                   	pop    %edi
  80276b:	5d                   	pop    %ebp
  80276c:	c3                   	ret    
  80276d:	8d 76 00             	lea    0x0(%esi),%esi
  802770:	29 f9                	sub    %edi,%ecx
  802772:	19 d6                	sbb    %edx,%esi
  802774:	89 74 24 04          	mov    %esi,0x4(%esp)
  802778:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80277c:	e9 18 ff ff ff       	jmp    802699 <__umoddi3+0x69>
