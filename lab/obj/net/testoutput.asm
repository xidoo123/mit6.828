
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 de 01 00 00       	call   80020f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  800038:	e8 55 0c 00 00       	call   800c92 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 30 80 00 20 	movl   $0x802720,0x803000
  800046:	27 80 00 

	output_envid = fork();
  800049:	e8 ad 0f 00 00       	call   800ffb <fork>
  80004e:	a3 00 40 80 00       	mov    %eax,0x804000
	if (output_envid < 0)
  800053:	85 c0                	test   %eax,%eax
  800055:	79 14                	jns    80006b <umain+0x38>
		panic("error forking");
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	68 2b 27 80 00       	push   $0x80272b
  80005f:	6a 16                	push   $0x16
  800061:	68 39 27 80 00       	push   $0x802739
  800066:	e8 04 02 00 00       	call   80026f <_panic>
  80006b:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800070:	85 c0                	test   %eax,%eax
  800072:	75 11                	jne    800085 <umain+0x52>
		output(ns_envid);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	56                   	push   %esi
  800078:	e8 40 01 00 00       	call   8001bd <output>
		return;
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	e9 8f 00 00 00       	jmp    800114 <umain+0xe1>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 07                	push   $0x7
  80008a:	68 00 b0 fe 0f       	push   $0xffeb000
  80008f:	6a 00                	push   $0x0
  800091:	e8 3a 0c 00 00       	call   800cd0 <sys_page_alloc>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x7c>
			panic("sys_page_alloc: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 4a 27 80 00       	push   $0x80274a
  8000a3:	6a 1e                	push   $0x1e
  8000a5:	68 39 27 80 00       	push   $0x802739
  8000aa:	e8 c0 01 00 00       	call   80026f <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000af:	53                   	push   %ebx
  8000b0:	68 5d 27 80 00       	push   $0x80275d
  8000b5:	68 fc 0f 00 00       	push   $0xffc
  8000ba:	68 04 b0 fe 0f       	push   $0xffeb004
  8000bf:	e8 b6 07 00 00       	call   80087a <snprintf>
  8000c4:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000c9:	83 c4 08             	add    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	68 69 27 80 00       	push   $0x802769
  8000d2:	e8 71 02 00 00       	call   800348 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000d7:	6a 07                	push   $0x7
  8000d9:	68 00 b0 fe 0f       	push   $0xffeb000
  8000de:	6a 0b                	push   $0xb
  8000e0:	ff 35 00 40 80 00    	pushl  0x804000
  8000e6:	e8 2e 11 00 00       	call   801219 <ipc_send>
		sys_page_unmap(0, pkt);
  8000eb:	83 c4 18             	add    $0x18,%esp
  8000ee:	68 00 b0 fe 0f       	push   $0xffeb000
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 5b 0c 00 00       	call   800d55 <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000fa:	83 c3 01             	add    $0x1,%ebx
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	83 fb 0a             	cmp    $0xa,%ebx
  800103:	75 80                	jne    800085 <umain+0x52>
  800105:	bb 14 00 00 00       	mov    $0x14,%ebx
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  80010a:	e8 a2 0b 00 00       	call   800cb1 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80010f:	83 eb 01             	sub    $0x1,%ebx
  800112:	75 f6                	jne    80010a <umain+0xd7>
		sys_yield();
}
  800114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 1c             	sub    $0x1c,%esp
  800124:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800127:	e8 95 0d 00 00       	call   800ec1 <sys_time_msec>
  80012c:	03 45 0c             	add    0xc(%ebp),%eax
  80012f:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800131:	c7 05 00 30 80 00 81 	movl   $0x802781,0x803000
  800138:	27 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80013b:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80013e:	eb 05                	jmp    800145 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800140:	e8 6c 0b 00 00       	call   800cb1 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800145:	e8 77 0d 00 00       	call   800ec1 <sys_time_msec>
  80014a:	89 c2                	mov    %eax,%edx
  80014c:	85 c0                	test   %eax,%eax
  80014e:	78 04                	js     800154 <timer+0x39>
  800150:	39 c3                	cmp    %eax,%ebx
  800152:	77 ec                	ja     800140 <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  800154:	85 c0                	test   %eax,%eax
  800156:	79 12                	jns    80016a <timer+0x4f>
			panic("sys_time_msec: %e", r);
  800158:	52                   	push   %edx
  800159:	68 8a 27 80 00       	push   $0x80278a
  80015e:	6a 0f                	push   $0xf
  800160:	68 9c 27 80 00       	push   $0x80279c
  800165:	e8 05 01 00 00       	call   80026f <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	6a 0c                	push   $0xc
  800170:	56                   	push   %esi
  800171:	e8 a3 10 00 00       	call   801219 <ipc_send>
  800176:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	57                   	push   %edi
  800181:	e8 2c 10 00 00       	call   8011b2 <ipc_recv>
  800186:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	39 f0                	cmp    %esi,%eax
  800190:	74 13                	je     8001a5 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	50                   	push   %eax
  800196:	68 a8 27 80 00       	push   $0x8027a8
  80019b:	e8 a8 01 00 00       	call   800348 <cprintf>
				continue;
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	eb d4                	jmp    800179 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  8001a5:	e8 17 0d 00 00       	call   800ec1 <sys_time_msec>
  8001aa:	01 c3                	add    %eax,%ebx
  8001ac:	eb 97                	jmp    800145 <timer+0x2a>

008001ae <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  8001b1:	c7 05 00 30 80 00 e3 	movl   $0x8027e3,0x803000
  8001b8:	27 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <output>:



void
output(envid_t ns_envid)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 10             	sub    $0x10,%esp
	binaryname = "ns_output";
  8001c5:	c7 05 00 30 80 00 ec 	movl   $0x8027ec,0x803000
  8001cc:	27 80 00 
	uint32_t whom;
    int perm;
    int32_t req;

    while (1) {
        req = ipc_recv((envid_t *)&whom, &nsipcbuf, &perm);
  8001cf:	8d 75 f0             	lea    -0x10(%ebp),%esi
  8001d2:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001d5:	83 ec 04             	sub    $0x4,%esp
  8001d8:	56                   	push   %esi
  8001d9:	68 00 60 80 00       	push   $0x806000
  8001de:	53                   	push   %ebx
  8001df:	e8 ce 0f 00 00       	call   8011b2 <ipc_recv>
        if (req != NSREQ_OUTPUT) {
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	83 f8 0b             	cmp    $0xb,%eax
  8001ea:	75 e9                	jne    8001d5 <output+0x18>
  8001ec:	eb 05                	jmp    8001f3 <output+0x36>
            continue;
        }
        while (sys_e1000_try_send(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) < 0) {
            sys_yield();
  8001ee:	e8 be 0a 00 00       	call   800cb1 <sys_yield>
    while (1) {
        req = ipc_recv((envid_t *)&whom, &nsipcbuf, &perm);
        if (req != NSREQ_OUTPUT) {
            continue;
        }
        while (sys_e1000_try_send(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) < 0) {
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	ff 35 00 60 80 00    	pushl  0x806000
  8001fc:	68 04 60 80 00       	push   $0x806004
  800201:	e8 da 0c 00 00       	call   800ee0 <sys_e1000_try_send>
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	85 c0                	test   %eax,%eax
  80020b:	78 e1                	js     8001ee <output+0x31>
  80020d:	eb c6                	jmp    8001d5 <output+0x18>

0080020f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800217:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80021a:	e8 73 0a 00 00       	call   800c92 <sys_getenvid>
  80021f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800224:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800227:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80022c:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800231:	85 db                	test   %ebx,%ebx
  800233:	7e 07                	jle    80023c <libmain+0x2d>
		binaryname = argv[0];
  800235:	8b 06                	mov    (%esi),%eax
  800237:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
  800241:	e8 ed fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800246:	e8 0a 00 00 00       	call   800255 <exit>
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80025b:	e8 11 12 00 00       	call   801471 <close_all>
	sys_env_destroy(0);
  800260:	83 ec 0c             	sub    $0xc,%esp
  800263:	6a 00                	push   $0x0
  800265:	e8 e7 09 00 00       	call   800c51 <sys_env_destroy>
}
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800274:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800277:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80027d:	e8 10 0a 00 00       	call   800c92 <sys_getenvid>
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	ff 75 0c             	pushl  0xc(%ebp)
  800288:	ff 75 08             	pushl  0x8(%ebp)
  80028b:	56                   	push   %esi
  80028c:	50                   	push   %eax
  80028d:	68 00 28 80 00       	push   $0x802800
  800292:	e8 b1 00 00 00       	call   800348 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800297:	83 c4 18             	add    $0x18,%esp
  80029a:	53                   	push   %ebx
  80029b:	ff 75 10             	pushl  0x10(%ebp)
  80029e:	e8 54 00 00 00       	call   8002f7 <vcprintf>
	cprintf("\n");
  8002a3:	c7 04 24 7f 27 80 00 	movl   $0x80277f,(%esp)
  8002aa:	e8 99 00 00 00       	call   800348 <cprintf>
  8002af:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002b2:	cc                   	int3   
  8002b3:	eb fd                	jmp    8002b2 <_panic+0x43>

008002b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 04             	sub    $0x4,%esp
  8002bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002bf:	8b 13                	mov    (%ebx),%edx
  8002c1:	8d 42 01             	lea    0x1(%edx),%eax
  8002c4:	89 03                	mov    %eax,(%ebx)
  8002c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002cd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002d2:	75 1a                	jne    8002ee <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002d4:	83 ec 08             	sub    $0x8,%esp
  8002d7:	68 ff 00 00 00       	push   $0xff
  8002dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8002df:	50                   	push   %eax
  8002e0:	e8 2f 09 00 00       	call   800c14 <sys_cputs>
		b->idx = 0;
  8002e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002eb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ee:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800300:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800307:	00 00 00 
	b.cnt = 0;
  80030a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800311:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800314:	ff 75 0c             	pushl  0xc(%ebp)
  800317:	ff 75 08             	pushl  0x8(%ebp)
  80031a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800320:	50                   	push   %eax
  800321:	68 b5 02 80 00       	push   $0x8002b5
  800326:	e8 54 01 00 00       	call   80047f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80032b:	83 c4 08             	add    $0x8,%esp
  80032e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800334:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80033a:	50                   	push   %eax
  80033b:	e8 d4 08 00 00       	call   800c14 <sys_cputs>

	return b.cnt;
}
  800340:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800351:	50                   	push   %eax
  800352:	ff 75 08             	pushl  0x8(%ebp)
  800355:	e8 9d ff ff ff       	call   8002f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	57                   	push   %edi
  800360:	56                   	push   %esi
  800361:	53                   	push   %ebx
  800362:	83 ec 1c             	sub    $0x1c,%esp
  800365:	89 c7                	mov    %eax,%edi
  800367:	89 d6                	mov    %edx,%esi
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80036f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800372:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800375:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800378:	bb 00 00 00 00       	mov    $0x0,%ebx
  80037d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800380:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800383:	39 d3                	cmp    %edx,%ebx
  800385:	72 05                	jb     80038c <printnum+0x30>
  800387:	39 45 10             	cmp    %eax,0x10(%ebp)
  80038a:	77 45                	ja     8003d1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80038c:	83 ec 0c             	sub    $0xc,%esp
  80038f:	ff 75 18             	pushl  0x18(%ebp)
  800392:	8b 45 14             	mov    0x14(%ebp),%eax
  800395:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800398:	53                   	push   %ebx
  800399:	ff 75 10             	pushl  0x10(%ebp)
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ab:	e8 e0 20 00 00       	call   802490 <__udivdi3>
  8003b0:	83 c4 18             	add    $0x18,%esp
  8003b3:	52                   	push   %edx
  8003b4:	50                   	push   %eax
  8003b5:	89 f2                	mov    %esi,%edx
  8003b7:	89 f8                	mov    %edi,%eax
  8003b9:	e8 9e ff ff ff       	call   80035c <printnum>
  8003be:	83 c4 20             	add    $0x20,%esp
  8003c1:	eb 18                	jmp    8003db <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	56                   	push   %esi
  8003c7:	ff 75 18             	pushl  0x18(%ebp)
  8003ca:	ff d7                	call   *%edi
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	eb 03                	jmp    8003d4 <printnum+0x78>
  8003d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d4:	83 eb 01             	sub    $0x1,%ebx
  8003d7:	85 db                	test   %ebx,%ebx
  8003d9:	7f e8                	jg     8003c3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	56                   	push   %esi
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ee:	e8 cd 21 00 00       	call   8025c0 <__umoddi3>
  8003f3:	83 c4 14             	add    $0x14,%esp
  8003f6:	0f be 80 23 28 80 00 	movsbl 0x802823(%eax),%eax
  8003fd:	50                   	push   %eax
  8003fe:	ff d7                	call   *%edi
}
  800400:	83 c4 10             	add    $0x10,%esp
  800403:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800406:	5b                   	pop    %ebx
  800407:	5e                   	pop    %esi
  800408:	5f                   	pop    %edi
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80040e:	83 fa 01             	cmp    $0x1,%edx
  800411:	7e 0e                	jle    800421 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800413:	8b 10                	mov    (%eax),%edx
  800415:	8d 4a 08             	lea    0x8(%edx),%ecx
  800418:	89 08                	mov    %ecx,(%eax)
  80041a:	8b 02                	mov    (%edx),%eax
  80041c:	8b 52 04             	mov    0x4(%edx),%edx
  80041f:	eb 22                	jmp    800443 <getuint+0x38>
	else if (lflag)
  800421:	85 d2                	test   %edx,%edx
  800423:	74 10                	je     800435 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800425:	8b 10                	mov    (%eax),%edx
  800427:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042a:	89 08                	mov    %ecx,(%eax)
  80042c:	8b 02                	mov    (%edx),%eax
  80042e:	ba 00 00 00 00       	mov    $0x0,%edx
  800433:	eb 0e                	jmp    800443 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800435:	8b 10                	mov    (%eax),%edx
  800437:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043a:	89 08                	mov    %ecx,(%eax)
  80043c:	8b 02                	mov    (%edx),%eax
  80043e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80044f:	8b 10                	mov    (%eax),%edx
  800451:	3b 50 04             	cmp    0x4(%eax),%edx
  800454:	73 0a                	jae    800460 <sprintputch+0x1b>
		*b->buf++ = ch;
  800456:	8d 4a 01             	lea    0x1(%edx),%ecx
  800459:	89 08                	mov    %ecx,(%eax)
  80045b:	8b 45 08             	mov    0x8(%ebp),%eax
  80045e:	88 02                	mov    %al,(%edx)
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800468:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80046b:	50                   	push   %eax
  80046c:	ff 75 10             	pushl  0x10(%ebp)
  80046f:	ff 75 0c             	pushl  0xc(%ebp)
  800472:	ff 75 08             	pushl  0x8(%ebp)
  800475:	e8 05 00 00 00       	call   80047f <vprintfmt>
	va_end(ap);
}
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	c9                   	leave  
  80047e:	c3                   	ret    

0080047f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	57                   	push   %edi
  800483:	56                   	push   %esi
  800484:	53                   	push   %ebx
  800485:	83 ec 2c             	sub    $0x2c,%esp
  800488:	8b 75 08             	mov    0x8(%ebp),%esi
  80048b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80048e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800491:	eb 12                	jmp    8004a5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800493:	85 c0                	test   %eax,%eax
  800495:	0f 84 89 03 00 00    	je     800824 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	50                   	push   %eax
  8004a0:	ff d6                	call   *%esi
  8004a2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a5:	83 c7 01             	add    $0x1,%edi
  8004a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ac:	83 f8 25             	cmp    $0x25,%eax
  8004af:	75 e2                	jne    800493 <vprintfmt+0x14>
  8004b1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004b5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004bc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004c3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8004cf:	eb 07                	jmp    8004d8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8d 47 01             	lea    0x1(%edi),%eax
  8004db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004de:	0f b6 07             	movzbl (%edi),%eax
  8004e1:	0f b6 c8             	movzbl %al,%ecx
  8004e4:	83 e8 23             	sub    $0x23,%eax
  8004e7:	3c 55                	cmp    $0x55,%al
  8004e9:	0f 87 1a 03 00 00    	ja     800809 <vprintfmt+0x38a>
  8004ef:	0f b6 c0             	movzbl %al,%eax
  8004f2:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004fc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800500:	eb d6                	jmp    8004d8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800505:	b8 00 00 00 00       	mov    $0x0,%eax
  80050a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80050d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800510:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800514:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800517:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80051a:	83 fa 09             	cmp    $0x9,%edx
  80051d:	77 39                	ja     800558 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80051f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800522:	eb e9                	jmp    80050d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 48 04             	lea    0x4(%eax),%ecx
  80052a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80052d:	8b 00                	mov    (%eax),%eax
  80052f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800535:	eb 27                	jmp    80055e <vprintfmt+0xdf>
  800537:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053a:	85 c0                	test   %eax,%eax
  80053c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800541:	0f 49 c8             	cmovns %eax,%ecx
  800544:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054a:	eb 8c                	jmp    8004d8 <vprintfmt+0x59>
  80054c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80054f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800556:	eb 80                	jmp    8004d8 <vprintfmt+0x59>
  800558:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80055b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80055e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800562:	0f 89 70 ff ff ff    	jns    8004d8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800568:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80056b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800575:	e9 5e ff ff ff       	jmp    8004d8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80057a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800580:	e9 53 ff ff ff       	jmp    8004d8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 50 04             	lea    0x4(%eax),%edx
  80058b:	89 55 14             	mov    %edx,0x14(%ebp)
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	53                   	push   %ebx
  800592:	ff 30                	pushl  (%eax)
  800594:	ff d6                	call   *%esi
			break;
  800596:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80059c:	e9 04 ff ff ff       	jmp    8004a5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 50 04             	lea    0x4(%eax),%edx
  8005a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	99                   	cltd   
  8005ad:	31 d0                	xor    %edx,%eax
  8005af:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b1:	83 f8 0f             	cmp    $0xf,%eax
  8005b4:	7f 0b                	jg     8005c1 <vprintfmt+0x142>
  8005b6:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  8005bd:	85 d2                	test   %edx,%edx
  8005bf:	75 18                	jne    8005d9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005c1:	50                   	push   %eax
  8005c2:	68 3b 28 80 00       	push   $0x80283b
  8005c7:	53                   	push   %ebx
  8005c8:	56                   	push   %esi
  8005c9:	e8 94 fe ff ff       	call   800462 <printfmt>
  8005ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005d4:	e9 cc fe ff ff       	jmp    8004a5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005d9:	52                   	push   %edx
  8005da:	68 c5 2c 80 00       	push   $0x802cc5
  8005df:	53                   	push   %ebx
  8005e0:	56                   	push   %esi
  8005e1:	e8 7c fe ff ff       	call   800462 <printfmt>
  8005e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ec:	e9 b4 fe ff ff       	jmp    8004a5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 04             	lea    0x4(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005fc:	85 ff                	test   %edi,%edi
  8005fe:	b8 34 28 80 00       	mov    $0x802834,%eax
  800603:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800606:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060a:	0f 8e 94 00 00 00    	jle    8006a4 <vprintfmt+0x225>
  800610:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800614:	0f 84 98 00 00 00    	je     8006b2 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	ff 75 d0             	pushl  -0x30(%ebp)
  800620:	57                   	push   %edi
  800621:	e8 86 02 00 00       	call   8008ac <strnlen>
  800626:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800629:	29 c1                	sub    %eax,%ecx
  80062b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80062e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800631:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800635:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800638:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80063b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063d:	eb 0f                	jmp    80064e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	ff 75 e0             	pushl  -0x20(%ebp)
  800646:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800648:	83 ef 01             	sub    $0x1,%edi
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	85 ff                	test   %edi,%edi
  800650:	7f ed                	jg     80063f <vprintfmt+0x1c0>
  800652:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800655:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800658:	85 c9                	test   %ecx,%ecx
  80065a:	b8 00 00 00 00       	mov    $0x0,%eax
  80065f:	0f 49 c1             	cmovns %ecx,%eax
  800662:	29 c1                	sub    %eax,%ecx
  800664:	89 75 08             	mov    %esi,0x8(%ebp)
  800667:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80066a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066d:	89 cb                	mov    %ecx,%ebx
  80066f:	eb 4d                	jmp    8006be <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800671:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800675:	74 1b                	je     800692 <vprintfmt+0x213>
  800677:	0f be c0             	movsbl %al,%eax
  80067a:	83 e8 20             	sub    $0x20,%eax
  80067d:	83 f8 5e             	cmp    $0x5e,%eax
  800680:	76 10                	jbe    800692 <vprintfmt+0x213>
					putch('?', putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	ff 75 0c             	pushl  0xc(%ebp)
  800688:	6a 3f                	push   $0x3f
  80068a:	ff 55 08             	call   *0x8(%ebp)
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	eb 0d                	jmp    80069f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	ff 75 0c             	pushl  0xc(%ebp)
  800698:	52                   	push   %edx
  800699:	ff 55 08             	call   *0x8(%ebp)
  80069c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069f:	83 eb 01             	sub    $0x1,%ebx
  8006a2:	eb 1a                	jmp    8006be <vprintfmt+0x23f>
  8006a4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b0:	eb 0c                	jmp    8006be <vprintfmt+0x23f>
  8006b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006be:	83 c7 01             	add    $0x1,%edi
  8006c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c5:	0f be d0             	movsbl %al,%edx
  8006c8:	85 d2                	test   %edx,%edx
  8006ca:	74 23                	je     8006ef <vprintfmt+0x270>
  8006cc:	85 f6                	test   %esi,%esi
  8006ce:	78 a1                	js     800671 <vprintfmt+0x1f2>
  8006d0:	83 ee 01             	sub    $0x1,%esi
  8006d3:	79 9c                	jns    800671 <vprintfmt+0x1f2>
  8006d5:	89 df                	mov    %ebx,%edi
  8006d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006dd:	eb 18                	jmp    8006f7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	6a 20                	push   $0x20
  8006e5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e7:	83 ef 01             	sub    $0x1,%edi
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 08                	jmp    8006f7 <vprintfmt+0x278>
  8006ef:	89 df                	mov    %ebx,%edi
  8006f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f7:	85 ff                	test   %edi,%edi
  8006f9:	7f e4                	jg     8006df <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fe:	e9 a2 fd ff ff       	jmp    8004a5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800703:	83 fa 01             	cmp    $0x1,%edx
  800706:	7e 16                	jle    80071e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8d 50 08             	lea    0x8(%eax),%edx
  80070e:	89 55 14             	mov    %edx,0x14(%ebp)
  800711:	8b 50 04             	mov    0x4(%eax),%edx
  800714:	8b 00                	mov    (%eax),%eax
  800716:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800719:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80071c:	eb 32                	jmp    800750 <vprintfmt+0x2d1>
	else if (lflag)
  80071e:	85 d2                	test   %edx,%edx
  800720:	74 18                	je     80073a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8d 50 04             	lea    0x4(%eax),%edx
  800728:	89 55 14             	mov    %edx,0x14(%ebp)
  80072b:	8b 00                	mov    (%eax),%eax
  80072d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800730:	89 c1                	mov    %eax,%ecx
  800732:	c1 f9 1f             	sar    $0x1f,%ecx
  800735:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800738:	eb 16                	jmp    800750 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8d 50 04             	lea    0x4(%eax),%edx
  800740:	89 55 14             	mov    %edx,0x14(%ebp)
  800743:	8b 00                	mov    (%eax),%eax
  800745:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800748:	89 c1                	mov    %eax,%ecx
  80074a:	c1 f9 1f             	sar    $0x1f,%ecx
  80074d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800750:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800753:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800756:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80075b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80075f:	79 74                	jns    8007d5 <vprintfmt+0x356>
				putch('-', putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	53                   	push   %ebx
  800765:	6a 2d                	push   $0x2d
  800767:	ff d6                	call   *%esi
				num = -(long long) num;
  800769:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80076c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80076f:	f7 d8                	neg    %eax
  800771:	83 d2 00             	adc    $0x0,%edx
  800774:	f7 da                	neg    %edx
  800776:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800779:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80077e:	eb 55                	jmp    8007d5 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
  800783:	e8 83 fc ff ff       	call   80040b <getuint>
			base = 10;
  800788:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80078d:	eb 46                	jmp    8007d5 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 74 fc ff ff       	call   80040b <getuint>
			base = 8;
  800797:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80079c:	eb 37                	jmp    8007d5 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80079e:	83 ec 08             	sub    $0x8,%esp
  8007a1:	53                   	push   %ebx
  8007a2:	6a 30                	push   $0x30
  8007a4:	ff d6                	call   *%esi
			putch('x', putdat);
  8007a6:	83 c4 08             	add    $0x8,%esp
  8007a9:	53                   	push   %ebx
  8007aa:	6a 78                	push   $0x78
  8007ac:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 04             	lea    0x4(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007be:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007c6:	eb 0d                	jmp    8007d5 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007cb:	e8 3b fc ff ff       	call   80040b <getuint>
			base = 16;
  8007d0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d5:	83 ec 0c             	sub    $0xc,%esp
  8007d8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007dc:	57                   	push   %edi
  8007dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8007e0:	51                   	push   %ecx
  8007e1:	52                   	push   %edx
  8007e2:	50                   	push   %eax
  8007e3:	89 da                	mov    %ebx,%edx
  8007e5:	89 f0                	mov    %esi,%eax
  8007e7:	e8 70 fb ff ff       	call   80035c <printnum>
			break;
  8007ec:	83 c4 20             	add    $0x20,%esp
  8007ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f2:	e9 ae fc ff ff       	jmp    8004a5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	51                   	push   %ecx
  8007fc:	ff d6                	call   *%esi
			break;
  8007fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800804:	e9 9c fc ff ff       	jmp    8004a5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800809:	83 ec 08             	sub    $0x8,%esp
  80080c:	53                   	push   %ebx
  80080d:	6a 25                	push   $0x25
  80080f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800811:	83 c4 10             	add    $0x10,%esp
  800814:	eb 03                	jmp    800819 <vprintfmt+0x39a>
  800816:	83 ef 01             	sub    $0x1,%edi
  800819:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80081d:	75 f7                	jne    800816 <vprintfmt+0x397>
  80081f:	e9 81 fc ff ff       	jmp    8004a5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800824:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800827:	5b                   	pop    %ebx
  800828:	5e                   	pop    %esi
  800829:	5f                   	pop    %edi
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	83 ec 18             	sub    $0x18,%esp
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800838:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80083b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80083f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800842:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800849:	85 c0                	test   %eax,%eax
  80084b:	74 26                	je     800873 <vsnprintf+0x47>
  80084d:	85 d2                	test   %edx,%edx
  80084f:	7e 22                	jle    800873 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800851:	ff 75 14             	pushl  0x14(%ebp)
  800854:	ff 75 10             	pushl  0x10(%ebp)
  800857:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80085a:	50                   	push   %eax
  80085b:	68 45 04 80 00       	push   $0x800445
  800860:	e8 1a fc ff ff       	call   80047f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800865:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800868:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	eb 05                	jmp    800878 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800873:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800880:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800883:	50                   	push   %eax
  800884:	ff 75 10             	pushl  0x10(%ebp)
  800887:	ff 75 0c             	pushl  0xc(%ebp)
  80088a:	ff 75 08             	pushl  0x8(%ebp)
  80088d:	e8 9a ff ff ff       	call   80082c <vsnprintf>
	va_end(ap);

	return rc;
}
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	eb 03                	jmp    8008a4 <strlen+0x10>
		n++;
  8008a1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a8:	75 f7                	jne    8008a1 <strlen+0xd>
		n++;
	return n;
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ba:	eb 03                	jmp    8008bf <strnlen+0x13>
		n++;
  8008bc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	39 c2                	cmp    %eax,%edx
  8008c1:	74 08                	je     8008cb <strnlen+0x1f>
  8008c3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008c7:	75 f3                	jne    8008bc <strnlen+0x10>
  8008c9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	53                   	push   %ebx
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d7:	89 c2                	mov    %eax,%edx
  8008d9:	83 c2 01             	add    $0x1,%edx
  8008dc:	83 c1 01             	add    $0x1,%ecx
  8008df:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008e3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e6:	84 db                	test   %bl,%bl
  8008e8:	75 ef                	jne    8008d9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ea:	5b                   	pop    %ebx
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	53                   	push   %ebx
  8008f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f4:	53                   	push   %ebx
  8008f5:	e8 9a ff ff ff       	call   800894 <strlen>
  8008fa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008fd:	ff 75 0c             	pushl  0xc(%ebp)
  800900:	01 d8                	add    %ebx,%eax
  800902:	50                   	push   %eax
  800903:	e8 c5 ff ff ff       	call   8008cd <strcpy>
	return dst;
}
  800908:	89 d8                	mov    %ebx,%eax
  80090a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 75 08             	mov    0x8(%ebp),%esi
  800917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091a:	89 f3                	mov    %esi,%ebx
  80091c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091f:	89 f2                	mov    %esi,%edx
  800921:	eb 0f                	jmp    800932 <strncpy+0x23>
		*dst++ = *src;
  800923:	83 c2 01             	add    $0x1,%edx
  800926:	0f b6 01             	movzbl (%ecx),%eax
  800929:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092c:	80 39 01             	cmpb   $0x1,(%ecx)
  80092f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800932:	39 da                	cmp    %ebx,%edx
  800934:	75 ed                	jne    800923 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800936:	89 f0                	mov    %esi,%eax
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	56                   	push   %esi
  800940:	53                   	push   %ebx
  800941:	8b 75 08             	mov    0x8(%ebp),%esi
  800944:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800947:	8b 55 10             	mov    0x10(%ebp),%edx
  80094a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094c:	85 d2                	test   %edx,%edx
  80094e:	74 21                	je     800971 <strlcpy+0x35>
  800950:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800954:	89 f2                	mov    %esi,%edx
  800956:	eb 09                	jmp    800961 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800958:	83 c2 01             	add    $0x1,%edx
  80095b:	83 c1 01             	add    $0x1,%ecx
  80095e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800961:	39 c2                	cmp    %eax,%edx
  800963:	74 09                	je     80096e <strlcpy+0x32>
  800965:	0f b6 19             	movzbl (%ecx),%ebx
  800968:	84 db                	test   %bl,%bl
  80096a:	75 ec                	jne    800958 <strlcpy+0x1c>
  80096c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80096e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800971:	29 f0                	sub    %esi,%eax
}
  800973:	5b                   	pop    %ebx
  800974:	5e                   	pop    %esi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800980:	eb 06                	jmp    800988 <strcmp+0x11>
		p++, q++;
  800982:	83 c1 01             	add    $0x1,%ecx
  800985:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800988:	0f b6 01             	movzbl (%ecx),%eax
  80098b:	84 c0                	test   %al,%al
  80098d:	74 04                	je     800993 <strcmp+0x1c>
  80098f:	3a 02                	cmp    (%edx),%al
  800991:	74 ef                	je     800982 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800993:	0f b6 c0             	movzbl %al,%eax
  800996:	0f b6 12             	movzbl (%edx),%edx
  800999:	29 d0                	sub    %edx,%eax
}
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a7:	89 c3                	mov    %eax,%ebx
  8009a9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ac:	eb 06                	jmp    8009b4 <strncmp+0x17>
		n--, p++, q++;
  8009ae:	83 c0 01             	add    $0x1,%eax
  8009b1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b4:	39 d8                	cmp    %ebx,%eax
  8009b6:	74 15                	je     8009cd <strncmp+0x30>
  8009b8:	0f b6 08             	movzbl (%eax),%ecx
  8009bb:	84 c9                	test   %cl,%cl
  8009bd:	74 04                	je     8009c3 <strncmp+0x26>
  8009bf:	3a 0a                	cmp    (%edx),%cl
  8009c1:	74 eb                	je     8009ae <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c3:	0f b6 00             	movzbl (%eax),%eax
  8009c6:	0f b6 12             	movzbl (%edx),%edx
  8009c9:	29 d0                	sub    %edx,%eax
  8009cb:	eb 05                	jmp    8009d2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009df:	eb 07                	jmp    8009e8 <strchr+0x13>
		if (*s == c)
  8009e1:	38 ca                	cmp    %cl,%dl
  8009e3:	74 0f                	je     8009f4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009e5:	83 c0 01             	add    $0x1,%eax
  8009e8:	0f b6 10             	movzbl (%eax),%edx
  8009eb:	84 d2                	test   %dl,%dl
  8009ed:	75 f2                	jne    8009e1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a00:	eb 03                	jmp    800a05 <strfind+0xf>
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a08:	38 ca                	cmp    %cl,%dl
  800a0a:	74 04                	je     800a10 <strfind+0x1a>
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	75 f2                	jne    800a02 <strfind+0xc>
			break;
	return (char *) s;
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a1e:	85 c9                	test   %ecx,%ecx
  800a20:	74 36                	je     800a58 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a22:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a28:	75 28                	jne    800a52 <memset+0x40>
  800a2a:	f6 c1 03             	test   $0x3,%cl
  800a2d:	75 23                	jne    800a52 <memset+0x40>
		c &= 0xFF;
  800a2f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a33:	89 d3                	mov    %edx,%ebx
  800a35:	c1 e3 08             	shl    $0x8,%ebx
  800a38:	89 d6                	mov    %edx,%esi
  800a3a:	c1 e6 18             	shl    $0x18,%esi
  800a3d:	89 d0                	mov    %edx,%eax
  800a3f:	c1 e0 10             	shl    $0x10,%eax
  800a42:	09 f0                	or     %esi,%eax
  800a44:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a46:	89 d8                	mov    %ebx,%eax
  800a48:	09 d0                	or     %edx,%eax
  800a4a:	c1 e9 02             	shr    $0x2,%ecx
  800a4d:	fc                   	cld    
  800a4e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a50:	eb 06                	jmp    800a58 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	fc                   	cld    
  800a56:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a58:	89 f8                	mov    %edi,%eax
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a6d:	39 c6                	cmp    %eax,%esi
  800a6f:	73 35                	jae    800aa6 <memmove+0x47>
  800a71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	73 2e                	jae    800aa6 <memmove+0x47>
		s += n;
		d += n;
  800a78:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7b:	89 d6                	mov    %edx,%esi
  800a7d:	09 fe                	or     %edi,%esi
  800a7f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a85:	75 13                	jne    800a9a <memmove+0x3b>
  800a87:	f6 c1 03             	test   $0x3,%cl
  800a8a:	75 0e                	jne    800a9a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a8c:	83 ef 04             	sub    $0x4,%edi
  800a8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a92:	c1 e9 02             	shr    $0x2,%ecx
  800a95:	fd                   	std    
  800a96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a98:	eb 09                	jmp    800aa3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a9a:	83 ef 01             	sub    $0x1,%edi
  800a9d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aa0:	fd                   	std    
  800aa1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa3:	fc                   	cld    
  800aa4:	eb 1d                	jmp    800ac3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	89 f2                	mov    %esi,%edx
  800aa8:	09 c2                	or     %eax,%edx
  800aaa:	f6 c2 03             	test   $0x3,%dl
  800aad:	75 0f                	jne    800abe <memmove+0x5f>
  800aaf:	f6 c1 03             	test   $0x3,%cl
  800ab2:	75 0a                	jne    800abe <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ab4:	c1 e9 02             	shr    $0x2,%ecx
  800ab7:	89 c7                	mov    %eax,%edi
  800ab9:	fc                   	cld    
  800aba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abc:	eb 05                	jmp    800ac3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800abe:	89 c7                	mov    %eax,%edi
  800ac0:	fc                   	cld    
  800ac1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aca:	ff 75 10             	pushl  0x10(%ebp)
  800acd:	ff 75 0c             	pushl  0xc(%ebp)
  800ad0:	ff 75 08             	pushl  0x8(%ebp)
  800ad3:	e8 87 ff ff ff       	call   800a5f <memmove>
}
  800ad8:	c9                   	leave  
  800ad9:	c3                   	ret    

00800ada <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae5:	89 c6                	mov    %eax,%esi
  800ae7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aea:	eb 1a                	jmp    800b06 <memcmp+0x2c>
		if (*s1 != *s2)
  800aec:	0f b6 08             	movzbl (%eax),%ecx
  800aef:	0f b6 1a             	movzbl (%edx),%ebx
  800af2:	38 d9                	cmp    %bl,%cl
  800af4:	74 0a                	je     800b00 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800af6:	0f b6 c1             	movzbl %cl,%eax
  800af9:	0f b6 db             	movzbl %bl,%ebx
  800afc:	29 d8                	sub    %ebx,%eax
  800afe:	eb 0f                	jmp    800b0f <memcmp+0x35>
		s1++, s2++;
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b06:	39 f0                	cmp    %esi,%eax
  800b08:	75 e2                	jne    800aec <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	53                   	push   %ebx
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b1a:	89 c1                	mov    %eax,%ecx
  800b1c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b23:	eb 0a                	jmp    800b2f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b25:	0f b6 10             	movzbl (%eax),%edx
  800b28:	39 da                	cmp    %ebx,%edx
  800b2a:	74 07                	je     800b33 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b2c:	83 c0 01             	add    $0x1,%eax
  800b2f:	39 c8                	cmp    %ecx,%eax
  800b31:	72 f2                	jb     800b25 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b33:	5b                   	pop    %ebx
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b42:	eb 03                	jmp    800b47 <strtol+0x11>
		s++;
  800b44:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b47:	0f b6 01             	movzbl (%ecx),%eax
  800b4a:	3c 20                	cmp    $0x20,%al
  800b4c:	74 f6                	je     800b44 <strtol+0xe>
  800b4e:	3c 09                	cmp    $0x9,%al
  800b50:	74 f2                	je     800b44 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b52:	3c 2b                	cmp    $0x2b,%al
  800b54:	75 0a                	jne    800b60 <strtol+0x2a>
		s++;
  800b56:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b59:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5e:	eb 11                	jmp    800b71 <strtol+0x3b>
  800b60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b65:	3c 2d                	cmp    $0x2d,%al
  800b67:	75 08                	jne    800b71 <strtol+0x3b>
		s++, neg = 1;
  800b69:	83 c1 01             	add    $0x1,%ecx
  800b6c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b71:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b77:	75 15                	jne    800b8e <strtol+0x58>
  800b79:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7c:	75 10                	jne    800b8e <strtol+0x58>
  800b7e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b82:	75 7c                	jne    800c00 <strtol+0xca>
		s += 2, base = 16;
  800b84:	83 c1 02             	add    $0x2,%ecx
  800b87:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b8c:	eb 16                	jmp    800ba4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b8e:	85 db                	test   %ebx,%ebx
  800b90:	75 12                	jne    800ba4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b92:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b97:	80 39 30             	cmpb   $0x30,(%ecx)
  800b9a:	75 08                	jne    800ba4 <strtol+0x6e>
		s++, base = 8;
  800b9c:	83 c1 01             	add    $0x1,%ecx
  800b9f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bac:	0f b6 11             	movzbl (%ecx),%edx
  800baf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bb2:	89 f3                	mov    %esi,%ebx
  800bb4:	80 fb 09             	cmp    $0x9,%bl
  800bb7:	77 08                	ja     800bc1 <strtol+0x8b>
			dig = *s - '0';
  800bb9:	0f be d2             	movsbl %dl,%edx
  800bbc:	83 ea 30             	sub    $0x30,%edx
  800bbf:	eb 22                	jmp    800be3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bc1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bc4:	89 f3                	mov    %esi,%ebx
  800bc6:	80 fb 19             	cmp    $0x19,%bl
  800bc9:	77 08                	ja     800bd3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bcb:	0f be d2             	movsbl %dl,%edx
  800bce:	83 ea 57             	sub    $0x57,%edx
  800bd1:	eb 10                	jmp    800be3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bd3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bd6:	89 f3                	mov    %esi,%ebx
  800bd8:	80 fb 19             	cmp    $0x19,%bl
  800bdb:	77 16                	ja     800bf3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bdd:	0f be d2             	movsbl %dl,%edx
  800be0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800be3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800be6:	7d 0b                	jge    800bf3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800be8:	83 c1 01             	add    $0x1,%ecx
  800beb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bef:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bf1:	eb b9                	jmp    800bac <strtol+0x76>

	if (endptr)
  800bf3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf7:	74 0d                	je     800c06 <strtol+0xd0>
		*endptr = (char *) s;
  800bf9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfc:	89 0e                	mov    %ecx,(%esi)
  800bfe:	eb 06                	jmp    800c06 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c00:	85 db                	test   %ebx,%ebx
  800c02:	74 98                	je     800b9c <strtol+0x66>
  800c04:	eb 9e                	jmp    800ba4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c06:	89 c2                	mov    %eax,%edx
  800c08:	f7 da                	neg    %edx
  800c0a:	85 ff                	test   %edi,%edi
  800c0c:	0f 45 c2             	cmovne %edx,%eax
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	89 c3                	mov    %eax,%ebx
  800c27:	89 c7                	mov    %eax,%edi
  800c29:	89 c6                	mov    %eax,%esi
  800c2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c42:	89 d1                	mov    %edx,%ecx
  800c44:	89 d3                	mov    %edx,%ebx
  800c46:	89 d7                	mov    %edx,%edi
  800c48:	89 d6                	mov    %edx,%esi
  800c4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 cb                	mov    %ecx,%ebx
  800c69:	89 cf                	mov    %ecx,%edi
  800c6b:	89 ce                	mov    %ecx,%esi
  800c6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	7e 17                	jle    800c8a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	50                   	push   %eax
  800c77:	6a 03                	push   $0x3
  800c79:	68 1f 2b 80 00       	push   $0x802b1f
  800c7e:	6a 23                	push   $0x23
  800c80:	68 3c 2b 80 00       	push   $0x802b3c
  800c85:	e8 e5 f5 ff ff       	call   80026f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9d:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca2:	89 d1                	mov    %edx,%ecx
  800ca4:	89 d3                	mov    %edx,%ebx
  800ca6:	89 d7                	mov    %edx,%edi
  800ca8:	89 d6                	mov    %edx,%esi
  800caa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_yield>:

void
sys_yield(void)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc1:	89 d1                	mov    %edx,%ecx
  800cc3:	89 d3                	mov    %edx,%ebx
  800cc5:	89 d7                	mov    %edx,%edi
  800cc7:	89 d6                	mov    %edx,%esi
  800cc9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	be 00 00 00 00       	mov    $0x0,%esi
  800cde:	b8 04 00 00 00       	mov    $0x4,%eax
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cec:	89 f7                	mov    %esi,%edi
  800cee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 04                	push   $0x4
  800cfa:	68 1f 2b 80 00       	push   $0x802b1f
  800cff:	6a 23                	push   $0x23
  800d01:	68 3c 2b 80 00       	push   $0x802b3c
  800d06:	e8 64 f5 ff ff       	call   80026f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	b8 05 00 00 00       	mov    $0x5,%eax
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2d:	8b 75 18             	mov    0x18(%ebp),%esi
  800d30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 05                	push   $0x5
  800d3c:	68 1f 2b 80 00       	push   $0x802b1f
  800d41:	6a 23                	push   $0x23
  800d43:	68 3c 2b 80 00       	push   $0x802b3c
  800d48:	e8 22 f5 ff ff       	call   80026f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	b8 06 00 00 00       	mov    $0x6,%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 17                	jle    800d8f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 06                	push   $0x6
  800d7e:	68 1f 2b 80 00       	push   $0x802b1f
  800d83:	6a 23                	push   $0x23
  800d85:	68 3c 2b 80 00       	push   $0x802b3c
  800d8a:	e8 e0 f4 ff ff       	call   80026f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da5:	b8 08 00 00 00       	mov    $0x8,%eax
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	89 df                	mov    %ebx,%edi
  800db2:	89 de                	mov    %ebx,%esi
  800db4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 17                	jle    800dd1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	50                   	push   %eax
  800dbe:	6a 08                	push   $0x8
  800dc0:	68 1f 2b 80 00       	push   $0x802b1f
  800dc5:	6a 23                	push   $0x23
  800dc7:	68 3c 2b 80 00       	push   $0x802b3c
  800dcc:	e8 9e f4 ff ff       	call   80026f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de7:	b8 09 00 00 00       	mov    $0x9,%eax
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800def:	8b 55 08             	mov    0x8(%ebp),%edx
  800df2:	89 df                	mov    %ebx,%edi
  800df4:	89 de                	mov    %ebx,%esi
  800df6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	7e 17                	jle    800e13 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfc:	83 ec 0c             	sub    $0xc,%esp
  800dff:	50                   	push   %eax
  800e00:	6a 09                	push   $0x9
  800e02:	68 1f 2b 80 00       	push   $0x802b1f
  800e07:	6a 23                	push   $0x23
  800e09:	68 3c 2b 80 00       	push   $0x802b3c
  800e0e:	e8 5c f4 ff ff       	call   80026f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e29:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	8b 55 08             	mov    0x8(%ebp),%edx
  800e34:	89 df                	mov    %ebx,%edi
  800e36:	89 de                	mov    %ebx,%esi
  800e38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	7e 17                	jle    800e55 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3e:	83 ec 0c             	sub    $0xc,%esp
  800e41:	50                   	push   %eax
  800e42:	6a 0a                	push   $0xa
  800e44:	68 1f 2b 80 00       	push   $0x802b1f
  800e49:	6a 23                	push   $0x23
  800e4b:	68 3c 2b 80 00       	push   $0x802b3c
  800e50:	e8 1a f4 ff ff       	call   80026f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	be 00 00 00 00       	mov    $0x0,%esi
  800e68:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e79:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e93:	8b 55 08             	mov    0x8(%ebp),%edx
  800e96:	89 cb                	mov    %ecx,%ebx
  800e98:	89 cf                	mov    %ecx,%edi
  800e9a:	89 ce                	mov    %ecx,%esi
  800e9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	7e 17                	jle    800eb9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea2:	83 ec 0c             	sub    $0xc,%esp
  800ea5:	50                   	push   %eax
  800ea6:	6a 0d                	push   $0xd
  800ea8:	68 1f 2b 80 00       	push   $0x802b1f
  800ead:	6a 23                	push   $0x23
  800eaf:	68 3c 2b 80 00       	push   $0x802b3c
  800eb4:	e8 b6 f3 ff ff       	call   80026f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	57                   	push   %edi
  800ec5:	56                   	push   %esi
  800ec6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ed1:	89 d1                	mov    %edx,%ecx
  800ed3:	89 d3                	mov    %edx,%ebx
  800ed5:	89 d7                	mov    %edx,%edi
  800ed7:	89 d6                	mov    %edx,%esi
  800ed9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eee:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef9:	89 df                	mov    %ebx,%edi
  800efb:	89 de                	mov    %ebx,%esi
  800efd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eff:	85 c0                	test   %eax,%eax
  800f01:	7e 17                	jle    800f1a <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	50                   	push   %eax
  800f07:	6a 0f                	push   $0xf
  800f09:	68 1f 2b 80 00       	push   $0x802b1f
  800f0e:	6a 23                	push   $0x23
  800f10:	68 3c 2b 80 00       	push   $0x802b3c
  800f15:	e8 55 f3 ff ff       	call   80026f <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f2a:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800f2c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f30:	75 25                	jne    800f57 <pgfault+0x35>
  800f32:	89 d8                	mov    %ebx,%eax
  800f34:	c1 e8 0c             	shr    $0xc,%eax
  800f37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3e:	f6 c4 08             	test   $0x8,%ah
  800f41:	75 14                	jne    800f57 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	68 4c 2b 80 00       	push   $0x802b4c
  800f4b:	6a 1e                	push   $0x1e
  800f4d:	68 e0 2b 80 00       	push   $0x802be0
  800f52:	e8 18 f3 ff ff       	call   80026f <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f57:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f5d:	e8 30 fd ff ff       	call   800c92 <sys_getenvid>
  800f62:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	6a 07                	push   $0x7
  800f69:	68 00 f0 7f 00       	push   $0x7ff000
  800f6e:	50                   	push   %eax
  800f6f:	e8 5c fd ff ff       	call   800cd0 <sys_page_alloc>
	if (r < 0)
  800f74:	83 c4 10             	add    $0x10,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	79 12                	jns    800f8d <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f7b:	50                   	push   %eax
  800f7c:	68 78 2b 80 00       	push   $0x802b78
  800f81:	6a 33                	push   $0x33
  800f83:	68 e0 2b 80 00       	push   $0x802be0
  800f88:	e8 e2 f2 ff ff       	call   80026f <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	68 00 10 00 00       	push   $0x1000
  800f95:	53                   	push   %ebx
  800f96:	68 00 f0 7f 00       	push   $0x7ff000
  800f9b:	e8 27 fb ff ff       	call   800ac7 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800fa0:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fa7:	53                   	push   %ebx
  800fa8:	56                   	push   %esi
  800fa9:	68 00 f0 7f 00       	push   $0x7ff000
  800fae:	56                   	push   %esi
  800faf:	e8 5f fd ff ff       	call   800d13 <sys_page_map>
	if (r < 0)
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	79 12                	jns    800fcd <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800fbb:	50                   	push   %eax
  800fbc:	68 9c 2b 80 00       	push   $0x802b9c
  800fc1:	6a 3b                	push   $0x3b
  800fc3:	68 e0 2b 80 00       	push   $0x802be0
  800fc8:	e8 a2 f2 ff ff       	call   80026f <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	68 00 f0 7f 00       	push   $0x7ff000
  800fd5:	56                   	push   %esi
  800fd6:	e8 7a fd ff ff       	call   800d55 <sys_page_unmap>
	if (r < 0)
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	79 12                	jns    800ff4 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800fe2:	50                   	push   %eax
  800fe3:	68 c0 2b 80 00       	push   $0x802bc0
  800fe8:	6a 40                	push   $0x40
  800fea:	68 e0 2b 80 00       	push   $0x802be0
  800fef:	e8 7b f2 ff ff       	call   80026f <_panic>
}
  800ff4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	57                   	push   %edi
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
  801001:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  801004:	68 22 0f 80 00       	push   $0x800f22
  801009:	e8 dc 13 00 00       	call   8023ea <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80100e:	b8 07 00 00 00       	mov    $0x7,%eax
  801013:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	0f 88 64 01 00 00    	js     801184 <fork+0x189>
  801020:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801025:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80102a:	85 c0                	test   %eax,%eax
  80102c:	75 21                	jne    80104f <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  80102e:	e8 5f fc ff ff       	call   800c92 <sys_getenvid>
  801033:	25 ff 03 00 00       	and    $0x3ff,%eax
  801038:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80103b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801040:	a3 0c 40 80 00       	mov    %eax,0x80400c
        return 0;
  801045:	ba 00 00 00 00       	mov    $0x0,%edx
  80104a:	e9 3f 01 00 00       	jmp    80118e <fork+0x193>
  80104f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801052:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801054:	89 d8                	mov    %ebx,%eax
  801056:	c1 e8 16             	shr    $0x16,%eax
  801059:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801060:	a8 01                	test   $0x1,%al
  801062:	0f 84 bd 00 00 00    	je     801125 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801068:	89 d8                	mov    %ebx,%eax
  80106a:	c1 e8 0c             	shr    $0xc,%eax
  80106d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801074:	f6 c2 01             	test   $0x1,%dl
  801077:	0f 84 a8 00 00 00    	je     801125 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  80107d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801084:	a8 04                	test   $0x4,%al
  801086:	0f 84 99 00 00 00    	je     801125 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  80108c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801093:	f6 c4 04             	test   $0x4,%ah
  801096:	74 17                	je     8010af <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	68 07 0e 00 00       	push   $0xe07
  8010a0:	53                   	push   %ebx
  8010a1:	57                   	push   %edi
  8010a2:	53                   	push   %ebx
  8010a3:	6a 00                	push   $0x0
  8010a5:	e8 69 fc ff ff       	call   800d13 <sys_page_map>
  8010aa:	83 c4 20             	add    $0x20,%esp
  8010ad:	eb 76                	jmp    801125 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010af:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b6:	a8 02                	test   $0x2,%al
  8010b8:	75 0c                	jne    8010c6 <fork+0xcb>
  8010ba:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010c1:	f6 c4 08             	test   $0x8,%ah
  8010c4:	74 3f                	je     801105 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	68 05 08 00 00       	push   $0x805
  8010ce:	53                   	push   %ebx
  8010cf:	57                   	push   %edi
  8010d0:	53                   	push   %ebx
  8010d1:	6a 00                	push   $0x0
  8010d3:	e8 3b fc ff ff       	call   800d13 <sys_page_map>
		if (r < 0)
  8010d8:	83 c4 20             	add    $0x20,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	0f 88 a5 00 00 00    	js     801188 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	68 05 08 00 00       	push   $0x805
  8010eb:	53                   	push   %ebx
  8010ec:	6a 00                	push   $0x0
  8010ee:	53                   	push   %ebx
  8010ef:	6a 00                	push   $0x0
  8010f1:	e8 1d fc ff ff       	call   800d13 <sys_page_map>
  8010f6:	83 c4 20             	add    $0x20,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  801100:	0f 4f c1             	cmovg  %ecx,%eax
  801103:	eb 1c                	jmp    801121 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	6a 05                	push   $0x5
  80110a:	53                   	push   %ebx
  80110b:	57                   	push   %edi
  80110c:	53                   	push   %ebx
  80110d:	6a 00                	push   $0x0
  80110f:	e8 ff fb ff ff       	call   800d13 <sys_page_map>
  801114:	83 c4 20             	add    $0x20,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111e:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801121:	85 c0                	test   %eax,%eax
  801123:	78 67                	js     80118c <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801125:	83 c6 01             	add    $0x1,%esi
  801128:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80112e:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801134:	0f 85 1a ff ff ff    	jne    801054 <fork+0x59>
  80113a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80113d:	83 ec 04             	sub    $0x4,%esp
  801140:	6a 07                	push   $0x7
  801142:	68 00 f0 bf ee       	push   $0xeebff000
  801147:	57                   	push   %edi
  801148:	e8 83 fb ff ff       	call   800cd0 <sys_page_alloc>
	if (r < 0)
  80114d:	83 c4 10             	add    $0x10,%esp
		return r;
  801150:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801152:	85 c0                	test   %eax,%eax
  801154:	78 38                	js     80118e <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801156:	83 ec 08             	sub    $0x8,%esp
  801159:	68 31 24 80 00       	push   $0x802431
  80115e:	57                   	push   %edi
  80115f:	e8 b7 fc ff ff       	call   800e1b <sys_env_set_pgfault_upcall>
	if (r < 0)
  801164:	83 c4 10             	add    $0x10,%esp
		return r;
  801167:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801169:	85 c0                	test   %eax,%eax
  80116b:	78 21                	js     80118e <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	6a 02                	push   $0x2
  801172:	57                   	push   %edi
  801173:	e8 1f fc ff ff       	call   800d97 <sys_env_set_status>
	if (r < 0)
  801178:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  80117b:	85 c0                	test   %eax,%eax
  80117d:	0f 48 f8             	cmovs  %eax,%edi
  801180:	89 fa                	mov    %edi,%edx
  801182:	eb 0a                	jmp    80118e <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801184:	89 c2                	mov    %eax,%edx
  801186:	eb 06                	jmp    80118e <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801188:	89 c2                	mov    %eax,%edx
  80118a:	eb 02                	jmp    80118e <fork+0x193>
  80118c:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  80118e:	89 d0                	mov    %edx,%eax
  801190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <sfork>:

// Challenge!
int
sfork(void)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80119e:	68 eb 2b 80 00       	push   $0x802beb
  8011a3:	68 c9 00 00 00       	push   $0xc9
  8011a8:	68 e0 2b 80 00       	push   $0x802be0
  8011ad:	e8 bd f0 ff ff       	call   80026f <_panic>

008011b2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	56                   	push   %esi
  8011b6:	53                   	push   %ebx
  8011b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8011c0:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8011c2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011c7:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8011ca:	83 ec 0c             	sub    $0xc,%esp
  8011cd:	50                   	push   %eax
  8011ce:	e8 ad fc ff ff       	call   800e80 <sys_ipc_recv>

	if (from_env_store != NULL)
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 f6                	test   %esi,%esi
  8011d8:	74 14                	je     8011ee <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8011da:	ba 00 00 00 00       	mov    $0x0,%edx
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 09                	js     8011ec <ipc_recv+0x3a>
  8011e3:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8011e9:	8b 52 74             	mov    0x74(%edx),%edx
  8011ec:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8011ee:	85 db                	test   %ebx,%ebx
  8011f0:	74 14                	je     801206 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8011f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 09                	js     801204 <ipc_recv+0x52>
  8011fb:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801201:	8b 52 78             	mov    0x78(%edx),%edx
  801204:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801206:	85 c0                	test   %eax,%eax
  801208:	78 08                	js     801212 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80120a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80120f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801212:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	8b 7d 08             	mov    0x8(%ebp),%edi
  801225:	8b 75 0c             	mov    0xc(%ebp),%esi
  801228:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80122b:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80122d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801232:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801235:	ff 75 14             	pushl  0x14(%ebp)
  801238:	53                   	push   %ebx
  801239:	56                   	push   %esi
  80123a:	57                   	push   %edi
  80123b:	e8 1d fc ff ff       	call   800e5d <sys_ipc_try_send>

		if (err < 0) {
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	79 1e                	jns    801265 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801247:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80124a:	75 07                	jne    801253 <ipc_send+0x3a>
				sys_yield();
  80124c:	e8 60 fa ff ff       	call   800cb1 <sys_yield>
  801251:	eb e2                	jmp    801235 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801253:	50                   	push   %eax
  801254:	68 01 2c 80 00       	push   $0x802c01
  801259:	6a 49                	push   $0x49
  80125b:	68 0e 2c 80 00       	push   $0x802c0e
  801260:	e8 0a f0 ff ff       	call   80026f <_panic>
		}

	} while (err < 0);

}
  801265:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5f                   	pop    %edi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801278:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80127b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801281:	8b 52 50             	mov    0x50(%edx),%edx
  801284:	39 ca                	cmp    %ecx,%edx
  801286:	75 0d                	jne    801295 <ipc_find_env+0x28>
			return envs[i].env_id;
  801288:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80128b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801290:	8b 40 48             	mov    0x48(%eax),%eax
  801293:	eb 0f                	jmp    8012a4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801295:	83 c0 01             	add    $0x1,%eax
  801298:	3d 00 04 00 00       	cmp    $0x400,%eax
  80129d:	75 d9                	jne    801278 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ac:	05 00 00 00 30       	add    $0x30000000,%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
}
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012c6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	c1 ea 16             	shr    $0x16,%edx
  8012dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e4:	f6 c2 01             	test   $0x1,%dl
  8012e7:	74 11                	je     8012fa <fd_alloc+0x2d>
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	c1 ea 0c             	shr    $0xc,%edx
  8012ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f5:	f6 c2 01             	test   $0x1,%dl
  8012f8:	75 09                	jne    801303 <fd_alloc+0x36>
			*fd_store = fd;
  8012fa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801301:	eb 17                	jmp    80131a <fd_alloc+0x4d>
  801303:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801308:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80130d:	75 c9                	jne    8012d8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80130f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801315:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801322:	83 f8 1f             	cmp    $0x1f,%eax
  801325:	77 36                	ja     80135d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801327:	c1 e0 0c             	shl    $0xc,%eax
  80132a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80132f:	89 c2                	mov    %eax,%edx
  801331:	c1 ea 16             	shr    $0x16,%edx
  801334:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80133b:	f6 c2 01             	test   $0x1,%dl
  80133e:	74 24                	je     801364 <fd_lookup+0x48>
  801340:	89 c2                	mov    %eax,%edx
  801342:	c1 ea 0c             	shr    $0xc,%edx
  801345:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134c:	f6 c2 01             	test   $0x1,%dl
  80134f:	74 1a                	je     80136b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801351:	8b 55 0c             	mov    0xc(%ebp),%edx
  801354:	89 02                	mov    %eax,(%edx)
	return 0;
  801356:	b8 00 00 00 00       	mov    $0x0,%eax
  80135b:	eb 13                	jmp    801370 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80135d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801362:	eb 0c                	jmp    801370 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801369:	eb 05                	jmp    801370 <fd_lookup+0x54>
  80136b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137b:	ba 98 2c 80 00       	mov    $0x802c98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801380:	eb 13                	jmp    801395 <dev_lookup+0x23>
  801382:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801385:	39 08                	cmp    %ecx,(%eax)
  801387:	75 0c                	jne    801395 <dev_lookup+0x23>
			*dev = devtab[i];
  801389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
  801393:	eb 2e                	jmp    8013c3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801395:	8b 02                	mov    (%edx),%eax
  801397:	85 c0                	test   %eax,%eax
  801399:	75 e7                	jne    801382 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80139b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013a0:	8b 40 48             	mov    0x48(%eax),%eax
  8013a3:	83 ec 04             	sub    $0x4,%esp
  8013a6:	51                   	push   %ecx
  8013a7:	50                   	push   %eax
  8013a8:	68 18 2c 80 00       	push   $0x802c18
  8013ad:	e8 96 ef ff ff       	call   800348 <cprintf>
	*dev = 0;
  8013b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 10             	sub    $0x10,%esp
  8013cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d6:	50                   	push   %eax
  8013d7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013dd:	c1 e8 0c             	shr    $0xc,%eax
  8013e0:	50                   	push   %eax
  8013e1:	e8 36 ff ff ff       	call   80131c <fd_lookup>
  8013e6:	83 c4 08             	add    $0x8,%esp
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 05                	js     8013f2 <fd_close+0x2d>
	    || fd != fd2)
  8013ed:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013f0:	74 0c                	je     8013fe <fd_close+0x39>
		return (must_exist ? r : 0);
  8013f2:	84 db                	test   %bl,%bl
  8013f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f9:	0f 44 c2             	cmove  %edx,%eax
  8013fc:	eb 41                	jmp    80143f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801404:	50                   	push   %eax
  801405:	ff 36                	pushl  (%esi)
  801407:	e8 66 ff ff ff       	call   801372 <dev_lookup>
  80140c:	89 c3                	mov    %eax,%ebx
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	85 c0                	test   %eax,%eax
  801413:	78 1a                	js     80142f <fd_close+0x6a>
		if (dev->dev_close)
  801415:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801418:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80141b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801420:	85 c0                	test   %eax,%eax
  801422:	74 0b                	je     80142f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801424:	83 ec 0c             	sub    $0xc,%esp
  801427:	56                   	push   %esi
  801428:	ff d0                	call   *%eax
  80142a:	89 c3                	mov    %eax,%ebx
  80142c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	56                   	push   %esi
  801433:	6a 00                	push   $0x0
  801435:	e8 1b f9 ff ff       	call   800d55 <sys_page_unmap>
	return r;
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	89 d8                	mov    %ebx,%eax
}
  80143f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801442:	5b                   	pop    %ebx
  801443:	5e                   	pop    %esi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    

00801446 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	ff 75 08             	pushl  0x8(%ebp)
  801453:	e8 c4 fe ff ff       	call   80131c <fd_lookup>
  801458:	83 c4 08             	add    $0x8,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 10                	js     80146f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	6a 01                	push   $0x1
  801464:	ff 75 f4             	pushl  -0xc(%ebp)
  801467:	e8 59 ff ff ff       	call   8013c5 <fd_close>
  80146c:	83 c4 10             	add    $0x10,%esp
}
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <close_all>:

void
close_all(void)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	53                   	push   %ebx
  801475:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801478:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	53                   	push   %ebx
  801481:	e8 c0 ff ff ff       	call   801446 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801486:	83 c3 01             	add    $0x1,%ebx
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	83 fb 20             	cmp    $0x20,%ebx
  80148f:	75 ec                	jne    80147d <close_all+0xc>
		close(i);
}
  801491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	57                   	push   %edi
  80149a:	56                   	push   %esi
  80149b:	53                   	push   %ebx
  80149c:	83 ec 2c             	sub    $0x2c,%esp
  80149f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	ff 75 08             	pushl  0x8(%ebp)
  8014a9:	e8 6e fe ff ff       	call   80131c <fd_lookup>
  8014ae:	83 c4 08             	add    $0x8,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	0f 88 c1 00 00 00    	js     80157a <dup+0xe4>
		return r;
	close(newfdnum);
  8014b9:	83 ec 0c             	sub    $0xc,%esp
  8014bc:	56                   	push   %esi
  8014bd:	e8 84 ff ff ff       	call   801446 <close>

	newfd = INDEX2FD(newfdnum);
  8014c2:	89 f3                	mov    %esi,%ebx
  8014c4:	c1 e3 0c             	shl    $0xc,%ebx
  8014c7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014cd:	83 c4 04             	add    $0x4,%esp
  8014d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014d3:	e8 de fd ff ff       	call   8012b6 <fd2data>
  8014d8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014da:	89 1c 24             	mov    %ebx,(%esp)
  8014dd:	e8 d4 fd ff ff       	call   8012b6 <fd2data>
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014e8:	89 f8                	mov    %edi,%eax
  8014ea:	c1 e8 16             	shr    $0x16,%eax
  8014ed:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014f4:	a8 01                	test   $0x1,%al
  8014f6:	74 37                	je     80152f <dup+0x99>
  8014f8:	89 f8                	mov    %edi,%eax
  8014fa:	c1 e8 0c             	shr    $0xc,%eax
  8014fd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801504:	f6 c2 01             	test   $0x1,%dl
  801507:	74 26                	je     80152f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801509:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801510:	83 ec 0c             	sub    $0xc,%esp
  801513:	25 07 0e 00 00       	and    $0xe07,%eax
  801518:	50                   	push   %eax
  801519:	ff 75 d4             	pushl  -0x2c(%ebp)
  80151c:	6a 00                	push   $0x0
  80151e:	57                   	push   %edi
  80151f:	6a 00                	push   $0x0
  801521:	e8 ed f7 ff ff       	call   800d13 <sys_page_map>
  801526:	89 c7                	mov    %eax,%edi
  801528:	83 c4 20             	add    $0x20,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 2e                	js     80155d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80152f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801532:	89 d0                	mov    %edx,%eax
  801534:	c1 e8 0c             	shr    $0xc,%eax
  801537:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	25 07 0e 00 00       	and    $0xe07,%eax
  801546:	50                   	push   %eax
  801547:	53                   	push   %ebx
  801548:	6a 00                	push   $0x0
  80154a:	52                   	push   %edx
  80154b:	6a 00                	push   $0x0
  80154d:	e8 c1 f7 ff ff       	call   800d13 <sys_page_map>
  801552:	89 c7                	mov    %eax,%edi
  801554:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801557:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801559:	85 ff                	test   %edi,%edi
  80155b:	79 1d                	jns    80157a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	53                   	push   %ebx
  801561:	6a 00                	push   $0x0
  801563:	e8 ed f7 ff ff       	call   800d55 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80156e:	6a 00                	push   $0x0
  801570:	e8 e0 f7 ff ff       	call   800d55 <sys_page_unmap>
	return r;
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	89 f8                	mov    %edi,%eax
}
  80157a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157d:	5b                   	pop    %ebx
  80157e:	5e                   	pop    %esi
  80157f:	5f                   	pop    %edi
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	53                   	push   %ebx
  801586:	83 ec 14             	sub    $0x14,%esp
  801589:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	53                   	push   %ebx
  801591:	e8 86 fd ff ff       	call   80131c <fd_lookup>
  801596:	83 c4 08             	add    $0x8,%esp
  801599:	89 c2                	mov    %eax,%edx
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 6d                	js     80160c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a9:	ff 30                	pushl  (%eax)
  8015ab:	e8 c2 fd ff ff       	call   801372 <dev_lookup>
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 4c                	js     801603 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ba:	8b 42 08             	mov    0x8(%edx),%eax
  8015bd:	83 e0 03             	and    $0x3,%eax
  8015c0:	83 f8 01             	cmp    $0x1,%eax
  8015c3:	75 21                	jne    8015e6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8015ca:	8b 40 48             	mov    0x48(%eax),%eax
  8015cd:	83 ec 04             	sub    $0x4,%esp
  8015d0:	53                   	push   %ebx
  8015d1:	50                   	push   %eax
  8015d2:	68 5c 2c 80 00       	push   $0x802c5c
  8015d7:	e8 6c ed ff ff       	call   800348 <cprintf>
		return -E_INVAL;
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e4:	eb 26                	jmp    80160c <read+0x8a>
	}
	if (!dev->dev_read)
  8015e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e9:	8b 40 08             	mov    0x8(%eax),%eax
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	74 17                	je     801607 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015f0:	83 ec 04             	sub    $0x4,%esp
  8015f3:	ff 75 10             	pushl  0x10(%ebp)
  8015f6:	ff 75 0c             	pushl  0xc(%ebp)
  8015f9:	52                   	push   %edx
  8015fa:	ff d0                	call   *%eax
  8015fc:	89 c2                	mov    %eax,%edx
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	eb 09                	jmp    80160c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801603:	89 c2                	mov    %eax,%edx
  801605:	eb 05                	jmp    80160c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801607:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80160c:	89 d0                	mov    %edx,%eax
  80160e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	57                   	push   %edi
  801617:	56                   	push   %esi
  801618:	53                   	push   %ebx
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80161f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801622:	bb 00 00 00 00       	mov    $0x0,%ebx
  801627:	eb 21                	jmp    80164a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801629:	83 ec 04             	sub    $0x4,%esp
  80162c:	89 f0                	mov    %esi,%eax
  80162e:	29 d8                	sub    %ebx,%eax
  801630:	50                   	push   %eax
  801631:	89 d8                	mov    %ebx,%eax
  801633:	03 45 0c             	add    0xc(%ebp),%eax
  801636:	50                   	push   %eax
  801637:	57                   	push   %edi
  801638:	e8 45 ff ff ff       	call   801582 <read>
		if (m < 0)
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	78 10                	js     801654 <readn+0x41>
			return m;
		if (m == 0)
  801644:	85 c0                	test   %eax,%eax
  801646:	74 0a                	je     801652 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801648:	01 c3                	add    %eax,%ebx
  80164a:	39 f3                	cmp    %esi,%ebx
  80164c:	72 db                	jb     801629 <readn+0x16>
  80164e:	89 d8                	mov    %ebx,%eax
  801650:	eb 02                	jmp    801654 <readn+0x41>
  801652:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801654:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801657:	5b                   	pop    %ebx
  801658:	5e                   	pop    %esi
  801659:	5f                   	pop    %edi
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	53                   	push   %ebx
  801660:	83 ec 14             	sub    $0x14,%esp
  801663:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801666:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	53                   	push   %ebx
  80166b:	e8 ac fc ff ff       	call   80131c <fd_lookup>
  801670:	83 c4 08             	add    $0x8,%esp
  801673:	89 c2                	mov    %eax,%edx
  801675:	85 c0                	test   %eax,%eax
  801677:	78 68                	js     8016e1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167f:	50                   	push   %eax
  801680:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801683:	ff 30                	pushl  (%eax)
  801685:	e8 e8 fc ff ff       	call   801372 <dev_lookup>
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 47                	js     8016d8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801694:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801698:	75 21                	jne    8016bb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80169a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80169f:	8b 40 48             	mov    0x48(%eax),%eax
  8016a2:	83 ec 04             	sub    $0x4,%esp
  8016a5:	53                   	push   %ebx
  8016a6:	50                   	push   %eax
  8016a7:	68 78 2c 80 00       	push   $0x802c78
  8016ac:	e8 97 ec ff ff       	call   800348 <cprintf>
		return -E_INVAL;
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016b9:	eb 26                	jmp    8016e1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016be:	8b 52 0c             	mov    0xc(%edx),%edx
  8016c1:	85 d2                	test   %edx,%edx
  8016c3:	74 17                	je     8016dc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016c5:	83 ec 04             	sub    $0x4,%esp
  8016c8:	ff 75 10             	pushl  0x10(%ebp)
  8016cb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ce:	50                   	push   %eax
  8016cf:	ff d2                	call   *%edx
  8016d1:	89 c2                	mov    %eax,%edx
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	eb 09                	jmp    8016e1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d8:	89 c2                	mov    %eax,%edx
  8016da:	eb 05                	jmp    8016e1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016e1:	89 d0                	mov    %edx,%eax
  8016e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ee:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016f1:	50                   	push   %eax
  8016f2:	ff 75 08             	pushl  0x8(%ebp)
  8016f5:	e8 22 fc ff ff       	call   80131c <fd_lookup>
  8016fa:	83 c4 08             	add    $0x8,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 0e                	js     80170f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801701:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801704:	8b 55 0c             	mov    0xc(%ebp),%edx
  801707:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80170a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	53                   	push   %ebx
  801715:	83 ec 14             	sub    $0x14,%esp
  801718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	53                   	push   %ebx
  801720:	e8 f7 fb ff ff       	call   80131c <fd_lookup>
  801725:	83 c4 08             	add    $0x8,%esp
  801728:	89 c2                	mov    %eax,%edx
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 65                	js     801793 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801738:	ff 30                	pushl  (%eax)
  80173a:	e8 33 fc ff ff       	call   801372 <dev_lookup>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 44                	js     80178a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80174d:	75 21                	jne    801770 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80174f:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801754:	8b 40 48             	mov    0x48(%eax),%eax
  801757:	83 ec 04             	sub    $0x4,%esp
  80175a:	53                   	push   %ebx
  80175b:	50                   	push   %eax
  80175c:	68 38 2c 80 00       	push   $0x802c38
  801761:	e8 e2 eb ff ff       	call   800348 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80176e:	eb 23                	jmp    801793 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801773:	8b 52 18             	mov    0x18(%edx),%edx
  801776:	85 d2                	test   %edx,%edx
  801778:	74 14                	je     80178e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	ff 75 0c             	pushl  0xc(%ebp)
  801780:	50                   	push   %eax
  801781:	ff d2                	call   *%edx
  801783:	89 c2                	mov    %eax,%edx
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	eb 09                	jmp    801793 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178a:	89 c2                	mov    %eax,%edx
  80178c:	eb 05                	jmp    801793 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80178e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801793:	89 d0                	mov    %edx,%eax
  801795:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	53                   	push   %ebx
  80179e:	83 ec 14             	sub    $0x14,%esp
  8017a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a7:	50                   	push   %eax
  8017a8:	ff 75 08             	pushl  0x8(%ebp)
  8017ab:	e8 6c fb ff ff       	call   80131c <fd_lookup>
  8017b0:	83 c4 08             	add    $0x8,%esp
  8017b3:	89 c2                	mov    %eax,%edx
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 58                	js     801811 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017bf:	50                   	push   %eax
  8017c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c3:	ff 30                	pushl  (%eax)
  8017c5:	e8 a8 fb ff ff       	call   801372 <dev_lookup>
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 37                	js     801808 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017d8:	74 32                	je     80180c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017da:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017e4:	00 00 00 
	stat->st_isdir = 0;
  8017e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ee:	00 00 00 
	stat->st_dev = dev;
  8017f1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	53                   	push   %ebx
  8017fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8017fe:	ff 50 14             	call   *0x14(%eax)
  801801:	89 c2                	mov    %eax,%edx
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	eb 09                	jmp    801811 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801808:	89 c2                	mov    %eax,%edx
  80180a:	eb 05                	jmp    801811 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80180c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801811:	89 d0                	mov    %edx,%eax
  801813:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80181d:	83 ec 08             	sub    $0x8,%esp
  801820:	6a 00                	push   $0x0
  801822:	ff 75 08             	pushl  0x8(%ebp)
  801825:	e8 d6 01 00 00       	call   801a00 <open>
  80182a:	89 c3                	mov    %eax,%ebx
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 1b                	js     80184e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	ff 75 0c             	pushl  0xc(%ebp)
  801839:	50                   	push   %eax
  80183a:	e8 5b ff ff ff       	call   80179a <fstat>
  80183f:	89 c6                	mov    %eax,%esi
	close(fd);
  801841:	89 1c 24             	mov    %ebx,(%esp)
  801844:	e8 fd fb ff ff       	call   801446 <close>
	return r;
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	89 f0                	mov    %esi,%eax
}
  80184e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801851:	5b                   	pop    %ebx
  801852:	5e                   	pop    %esi
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
  80185a:	89 c6                	mov    %eax,%esi
  80185c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80185e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801865:	75 12                	jne    801879 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801867:	83 ec 0c             	sub    $0xc,%esp
  80186a:	6a 01                	push   $0x1
  80186c:	e8 fc f9 ff ff       	call   80126d <ipc_find_env>
  801871:	a3 04 40 80 00       	mov    %eax,0x804004
  801876:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801879:	6a 07                	push   $0x7
  80187b:	68 00 50 80 00       	push   $0x805000
  801880:	56                   	push   %esi
  801881:	ff 35 04 40 80 00    	pushl  0x804004
  801887:	e8 8d f9 ff ff       	call   801219 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80188c:	83 c4 0c             	add    $0xc,%esp
  80188f:	6a 00                	push   $0x0
  801891:	53                   	push   %ebx
  801892:	6a 00                	push   $0x0
  801894:	e8 19 f9 ff ff       	call   8011b2 <ipc_recv>
}
  801899:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189c:	5b                   	pop    %ebx
  80189d:	5e                   	pop    %esi
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    

008018a0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018be:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c3:	e8 8d ff ff ff       	call   801855 <fsipc>
}
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018db:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8018e5:	e8 6b ff ff ff       	call   801855 <fsipc>
}
  8018ea:	c9                   	leave  
  8018eb:	c3                   	ret    

008018ec <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	53                   	push   %ebx
  8018f0:	83 ec 04             	sub    $0x4,%esp
  8018f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801901:	ba 00 00 00 00       	mov    $0x0,%edx
  801906:	b8 05 00 00 00       	mov    $0x5,%eax
  80190b:	e8 45 ff ff ff       	call   801855 <fsipc>
  801910:	85 c0                	test   %eax,%eax
  801912:	78 2c                	js     801940 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	68 00 50 80 00       	push   $0x805000
  80191c:	53                   	push   %ebx
  80191d:	e8 ab ef ff ff       	call   8008cd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801922:	a1 80 50 80 00       	mov    0x805080,%eax
  801927:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80192d:	a1 84 50 80 00       	mov    0x805084,%eax
  801932:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801940:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	83 ec 0c             	sub    $0xc,%esp
  80194b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80194e:	8b 55 08             	mov    0x8(%ebp),%edx
  801951:	8b 52 0c             	mov    0xc(%edx),%edx
  801954:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80195a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80195f:	50                   	push   %eax
  801960:	ff 75 0c             	pushl  0xc(%ebp)
  801963:	68 08 50 80 00       	push   $0x805008
  801968:	e8 f2 f0 ff ff       	call   800a5f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80196d:	ba 00 00 00 00       	mov    $0x0,%edx
  801972:	b8 04 00 00 00       	mov    $0x4,%eax
  801977:	e8 d9 fe ff ff       	call   801855 <fsipc>

}
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	56                   	push   %esi
  801982:	53                   	push   %ebx
  801983:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	8b 40 0c             	mov    0xc(%eax),%eax
  80198c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801991:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801997:	ba 00 00 00 00       	mov    $0x0,%edx
  80199c:	b8 03 00 00 00       	mov    $0x3,%eax
  8019a1:	e8 af fe ff ff       	call   801855 <fsipc>
  8019a6:	89 c3                	mov    %eax,%ebx
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	78 4b                	js     8019f7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019ac:	39 c6                	cmp    %eax,%esi
  8019ae:	73 16                	jae    8019c6 <devfile_read+0x48>
  8019b0:	68 ac 2c 80 00       	push   $0x802cac
  8019b5:	68 b3 2c 80 00       	push   $0x802cb3
  8019ba:	6a 7c                	push   $0x7c
  8019bc:	68 c8 2c 80 00       	push   $0x802cc8
  8019c1:	e8 a9 e8 ff ff       	call   80026f <_panic>
	assert(r <= PGSIZE);
  8019c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019cb:	7e 16                	jle    8019e3 <devfile_read+0x65>
  8019cd:	68 d3 2c 80 00       	push   $0x802cd3
  8019d2:	68 b3 2c 80 00       	push   $0x802cb3
  8019d7:	6a 7d                	push   $0x7d
  8019d9:	68 c8 2c 80 00       	push   $0x802cc8
  8019de:	e8 8c e8 ff ff       	call   80026f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019e3:	83 ec 04             	sub    $0x4,%esp
  8019e6:	50                   	push   %eax
  8019e7:	68 00 50 80 00       	push   $0x805000
  8019ec:	ff 75 0c             	pushl  0xc(%ebp)
  8019ef:	e8 6b f0 ff ff       	call   800a5f <memmove>
	return r;
  8019f4:	83 c4 10             	add    $0x10,%esp
}
  8019f7:	89 d8                	mov    %ebx,%eax
  8019f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fc:	5b                   	pop    %ebx
  8019fd:	5e                   	pop    %esi
  8019fe:	5d                   	pop    %ebp
  8019ff:	c3                   	ret    

00801a00 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	53                   	push   %ebx
  801a04:	83 ec 20             	sub    $0x20,%esp
  801a07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a0a:	53                   	push   %ebx
  801a0b:	e8 84 ee ff ff       	call   800894 <strlen>
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a18:	7f 67                	jg     801a81 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a20:	50                   	push   %eax
  801a21:	e8 a7 f8 ff ff       	call   8012cd <fd_alloc>
  801a26:	83 c4 10             	add    $0x10,%esp
		return r;
  801a29:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	78 57                	js     801a86 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a2f:	83 ec 08             	sub    $0x8,%esp
  801a32:	53                   	push   %ebx
  801a33:	68 00 50 80 00       	push   $0x805000
  801a38:	e8 90 ee ff ff       	call   8008cd <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a40:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a48:	b8 01 00 00 00       	mov    $0x1,%eax
  801a4d:	e8 03 fe ff ff       	call   801855 <fsipc>
  801a52:	89 c3                	mov    %eax,%ebx
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	85 c0                	test   %eax,%eax
  801a59:	79 14                	jns    801a6f <open+0x6f>
		fd_close(fd, 0);
  801a5b:	83 ec 08             	sub    $0x8,%esp
  801a5e:	6a 00                	push   $0x0
  801a60:	ff 75 f4             	pushl  -0xc(%ebp)
  801a63:	e8 5d f9 ff ff       	call   8013c5 <fd_close>
		return r;
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	89 da                	mov    %ebx,%edx
  801a6d:	eb 17                	jmp    801a86 <open+0x86>
	}

	return fd2num(fd);
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	ff 75 f4             	pushl  -0xc(%ebp)
  801a75:	e8 2c f8 ff ff       	call   8012a6 <fd2num>
  801a7a:	89 c2                	mov    %eax,%edx
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	eb 05                	jmp    801a86 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a81:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a86:	89 d0                	mov    %edx,%eax
  801a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a93:	ba 00 00 00 00       	mov    $0x0,%edx
  801a98:	b8 08 00 00 00       	mov    $0x8,%eax
  801a9d:	e8 b3 fd ff ff       	call   801855 <fsipc>
}
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801aaa:	68 df 2c 80 00       	push   $0x802cdf
  801aaf:	ff 75 0c             	pushl  0xc(%ebp)
  801ab2:	e8 16 ee ff ff       	call   8008cd <strcpy>
	return 0;
}
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    

00801abe <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	53                   	push   %ebx
  801ac2:	83 ec 10             	sub    $0x10,%esp
  801ac5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ac8:	53                   	push   %ebx
  801ac9:	e8 87 09 00 00       	call   802455 <pageref>
  801ace:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ad1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ad6:	83 f8 01             	cmp    $0x1,%eax
  801ad9:	75 10                	jne    801aeb <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	ff 73 0c             	pushl  0xc(%ebx)
  801ae1:	e8 c0 02 00 00       	call   801da6 <nsipc_close>
  801ae6:	89 c2                	mov    %eax,%edx
  801ae8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801aeb:	89 d0                	mov    %edx,%eax
  801aed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801af8:	6a 00                	push   $0x0
  801afa:	ff 75 10             	pushl  0x10(%ebp)
  801afd:	ff 75 0c             	pushl  0xc(%ebp)
  801b00:	8b 45 08             	mov    0x8(%ebp),%eax
  801b03:	ff 70 0c             	pushl  0xc(%eax)
  801b06:	e8 78 03 00 00       	call   801e83 <nsipc_send>
}
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    

00801b0d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b13:	6a 00                	push   $0x0
  801b15:	ff 75 10             	pushl  0x10(%ebp)
  801b18:	ff 75 0c             	pushl  0xc(%ebp)
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1e:	ff 70 0c             	pushl  0xc(%eax)
  801b21:	e8 f1 02 00 00       	call   801e17 <nsipc_recv>
}
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b2e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b31:	52                   	push   %edx
  801b32:	50                   	push   %eax
  801b33:	e8 e4 f7 ff ff       	call   80131c <fd_lookup>
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	78 17                	js     801b56 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b42:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b48:	39 08                	cmp    %ecx,(%eax)
  801b4a:	75 05                	jne    801b51 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b4c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4f:	eb 05                	jmp    801b56 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b51:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	83 ec 1c             	sub    $0x1c,%esp
  801b60:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b65:	50                   	push   %eax
  801b66:	e8 62 f7 ff ff       	call   8012cd <fd_alloc>
  801b6b:	89 c3                	mov    %eax,%ebx
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	78 1b                	js     801b8f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b74:	83 ec 04             	sub    $0x4,%esp
  801b77:	68 07 04 00 00       	push   $0x407
  801b7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7f:	6a 00                	push   $0x0
  801b81:	e8 4a f1 ff ff       	call   800cd0 <sys_page_alloc>
  801b86:	89 c3                	mov    %eax,%ebx
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	79 10                	jns    801b9f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	56                   	push   %esi
  801b93:	e8 0e 02 00 00       	call   801da6 <nsipc_close>
		return r;
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	89 d8                	mov    %ebx,%eax
  801b9d:	eb 24                	jmp    801bc3 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b9f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bad:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bb4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	50                   	push   %eax
  801bbb:	e8 e6 f6 ff ff       	call   8012a6 <fd2num>
  801bc0:	83 c4 10             	add    $0x10,%esp
}
  801bc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc6:	5b                   	pop    %ebx
  801bc7:	5e                   	pop    %esi
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    

00801bca <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd3:	e8 50 ff ff ff       	call   801b28 <fd2sockid>
		return r;
  801bd8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	78 1f                	js     801bfd <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bde:	83 ec 04             	sub    $0x4,%esp
  801be1:	ff 75 10             	pushl  0x10(%ebp)
  801be4:	ff 75 0c             	pushl  0xc(%ebp)
  801be7:	50                   	push   %eax
  801be8:	e8 12 01 00 00       	call   801cff <nsipc_accept>
  801bed:	83 c4 10             	add    $0x10,%esp
		return r;
  801bf0:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	78 07                	js     801bfd <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bf6:	e8 5d ff ff ff       	call   801b58 <alloc_sockfd>
  801bfb:	89 c1                	mov    %eax,%ecx
}
  801bfd:	89 c8                	mov    %ecx,%eax
  801bff:	c9                   	leave  
  801c00:	c3                   	ret    

00801c01 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c07:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0a:	e8 19 ff ff ff       	call   801b28 <fd2sockid>
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	78 12                	js     801c25 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c13:	83 ec 04             	sub    $0x4,%esp
  801c16:	ff 75 10             	pushl  0x10(%ebp)
  801c19:	ff 75 0c             	pushl  0xc(%ebp)
  801c1c:	50                   	push   %eax
  801c1d:	e8 2d 01 00 00       	call   801d4f <nsipc_bind>
  801c22:	83 c4 10             	add    $0x10,%esp
}
  801c25:	c9                   	leave  
  801c26:	c3                   	ret    

00801c27 <shutdown>:

int
shutdown(int s, int how)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	e8 f3 fe ff ff       	call   801b28 <fd2sockid>
  801c35:	85 c0                	test   %eax,%eax
  801c37:	78 0f                	js     801c48 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c39:	83 ec 08             	sub    $0x8,%esp
  801c3c:	ff 75 0c             	pushl  0xc(%ebp)
  801c3f:	50                   	push   %eax
  801c40:	e8 3f 01 00 00       	call   801d84 <nsipc_shutdown>
  801c45:	83 c4 10             	add    $0x10,%esp
}
  801c48:	c9                   	leave  
  801c49:	c3                   	ret    

00801c4a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c50:	8b 45 08             	mov    0x8(%ebp),%eax
  801c53:	e8 d0 fe ff ff       	call   801b28 <fd2sockid>
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	78 12                	js     801c6e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c5c:	83 ec 04             	sub    $0x4,%esp
  801c5f:	ff 75 10             	pushl  0x10(%ebp)
  801c62:	ff 75 0c             	pushl  0xc(%ebp)
  801c65:	50                   	push   %eax
  801c66:	e8 55 01 00 00       	call   801dc0 <nsipc_connect>
  801c6b:	83 c4 10             	add    $0x10,%esp
}
  801c6e:	c9                   	leave  
  801c6f:	c3                   	ret    

00801c70 <listen>:

int
listen(int s, int backlog)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c76:	8b 45 08             	mov    0x8(%ebp),%eax
  801c79:	e8 aa fe ff ff       	call   801b28 <fd2sockid>
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	78 0f                	js     801c91 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c82:	83 ec 08             	sub    $0x8,%esp
  801c85:	ff 75 0c             	pushl  0xc(%ebp)
  801c88:	50                   	push   %eax
  801c89:	e8 67 01 00 00       	call   801df5 <nsipc_listen>
  801c8e:	83 c4 10             	add    $0x10,%esp
}
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    

00801c93 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c99:	ff 75 10             	pushl  0x10(%ebp)
  801c9c:	ff 75 0c             	pushl  0xc(%ebp)
  801c9f:	ff 75 08             	pushl  0x8(%ebp)
  801ca2:	e8 3a 02 00 00       	call   801ee1 <nsipc_socket>
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 05                	js     801cb3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801cae:	e8 a5 fe ff ff       	call   801b58 <alloc_sockfd>
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	53                   	push   %ebx
  801cb9:	83 ec 04             	sub    $0x4,%esp
  801cbc:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cbe:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801cc5:	75 12                	jne    801cd9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cc7:	83 ec 0c             	sub    $0xc,%esp
  801cca:	6a 02                	push   $0x2
  801ccc:	e8 9c f5 ff ff       	call   80126d <ipc_find_env>
  801cd1:	a3 08 40 80 00       	mov    %eax,0x804008
  801cd6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cd9:	6a 07                	push   $0x7
  801cdb:	68 00 60 80 00       	push   $0x806000
  801ce0:	53                   	push   %ebx
  801ce1:	ff 35 08 40 80 00    	pushl  0x804008
  801ce7:	e8 2d f5 ff ff       	call   801219 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cec:	83 c4 0c             	add    $0xc,%esp
  801cef:	6a 00                	push   $0x0
  801cf1:	6a 00                	push   $0x0
  801cf3:	6a 00                	push   $0x0
  801cf5:	e8 b8 f4 ff ff       	call   8011b2 <ipc_recv>
}
  801cfa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    

00801cff <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d0f:	8b 06                	mov    (%esi),%eax
  801d11:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	e8 95 ff ff ff       	call   801cb5 <nsipc>
  801d20:	89 c3                	mov    %eax,%ebx
  801d22:	85 c0                	test   %eax,%eax
  801d24:	78 20                	js     801d46 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d26:	83 ec 04             	sub    $0x4,%esp
  801d29:	ff 35 10 60 80 00    	pushl  0x806010
  801d2f:	68 00 60 80 00       	push   $0x806000
  801d34:	ff 75 0c             	pushl  0xc(%ebp)
  801d37:	e8 23 ed ff ff       	call   800a5f <memmove>
		*addrlen = ret->ret_addrlen;
  801d3c:	a1 10 60 80 00       	mov    0x806010,%eax
  801d41:	89 06                	mov    %eax,(%esi)
  801d43:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d46:	89 d8                	mov    %ebx,%eax
  801d48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4b:	5b                   	pop    %ebx
  801d4c:	5e                   	pop    %esi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	53                   	push   %ebx
  801d53:	83 ec 08             	sub    $0x8,%esp
  801d56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d59:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d61:	53                   	push   %ebx
  801d62:	ff 75 0c             	pushl  0xc(%ebp)
  801d65:	68 04 60 80 00       	push   $0x806004
  801d6a:	e8 f0 ec ff ff       	call   800a5f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d6f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d75:	b8 02 00 00 00       	mov    $0x2,%eax
  801d7a:	e8 36 ff ff ff       	call   801cb5 <nsipc>
}
  801d7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d82:	c9                   	leave  
  801d83:	c3                   	ret    

00801d84 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d95:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d9a:	b8 03 00 00 00       	mov    $0x3,%eax
  801d9f:	e8 11 ff ff ff       	call   801cb5 <nsipc>
}
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <nsipc_close>:

int
nsipc_close(int s)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dac:	8b 45 08             	mov    0x8(%ebp),%eax
  801daf:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801db4:	b8 04 00 00 00       	mov    $0x4,%eax
  801db9:	e8 f7 fe ff ff       	call   801cb5 <nsipc>
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dca:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dd2:	53                   	push   %ebx
  801dd3:	ff 75 0c             	pushl  0xc(%ebp)
  801dd6:	68 04 60 80 00       	push   $0x806004
  801ddb:	e8 7f ec ff ff       	call   800a5f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801de0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801de6:	b8 05 00 00 00       	mov    $0x5,%eax
  801deb:	e8 c5 fe ff ff       	call   801cb5 <nsipc>
}
  801df0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e06:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e0b:	b8 06 00 00 00       	mov    $0x6,%eax
  801e10:	e8 a0 fe ff ff       	call   801cb5 <nsipc>
}
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
  801e1c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e22:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e27:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e30:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e35:	b8 07 00 00 00       	mov    $0x7,%eax
  801e3a:	e8 76 fe ff ff       	call   801cb5 <nsipc>
  801e3f:	89 c3                	mov    %eax,%ebx
  801e41:	85 c0                	test   %eax,%eax
  801e43:	78 35                	js     801e7a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e45:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e4a:	7f 04                	jg     801e50 <nsipc_recv+0x39>
  801e4c:	39 c6                	cmp    %eax,%esi
  801e4e:	7d 16                	jge    801e66 <nsipc_recv+0x4f>
  801e50:	68 eb 2c 80 00       	push   $0x802ceb
  801e55:	68 b3 2c 80 00       	push   $0x802cb3
  801e5a:	6a 62                	push   $0x62
  801e5c:	68 00 2d 80 00       	push   $0x802d00
  801e61:	e8 09 e4 ff ff       	call   80026f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e66:	83 ec 04             	sub    $0x4,%esp
  801e69:	50                   	push   %eax
  801e6a:	68 00 60 80 00       	push   $0x806000
  801e6f:	ff 75 0c             	pushl  0xc(%ebp)
  801e72:	e8 e8 eb ff ff       	call   800a5f <memmove>
  801e77:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e7a:	89 d8                	mov    %ebx,%eax
  801e7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e7f:	5b                   	pop    %ebx
  801e80:	5e                   	pop    %esi
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    

00801e83 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	53                   	push   %ebx
  801e87:	83 ec 04             	sub    $0x4,%esp
  801e8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e90:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e95:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e9b:	7e 16                	jle    801eb3 <nsipc_send+0x30>
  801e9d:	68 0c 2d 80 00       	push   $0x802d0c
  801ea2:	68 b3 2c 80 00       	push   $0x802cb3
  801ea7:	6a 6d                	push   $0x6d
  801ea9:	68 00 2d 80 00       	push   $0x802d00
  801eae:	e8 bc e3 ff ff       	call   80026f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801eb3:	83 ec 04             	sub    $0x4,%esp
  801eb6:	53                   	push   %ebx
  801eb7:	ff 75 0c             	pushl  0xc(%ebp)
  801eba:	68 0c 60 80 00       	push   $0x80600c
  801ebf:	e8 9b eb ff ff       	call   800a5f <memmove>
	nsipcbuf.send.req_size = size;
  801ec4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801eca:	8b 45 14             	mov    0x14(%ebp),%eax
  801ecd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ed2:	b8 08 00 00 00       	mov    $0x8,%eax
  801ed7:	e8 d9 fd ff ff       	call   801cb5 <nsipc>
}
  801edc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801edf:	c9                   	leave  
  801ee0:	c3                   	ret    

00801ee1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eea:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef2:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ef7:	8b 45 10             	mov    0x10(%ebp),%eax
  801efa:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801eff:	b8 09 00 00 00       	mov    $0x9,%eax
  801f04:	e8 ac fd ff ff       	call   801cb5 <nsipc>
}
  801f09:	c9                   	leave  
  801f0a:	c3                   	ret    

00801f0b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	56                   	push   %esi
  801f0f:	53                   	push   %ebx
  801f10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f13:	83 ec 0c             	sub    $0xc,%esp
  801f16:	ff 75 08             	pushl  0x8(%ebp)
  801f19:	e8 98 f3 ff ff       	call   8012b6 <fd2data>
  801f1e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f20:	83 c4 08             	add    $0x8,%esp
  801f23:	68 18 2d 80 00       	push   $0x802d18
  801f28:	53                   	push   %ebx
  801f29:	e8 9f e9 ff ff       	call   8008cd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f2e:	8b 46 04             	mov    0x4(%esi),%eax
  801f31:	2b 06                	sub    (%esi),%eax
  801f33:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f39:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f40:	00 00 00 
	stat->st_dev = &devpipe;
  801f43:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f4a:	30 80 00 
	return 0;
}
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	53                   	push   %ebx
  801f5d:	83 ec 0c             	sub    $0xc,%esp
  801f60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f63:	53                   	push   %ebx
  801f64:	6a 00                	push   $0x0
  801f66:	e8 ea ed ff ff       	call   800d55 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f6b:	89 1c 24             	mov    %ebx,(%esp)
  801f6e:	e8 43 f3 ff ff       	call   8012b6 <fd2data>
  801f73:	83 c4 08             	add    $0x8,%esp
  801f76:	50                   	push   %eax
  801f77:	6a 00                	push   $0x0
  801f79:	e8 d7 ed ff ff       	call   800d55 <sys_page_unmap>
}
  801f7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f81:	c9                   	leave  
  801f82:	c3                   	ret    

00801f83 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	57                   	push   %edi
  801f87:	56                   	push   %esi
  801f88:	53                   	push   %ebx
  801f89:	83 ec 1c             	sub    $0x1c,%esp
  801f8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f8f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f91:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f96:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f99:	83 ec 0c             	sub    $0xc,%esp
  801f9c:	ff 75 e0             	pushl  -0x20(%ebp)
  801f9f:	e8 b1 04 00 00       	call   802455 <pageref>
  801fa4:	89 c3                	mov    %eax,%ebx
  801fa6:	89 3c 24             	mov    %edi,(%esp)
  801fa9:	e8 a7 04 00 00       	call   802455 <pageref>
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	39 c3                	cmp    %eax,%ebx
  801fb3:	0f 94 c1             	sete   %cl
  801fb6:	0f b6 c9             	movzbl %cl,%ecx
  801fb9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fbc:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801fc2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fc5:	39 ce                	cmp    %ecx,%esi
  801fc7:	74 1b                	je     801fe4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fc9:	39 c3                	cmp    %eax,%ebx
  801fcb:	75 c4                	jne    801f91 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fcd:	8b 42 58             	mov    0x58(%edx),%eax
  801fd0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fd3:	50                   	push   %eax
  801fd4:	56                   	push   %esi
  801fd5:	68 1f 2d 80 00       	push   $0x802d1f
  801fda:	e8 69 e3 ff ff       	call   800348 <cprintf>
  801fdf:	83 c4 10             	add    $0x10,%esp
  801fe2:	eb ad                	jmp    801f91 <_pipeisclosed+0xe>
	}
}
  801fe4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fe7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fea:	5b                   	pop    %ebx
  801feb:	5e                   	pop    %esi
  801fec:	5f                   	pop    %edi
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    

00801fef <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	57                   	push   %edi
  801ff3:	56                   	push   %esi
  801ff4:	53                   	push   %ebx
  801ff5:	83 ec 28             	sub    $0x28,%esp
  801ff8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ffb:	56                   	push   %esi
  801ffc:	e8 b5 f2 ff ff       	call   8012b6 <fd2data>
  802001:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	bf 00 00 00 00       	mov    $0x0,%edi
  80200b:	eb 4b                	jmp    802058 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80200d:	89 da                	mov    %ebx,%edx
  80200f:	89 f0                	mov    %esi,%eax
  802011:	e8 6d ff ff ff       	call   801f83 <_pipeisclosed>
  802016:	85 c0                	test   %eax,%eax
  802018:	75 48                	jne    802062 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80201a:	e8 92 ec ff ff       	call   800cb1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80201f:	8b 43 04             	mov    0x4(%ebx),%eax
  802022:	8b 0b                	mov    (%ebx),%ecx
  802024:	8d 51 20             	lea    0x20(%ecx),%edx
  802027:	39 d0                	cmp    %edx,%eax
  802029:	73 e2                	jae    80200d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80202b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80202e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802032:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802035:	89 c2                	mov    %eax,%edx
  802037:	c1 fa 1f             	sar    $0x1f,%edx
  80203a:	89 d1                	mov    %edx,%ecx
  80203c:	c1 e9 1b             	shr    $0x1b,%ecx
  80203f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802042:	83 e2 1f             	and    $0x1f,%edx
  802045:	29 ca                	sub    %ecx,%edx
  802047:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80204b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80204f:	83 c0 01             	add    $0x1,%eax
  802052:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802055:	83 c7 01             	add    $0x1,%edi
  802058:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80205b:	75 c2                	jne    80201f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80205d:	8b 45 10             	mov    0x10(%ebp),%eax
  802060:	eb 05                	jmp    802067 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802062:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802067:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206a:	5b                   	pop    %ebx
  80206b:	5e                   	pop    %esi
  80206c:	5f                   	pop    %edi
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    

0080206f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80206f:	55                   	push   %ebp
  802070:	89 e5                	mov    %esp,%ebp
  802072:	57                   	push   %edi
  802073:	56                   	push   %esi
  802074:	53                   	push   %ebx
  802075:	83 ec 18             	sub    $0x18,%esp
  802078:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80207b:	57                   	push   %edi
  80207c:	e8 35 f2 ff ff       	call   8012b6 <fd2data>
  802081:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	bb 00 00 00 00       	mov    $0x0,%ebx
  80208b:	eb 3d                	jmp    8020ca <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80208d:	85 db                	test   %ebx,%ebx
  80208f:	74 04                	je     802095 <devpipe_read+0x26>
				return i;
  802091:	89 d8                	mov    %ebx,%eax
  802093:	eb 44                	jmp    8020d9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802095:	89 f2                	mov    %esi,%edx
  802097:	89 f8                	mov    %edi,%eax
  802099:	e8 e5 fe ff ff       	call   801f83 <_pipeisclosed>
  80209e:	85 c0                	test   %eax,%eax
  8020a0:	75 32                	jne    8020d4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020a2:	e8 0a ec ff ff       	call   800cb1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020a7:	8b 06                	mov    (%esi),%eax
  8020a9:	3b 46 04             	cmp    0x4(%esi),%eax
  8020ac:	74 df                	je     80208d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020ae:	99                   	cltd   
  8020af:	c1 ea 1b             	shr    $0x1b,%edx
  8020b2:	01 d0                	add    %edx,%eax
  8020b4:	83 e0 1f             	and    $0x1f,%eax
  8020b7:	29 d0                	sub    %edx,%eax
  8020b9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020c1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020c4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c7:	83 c3 01             	add    $0x1,%ebx
  8020ca:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020cd:	75 d8                	jne    8020a7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d2:	eb 05                	jmp    8020d9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020d4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020dc:	5b                   	pop    %ebx
  8020dd:	5e                   	pop    %esi
  8020de:	5f                   	pop    %edi
  8020df:	5d                   	pop    %ebp
  8020e0:	c3                   	ret    

008020e1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020e1:	55                   	push   %ebp
  8020e2:	89 e5                	mov    %esp,%ebp
  8020e4:	56                   	push   %esi
  8020e5:	53                   	push   %ebx
  8020e6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ec:	50                   	push   %eax
  8020ed:	e8 db f1 ff ff       	call   8012cd <fd_alloc>
  8020f2:	83 c4 10             	add    $0x10,%esp
  8020f5:	89 c2                	mov    %eax,%edx
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	0f 88 2c 01 00 00    	js     80222b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ff:	83 ec 04             	sub    $0x4,%esp
  802102:	68 07 04 00 00       	push   $0x407
  802107:	ff 75 f4             	pushl  -0xc(%ebp)
  80210a:	6a 00                	push   $0x0
  80210c:	e8 bf eb ff ff       	call   800cd0 <sys_page_alloc>
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	89 c2                	mov    %eax,%edx
  802116:	85 c0                	test   %eax,%eax
  802118:	0f 88 0d 01 00 00    	js     80222b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80211e:	83 ec 0c             	sub    $0xc,%esp
  802121:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802124:	50                   	push   %eax
  802125:	e8 a3 f1 ff ff       	call   8012cd <fd_alloc>
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	85 c0                	test   %eax,%eax
  802131:	0f 88 e2 00 00 00    	js     802219 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802137:	83 ec 04             	sub    $0x4,%esp
  80213a:	68 07 04 00 00       	push   $0x407
  80213f:	ff 75 f0             	pushl  -0x10(%ebp)
  802142:	6a 00                	push   $0x0
  802144:	e8 87 eb ff ff       	call   800cd0 <sys_page_alloc>
  802149:	89 c3                	mov    %eax,%ebx
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	85 c0                	test   %eax,%eax
  802150:	0f 88 c3 00 00 00    	js     802219 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802156:	83 ec 0c             	sub    $0xc,%esp
  802159:	ff 75 f4             	pushl  -0xc(%ebp)
  80215c:	e8 55 f1 ff ff       	call   8012b6 <fd2data>
  802161:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802163:	83 c4 0c             	add    $0xc,%esp
  802166:	68 07 04 00 00       	push   $0x407
  80216b:	50                   	push   %eax
  80216c:	6a 00                	push   $0x0
  80216e:	e8 5d eb ff ff       	call   800cd0 <sys_page_alloc>
  802173:	89 c3                	mov    %eax,%ebx
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	85 c0                	test   %eax,%eax
  80217a:	0f 88 89 00 00 00    	js     802209 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802180:	83 ec 0c             	sub    $0xc,%esp
  802183:	ff 75 f0             	pushl  -0x10(%ebp)
  802186:	e8 2b f1 ff ff       	call   8012b6 <fd2data>
  80218b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802192:	50                   	push   %eax
  802193:	6a 00                	push   $0x0
  802195:	56                   	push   %esi
  802196:	6a 00                	push   $0x0
  802198:	e8 76 eb ff ff       	call   800d13 <sys_page_map>
  80219d:	89 c3                	mov    %eax,%ebx
  80219f:	83 c4 20             	add    $0x20,%esp
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	78 55                	js     8021fb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021a6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021af:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021bb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021d0:	83 ec 0c             	sub    $0xc,%esp
  8021d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d6:	e8 cb f0 ff ff       	call   8012a6 <fd2num>
  8021db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021de:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021e0:	83 c4 04             	add    $0x4,%esp
  8021e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8021e6:	e8 bb f0 ff ff       	call   8012a6 <fd2num>
  8021eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ee:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021f1:	83 c4 10             	add    $0x10,%esp
  8021f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8021f9:	eb 30                	jmp    80222b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021fb:	83 ec 08             	sub    $0x8,%esp
  8021fe:	56                   	push   %esi
  8021ff:	6a 00                	push   $0x0
  802201:	e8 4f eb ff ff       	call   800d55 <sys_page_unmap>
  802206:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802209:	83 ec 08             	sub    $0x8,%esp
  80220c:	ff 75 f0             	pushl  -0x10(%ebp)
  80220f:	6a 00                	push   $0x0
  802211:	e8 3f eb ff ff       	call   800d55 <sys_page_unmap>
  802216:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802219:	83 ec 08             	sub    $0x8,%esp
  80221c:	ff 75 f4             	pushl  -0xc(%ebp)
  80221f:	6a 00                	push   $0x0
  802221:	e8 2f eb ff ff       	call   800d55 <sys_page_unmap>
  802226:	83 c4 10             	add    $0x10,%esp
  802229:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5d                   	pop    %ebp
  802233:	c3                   	ret    

00802234 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802234:	55                   	push   %ebp
  802235:	89 e5                	mov    %esp,%ebp
  802237:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80223a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80223d:	50                   	push   %eax
  80223e:	ff 75 08             	pushl  0x8(%ebp)
  802241:	e8 d6 f0 ff ff       	call   80131c <fd_lookup>
  802246:	83 c4 10             	add    $0x10,%esp
  802249:	85 c0                	test   %eax,%eax
  80224b:	78 18                	js     802265 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80224d:	83 ec 0c             	sub    $0xc,%esp
  802250:	ff 75 f4             	pushl  -0xc(%ebp)
  802253:	e8 5e f0 ff ff       	call   8012b6 <fd2data>
	return _pipeisclosed(fd, p);
  802258:	89 c2                	mov    %eax,%edx
  80225a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225d:	e8 21 fd ff ff       	call   801f83 <_pipeisclosed>
  802262:	83 c4 10             	add    $0x10,%esp
}
  802265:	c9                   	leave  
  802266:	c3                   	ret    

00802267 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80226a:	b8 00 00 00 00       	mov    $0x0,%eax
  80226f:	5d                   	pop    %ebp
  802270:	c3                   	ret    

00802271 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802277:	68 37 2d 80 00       	push   $0x802d37
  80227c:	ff 75 0c             	pushl  0xc(%ebp)
  80227f:	e8 49 e6 ff ff       	call   8008cd <strcpy>
	return 0;
}
  802284:	b8 00 00 00 00       	mov    $0x0,%eax
  802289:	c9                   	leave  
  80228a:	c3                   	ret    

0080228b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	57                   	push   %edi
  80228f:	56                   	push   %esi
  802290:	53                   	push   %ebx
  802291:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802297:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80229c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022a2:	eb 2d                	jmp    8022d1 <devcons_write+0x46>
		m = n - tot;
  8022a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022a7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022a9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022ac:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022b1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022b4:	83 ec 04             	sub    $0x4,%esp
  8022b7:	53                   	push   %ebx
  8022b8:	03 45 0c             	add    0xc(%ebp),%eax
  8022bb:	50                   	push   %eax
  8022bc:	57                   	push   %edi
  8022bd:	e8 9d e7 ff ff       	call   800a5f <memmove>
		sys_cputs(buf, m);
  8022c2:	83 c4 08             	add    $0x8,%esp
  8022c5:	53                   	push   %ebx
  8022c6:	57                   	push   %edi
  8022c7:	e8 48 e9 ff ff       	call   800c14 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022cc:	01 de                	add    %ebx,%esi
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022d6:	72 cc                	jb     8022a4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022db:	5b                   	pop    %ebx
  8022dc:	5e                   	pop    %esi
  8022dd:	5f                   	pop    %edi
  8022de:	5d                   	pop    %ebp
  8022df:	c3                   	ret    

008022e0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
  8022e3:	83 ec 08             	sub    $0x8,%esp
  8022e6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ef:	74 2a                	je     80231b <devcons_read+0x3b>
  8022f1:	eb 05                	jmp    8022f8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022f3:	e8 b9 e9 ff ff       	call   800cb1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022f8:	e8 35 e9 ff ff       	call   800c32 <sys_cgetc>
  8022fd:	85 c0                	test   %eax,%eax
  8022ff:	74 f2                	je     8022f3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802301:	85 c0                	test   %eax,%eax
  802303:	78 16                	js     80231b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802305:	83 f8 04             	cmp    $0x4,%eax
  802308:	74 0c                	je     802316 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80230a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80230d:	88 02                	mov    %al,(%edx)
	return 1;
  80230f:	b8 01 00 00 00       	mov    $0x1,%eax
  802314:	eb 05                	jmp    80231b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802316:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80231b:	c9                   	leave  
  80231c:	c3                   	ret    

0080231d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80231d:	55                   	push   %ebp
  80231e:	89 e5                	mov    %esp,%ebp
  802320:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802323:	8b 45 08             	mov    0x8(%ebp),%eax
  802326:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802329:	6a 01                	push   $0x1
  80232b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80232e:	50                   	push   %eax
  80232f:	e8 e0 e8 ff ff       	call   800c14 <sys_cputs>
}
  802334:	83 c4 10             	add    $0x10,%esp
  802337:	c9                   	leave  
  802338:	c3                   	ret    

00802339 <getchar>:

int
getchar(void)
{
  802339:	55                   	push   %ebp
  80233a:	89 e5                	mov    %esp,%ebp
  80233c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80233f:	6a 01                	push   $0x1
  802341:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802344:	50                   	push   %eax
  802345:	6a 00                	push   $0x0
  802347:	e8 36 f2 ff ff       	call   801582 <read>
	if (r < 0)
  80234c:	83 c4 10             	add    $0x10,%esp
  80234f:	85 c0                	test   %eax,%eax
  802351:	78 0f                	js     802362 <getchar+0x29>
		return r;
	if (r < 1)
  802353:	85 c0                	test   %eax,%eax
  802355:	7e 06                	jle    80235d <getchar+0x24>
		return -E_EOF;
	return c;
  802357:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80235b:	eb 05                	jmp    802362 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80235d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802362:	c9                   	leave  
  802363:	c3                   	ret    

00802364 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802364:	55                   	push   %ebp
  802365:	89 e5                	mov    %esp,%ebp
  802367:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80236a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236d:	50                   	push   %eax
  80236e:	ff 75 08             	pushl  0x8(%ebp)
  802371:	e8 a6 ef ff ff       	call   80131c <fd_lookup>
  802376:	83 c4 10             	add    $0x10,%esp
  802379:	85 c0                	test   %eax,%eax
  80237b:	78 11                	js     80238e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80237d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802380:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802386:	39 10                	cmp    %edx,(%eax)
  802388:	0f 94 c0             	sete   %al
  80238b:	0f b6 c0             	movzbl %al,%eax
}
  80238e:	c9                   	leave  
  80238f:	c3                   	ret    

00802390 <opencons>:

int
opencons(void)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802399:	50                   	push   %eax
  80239a:	e8 2e ef ff ff       	call   8012cd <fd_alloc>
  80239f:	83 c4 10             	add    $0x10,%esp
		return r;
  8023a2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023a4:	85 c0                	test   %eax,%eax
  8023a6:	78 3e                	js     8023e6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023a8:	83 ec 04             	sub    $0x4,%esp
  8023ab:	68 07 04 00 00       	push   $0x407
  8023b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b3:	6a 00                	push   $0x0
  8023b5:	e8 16 e9 ff ff       	call   800cd0 <sys_page_alloc>
  8023ba:	83 c4 10             	add    $0x10,%esp
		return r;
  8023bd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023bf:	85 c0                	test   %eax,%eax
  8023c1:	78 23                	js     8023e6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023c3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023cc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023d8:	83 ec 0c             	sub    $0xc,%esp
  8023db:	50                   	push   %eax
  8023dc:	e8 c5 ee ff ff       	call   8012a6 <fd2num>
  8023e1:	89 c2                	mov    %eax,%edx
  8023e3:	83 c4 10             	add    $0x10,%esp
}
  8023e6:	89 d0                	mov    %edx,%eax
  8023e8:	c9                   	leave  
  8023e9:	c3                   	ret    

008023ea <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023ea:	55                   	push   %ebp
  8023eb:	89 e5                	mov    %esp,%ebp
  8023ed:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023f0:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023f7:	75 2e                	jne    802427 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8023f9:	e8 94 e8 ff ff       	call   800c92 <sys_getenvid>
  8023fe:	83 ec 04             	sub    $0x4,%esp
  802401:	68 07 0e 00 00       	push   $0xe07
  802406:	68 00 f0 bf ee       	push   $0xeebff000
  80240b:	50                   	push   %eax
  80240c:	e8 bf e8 ff ff       	call   800cd0 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802411:	e8 7c e8 ff ff       	call   800c92 <sys_getenvid>
  802416:	83 c4 08             	add    $0x8,%esp
  802419:	68 31 24 80 00       	push   $0x802431
  80241e:	50                   	push   %eax
  80241f:	e8 f7 e9 ff ff       	call   800e1b <sys_env_set_pgfault_upcall>
  802424:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802427:	8b 45 08             	mov    0x8(%ebp),%eax
  80242a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80242f:	c9                   	leave  
  802430:	c3                   	ret    

00802431 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802431:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802432:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802437:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802439:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80243c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802440:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802444:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802447:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80244a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80244b:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80244e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80244f:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802450:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802454:	c3                   	ret    

00802455 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80245b:	89 d0                	mov    %edx,%eax
  80245d:	c1 e8 16             	shr    $0x16,%eax
  802460:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802467:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80246c:	f6 c1 01             	test   $0x1,%cl
  80246f:	74 1d                	je     80248e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802471:	c1 ea 0c             	shr    $0xc,%edx
  802474:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80247b:	f6 c2 01             	test   $0x1,%dl
  80247e:	74 0e                	je     80248e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802480:	c1 ea 0c             	shr    $0xc,%edx
  802483:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80248a:	ef 
  80248b:	0f b7 c0             	movzwl %ax,%eax
}
  80248e:	5d                   	pop    %ebp
  80248f:	c3                   	ret    

00802490 <__udivdi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	53                   	push   %ebx
  802494:	83 ec 1c             	sub    $0x1c,%esp
  802497:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80249b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80249f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024a7:	85 f6                	test   %esi,%esi
  8024a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ad:	89 ca                	mov    %ecx,%edx
  8024af:	89 f8                	mov    %edi,%eax
  8024b1:	75 3d                	jne    8024f0 <__udivdi3+0x60>
  8024b3:	39 cf                	cmp    %ecx,%edi
  8024b5:	0f 87 c5 00 00 00    	ja     802580 <__udivdi3+0xf0>
  8024bb:	85 ff                	test   %edi,%edi
  8024bd:	89 fd                	mov    %edi,%ebp
  8024bf:	75 0b                	jne    8024cc <__udivdi3+0x3c>
  8024c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c6:	31 d2                	xor    %edx,%edx
  8024c8:	f7 f7                	div    %edi
  8024ca:	89 c5                	mov    %eax,%ebp
  8024cc:	89 c8                	mov    %ecx,%eax
  8024ce:	31 d2                	xor    %edx,%edx
  8024d0:	f7 f5                	div    %ebp
  8024d2:	89 c1                	mov    %eax,%ecx
  8024d4:	89 d8                	mov    %ebx,%eax
  8024d6:	89 cf                	mov    %ecx,%edi
  8024d8:	f7 f5                	div    %ebp
  8024da:	89 c3                	mov    %eax,%ebx
  8024dc:	89 d8                	mov    %ebx,%eax
  8024de:	89 fa                	mov    %edi,%edx
  8024e0:	83 c4 1c             	add    $0x1c,%esp
  8024e3:	5b                   	pop    %ebx
  8024e4:	5e                   	pop    %esi
  8024e5:	5f                   	pop    %edi
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    
  8024e8:	90                   	nop
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	39 ce                	cmp    %ecx,%esi
  8024f2:	77 74                	ja     802568 <__udivdi3+0xd8>
  8024f4:	0f bd fe             	bsr    %esi,%edi
  8024f7:	83 f7 1f             	xor    $0x1f,%edi
  8024fa:	0f 84 98 00 00 00    	je     802598 <__udivdi3+0x108>
  802500:	bb 20 00 00 00       	mov    $0x20,%ebx
  802505:	89 f9                	mov    %edi,%ecx
  802507:	89 c5                	mov    %eax,%ebp
  802509:	29 fb                	sub    %edi,%ebx
  80250b:	d3 e6                	shl    %cl,%esi
  80250d:	89 d9                	mov    %ebx,%ecx
  80250f:	d3 ed                	shr    %cl,%ebp
  802511:	89 f9                	mov    %edi,%ecx
  802513:	d3 e0                	shl    %cl,%eax
  802515:	09 ee                	or     %ebp,%esi
  802517:	89 d9                	mov    %ebx,%ecx
  802519:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80251d:	89 d5                	mov    %edx,%ebp
  80251f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802523:	d3 ed                	shr    %cl,%ebp
  802525:	89 f9                	mov    %edi,%ecx
  802527:	d3 e2                	shl    %cl,%edx
  802529:	89 d9                	mov    %ebx,%ecx
  80252b:	d3 e8                	shr    %cl,%eax
  80252d:	09 c2                	or     %eax,%edx
  80252f:	89 d0                	mov    %edx,%eax
  802531:	89 ea                	mov    %ebp,%edx
  802533:	f7 f6                	div    %esi
  802535:	89 d5                	mov    %edx,%ebp
  802537:	89 c3                	mov    %eax,%ebx
  802539:	f7 64 24 0c          	mull   0xc(%esp)
  80253d:	39 d5                	cmp    %edx,%ebp
  80253f:	72 10                	jb     802551 <__udivdi3+0xc1>
  802541:	8b 74 24 08          	mov    0x8(%esp),%esi
  802545:	89 f9                	mov    %edi,%ecx
  802547:	d3 e6                	shl    %cl,%esi
  802549:	39 c6                	cmp    %eax,%esi
  80254b:	73 07                	jae    802554 <__udivdi3+0xc4>
  80254d:	39 d5                	cmp    %edx,%ebp
  80254f:	75 03                	jne    802554 <__udivdi3+0xc4>
  802551:	83 eb 01             	sub    $0x1,%ebx
  802554:	31 ff                	xor    %edi,%edi
  802556:	89 d8                	mov    %ebx,%eax
  802558:	89 fa                	mov    %edi,%edx
  80255a:	83 c4 1c             	add    $0x1c,%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5f                   	pop    %edi
  802560:	5d                   	pop    %ebp
  802561:	c3                   	ret    
  802562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802568:	31 ff                	xor    %edi,%edi
  80256a:	31 db                	xor    %ebx,%ebx
  80256c:	89 d8                	mov    %ebx,%eax
  80256e:	89 fa                	mov    %edi,%edx
  802570:	83 c4 1c             	add    $0x1c,%esp
  802573:	5b                   	pop    %ebx
  802574:	5e                   	pop    %esi
  802575:	5f                   	pop    %edi
  802576:	5d                   	pop    %ebp
  802577:	c3                   	ret    
  802578:	90                   	nop
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	89 d8                	mov    %ebx,%eax
  802582:	f7 f7                	div    %edi
  802584:	31 ff                	xor    %edi,%edi
  802586:	89 c3                	mov    %eax,%ebx
  802588:	89 d8                	mov    %ebx,%eax
  80258a:	89 fa                	mov    %edi,%edx
  80258c:	83 c4 1c             	add    $0x1c,%esp
  80258f:	5b                   	pop    %ebx
  802590:	5e                   	pop    %esi
  802591:	5f                   	pop    %edi
  802592:	5d                   	pop    %ebp
  802593:	c3                   	ret    
  802594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802598:	39 ce                	cmp    %ecx,%esi
  80259a:	72 0c                	jb     8025a8 <__udivdi3+0x118>
  80259c:	31 db                	xor    %ebx,%ebx
  80259e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025a2:	0f 87 34 ff ff ff    	ja     8024dc <__udivdi3+0x4c>
  8025a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025ad:	e9 2a ff ff ff       	jmp    8024dc <__udivdi3+0x4c>
  8025b2:	66 90                	xchg   %ax,%ax
  8025b4:	66 90                	xchg   %ax,%ax
  8025b6:	66 90                	xchg   %ax,%ax
  8025b8:	66 90                	xchg   %ax,%ax
  8025ba:	66 90                	xchg   %ax,%ax
  8025bc:	66 90                	xchg   %ax,%ax
  8025be:	66 90                	xchg   %ax,%ax

008025c0 <__umoddi3>:
  8025c0:	55                   	push   %ebp
  8025c1:	57                   	push   %edi
  8025c2:	56                   	push   %esi
  8025c3:	53                   	push   %ebx
  8025c4:	83 ec 1c             	sub    $0x1c,%esp
  8025c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025d7:	85 d2                	test   %edx,%edx
  8025d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025e1:	89 f3                	mov    %esi,%ebx
  8025e3:	89 3c 24             	mov    %edi,(%esp)
  8025e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ea:	75 1c                	jne    802608 <__umoddi3+0x48>
  8025ec:	39 f7                	cmp    %esi,%edi
  8025ee:	76 50                	jbe    802640 <__umoddi3+0x80>
  8025f0:	89 c8                	mov    %ecx,%eax
  8025f2:	89 f2                	mov    %esi,%edx
  8025f4:	f7 f7                	div    %edi
  8025f6:	89 d0                	mov    %edx,%eax
  8025f8:	31 d2                	xor    %edx,%edx
  8025fa:	83 c4 1c             	add    $0x1c,%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    
  802602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802608:	39 f2                	cmp    %esi,%edx
  80260a:	89 d0                	mov    %edx,%eax
  80260c:	77 52                	ja     802660 <__umoddi3+0xa0>
  80260e:	0f bd ea             	bsr    %edx,%ebp
  802611:	83 f5 1f             	xor    $0x1f,%ebp
  802614:	75 5a                	jne    802670 <__umoddi3+0xb0>
  802616:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80261a:	0f 82 e0 00 00 00    	jb     802700 <__umoddi3+0x140>
  802620:	39 0c 24             	cmp    %ecx,(%esp)
  802623:	0f 86 d7 00 00 00    	jbe    802700 <__umoddi3+0x140>
  802629:	8b 44 24 08          	mov    0x8(%esp),%eax
  80262d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802631:	83 c4 1c             	add    $0x1c,%esp
  802634:	5b                   	pop    %ebx
  802635:	5e                   	pop    %esi
  802636:	5f                   	pop    %edi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	85 ff                	test   %edi,%edi
  802642:	89 fd                	mov    %edi,%ebp
  802644:	75 0b                	jne    802651 <__umoddi3+0x91>
  802646:	b8 01 00 00 00       	mov    $0x1,%eax
  80264b:	31 d2                	xor    %edx,%edx
  80264d:	f7 f7                	div    %edi
  80264f:	89 c5                	mov    %eax,%ebp
  802651:	89 f0                	mov    %esi,%eax
  802653:	31 d2                	xor    %edx,%edx
  802655:	f7 f5                	div    %ebp
  802657:	89 c8                	mov    %ecx,%eax
  802659:	f7 f5                	div    %ebp
  80265b:	89 d0                	mov    %edx,%eax
  80265d:	eb 99                	jmp    8025f8 <__umoddi3+0x38>
  80265f:	90                   	nop
  802660:	89 c8                	mov    %ecx,%eax
  802662:	89 f2                	mov    %esi,%edx
  802664:	83 c4 1c             	add    $0x1c,%esp
  802667:	5b                   	pop    %ebx
  802668:	5e                   	pop    %esi
  802669:	5f                   	pop    %edi
  80266a:	5d                   	pop    %ebp
  80266b:	c3                   	ret    
  80266c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802670:	8b 34 24             	mov    (%esp),%esi
  802673:	bf 20 00 00 00       	mov    $0x20,%edi
  802678:	89 e9                	mov    %ebp,%ecx
  80267a:	29 ef                	sub    %ebp,%edi
  80267c:	d3 e0                	shl    %cl,%eax
  80267e:	89 f9                	mov    %edi,%ecx
  802680:	89 f2                	mov    %esi,%edx
  802682:	d3 ea                	shr    %cl,%edx
  802684:	89 e9                	mov    %ebp,%ecx
  802686:	09 c2                	or     %eax,%edx
  802688:	89 d8                	mov    %ebx,%eax
  80268a:	89 14 24             	mov    %edx,(%esp)
  80268d:	89 f2                	mov    %esi,%edx
  80268f:	d3 e2                	shl    %cl,%edx
  802691:	89 f9                	mov    %edi,%ecx
  802693:	89 54 24 04          	mov    %edx,0x4(%esp)
  802697:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	89 e9                	mov    %ebp,%ecx
  80269f:	89 c6                	mov    %eax,%esi
  8026a1:	d3 e3                	shl    %cl,%ebx
  8026a3:	89 f9                	mov    %edi,%ecx
  8026a5:	89 d0                	mov    %edx,%eax
  8026a7:	d3 e8                	shr    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	09 d8                	or     %ebx,%eax
  8026ad:	89 d3                	mov    %edx,%ebx
  8026af:	89 f2                	mov    %esi,%edx
  8026b1:	f7 34 24             	divl   (%esp)
  8026b4:	89 d6                	mov    %edx,%esi
  8026b6:	d3 e3                	shl    %cl,%ebx
  8026b8:	f7 64 24 04          	mull   0x4(%esp)
  8026bc:	39 d6                	cmp    %edx,%esi
  8026be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026c2:	89 d1                	mov    %edx,%ecx
  8026c4:	89 c3                	mov    %eax,%ebx
  8026c6:	72 08                	jb     8026d0 <__umoddi3+0x110>
  8026c8:	75 11                	jne    8026db <__umoddi3+0x11b>
  8026ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ce:	73 0b                	jae    8026db <__umoddi3+0x11b>
  8026d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026d4:	1b 14 24             	sbb    (%esp),%edx
  8026d7:	89 d1                	mov    %edx,%ecx
  8026d9:	89 c3                	mov    %eax,%ebx
  8026db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026df:	29 da                	sub    %ebx,%edx
  8026e1:	19 ce                	sbb    %ecx,%esi
  8026e3:	89 f9                	mov    %edi,%ecx
  8026e5:	89 f0                	mov    %esi,%eax
  8026e7:	d3 e0                	shl    %cl,%eax
  8026e9:	89 e9                	mov    %ebp,%ecx
  8026eb:	d3 ea                	shr    %cl,%edx
  8026ed:	89 e9                	mov    %ebp,%ecx
  8026ef:	d3 ee                	shr    %cl,%esi
  8026f1:	09 d0                	or     %edx,%eax
  8026f3:	89 f2                	mov    %esi,%edx
  8026f5:	83 c4 1c             	add    $0x1c,%esp
  8026f8:	5b                   	pop    %ebx
  8026f9:	5e                   	pop    %esi
  8026fa:	5f                   	pop    %edi
  8026fb:	5d                   	pop    %ebp
  8026fc:	c3                   	ret    
  8026fd:	8d 76 00             	lea    0x0(%esi),%esi
  802700:	29 f9                	sub    %edi,%ecx
  802702:	19 d6                	sbb    %edx,%esi
  802704:	89 74 24 04          	mov    %esi,0x4(%esp)
  802708:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80270c:	e9 18 ff ff ff       	jmp    802629 <__umoddi3+0x69>
