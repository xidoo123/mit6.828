
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 fa 17 00 00       	call   801849 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 f0 17 00 00       	call   801849 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 e0 29 80 00 	movl   $0x8029e0,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 4b 2a 80 00 	movl   $0x802a4b,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 06 0e 00 00       	call   800e89 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 51 16 00 00       	call   8016e3 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 5a 2a 80 00       	push   $0x802a5a
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 d1 0d 00 00       	call   800e89 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 1c 16 00 00       	call   8016e3 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 55 2a 80 00       	push   $0x802a55
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 ac 14 00 00       	call   8015a7 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 a0 14 00 00       	call   8015a7 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 68 2a 80 00       	push   $0x802a68
  80011b:	e8 41 1a 00 00       	call   801b61 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 75 2a 80 00       	push   $0x802a75
  80012f:	6a 13                	push   $0x13
  800131:	68 8b 2a 80 00       	push   $0x802a8b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 84 22 00 00       	call   8023cb <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 9c 2a 80 00       	push   $0x802a9c
  800154:	6a 15                	push   $0x15
  800156:	68 8b 2a 80 00       	push   $0x802a8b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 04 2a 80 00       	push   $0x802a04
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 d8 10 00 00       	call   80124d <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 a5 2a 80 00       	push   $0x802aa5
  800182:	6a 1a                	push   $0x1a
  800184:	68 8b 2a 80 00       	push   $0x802a8b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 5a 14 00 00       	call   8015f7 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 4f 14 00 00       	call   8015f7 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 f7 13 00 00       	call   8015a7 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 ef 13 00 00       	call   8015a7 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 ae 2a 80 00       	push   $0x802aae
  8001bf:	68 72 2a 80 00       	push   $0x802a72
  8001c4:	68 b1 2a 80 00       	push   $0x802ab1
  8001c9:	e8 b4 1f 00 00       	call   802182 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 b5 2a 80 00       	push   $0x802ab5
  8001dd:	6a 21                	push   $0x21
  8001df:	68 8b 2a 80 00       	push   $0x802a8b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 b4 13 00 00       	call   8015a7 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 a8 13 00 00       	call   8015a7 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 4a 23 00 00       	call   802551 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 8f 13 00 00       	call   8015a7 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 87 13 00 00       	call   8015a7 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 bf 2a 80 00       	push   $0x802abf
  800230:	e8 2c 19 00 00       	call   801b61 <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 28 2a 80 00       	push   $0x802a28
  800245:	6a 2c                	push   $0x2c
  800247:	68 8b 2a 80 00       	push   $0x802a8b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 77 14 00 00       	call   8016e3 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 64 14 00 00       	call   8016e3 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 cd 2a 80 00       	push   $0x802acd
  80028c:	6a 33                	push   $0x33
  80028e:	68 8b 2a 80 00       	push   $0x802a8b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 e7 2a 80 00       	push   $0x802ae7
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 8b 2a 80 00       	push   $0x802a8b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 01 2b 80 00       	push   $0x802b01
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 16 2b 80 00       	push   $0x802b16
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 24 08 00 00       	call   800b42 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 78 09 00 00       	call   800cd4 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 23 0b 00 00       	call   800e89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 94 0b 00 00       	call   800f26 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 10 0b 00 00       	call   800ea7 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 bb 0a 00 00       	call   800e89 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 fd 12 00 00       	call   8016e3 <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 6d 10 00 00       	call   80147d <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 f5 0f 00 00       	call   80142e <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 f1 0a 00 00       	call   800f45 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 8c 0f 00 00       	call   801407 <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 73 0a 00 00       	call   800f07 <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 fd 10 00 00       	call   8015d2 <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 e7 09 00 00       	call   800ec6 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 10 0a 00 00       	call   800f07 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 2c 2b 80 00       	push   $0x802b2c
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 58 2a 80 00 	movl   $0x802a58,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 2f 09 00 00       	call   800e89 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 d4 08 00 00       	call   800e89 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 1b 21 00 00       	call   802740 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 08 22 00 00       	call   802870 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 4f 2b 80 00 	movsbl 0x802b4f(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 89 03 00 00    	je     800a99 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 07                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8d 47 01             	lea    0x1(%edi),%eax
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	0f b6 07             	movzbl (%edi),%eax
  800756:	0f b6 c8             	movzbl %al,%ecx
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 1a 03 00 00    	ja     800a7e <vprintfmt+0x38a>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 a0 2c 80 00 	jmp    *0x802ca0(,%eax,4)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800775:	eb d6                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800782:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800785:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800789:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80078c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078f:	83 fa 09             	cmp    $0x9,%edx
  800792:	77 39                	ja     8007cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800794:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800797:	eb e9                	jmp    800782 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 48 04             	lea    0x4(%eax),%ecx
  80079f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007aa:	eb 27                	jmp    8007d3 <vprintfmt+0xdf>
  8007ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	0f 49 c8             	cmovns %eax,%ecx
  8007b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	eb 8c                	jmp    80074d <vprintfmt+0x59>
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cb:	eb 80                	jmp    80074d <vprintfmt+0x59>
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d7:	0f 89 70 ff ff ff    	jns    80074d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ea:	e9 5e ff ff ff       	jmp    80074d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f5:	e9 53 ff ff ff       	jmp    80074d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	ff 30                	pushl  (%eax)
  800809:	ff d6                	call   *%esi
			break;
  80080b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800811:	e9 04 ff ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	99                   	cltd   
  800822:	31 d0                	xor    %edx,%eax
  800824:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800826:	83 f8 0f             	cmp    $0xf,%eax
  800829:	7f 0b                	jg     800836 <vprintfmt+0x142>
  80082b:	8b 14 85 00 2e 80 00 	mov    0x802e00(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 67 2b 80 00       	push   $0x802b67
  80083c:	53                   	push   %ebx
  80083d:	56                   	push   %esi
  80083e:	e8 94 fe ff ff       	call   8006d7 <printfmt>
  800843:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800849:	e9 cc fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80084e:	52                   	push   %edx
  80084f:	68 09 30 80 00       	push   $0x803009
  800854:	53                   	push   %ebx
  800855:	56                   	push   %esi
  800856:	e8 7c fe ff ff       	call   8006d7 <printfmt>
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800861:	e9 b4 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800871:	85 ff                	test   %edi,%edi
  800873:	b8 60 2b 80 00       	mov    $0x802b60,%eax
  800878:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80087f:	0f 8e 94 00 00 00    	jle    800919 <vprintfmt+0x225>
  800885:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800889:	0f 84 98 00 00 00    	je     800927 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	ff 75 d0             	pushl  -0x30(%ebp)
  800895:	57                   	push   %edi
  800896:	e8 86 02 00 00       	call   800b21 <strnlen>
  80089b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80089e:	29 c1                	sub    %eax,%ecx
  8008a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b2:	eb 0f                	jmp    8008c3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 ff                	test   %edi,%edi
  8008c5:	7f ed                	jg     8008b4 <vprintfmt+0x1c0>
  8008c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	0f 49 c1             	cmovns %ecx,%eax
  8008d7:	29 c1                	sub    %eax,%ecx
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	89 cb                	mov    %ecx,%ebx
  8008e4:	eb 4d                	jmp    800933 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ea:	74 1b                	je     800907 <vprintfmt+0x213>
  8008ec:	0f be c0             	movsbl %al,%eax
  8008ef:	83 e8 20             	sub    $0x20,%eax
  8008f2:	83 f8 5e             	cmp    $0x5e,%eax
  8008f5:	76 10                	jbe    800907 <vprintfmt+0x213>
					putch('?', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	6a 3f                	push   $0x3f
  8008ff:	ff 55 08             	call   *0x8(%ebp)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 0d                	jmp    800914 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	52                   	push   %edx
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	eb 1a                	jmp    800933 <vprintfmt+0x23f>
  800919:	89 75 08             	mov    %esi,0x8(%ebp)
  80091c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80091f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800925:	eb 0c                	jmp    800933 <vprintfmt+0x23f>
  800927:	89 75 08             	mov    %esi,0x8(%ebp)
  80092a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800933:	83 c7 01             	add    $0x1,%edi
  800936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093a:	0f be d0             	movsbl %al,%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 23                	je     800964 <vprintfmt+0x270>
  800941:	85 f6                	test   %esi,%esi
  800943:	78 a1                	js     8008e6 <vprintfmt+0x1f2>
  800945:	83 ee 01             	sub    $0x1,%esi
  800948:	79 9c                	jns    8008e6 <vprintfmt+0x1f2>
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	eb 18                	jmp    80096c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 20                	push   $0x20
  80095a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 08                	jmp    80096c <vprintfmt+0x278>
  800964:	89 df                	mov    %ebx,%edi
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f e4                	jg     800954 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 a2 fd ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800978:	83 fa 01             	cmp    $0x1,%edx
  80097b:	7e 16                	jle    800993 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 08             	lea    0x8(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 50 04             	mov    0x4(%eax),%edx
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800991:	eb 32                	jmp    8009c5 <vprintfmt+0x2d1>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 18                	je     8009af <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bd:	89 c1                	mov    %eax,%ecx
  8009bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d4:	79 74                	jns    800a4a <vprintfmt+0x356>
				putch('-', putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	53                   	push   %ebx
  8009da:	6a 2d                	push   $0x2d
  8009dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8009de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e4:	f7 d8                	neg    %eax
  8009e6:	83 d2 00             	adc    $0x0,%edx
  8009e9:	f7 da                	neg    %edx
  8009eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f3:	eb 55                	jmp    800a4a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f8:	e8 83 fc ff ff       	call   800680 <getuint>
			base = 10;
  8009fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a02:	eb 46                	jmp    800a4a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800a04:	8d 45 14             	lea    0x14(%ebp),%eax
  800a07:	e8 74 fc ff ff       	call   800680 <getuint>
			base = 8;
  800a0c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a11:	eb 37                	jmp    800a4a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 30                	push   $0x30
  800a19:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1b:	83 c4 08             	add    $0x8,%esp
  800a1e:	53                   	push   %ebx
  800a1f:	6a 78                	push   $0x78
  800a21:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8d 50 04             	lea    0x4(%eax),%edx
  800a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a33:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a36:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3b:	eb 0d                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a40:	e8 3b fc ff ff       	call   800680 <getuint>
			base = 16;
  800a45:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a51:	57                   	push   %edi
  800a52:	ff 75 e0             	pushl  -0x20(%ebp)
  800a55:	51                   	push   %ecx
  800a56:	52                   	push   %edx
  800a57:	50                   	push   %eax
  800a58:	89 da                	mov    %ebx,%edx
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	e8 70 fb ff ff       	call   8005d1 <printnum>
			break;
  800a61:	83 c4 20             	add    $0x20,%esp
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	e9 ae fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	51                   	push   %ecx
  800a71:	ff d6                	call   *%esi
			break;
  800a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a79:	e9 9c fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	53                   	push   %ebx
  800a82:	6a 25                	push   $0x25
  800a84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	eb 03                	jmp    800a8e <vprintfmt+0x39a>
  800a8b:	83 ef 01             	sub    $0x1,%edi
  800a8e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a92:	75 f7                	jne    800a8b <vprintfmt+0x397>
  800a94:	e9 81 fc ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 18             	sub    $0x18,%esp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	74 26                	je     800ae8 <vsnprintf+0x47>
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	7e 22                	jle    800ae8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac6:	ff 75 14             	pushl  0x14(%ebp)
  800ac9:	ff 75 10             	pushl  0x10(%ebp)
  800acc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800acf:	50                   	push   %eax
  800ad0:	68 ba 06 80 00       	push   $0x8006ba
  800ad5:	e8 1a fc ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800add:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	eb 05                	jmp    800aed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af8:	50                   	push   %eax
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 9a ff ff ff       	call   800aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	eb 03                	jmp    800b19 <strlen+0x10>
		n++;
  800b16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1d:	75 f7                	jne    800b16 <strlen+0xd>
		n++;
	return n;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	eb 03                	jmp    800b34 <strnlen+0x13>
		n++;
  800b31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	39 c2                	cmp    %eax,%edx
  800b36:	74 08                	je     800b40 <strnlen+0x1f>
  800b38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3c:	75 f3                	jne    800b31 <strnlen+0x10>
  800b3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5b:	84 db                	test   %bl,%bl
  800b5d:	75 ef                	jne    800b4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b69:	53                   	push   %ebx
  800b6a:	e8 9a ff ff ff       	call   800b09 <strlen>
  800b6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	01 d8                	add    %ebx,%eax
  800b77:	50                   	push   %eax
  800b78:	e8 c5 ff ff ff       	call   800b42 <strcpy>
	return dst;
}
  800b7d:	89 d8                	mov    %ebx,%eax
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	eb 0f                	jmp    800ba7 <strncpy+0x23>
		*dst++ = *src;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba1:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba7:	39 da                	cmp    %ebx,%edx
  800ba9:	75 ed                	jne    800b98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc1:	85 d2                	test   %edx,%edx
  800bc3:	74 21                	je     800be6 <strlcpy+0x35>
  800bc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc9:	89 f2                	mov    %esi,%edx
  800bcb:	eb 09                	jmp    800bd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd6:	39 c2                	cmp    %eax,%edx
  800bd8:	74 09                	je     800be3 <strlcpy+0x32>
  800bda:	0f b6 19             	movzbl (%ecx),%ebx
  800bdd:	84 db                	test   %bl,%bl
  800bdf:	75 ec                	jne    800bcd <strlcpy+0x1c>
  800be1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 03                	jmp    800c7a <strfind+0xf>
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7d:	38 ca                	cmp    %cl,%dl
  800c7f:	74 04                	je     800c85 <strfind+0x1a>
  800c81:	84 d2                	test   %dl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cbb:	89 d8                	mov    %ebx,%eax
  800cbd:	09 d0                	or     %edx,%eax
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d29:	c1 e9 02             	shr    $0x2,%ecx
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	ff 75 08             	pushl  0x8(%ebp)
  800d48:	e8 87 ff ff ff       	call   800cd4 <memmove>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5a:	89 c6                	mov    %eax,%esi
  800d5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	eb 1a                	jmp    800d7b <memcmp+0x2c>
		if (*s1 != *s2)
  800d61:	0f b6 08             	movzbl (%eax),%ecx
  800d64:	0f b6 1a             	movzbl (%edx),%ebx
  800d67:	38 d9                	cmp    %bl,%cl
  800d69:	74 0a                	je     800d75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6b:	0f b6 c1             	movzbl %cl,%eax
  800d6e:	0f b6 db             	movzbl %bl,%ebx
  800d71:	29 d8                	sub    %ebx,%eax
  800d73:	eb 0f                	jmp    800d84 <memcmp+0x35>
		s1++, s2++;
  800d75:	83 c0 01             	add    $0x1,%eax
  800d78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7b:	39 f0                	cmp    %esi,%eax
  800d7d:	75 e2                	jne    800d61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d94:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d98:	eb 0a                	jmp    800da4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9a:	0f b6 10             	movzbl (%eax),%edx
  800d9d:	39 da                	cmp    %ebx,%edx
  800d9f:	74 07                	je     800da8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da1:	83 c0 01             	add    $0x1,%eax
  800da4:	39 c8                	cmp    %ecx,%eax
  800da6:	72 f2                	jb     800d9a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da8:	5b                   	pop    %ebx
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db7:	eb 03                	jmp    800dbc <strtol+0x11>
		s++;
  800db9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbc:	0f b6 01             	movzbl (%ecx),%eax
  800dbf:	3c 20                	cmp    $0x20,%al
  800dc1:	74 f6                	je     800db9 <strtol+0xe>
  800dc3:	3c 09                	cmp    $0x9,%al
  800dc5:	74 f2                	je     800db9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc7:	3c 2b                	cmp    $0x2b,%al
  800dc9:	75 0a                	jne    800dd5 <strtol+0x2a>
		s++;
  800dcb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dce:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd3:	eb 11                	jmp    800de6 <strtol+0x3b>
  800dd5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dda:	3c 2d                	cmp    $0x2d,%al
  800ddc:	75 08                	jne    800de6 <strtol+0x3b>
		s++, neg = 1;
  800dde:	83 c1 01             	add    $0x1,%ecx
  800de1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dec:	75 15                	jne    800e03 <strtol+0x58>
  800dee:	80 39 30             	cmpb   $0x30,(%ecx)
  800df1:	75 10                	jne    800e03 <strtol+0x58>
  800df3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df7:	75 7c                	jne    800e75 <strtol+0xca>
		s += 2, base = 16;
  800df9:	83 c1 02             	add    $0x2,%ecx
  800dfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e01:	eb 16                	jmp    800e19 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	75 12                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e07:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e0f:	75 08                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
  800e11:	83 c1 01             	add    $0x1,%ecx
  800e14:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e21:	0f b6 11             	movzbl (%ecx),%edx
  800e24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e27:	89 f3                	mov    %esi,%ebx
  800e29:	80 fb 09             	cmp    $0x9,%bl
  800e2c:	77 08                	ja     800e36 <strtol+0x8b>
			dig = *s - '0';
  800e2e:	0f be d2             	movsbl %dl,%edx
  800e31:	83 ea 30             	sub    $0x30,%edx
  800e34:	eb 22                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e36:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e39:	89 f3                	mov    %esi,%ebx
  800e3b:	80 fb 19             	cmp    $0x19,%bl
  800e3e:	77 08                	ja     800e48 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e40:	0f be d2             	movsbl %dl,%edx
  800e43:	83 ea 57             	sub    $0x57,%edx
  800e46:	eb 10                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e48:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4b:	89 f3                	mov    %esi,%ebx
  800e4d:	80 fb 19             	cmp    $0x19,%bl
  800e50:	77 16                	ja     800e68 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e52:	0f be d2             	movsbl %dl,%edx
  800e55:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5b:	7d 0b                	jge    800e68 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e5d:	83 c1 01             	add    $0x1,%ecx
  800e60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e64:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e66:	eb b9                	jmp    800e21 <strtol+0x76>

	if (endptr)
  800e68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6c:	74 0d                	je     800e7b <strtol+0xd0>
		*endptr = (char *) s;
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	89 0e                	mov    %ecx,(%esi)
  800e73:	eb 06                	jmp    800e7b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e75:	85 db                	test   %ebx,%ebx
  800e77:	74 98                	je     800e11 <strtol+0x66>
  800e79:	eb 9e                	jmp    800e19 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	f7 da                	neg    %edx
  800e7f:	85 ff                	test   %edi,%edi
  800e81:	0f 45 c2             	cmovne %edx,%eax
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	89 d1                	mov    %edx,%ecx
  800eb9:	89 d3                	mov    %edx,%ebx
  800ebb:	89 d7                	mov    %edx,%edi
  800ebd:	89 d6                	mov    %edx,%esi
  800ebf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 03                	push   $0x3
  800eee:	68 5f 2e 80 00       	push   $0x802e5f
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 7c 2e 80 00       	push   $0x802e7c
  800efa:	e8 e5 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f12:	b8 02 00 00 00       	mov    $0x2,%eax
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 d3                	mov    %edx,%ebx
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 d6                	mov    %edx,%esi
  800f1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_yield>:

void
sys_yield(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 04 00 00 00       	mov    $0x4,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	89 f7                	mov    %esi,%edi
  800f63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 17                	jle    800f80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	50                   	push   %eax
  800f6d:	6a 04                	push   $0x4
  800f6f:	68 5f 2e 80 00       	push   $0x802e5f
  800f74:	6a 23                	push   $0x23
  800f76:	68 7c 2e 80 00       	push   $0x802e7c
  800f7b:	e8 64 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	b8 05 00 00 00       	mov    $0x5,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa2:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 17                	jle    800fc2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	50                   	push   %eax
  800faf:	6a 05                	push   $0x5
  800fb1:	68 5f 2e 80 00       	push   $0x802e5f
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 7c 2e 80 00       	push   $0x802e7c
  800fbd:	e8 22 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 df                	mov    %ebx,%edi
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7e 17                	jle    801004 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	50                   	push   %eax
  800ff1:	6a 06                	push   $0x6
  800ff3:	68 5f 2e 80 00       	push   $0x802e5f
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 7c 2e 80 00       	push   $0x802e7c
  800fff:	e8 e0 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101a:	b8 08 00 00 00       	mov    $0x8,%eax
  80101f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	89 df                	mov    %ebx,%edi
  801027:	89 de                	mov    %ebx,%esi
  801029:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 17                	jle    801046 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	6a 08                	push   $0x8
  801035:	68 5f 2e 80 00       	push   $0x802e5f
  80103a:	6a 23                	push   $0x23
  80103c:	68 7c 2e 80 00       	push   $0x802e7c
  801041:	e8 9e f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105c:	b8 09 00 00 00       	mov    $0x9,%eax
  801061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 df                	mov    %ebx,%edi
  801069:	89 de                	mov    %ebx,%esi
  80106b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 09                	push   $0x9
  801077:	68 5f 2e 80 00       	push   $0x802e5f
  80107c:	6a 23                	push   $0x23
  80107e:	68 7c 2e 80 00       	push   $0x802e7c
  801083:	e8 5c f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 df                	mov    %ebx,%edi
  8010ab:	89 de                	mov    %ebx,%esi
  8010ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 17                	jle    8010ca <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 0a                	push   $0xa
  8010b9:	68 5f 2e 80 00       	push   $0x802e5f
  8010be:	6a 23                	push   $0x23
  8010c0:	68 7c 2e 80 00       	push   $0x802e7c
  8010c5:	e8 1a f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	be 00 00 00 00       	mov    $0x0,%esi
  8010dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ee:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801103:	b8 0d 00 00 00       	mov    $0xd,%eax
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 cb                	mov    %ecx,%ebx
  80110d:	89 cf                	mov    %ecx,%edi
  80110f:	89 ce                	mov    %ecx,%esi
  801111:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 0d                	push   $0xd
  80111d:	68 5f 2e 80 00       	push   $0x802e5f
  801122:	6a 23                	push   $0x23
  801124:	68 7c 2e 80 00       	push   $0x802e7c
  801129:	e8 b6 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	8b 75 08             	mov    0x8(%ebp),%esi
	void *addr = (void *) utf->utf_fault_va;
  801142:	8b 1e                	mov    (%esi),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  801144:	f6 46 04 02          	testb  $0x2,0x4(%esi)
  801148:	75 25                	jne    80116f <pgfault+0x39>
  80114a:	89 d8                	mov    %ebx,%eax
  80114c:	c1 e8 0c             	shr    $0xc,%eax
  80114f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801156:	f6 c4 08             	test   $0x8,%ah
  801159:	75 14                	jne    80116f <pgfault+0x39>
		panic("pgfault: not due to a write or a COW page");
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	68 8c 2e 80 00       	push   $0x802e8c
  801163:	6a 1e                	push   $0x1e
  801165:	68 20 2f 80 00       	push   $0x802f20
  80116a:	e8 75 f3 ff ff       	call   8004e4 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  80116f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  801175:	e8 8d fd ff ff       	call   800f07 <sys_getenvid>
  80117a:	89 c7                	mov    %eax,%edi

	if ( (uint32_t)addr ==  0xeebfd000) {
  80117c:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801182:	75 31                	jne    8011b5 <pgfault+0x7f>
		cprintf("[hit %e]\n", utf->utf_err);
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	ff 76 04             	pushl  0x4(%esi)
  80118a:	68 2b 2f 80 00       	push   $0x802f2b
  80118f:	e8 29 f4 ff ff       	call   8005bd <cprintf>
		cprintf("[hit 0x%x]\n", utf->utf_eip);
  801194:	83 c4 08             	add    $0x8,%esp
  801197:	ff 76 28             	pushl  0x28(%esi)
  80119a:	68 35 2f 80 00       	push   $0x802f35
  80119f:	e8 19 f4 ff ff       	call   8005bd <cprintf>
		cprintf("[hit %d]\n", envid);
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	57                   	push   %edi
  8011a8:	68 41 2f 80 00       	push   $0x802f41
  8011ad:	e8 0b f4 ff ff       	call   8005bd <cprintf>
  8011b2:	83 c4 10             	add    $0x10,%esp
	}

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	6a 07                	push   $0x7
  8011ba:	68 00 f0 7f 00       	push   $0x7ff000
  8011bf:	57                   	push   %edi
  8011c0:	e8 80 fd ff ff       	call   800f45 <sys_page_alloc>
	if (r < 0)
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	79 12                	jns    8011de <pgfault+0xa8>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  8011cc:	50                   	push   %eax
  8011cd:	68 b8 2e 80 00       	push   $0x802eb8
  8011d2:	6a 39                	push   $0x39
  8011d4:	68 20 2f 80 00       	push   $0x802f20
  8011d9:	e8 06 f3 ff ff       	call   8004e4 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	68 00 10 00 00       	push   $0x1000
  8011e6:	53                   	push   %ebx
  8011e7:	68 00 f0 7f 00       	push   $0x7ff000
  8011ec:	e8 4b fb ff ff       	call   800d3c <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  8011f1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8011f8:	53                   	push   %ebx
  8011f9:	57                   	push   %edi
  8011fa:	68 00 f0 7f 00       	push   $0x7ff000
  8011ff:	57                   	push   %edi
  801200:	e8 83 fd ff ff       	call   800f88 <sys_page_map>
	if (r < 0)
  801205:	83 c4 20             	add    $0x20,%esp
  801208:	85 c0                	test   %eax,%eax
  80120a:	79 12                	jns    80121e <pgfault+0xe8>
		panic("pgfault: sys_page_map failed: %e\n", r);
  80120c:	50                   	push   %eax
  80120d:	68 dc 2e 80 00       	push   $0x802edc
  801212:	6a 41                	push   $0x41
  801214:	68 20 2f 80 00       	push   $0x802f20
  801219:	e8 c6 f2 ff ff       	call   8004e4 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  80121e:	83 ec 08             	sub    $0x8,%esp
  801221:	68 00 f0 7f 00       	push   $0x7ff000
  801226:	57                   	push   %edi
  801227:	e8 9e fd ff ff       	call   800fca <sys_page_unmap>
	if (r < 0)
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	79 12                	jns    801245 <pgfault+0x10f>
        panic("pgfault: page unmap failed: %e\n", r);
  801233:	50                   	push   %eax
  801234:	68 00 2f 80 00       	push   $0x802f00
  801239:	6a 46                	push   $0x46
  80123b:	68 20 2f 80 00       	push   $0x802f20
  801240:	e8 9f f2 ff ff       	call   8004e4 <_panic>
}
  801245:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801248:	5b                   	pop    %ebx
  801249:	5e                   	pop    %esi
  80124a:	5f                   	pop    %edi
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	57                   	push   %edi
  801251:	56                   	push   %esi
  801252:	53                   	push   %ebx
  801253:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  801256:	68 36 11 80 00       	push   $0x801136
  80125b:	e8 40 13 00 00       	call   8025a0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801260:	b8 07 00 00 00       	mov    $0x7,%eax
  801265:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	0f 88 67 01 00 00    	js     8013d9 <fork+0x18c>
  801272:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801277:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80127c:	85 c0                	test   %eax,%eax
  80127e:	75 21                	jne    8012a1 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801280:	e8 82 fc ff ff       	call   800f07 <sys_getenvid>
  801285:	25 ff 03 00 00       	and    $0x3ff,%eax
  80128a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80128d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801292:	a3 04 50 80 00       	mov    %eax,0x805004
        return 0;
  801297:	ba 00 00 00 00       	mov    $0x0,%edx
  80129c:	e9 42 01 00 00       	jmp    8013e3 <fork+0x196>
  8012a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a4:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8012a6:	89 d8                	mov    %ebx,%eax
  8012a8:	c1 e8 16             	shr    $0x16,%eax
  8012ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b2:	a8 01                	test   $0x1,%al
  8012b4:	0f 84 c0 00 00 00    	je     80137a <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  8012ba:	89 d8                	mov    %ebx,%eax
  8012bc:	c1 e8 0c             	shr    $0xc,%eax
  8012bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012c6:	f6 c2 01             	test   $0x1,%dl
  8012c9:	0f 84 ab 00 00 00    	je     80137a <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  8012cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d6:	a9 02 08 00 00       	test   $0x802,%eax
  8012db:	0f 84 99 00 00 00    	je     80137a <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  8012e1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012e8:	f6 c4 04             	test   $0x4,%ah
  8012eb:	74 17                	je     801304 <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	68 07 0e 00 00       	push   $0xe07
  8012f5:	53                   	push   %ebx
  8012f6:	57                   	push   %edi
  8012f7:	53                   	push   %ebx
  8012f8:	6a 00                	push   $0x0
  8012fa:	e8 89 fc ff ff       	call   800f88 <sys_page_map>
  8012ff:	83 c4 20             	add    $0x20,%esp
  801302:	eb 76                	jmp    80137a <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801304:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80130b:	a8 02                	test   $0x2,%al
  80130d:	75 0c                	jne    80131b <fork+0xce>
  80130f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801316:	f6 c4 08             	test   $0x8,%ah
  801319:	74 3f                	je     80135a <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	68 05 08 00 00       	push   $0x805
  801323:	53                   	push   %ebx
  801324:	57                   	push   %edi
  801325:	53                   	push   %ebx
  801326:	6a 00                	push   $0x0
  801328:	e8 5b fc ff ff       	call   800f88 <sys_page_map>
		if (r < 0)
  80132d:	83 c4 20             	add    $0x20,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	0f 88 a5 00 00 00    	js     8013dd <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	68 05 08 00 00       	push   $0x805
  801340:	53                   	push   %ebx
  801341:	6a 00                	push   $0x0
  801343:	53                   	push   %ebx
  801344:	6a 00                	push   $0x0
  801346:	e8 3d fc ff ff       	call   800f88 <sys_page_map>
  80134b:	83 c4 20             	add    $0x20,%esp
  80134e:	85 c0                	test   %eax,%eax
  801350:	b9 00 00 00 00       	mov    $0x0,%ecx
  801355:	0f 4f c1             	cmovg  %ecx,%eax
  801358:	eb 1c                	jmp    801376 <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	6a 05                	push   $0x5
  80135f:	53                   	push   %ebx
  801360:	57                   	push   %edi
  801361:	53                   	push   %ebx
  801362:	6a 00                	push   $0x0
  801364:	e8 1f fc ff ff       	call   800f88 <sys_page_map>
  801369:	83 c4 20             	add    $0x20,%esp
  80136c:	85 c0                	test   %eax,%eax
  80136e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801373:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801376:	85 c0                	test   %eax,%eax
  801378:	78 67                	js     8013e1 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80137a:	83 c6 01             	add    $0x1,%esi
  80137d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801383:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801389:	0f 85 17 ff ff ff    	jne    8012a6 <fork+0x59>
  80138f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801392:	83 ec 04             	sub    $0x4,%esp
  801395:	6a 07                	push   $0x7
  801397:	68 00 f0 bf ee       	push   $0xeebff000
  80139c:	57                   	push   %edi
  80139d:	e8 a3 fb ff ff       	call   800f45 <sys_page_alloc>
	if (r < 0)
  8013a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8013a5:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 38                	js     8013e3 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	68 e7 25 80 00       	push   $0x8025e7
  8013b3:	57                   	push   %edi
  8013b4:	e8 d7 fc ff ff       	call   801090 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8013b9:	83 c4 10             	add    $0x10,%esp
		return r;
  8013bc:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 21                	js     8013e3 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	6a 02                	push   $0x2
  8013c7:	57                   	push   %edi
  8013c8:	e8 3f fc ff ff       	call   80100c <sys_env_set_status>
	if (r < 0)
  8013cd:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	0f 48 f8             	cmovs  %eax,%edi
  8013d5:	89 fa                	mov    %edi,%edx
  8013d7:	eb 0a                	jmp    8013e3 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	eb 06                	jmp    8013e3 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	eb 02                	jmp    8013e3 <fork+0x196>
  8013e1:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8013e3:	89 d0                	mov    %edx,%eax
  8013e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5f                   	pop    %edi
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <sfork>:

// Challenge!
int
sfork(void)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8013f3:	68 4b 2f 80 00       	push   $0x802f4b
  8013f8:	68 ce 00 00 00       	push   $0xce
  8013fd:	68 20 2f 80 00       	push   $0x802f20
  801402:	e8 dd f0 ff ff       	call   8004e4 <_panic>

00801407 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80140a:	8b 45 08             	mov    0x8(%ebp),%eax
  80140d:	05 00 00 00 30       	add    $0x30000000,%eax
  801412:	c1 e8 0c             	shr    $0xc,%eax
}
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
  80141d:	05 00 00 00 30       	add    $0x30000000,%eax
  801422:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801427:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801434:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801439:	89 c2                	mov    %eax,%edx
  80143b:	c1 ea 16             	shr    $0x16,%edx
  80143e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801445:	f6 c2 01             	test   $0x1,%dl
  801448:	74 11                	je     80145b <fd_alloc+0x2d>
  80144a:	89 c2                	mov    %eax,%edx
  80144c:	c1 ea 0c             	shr    $0xc,%edx
  80144f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801456:	f6 c2 01             	test   $0x1,%dl
  801459:	75 09                	jne    801464 <fd_alloc+0x36>
			*fd_store = fd;
  80145b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80145d:	b8 00 00 00 00       	mov    $0x0,%eax
  801462:	eb 17                	jmp    80147b <fd_alloc+0x4d>
  801464:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801469:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80146e:	75 c9                	jne    801439 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801470:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801476:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80147b:	5d                   	pop    %ebp
  80147c:	c3                   	ret    

0080147d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801483:	83 f8 1f             	cmp    $0x1f,%eax
  801486:	77 36                	ja     8014be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801488:	c1 e0 0c             	shl    $0xc,%eax
  80148b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801490:	89 c2                	mov    %eax,%edx
  801492:	c1 ea 16             	shr    $0x16,%edx
  801495:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80149c:	f6 c2 01             	test   $0x1,%dl
  80149f:	74 24                	je     8014c5 <fd_lookup+0x48>
  8014a1:	89 c2                	mov    %eax,%edx
  8014a3:	c1 ea 0c             	shr    $0xc,%edx
  8014a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ad:	f6 c2 01             	test   $0x1,%dl
  8014b0:	74 1a                	je     8014cc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b5:	89 02                	mov    %eax,(%edx)
	return 0;
  8014b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bc:	eb 13                	jmp    8014d1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c3:	eb 0c                	jmp    8014d1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ca:	eb 05                	jmp    8014d1 <fd_lookup+0x54>
  8014cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014d1:	5d                   	pop    %ebp
  8014d2:	c3                   	ret    

008014d3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014dc:	ba e0 2f 80 00       	mov    $0x802fe0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014e1:	eb 13                	jmp    8014f6 <dev_lookup+0x23>
  8014e3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014e6:	39 08                	cmp    %ecx,(%eax)
  8014e8:	75 0c                	jne    8014f6 <dev_lookup+0x23>
			*dev = devtab[i];
  8014ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ed:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f4:	eb 2e                	jmp    801524 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014f6:	8b 02                	mov    (%edx),%eax
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	75 e7                	jne    8014e3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014fc:	a1 04 50 80 00       	mov    0x805004,%eax
  801501:	8b 40 48             	mov    0x48(%eax),%eax
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	51                   	push   %ecx
  801508:	50                   	push   %eax
  801509:	68 64 2f 80 00       	push   $0x802f64
  80150e:	e8 aa f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  801513:	8b 45 0c             	mov    0xc(%ebp),%eax
  801516:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	56                   	push   %esi
  80152a:	53                   	push   %ebx
  80152b:	83 ec 10             	sub    $0x10,%esp
  80152e:	8b 75 08             	mov    0x8(%ebp),%esi
  801531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801534:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801537:	50                   	push   %eax
  801538:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80153e:	c1 e8 0c             	shr    $0xc,%eax
  801541:	50                   	push   %eax
  801542:	e8 36 ff ff ff       	call   80147d <fd_lookup>
  801547:	83 c4 08             	add    $0x8,%esp
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 05                	js     801553 <fd_close+0x2d>
	    || fd != fd2)
  80154e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801551:	74 0c                	je     80155f <fd_close+0x39>
		return (must_exist ? r : 0);
  801553:	84 db                	test   %bl,%bl
  801555:	ba 00 00 00 00       	mov    $0x0,%edx
  80155a:	0f 44 c2             	cmove  %edx,%eax
  80155d:	eb 41                	jmp    8015a0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	ff 36                	pushl  (%esi)
  801568:	e8 66 ff ff ff       	call   8014d3 <dev_lookup>
  80156d:	89 c3                	mov    %eax,%ebx
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	78 1a                	js     801590 <fd_close+0x6a>
		if (dev->dev_close)
  801576:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801579:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80157c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801581:	85 c0                	test   %eax,%eax
  801583:	74 0b                	je     801590 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801585:	83 ec 0c             	sub    $0xc,%esp
  801588:	56                   	push   %esi
  801589:	ff d0                	call   *%eax
  80158b:	89 c3                	mov    %eax,%ebx
  80158d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801590:	83 ec 08             	sub    $0x8,%esp
  801593:	56                   	push   %esi
  801594:	6a 00                	push   $0x0
  801596:	e8 2f fa ff ff       	call   800fca <sys_page_unmap>
	return r;
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	89 d8                	mov    %ebx,%eax
}
  8015a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a3:	5b                   	pop    %ebx
  8015a4:	5e                   	pop    %esi
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    

008015a7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	ff 75 08             	pushl  0x8(%ebp)
  8015b4:	e8 c4 fe ff ff       	call   80147d <fd_lookup>
  8015b9:	83 c4 08             	add    $0x8,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 10                	js     8015d0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	6a 01                	push   $0x1
  8015c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c8:	e8 59 ff ff ff       	call   801526 <fd_close>
  8015cd:	83 c4 10             	add    $0x10,%esp
}
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <close_all>:

void
close_all(void)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	53                   	push   %ebx
  8015e2:	e8 c0 ff ff ff       	call   8015a7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015e7:	83 c3 01             	add    $0x1,%ebx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	83 fb 20             	cmp    $0x20,%ebx
  8015f0:	75 ec                	jne    8015de <close_all+0xc>
		close(i);
}
  8015f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f5:	c9                   	leave  
  8015f6:	c3                   	ret    

008015f7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	57                   	push   %edi
  8015fb:	56                   	push   %esi
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 2c             	sub    $0x2c,%esp
  801600:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801603:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	ff 75 08             	pushl  0x8(%ebp)
  80160a:	e8 6e fe ff ff       	call   80147d <fd_lookup>
  80160f:	83 c4 08             	add    $0x8,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	0f 88 c1 00 00 00    	js     8016db <dup+0xe4>
		return r;
	close(newfdnum);
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	56                   	push   %esi
  80161e:	e8 84 ff ff ff       	call   8015a7 <close>

	newfd = INDEX2FD(newfdnum);
  801623:	89 f3                	mov    %esi,%ebx
  801625:	c1 e3 0c             	shl    $0xc,%ebx
  801628:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80162e:	83 c4 04             	add    $0x4,%esp
  801631:	ff 75 e4             	pushl  -0x1c(%ebp)
  801634:	e8 de fd ff ff       	call   801417 <fd2data>
  801639:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80163b:	89 1c 24             	mov    %ebx,(%esp)
  80163e:	e8 d4 fd ff ff       	call   801417 <fd2data>
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801649:	89 f8                	mov    %edi,%eax
  80164b:	c1 e8 16             	shr    $0x16,%eax
  80164e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801655:	a8 01                	test   $0x1,%al
  801657:	74 37                	je     801690 <dup+0x99>
  801659:	89 f8                	mov    %edi,%eax
  80165b:	c1 e8 0c             	shr    $0xc,%eax
  80165e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801665:	f6 c2 01             	test   $0x1,%dl
  801668:	74 26                	je     801690 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80166a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801671:	83 ec 0c             	sub    $0xc,%esp
  801674:	25 07 0e 00 00       	and    $0xe07,%eax
  801679:	50                   	push   %eax
  80167a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80167d:	6a 00                	push   $0x0
  80167f:	57                   	push   %edi
  801680:	6a 00                	push   $0x0
  801682:	e8 01 f9 ff ff       	call   800f88 <sys_page_map>
  801687:	89 c7                	mov    %eax,%edi
  801689:	83 c4 20             	add    $0x20,%esp
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 2e                	js     8016be <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801690:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801693:	89 d0                	mov    %edx,%eax
  801695:	c1 e8 0c             	shr    $0xc,%eax
  801698:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80169f:	83 ec 0c             	sub    $0xc,%esp
  8016a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8016a7:	50                   	push   %eax
  8016a8:	53                   	push   %ebx
  8016a9:	6a 00                	push   $0x0
  8016ab:	52                   	push   %edx
  8016ac:	6a 00                	push   $0x0
  8016ae:	e8 d5 f8 ff ff       	call   800f88 <sys_page_map>
  8016b3:	89 c7                	mov    %eax,%edi
  8016b5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016b8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016ba:	85 ff                	test   %edi,%edi
  8016bc:	79 1d                	jns    8016db <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	53                   	push   %ebx
  8016c2:	6a 00                	push   $0x0
  8016c4:	e8 01 f9 ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016c9:	83 c4 08             	add    $0x8,%esp
  8016cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016cf:	6a 00                	push   $0x0
  8016d1:	e8 f4 f8 ff ff       	call   800fca <sys_page_unmap>
	return r;
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	89 f8                	mov    %edi,%eax
}
  8016db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5f                   	pop    %edi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 14             	sub    $0x14,%esp
  8016ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	53                   	push   %ebx
  8016f2:	e8 86 fd ff ff       	call   80147d <fd_lookup>
  8016f7:	83 c4 08             	add    $0x8,%esp
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 6d                	js     80176d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801706:	50                   	push   %eax
  801707:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170a:	ff 30                	pushl  (%eax)
  80170c:	e8 c2 fd ff ff       	call   8014d3 <dev_lookup>
  801711:	83 c4 10             	add    $0x10,%esp
  801714:	85 c0                	test   %eax,%eax
  801716:	78 4c                	js     801764 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801718:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80171b:	8b 42 08             	mov    0x8(%edx),%eax
  80171e:	83 e0 03             	and    $0x3,%eax
  801721:	83 f8 01             	cmp    $0x1,%eax
  801724:	75 21                	jne    801747 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801726:	a1 04 50 80 00       	mov    0x805004,%eax
  80172b:	8b 40 48             	mov    0x48(%eax),%eax
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	53                   	push   %ebx
  801732:	50                   	push   %eax
  801733:	68 a5 2f 80 00       	push   $0x802fa5
  801738:	e8 80 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801745:	eb 26                	jmp    80176d <read+0x8a>
	}
	if (!dev->dev_read)
  801747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174a:	8b 40 08             	mov    0x8(%eax),%eax
  80174d:	85 c0                	test   %eax,%eax
  80174f:	74 17                	je     801768 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801751:	83 ec 04             	sub    $0x4,%esp
  801754:	ff 75 10             	pushl  0x10(%ebp)
  801757:	ff 75 0c             	pushl  0xc(%ebp)
  80175a:	52                   	push   %edx
  80175b:	ff d0                	call   *%eax
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	eb 09                	jmp    80176d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801764:	89 c2                	mov    %eax,%edx
  801766:	eb 05                	jmp    80176d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801768:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80176d:	89 d0                	mov    %edx,%eax
  80176f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	57                   	push   %edi
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	83 ec 0c             	sub    $0xc,%esp
  80177d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801780:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801783:	bb 00 00 00 00       	mov    $0x0,%ebx
  801788:	eb 21                	jmp    8017ab <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	89 f0                	mov    %esi,%eax
  80178f:	29 d8                	sub    %ebx,%eax
  801791:	50                   	push   %eax
  801792:	89 d8                	mov    %ebx,%eax
  801794:	03 45 0c             	add    0xc(%ebp),%eax
  801797:	50                   	push   %eax
  801798:	57                   	push   %edi
  801799:	e8 45 ff ff ff       	call   8016e3 <read>
		if (m < 0)
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 10                	js     8017b5 <readn+0x41>
			return m;
		if (m == 0)
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	74 0a                	je     8017b3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017a9:	01 c3                	add    %eax,%ebx
  8017ab:	39 f3                	cmp    %esi,%ebx
  8017ad:	72 db                	jb     80178a <readn+0x16>
  8017af:	89 d8                	mov    %ebx,%eax
  8017b1:	eb 02                	jmp    8017b5 <readn+0x41>
  8017b3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	5f                   	pop    %edi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 14             	sub    $0x14,%esp
  8017c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ca:	50                   	push   %eax
  8017cb:	53                   	push   %ebx
  8017cc:	e8 ac fc ff ff       	call   80147d <fd_lookup>
  8017d1:	83 c4 08             	add    $0x8,%esp
  8017d4:	89 c2                	mov    %eax,%edx
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 68                	js     801842 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e0:	50                   	push   %eax
  8017e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e4:	ff 30                	pushl  (%eax)
  8017e6:	e8 e8 fc ff ff       	call   8014d3 <dev_lookup>
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 47                	js     801839 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017f9:	75 21                	jne    80181c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017fb:	a1 04 50 80 00       	mov    0x805004,%eax
  801800:	8b 40 48             	mov    0x48(%eax),%eax
  801803:	83 ec 04             	sub    $0x4,%esp
  801806:	53                   	push   %ebx
  801807:	50                   	push   %eax
  801808:	68 c1 2f 80 00       	push   $0x802fc1
  80180d:	e8 ab ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80181a:	eb 26                	jmp    801842 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80181c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80181f:	8b 52 0c             	mov    0xc(%edx),%edx
  801822:	85 d2                	test   %edx,%edx
  801824:	74 17                	je     80183d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801826:	83 ec 04             	sub    $0x4,%esp
  801829:	ff 75 10             	pushl  0x10(%ebp)
  80182c:	ff 75 0c             	pushl  0xc(%ebp)
  80182f:	50                   	push   %eax
  801830:	ff d2                	call   *%edx
  801832:	89 c2                	mov    %eax,%edx
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	eb 09                	jmp    801842 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801839:	89 c2                	mov    %eax,%edx
  80183b:	eb 05                	jmp    801842 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80183d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801842:	89 d0                	mov    %edx,%eax
  801844:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <seek>:

int
seek(int fdnum, off_t offset)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80184f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801852:	50                   	push   %eax
  801853:	ff 75 08             	pushl  0x8(%ebp)
  801856:	e8 22 fc ff ff       	call   80147d <fd_lookup>
  80185b:	83 c4 08             	add    $0x8,%esp
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 0e                	js     801870 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801862:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801865:	8b 55 0c             	mov    0xc(%ebp),%edx
  801868:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80186b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 14             	sub    $0x14,%esp
  801879:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187f:	50                   	push   %eax
  801880:	53                   	push   %ebx
  801881:	e8 f7 fb ff ff       	call   80147d <fd_lookup>
  801886:	83 c4 08             	add    $0x8,%esp
  801889:	89 c2                	mov    %eax,%edx
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 65                	js     8018f4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801895:	50                   	push   %eax
  801896:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801899:	ff 30                	pushl  (%eax)
  80189b:	e8 33 fc ff ff       	call   8014d3 <dev_lookup>
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 44                	js     8018eb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ae:	75 21                	jne    8018d1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018b0:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018b5:	8b 40 48             	mov    0x48(%eax),%eax
  8018b8:	83 ec 04             	sub    $0x4,%esp
  8018bb:	53                   	push   %ebx
  8018bc:	50                   	push   %eax
  8018bd:	68 84 2f 80 00       	push   $0x802f84
  8018c2:	e8 f6 ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018cf:	eb 23                	jmp    8018f4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d4:	8b 52 18             	mov    0x18(%edx),%edx
  8018d7:	85 d2                	test   %edx,%edx
  8018d9:	74 14                	je     8018ef <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018db:	83 ec 08             	sub    $0x8,%esp
  8018de:	ff 75 0c             	pushl  0xc(%ebp)
  8018e1:	50                   	push   %eax
  8018e2:	ff d2                	call   *%edx
  8018e4:	89 c2                	mov    %eax,%edx
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	eb 09                	jmp    8018f4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018eb:	89 c2                	mov    %eax,%edx
  8018ed:	eb 05                	jmp    8018f4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018ef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018f4:	89 d0                	mov    %edx,%eax
  8018f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f9:	c9                   	leave  
  8018fa:	c3                   	ret    

008018fb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	53                   	push   %ebx
  8018ff:	83 ec 14             	sub    $0x14,%esp
  801902:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801905:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801908:	50                   	push   %eax
  801909:	ff 75 08             	pushl  0x8(%ebp)
  80190c:	e8 6c fb ff ff       	call   80147d <fd_lookup>
  801911:	83 c4 08             	add    $0x8,%esp
  801914:	89 c2                	mov    %eax,%edx
  801916:	85 c0                	test   %eax,%eax
  801918:	78 58                	js     801972 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801920:	50                   	push   %eax
  801921:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801924:	ff 30                	pushl  (%eax)
  801926:	e8 a8 fb ff ff       	call   8014d3 <dev_lookup>
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 37                	js     801969 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801932:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801935:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801939:	74 32                	je     80196d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80193b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80193e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801945:	00 00 00 
	stat->st_isdir = 0;
  801948:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80194f:	00 00 00 
	stat->st_dev = dev;
  801952:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	53                   	push   %ebx
  80195c:	ff 75 f0             	pushl  -0x10(%ebp)
  80195f:	ff 50 14             	call   *0x14(%eax)
  801962:	89 c2                	mov    %eax,%edx
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	eb 09                	jmp    801972 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801969:	89 c2                	mov    %eax,%edx
  80196b:	eb 05                	jmp    801972 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80196d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801972:	89 d0                	mov    %edx,%eax
  801974:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801977:	c9                   	leave  
  801978:	c3                   	ret    

00801979 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	56                   	push   %esi
  80197d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	6a 00                	push   $0x0
  801983:	ff 75 08             	pushl  0x8(%ebp)
  801986:	e8 d6 01 00 00       	call   801b61 <open>
  80198b:	89 c3                	mov    %eax,%ebx
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	85 c0                	test   %eax,%eax
  801992:	78 1b                	js     8019af <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	ff 75 0c             	pushl  0xc(%ebp)
  80199a:	50                   	push   %eax
  80199b:	e8 5b ff ff ff       	call   8018fb <fstat>
  8019a0:	89 c6                	mov    %eax,%esi
	close(fd);
  8019a2:	89 1c 24             	mov    %ebx,(%esp)
  8019a5:	e8 fd fb ff ff       	call   8015a7 <close>
	return r;
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	89 f0                	mov    %esi,%eax
}
  8019af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	56                   	push   %esi
  8019ba:	53                   	push   %ebx
  8019bb:	89 c6                	mov    %eax,%esi
  8019bd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019bf:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019c6:	75 12                	jne    8019da <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	6a 01                	push   $0x1
  8019cd:	e8 f4 0c 00 00       	call   8026c6 <ipc_find_env>
  8019d2:	a3 00 50 80 00       	mov    %eax,0x805000
  8019d7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019da:	6a 07                	push   $0x7
  8019dc:	68 00 60 80 00       	push   $0x806000
  8019e1:	56                   	push   %esi
  8019e2:	ff 35 00 50 80 00    	pushl  0x805000
  8019e8:	e8 85 0c 00 00       	call   802672 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019ed:	83 c4 0c             	add    $0xc,%esp
  8019f0:	6a 00                	push   $0x0
  8019f2:	53                   	push   %ebx
  8019f3:	6a 00                	push   $0x0
  8019f5:	e8 11 0c 00 00       	call   80260b <ipc_recv>
}
  8019fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fd:	5b                   	pop    %ebx
  8019fe:	5e                   	pop    %esi
  8019ff:	5d                   	pop    %ebp
  801a00:	c3                   	ret    

00801a01 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a07:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a15:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1f:	b8 02 00 00 00       	mov    $0x2,%eax
  801a24:	e8 8d ff ff ff       	call   8019b6 <fsipc>
}
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a31:	8b 45 08             	mov    0x8(%ebp),%eax
  801a34:	8b 40 0c             	mov    0xc(%eax),%eax
  801a37:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a3c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a41:	b8 06 00 00 00       	mov    $0x6,%eax
  801a46:	e8 6b ff ff ff       	call   8019b6 <fsipc>
}
  801a4b:	c9                   	leave  
  801a4c:	c3                   	ret    

00801a4d <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	53                   	push   %ebx
  801a51:	83 ec 04             	sub    $0x4,%esp
  801a54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a57:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a62:	ba 00 00 00 00       	mov    $0x0,%edx
  801a67:	b8 05 00 00 00       	mov    $0x5,%eax
  801a6c:	e8 45 ff ff ff       	call   8019b6 <fsipc>
  801a71:	85 c0                	test   %eax,%eax
  801a73:	78 2c                	js     801aa1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	68 00 60 80 00       	push   $0x806000
  801a7d:	53                   	push   %ebx
  801a7e:	e8 bf f0 ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a83:	a1 80 60 80 00       	mov    0x806080,%eax
  801a88:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a8e:	a1 84 60 80 00       	mov    0x806084,%eax
  801a93:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab2:	8b 52 0c             	mov    0xc(%edx),%edx
  801ab5:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801abb:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ac0:	50                   	push   %eax
  801ac1:	ff 75 0c             	pushl  0xc(%ebp)
  801ac4:	68 08 60 80 00       	push   $0x806008
  801ac9:	e8 06 f2 ff ff       	call   800cd4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801ace:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad3:	b8 04 00 00 00       	mov    $0x4,%eax
  801ad8:	e8 d9 fe ff ff       	call   8019b6 <fsipc>

}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aea:	8b 40 0c             	mov    0xc(%eax),%eax
  801aed:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801af2:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801af8:	ba 00 00 00 00       	mov    $0x0,%edx
  801afd:	b8 03 00 00 00       	mov    $0x3,%eax
  801b02:	e8 af fe ff ff       	call   8019b6 <fsipc>
  801b07:	89 c3                	mov    %eax,%ebx
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	78 4b                	js     801b58 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b0d:	39 c6                	cmp    %eax,%esi
  801b0f:	73 16                	jae    801b27 <devfile_read+0x48>
  801b11:	68 f0 2f 80 00       	push   $0x802ff0
  801b16:	68 f7 2f 80 00       	push   $0x802ff7
  801b1b:	6a 7c                	push   $0x7c
  801b1d:	68 0c 30 80 00       	push   $0x80300c
  801b22:	e8 bd e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801b27:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b2c:	7e 16                	jle    801b44 <devfile_read+0x65>
  801b2e:	68 17 30 80 00       	push   $0x803017
  801b33:	68 f7 2f 80 00       	push   $0x802ff7
  801b38:	6a 7d                	push   $0x7d
  801b3a:	68 0c 30 80 00       	push   $0x80300c
  801b3f:	e8 a0 e9 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b44:	83 ec 04             	sub    $0x4,%esp
  801b47:	50                   	push   %eax
  801b48:	68 00 60 80 00       	push   $0x806000
  801b4d:	ff 75 0c             	pushl  0xc(%ebp)
  801b50:	e8 7f f1 ff ff       	call   800cd4 <memmove>
	return r;
  801b55:	83 c4 10             	add    $0x10,%esp
}
  801b58:	89 d8                	mov    %ebx,%eax
  801b5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5d                   	pop    %ebp
  801b60:	c3                   	ret    

00801b61 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	53                   	push   %ebx
  801b65:	83 ec 20             	sub    $0x20,%esp
  801b68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b6b:	53                   	push   %ebx
  801b6c:	e8 98 ef ff ff       	call   800b09 <strlen>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b79:	7f 67                	jg     801be2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b7b:	83 ec 0c             	sub    $0xc,%esp
  801b7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b81:	50                   	push   %eax
  801b82:	e8 a7 f8 ff ff       	call   80142e <fd_alloc>
  801b87:	83 c4 10             	add    $0x10,%esp
		return r;
  801b8a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	78 57                	js     801be7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b90:	83 ec 08             	sub    $0x8,%esp
  801b93:	53                   	push   %ebx
  801b94:	68 00 60 80 00       	push   $0x806000
  801b99:	e8 a4 ef ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba1:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bae:	e8 03 fe ff ff       	call   8019b6 <fsipc>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	79 14                	jns    801bd0 <open+0x6f>
		fd_close(fd, 0);
  801bbc:	83 ec 08             	sub    $0x8,%esp
  801bbf:	6a 00                	push   $0x0
  801bc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc4:	e8 5d f9 ff ff       	call   801526 <fd_close>
		return r;
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	89 da                	mov    %ebx,%edx
  801bce:	eb 17                	jmp    801be7 <open+0x86>
	}

	return fd2num(fd);
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd6:	e8 2c f8 ff ff       	call   801407 <fd2num>
  801bdb:	89 c2                	mov    %eax,%edx
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	eb 05                	jmp    801be7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801be2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801be7:	89 d0                	mov    %edx,%eax
  801be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf9:	b8 08 00 00 00       	mov    $0x8,%eax
  801bfe:	e8 b3 fd ff ff       	call   8019b6 <fsipc>
}
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    

00801c05 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	57                   	push   %edi
  801c09:	56                   	push   %esi
  801c0a:	53                   	push   %ebx
  801c0b:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c11:	6a 00                	push   $0x0
  801c13:	ff 75 08             	pushl  0x8(%ebp)
  801c16:	e8 46 ff ff ff       	call   801b61 <open>
  801c1b:	89 c7                	mov    %eax,%edi
  801c1d:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	0f 88 97 04 00 00    	js     8020c5 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c2e:	83 ec 04             	sub    $0x4,%esp
  801c31:	68 00 02 00 00       	push   $0x200
  801c36:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c3c:	50                   	push   %eax
  801c3d:	57                   	push   %edi
  801c3e:	e8 31 fb ff ff       	call   801774 <readn>
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c4b:	75 0c                	jne    801c59 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c4d:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c54:	45 4c 46 
  801c57:	74 33                	je     801c8c <spawn+0x87>
		close(fd);
  801c59:	83 ec 0c             	sub    $0xc,%esp
  801c5c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c62:	e8 40 f9 ff ff       	call   8015a7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c67:	83 c4 0c             	add    $0xc,%esp
  801c6a:	68 7f 45 4c 46       	push   $0x464c457f
  801c6f:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c75:	68 23 30 80 00       	push   $0x803023
  801c7a:	e8 3e e9 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801c87:	e9 ec 04 00 00       	jmp    802178 <spawn+0x573>
  801c8c:	b8 07 00 00 00       	mov    $0x7,%eax
  801c91:	cd 30                	int    $0x30
  801c93:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c99:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	0f 88 29 04 00 00    	js     8020d0 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ca7:	89 c6                	mov    %eax,%esi
  801ca9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801caf:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801cb2:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801cb8:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cbe:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cc3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cc5:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801ccb:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801cd6:	be 00 00 00 00       	mov    $0x0,%esi
  801cdb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cde:	eb 13                	jmp    801cf3 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801ce0:	83 ec 0c             	sub    $0xc,%esp
  801ce3:	50                   	push   %eax
  801ce4:	e8 20 ee ff ff       	call   800b09 <strlen>
  801ce9:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ced:	83 c3 01             	add    $0x1,%ebx
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801cfa:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	75 df                	jne    801ce0 <spawn+0xdb>
  801d01:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d07:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d0d:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d12:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d14:	89 fa                	mov    %edi,%edx
  801d16:	83 e2 fc             	and    $0xfffffffc,%edx
  801d19:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d20:	29 c2                	sub    %eax,%edx
  801d22:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d28:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d2b:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d30:	0f 86 b0 03 00 00    	jbe    8020e6 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d36:	83 ec 04             	sub    $0x4,%esp
  801d39:	6a 07                	push   $0x7
  801d3b:	68 00 00 40 00       	push   $0x400000
  801d40:	6a 00                	push   $0x0
  801d42:	e8 fe f1 ff ff       	call   800f45 <sys_page_alloc>
  801d47:	83 c4 10             	add    $0x10,%esp
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	0f 88 9e 03 00 00    	js     8020f0 <spawn+0x4eb>
  801d52:	be 00 00 00 00       	mov    $0x0,%esi
  801d57:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d60:	eb 30                	jmp    801d92 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d62:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d68:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801d6e:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801d71:	83 ec 08             	sub    $0x8,%esp
  801d74:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d77:	57                   	push   %edi
  801d78:	e8 c5 ed ff ff       	call   800b42 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d7d:	83 c4 04             	add    $0x4,%esp
  801d80:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d83:	e8 81 ed ff ff       	call   800b09 <strlen>
  801d88:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d8c:	83 c6 01             	add    $0x1,%esi
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d98:	7f c8                	jg     801d62 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d9a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801da0:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801da6:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801dad:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801db3:	74 19                	je     801dce <spawn+0x1c9>
  801db5:	68 b0 30 80 00       	push   $0x8030b0
  801dba:	68 f7 2f 80 00       	push   $0x802ff7
  801dbf:	68 f2 00 00 00       	push   $0xf2
  801dc4:	68 3d 30 80 00       	push   $0x80303d
  801dc9:	e8 16 e7 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801dce:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801dd4:	89 f8                	mov    %edi,%eax
  801dd6:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ddb:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801dde:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801de4:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801de7:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801ded:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	6a 07                	push   $0x7
  801df8:	68 00 d0 bf ee       	push   $0xeebfd000
  801dfd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e03:	68 00 00 40 00       	push   $0x400000
  801e08:	6a 00                	push   $0x0
  801e0a:	e8 79 f1 ff ff       	call   800f88 <sys_page_map>
  801e0f:	89 c3                	mov    %eax,%ebx
  801e11:	83 c4 20             	add    $0x20,%esp
  801e14:	85 c0                	test   %eax,%eax
  801e16:	0f 88 4a 03 00 00    	js     802166 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e1c:	83 ec 08             	sub    $0x8,%esp
  801e1f:	68 00 00 40 00       	push   $0x400000
  801e24:	6a 00                	push   $0x0
  801e26:	e8 9f f1 ff ff       	call   800fca <sys_page_unmap>
  801e2b:	89 c3                	mov    %eax,%ebx
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	0f 88 2e 03 00 00    	js     802166 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e38:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e3e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e45:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e4b:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e52:	00 00 00 
  801e55:	e9 8a 01 00 00       	jmp    801fe4 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801e5a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e60:	83 38 01             	cmpl   $0x1,(%eax)
  801e63:	0f 85 6d 01 00 00    	jne    801fd6 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e69:	89 c7                	mov    %eax,%edi
  801e6b:	8b 40 18             	mov    0x18(%eax),%eax
  801e6e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e74:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e77:	83 f8 01             	cmp    $0x1,%eax
  801e7a:	19 c0                	sbb    %eax,%eax
  801e7c:	83 e0 fe             	and    $0xfffffffe,%eax
  801e7f:	83 c0 07             	add    $0x7,%eax
  801e82:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e88:	89 f8                	mov    %edi,%eax
  801e8a:	8b 7f 04             	mov    0x4(%edi),%edi
  801e8d:	89 f9                	mov    %edi,%ecx
  801e8f:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801e95:	8b 78 10             	mov    0x10(%eax),%edi
  801e98:	8b 70 14             	mov    0x14(%eax),%esi
  801e9b:	89 f3                	mov    %esi,%ebx
  801e9d:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801ea3:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ea6:	89 f0                	mov    %esi,%eax
  801ea8:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ead:	74 14                	je     801ec3 <spawn+0x2be>
		va -= i;
  801eaf:	29 c6                	sub    %eax,%esi
		memsz += i;
  801eb1:	01 c3                	add    %eax,%ebx
  801eb3:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801eb9:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ebb:	29 c1                	sub    %eax,%ecx
  801ebd:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ec3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ec8:	e9 f7 00 00 00       	jmp    801fc4 <spawn+0x3bf>
		if (i >= filesz) {
  801ecd:	39 df                	cmp    %ebx,%edi
  801ecf:	77 27                	ja     801ef8 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ed1:	83 ec 04             	sub    $0x4,%esp
  801ed4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801eda:	56                   	push   %esi
  801edb:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ee1:	e8 5f f0 ff ff       	call   800f45 <sys_page_alloc>
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	0f 89 c7 00 00 00    	jns    801fb8 <spawn+0x3b3>
  801ef1:	89 c3                	mov    %eax,%ebx
  801ef3:	e9 09 02 00 00       	jmp    802101 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ef8:	83 ec 04             	sub    $0x4,%esp
  801efb:	6a 07                	push   $0x7
  801efd:	68 00 00 40 00       	push   $0x400000
  801f02:	6a 00                	push   $0x0
  801f04:	e8 3c f0 ff ff       	call   800f45 <sys_page_alloc>
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	0f 88 e3 01 00 00    	js     8020f7 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f14:	83 ec 08             	sub    $0x8,%esp
  801f17:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f1d:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f23:	50                   	push   %eax
  801f24:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f2a:	e8 1a f9 ff ff       	call   801849 <seek>
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 c0                	test   %eax,%eax
  801f34:	0f 88 c1 01 00 00    	js     8020fb <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f3a:	83 ec 04             	sub    $0x4,%esp
  801f3d:	89 f8                	mov    %edi,%eax
  801f3f:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801f45:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f4a:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801f4f:	0f 47 c1             	cmova  %ecx,%eax
  801f52:	50                   	push   %eax
  801f53:	68 00 00 40 00       	push   $0x400000
  801f58:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f5e:	e8 11 f8 ff ff       	call   801774 <readn>
  801f63:	83 c4 10             	add    $0x10,%esp
  801f66:	85 c0                	test   %eax,%eax
  801f68:	0f 88 91 01 00 00    	js     8020ff <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f6e:	83 ec 0c             	sub    $0xc,%esp
  801f71:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f77:	56                   	push   %esi
  801f78:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f7e:	68 00 00 40 00       	push   $0x400000
  801f83:	6a 00                	push   $0x0
  801f85:	e8 fe ef ff ff       	call   800f88 <sys_page_map>
  801f8a:	83 c4 20             	add    $0x20,%esp
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	79 15                	jns    801fa6 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801f91:	50                   	push   %eax
  801f92:	68 49 30 80 00       	push   $0x803049
  801f97:	68 25 01 00 00       	push   $0x125
  801f9c:	68 3d 30 80 00       	push   $0x80303d
  801fa1:	e8 3e e5 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  801fa6:	83 ec 08             	sub    $0x8,%esp
  801fa9:	68 00 00 40 00       	push   $0x400000
  801fae:	6a 00                	push   $0x0
  801fb0:	e8 15 f0 ff ff       	call   800fca <sys_page_unmap>
  801fb5:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801fb8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fbe:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801fc4:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801fca:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801fd0:	0f 87 f7 fe ff ff    	ja     801ecd <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801fd6:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801fdd:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801fe4:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801feb:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801ff1:	0f 8c 63 fe ff ff    	jl     801e5a <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ff7:	83 ec 0c             	sub    $0xc,%esp
  801ffa:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802000:	e8 a2 f5 ff ff       	call   8015a7 <close>
  802005:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  802008:	bb 00 08 00 00       	mov    $0x800,%ebx
  80200d:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  802013:	89 d8                	mov    %ebx,%eax
  802015:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  802018:	89 c2                	mov    %eax,%edx
  80201a:	c1 ea 16             	shr    $0x16,%edx
  80201d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802024:	f6 c2 01             	test   $0x1,%dl
  802027:	74 4b                	je     802074 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  802029:	89 c2                	mov    %eax,%edx
  80202b:	c1 ea 0c             	shr    $0xc,%edx
  80202e:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  802035:	f6 c1 01             	test   $0x1,%cl
  802038:	74 3a                	je     802074 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  80203a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802041:	f6 c6 04             	test   $0x4,%dh
  802044:	74 2e                	je     802074 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  802046:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  80204d:	8b 0d 04 50 80 00    	mov    0x805004,%ecx
  802053:	8b 49 48             	mov    0x48(%ecx),%ecx
  802056:	83 ec 0c             	sub    $0xc,%esp
  802059:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80205f:	52                   	push   %edx
  802060:	50                   	push   %eax
  802061:	56                   	push   %esi
  802062:	50                   	push   %eax
  802063:	51                   	push   %ecx
  802064:	e8 1f ef ff ff       	call   800f88 <sys_page_map>
					if (r < 0)
  802069:	83 c4 20             	add    $0x20,%esp
  80206c:	85 c0                	test   %eax,%eax
  80206e:	0f 88 ae 00 00 00    	js     802122 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  802074:	83 c3 01             	add    $0x1,%ebx
  802077:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80207d:	75 94                	jne    802013 <spawn+0x40e>
  80207f:	e9 b3 00 00 00       	jmp    802137 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802084:	50                   	push   %eax
  802085:	68 66 30 80 00       	push   $0x803066
  80208a:	68 86 00 00 00       	push   $0x86
  80208f:	68 3d 30 80 00       	push   $0x80303d
  802094:	e8 4b e4 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802099:	83 ec 08             	sub    $0x8,%esp
  80209c:	6a 02                	push   $0x2
  80209e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020a4:	e8 63 ef ff ff       	call   80100c <sys_env_set_status>
  8020a9:	83 c4 10             	add    $0x10,%esp
  8020ac:	85 c0                	test   %eax,%eax
  8020ae:	79 2b                	jns    8020db <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  8020b0:	50                   	push   %eax
  8020b1:	68 80 30 80 00       	push   $0x803080
  8020b6:	68 89 00 00 00       	push   $0x89
  8020bb:	68 3d 30 80 00       	push   $0x80303d
  8020c0:	e8 1f e4 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8020c5:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8020cb:	e9 a8 00 00 00       	jmp    802178 <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8020d0:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8020d6:	e9 9d 00 00 00       	jmp    802178 <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8020db:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8020e1:	e9 92 00 00 00       	jmp    802178 <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8020e6:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8020eb:	e9 88 00 00 00       	jmp    802178 <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8020f0:	89 c3                	mov    %eax,%ebx
  8020f2:	e9 81 00 00 00       	jmp    802178 <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	eb 06                	jmp    802101 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020fb:	89 c3                	mov    %eax,%ebx
  8020fd:	eb 02                	jmp    802101 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8020ff:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802101:	83 ec 0c             	sub    $0xc,%esp
  802104:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80210a:	e8 b7 ed ff ff       	call   800ec6 <sys_env_destroy>
	close(fd);
  80210f:	83 c4 04             	add    $0x4,%esp
  802112:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802118:	e8 8a f4 ff ff       	call   8015a7 <close>
	return r;
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	eb 56                	jmp    802178 <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802122:	50                   	push   %eax
  802123:	68 97 30 80 00       	push   $0x803097
  802128:	68 82 00 00 00       	push   $0x82
  80212d:	68 3d 30 80 00       	push   $0x80303d
  802132:	e8 ad e3 ff ff       	call   8004e4 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802137:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80213e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802141:	83 ec 08             	sub    $0x8,%esp
  802144:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80214a:	50                   	push   %eax
  80214b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802151:	e8 f8 ee ff ff       	call   80104e <sys_env_set_trapframe>
  802156:	83 c4 10             	add    $0x10,%esp
  802159:	85 c0                	test   %eax,%eax
  80215b:	0f 89 38 ff ff ff    	jns    802099 <spawn+0x494>
  802161:	e9 1e ff ff ff       	jmp    802084 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802166:	83 ec 08             	sub    $0x8,%esp
  802169:	68 00 00 40 00       	push   $0x400000
  80216e:	6a 00                	push   $0x0
  802170:	e8 55 ee ff ff       	call   800fca <sys_page_unmap>
  802175:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    

00802182 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	56                   	push   %esi
  802186:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802187:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80218a:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80218f:	eb 03                	jmp    802194 <spawnl+0x12>
		argc++;
  802191:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802194:	83 c2 04             	add    $0x4,%edx
  802197:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80219b:	75 f4                	jne    802191 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80219d:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021a4:	83 e2 f0             	and    $0xfffffff0,%edx
  8021a7:	29 d4                	sub    %edx,%esp
  8021a9:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021ad:	c1 ea 02             	shr    $0x2,%edx
  8021b0:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021b7:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021bc:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021c3:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021ca:	00 
  8021cb:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d2:	eb 0a                	jmp    8021de <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8021d4:	83 c0 01             	add    $0x1,%eax
  8021d7:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8021db:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021de:	39 d0                	cmp    %edx,%eax
  8021e0:	75 f2                	jne    8021d4 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8021e2:	83 ec 08             	sub    $0x8,%esp
  8021e5:	56                   	push   %esi
  8021e6:	ff 75 08             	pushl  0x8(%ebp)
  8021e9:	e8 17 fa ff ff       	call   801c05 <spawn>
}
  8021ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f1:	5b                   	pop    %ebx
  8021f2:	5e                   	pop    %esi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	56                   	push   %esi
  8021f9:	53                   	push   %ebx
  8021fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021fd:	83 ec 0c             	sub    $0xc,%esp
  802200:	ff 75 08             	pushl  0x8(%ebp)
  802203:	e8 0f f2 ff ff       	call   801417 <fd2data>
  802208:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80220a:	83 c4 08             	add    $0x8,%esp
  80220d:	68 d8 30 80 00       	push   $0x8030d8
  802212:	53                   	push   %ebx
  802213:	e8 2a e9 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802218:	8b 46 04             	mov    0x4(%esi),%eax
  80221b:	2b 06                	sub    (%esi),%eax
  80221d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802223:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80222a:	00 00 00 
	stat->st_dev = &devpipe;
  80222d:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802234:	40 80 00 
	return 0;
}
  802237:	b8 00 00 00 00       	mov    $0x0,%eax
  80223c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80223f:	5b                   	pop    %ebx
  802240:	5e                   	pop    %esi
  802241:	5d                   	pop    %ebp
  802242:	c3                   	ret    

00802243 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802243:	55                   	push   %ebp
  802244:	89 e5                	mov    %esp,%ebp
  802246:	53                   	push   %ebx
  802247:	83 ec 0c             	sub    $0xc,%esp
  80224a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80224d:	53                   	push   %ebx
  80224e:	6a 00                	push   $0x0
  802250:	e8 75 ed ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802255:	89 1c 24             	mov    %ebx,(%esp)
  802258:	e8 ba f1 ff ff       	call   801417 <fd2data>
  80225d:	83 c4 08             	add    $0x8,%esp
  802260:	50                   	push   %eax
  802261:	6a 00                	push   $0x0
  802263:	e8 62 ed ff ff       	call   800fca <sys_page_unmap>
}
  802268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80226b:	c9                   	leave  
  80226c:	c3                   	ret    

0080226d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80226d:	55                   	push   %ebp
  80226e:	89 e5                	mov    %esp,%ebp
  802270:	57                   	push   %edi
  802271:	56                   	push   %esi
  802272:	53                   	push   %ebx
  802273:	83 ec 1c             	sub    $0x1c,%esp
  802276:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802279:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80227b:	a1 04 50 80 00       	mov    0x805004,%eax
  802280:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802283:	83 ec 0c             	sub    $0xc,%esp
  802286:	ff 75 e0             	pushl  -0x20(%ebp)
  802289:	e8 71 04 00 00       	call   8026ff <pageref>
  80228e:	89 c3                	mov    %eax,%ebx
  802290:	89 3c 24             	mov    %edi,(%esp)
  802293:	e8 67 04 00 00       	call   8026ff <pageref>
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	39 c3                	cmp    %eax,%ebx
  80229d:	0f 94 c1             	sete   %cl
  8022a0:	0f b6 c9             	movzbl %cl,%ecx
  8022a3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8022a6:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8022ac:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022af:	39 ce                	cmp    %ecx,%esi
  8022b1:	74 1b                	je     8022ce <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022b3:	39 c3                	cmp    %eax,%ebx
  8022b5:	75 c4                	jne    80227b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022b7:	8b 42 58             	mov    0x58(%edx),%eax
  8022ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022bd:	50                   	push   %eax
  8022be:	56                   	push   %esi
  8022bf:	68 df 30 80 00       	push   $0x8030df
  8022c4:	e8 f4 e2 ff ff       	call   8005bd <cprintf>
  8022c9:	83 c4 10             	add    $0x10,%esp
  8022cc:	eb ad                	jmp    80227b <_pipeisclosed+0xe>
	}
}
  8022ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022d4:	5b                   	pop    %ebx
  8022d5:	5e                   	pop    %esi
  8022d6:	5f                   	pop    %edi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    

008022d9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	57                   	push   %edi
  8022dd:	56                   	push   %esi
  8022de:	53                   	push   %ebx
  8022df:	83 ec 28             	sub    $0x28,%esp
  8022e2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022e5:	56                   	push   %esi
  8022e6:	e8 2c f1 ff ff       	call   801417 <fd2data>
  8022eb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022ed:	83 c4 10             	add    $0x10,%esp
  8022f0:	bf 00 00 00 00       	mov    $0x0,%edi
  8022f5:	eb 4b                	jmp    802342 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022f7:	89 da                	mov    %ebx,%edx
  8022f9:	89 f0                	mov    %esi,%eax
  8022fb:	e8 6d ff ff ff       	call   80226d <_pipeisclosed>
  802300:	85 c0                	test   %eax,%eax
  802302:	75 48                	jne    80234c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802304:	e8 1d ec ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802309:	8b 43 04             	mov    0x4(%ebx),%eax
  80230c:	8b 0b                	mov    (%ebx),%ecx
  80230e:	8d 51 20             	lea    0x20(%ecx),%edx
  802311:	39 d0                	cmp    %edx,%eax
  802313:	73 e2                	jae    8022f7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802318:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80231c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80231f:	89 c2                	mov    %eax,%edx
  802321:	c1 fa 1f             	sar    $0x1f,%edx
  802324:	89 d1                	mov    %edx,%ecx
  802326:	c1 e9 1b             	shr    $0x1b,%ecx
  802329:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80232c:	83 e2 1f             	and    $0x1f,%edx
  80232f:	29 ca                	sub    %ecx,%edx
  802331:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802335:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802339:	83 c0 01             	add    $0x1,%eax
  80233c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80233f:	83 c7 01             	add    $0x1,%edi
  802342:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802345:	75 c2                	jne    802309 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802347:	8b 45 10             	mov    0x10(%ebp),%eax
  80234a:	eb 05                	jmp    802351 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80234c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802354:	5b                   	pop    %ebx
  802355:	5e                   	pop    %esi
  802356:	5f                   	pop    %edi
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    

00802359 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802359:	55                   	push   %ebp
  80235a:	89 e5                	mov    %esp,%ebp
  80235c:	57                   	push   %edi
  80235d:	56                   	push   %esi
  80235e:	53                   	push   %ebx
  80235f:	83 ec 18             	sub    $0x18,%esp
  802362:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802365:	57                   	push   %edi
  802366:	e8 ac f0 ff ff       	call   801417 <fd2data>
  80236b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80236d:	83 c4 10             	add    $0x10,%esp
  802370:	bb 00 00 00 00       	mov    $0x0,%ebx
  802375:	eb 3d                	jmp    8023b4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802377:	85 db                	test   %ebx,%ebx
  802379:	74 04                	je     80237f <devpipe_read+0x26>
				return i;
  80237b:	89 d8                	mov    %ebx,%eax
  80237d:	eb 44                	jmp    8023c3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80237f:	89 f2                	mov    %esi,%edx
  802381:	89 f8                	mov    %edi,%eax
  802383:	e8 e5 fe ff ff       	call   80226d <_pipeisclosed>
  802388:	85 c0                	test   %eax,%eax
  80238a:	75 32                	jne    8023be <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80238c:	e8 95 eb ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802391:	8b 06                	mov    (%esi),%eax
  802393:	3b 46 04             	cmp    0x4(%esi),%eax
  802396:	74 df                	je     802377 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802398:	99                   	cltd   
  802399:	c1 ea 1b             	shr    $0x1b,%edx
  80239c:	01 d0                	add    %edx,%eax
  80239e:	83 e0 1f             	and    $0x1f,%eax
  8023a1:	29 d0                	sub    %edx,%eax
  8023a3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023ab:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023ae:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023b1:	83 c3 01             	add    $0x1,%ebx
  8023b4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023b7:	75 d8                	jne    802391 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8023bc:	eb 05                	jmp    8023c3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023be:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023c6:	5b                   	pop    %ebx
  8023c7:	5e                   	pop    %esi
  8023c8:	5f                   	pop    %edi
  8023c9:	5d                   	pop    %ebp
  8023ca:	c3                   	ret    

008023cb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	56                   	push   %esi
  8023cf:	53                   	push   %ebx
  8023d0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d6:	50                   	push   %eax
  8023d7:	e8 52 f0 ff ff       	call   80142e <fd_alloc>
  8023dc:	83 c4 10             	add    $0x10,%esp
  8023df:	89 c2                	mov    %eax,%edx
  8023e1:	85 c0                	test   %eax,%eax
  8023e3:	0f 88 2c 01 00 00    	js     802515 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023e9:	83 ec 04             	sub    $0x4,%esp
  8023ec:	68 07 04 00 00       	push   $0x407
  8023f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f4:	6a 00                	push   $0x0
  8023f6:	e8 4a eb ff ff       	call   800f45 <sys_page_alloc>
  8023fb:	83 c4 10             	add    $0x10,%esp
  8023fe:	89 c2                	mov    %eax,%edx
  802400:	85 c0                	test   %eax,%eax
  802402:	0f 88 0d 01 00 00    	js     802515 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802408:	83 ec 0c             	sub    $0xc,%esp
  80240b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80240e:	50                   	push   %eax
  80240f:	e8 1a f0 ff ff       	call   80142e <fd_alloc>
  802414:	89 c3                	mov    %eax,%ebx
  802416:	83 c4 10             	add    $0x10,%esp
  802419:	85 c0                	test   %eax,%eax
  80241b:	0f 88 e2 00 00 00    	js     802503 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802421:	83 ec 04             	sub    $0x4,%esp
  802424:	68 07 04 00 00       	push   $0x407
  802429:	ff 75 f0             	pushl  -0x10(%ebp)
  80242c:	6a 00                	push   $0x0
  80242e:	e8 12 eb ff ff       	call   800f45 <sys_page_alloc>
  802433:	89 c3                	mov    %eax,%ebx
  802435:	83 c4 10             	add    $0x10,%esp
  802438:	85 c0                	test   %eax,%eax
  80243a:	0f 88 c3 00 00 00    	js     802503 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802440:	83 ec 0c             	sub    $0xc,%esp
  802443:	ff 75 f4             	pushl  -0xc(%ebp)
  802446:	e8 cc ef ff ff       	call   801417 <fd2data>
  80244b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80244d:	83 c4 0c             	add    $0xc,%esp
  802450:	68 07 04 00 00       	push   $0x407
  802455:	50                   	push   %eax
  802456:	6a 00                	push   $0x0
  802458:	e8 e8 ea ff ff       	call   800f45 <sys_page_alloc>
  80245d:	89 c3                	mov    %eax,%ebx
  80245f:	83 c4 10             	add    $0x10,%esp
  802462:	85 c0                	test   %eax,%eax
  802464:	0f 88 89 00 00 00    	js     8024f3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80246a:	83 ec 0c             	sub    $0xc,%esp
  80246d:	ff 75 f0             	pushl  -0x10(%ebp)
  802470:	e8 a2 ef ff ff       	call   801417 <fd2data>
  802475:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80247c:	50                   	push   %eax
  80247d:	6a 00                	push   $0x0
  80247f:	56                   	push   %esi
  802480:	6a 00                	push   $0x0
  802482:	e8 01 eb ff ff       	call   800f88 <sys_page_map>
  802487:	89 c3                	mov    %eax,%ebx
  802489:	83 c4 20             	add    $0x20,%esp
  80248c:	85 c0                	test   %eax,%eax
  80248e:	78 55                	js     8024e5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802490:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802496:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802499:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80249b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80249e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024a5:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024ae:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024b3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024ba:	83 ec 0c             	sub    $0xc,%esp
  8024bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8024c0:	e8 42 ef ff ff       	call   801407 <fd2num>
  8024c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024c8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024ca:	83 c4 04             	add    $0x4,%esp
  8024cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8024d0:	e8 32 ef ff ff       	call   801407 <fd2num>
  8024d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024d8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8024db:	83 c4 10             	add    $0x10,%esp
  8024de:	ba 00 00 00 00       	mov    $0x0,%edx
  8024e3:	eb 30                	jmp    802515 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8024e5:	83 ec 08             	sub    $0x8,%esp
  8024e8:	56                   	push   %esi
  8024e9:	6a 00                	push   $0x0
  8024eb:	e8 da ea ff ff       	call   800fca <sys_page_unmap>
  8024f0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8024f3:	83 ec 08             	sub    $0x8,%esp
  8024f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8024f9:	6a 00                	push   $0x0
  8024fb:	e8 ca ea ff ff       	call   800fca <sys_page_unmap>
  802500:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802503:	83 ec 08             	sub    $0x8,%esp
  802506:	ff 75 f4             	pushl  -0xc(%ebp)
  802509:	6a 00                	push   $0x0
  80250b:	e8 ba ea ff ff       	call   800fca <sys_page_unmap>
  802510:	83 c4 10             	add    $0x10,%esp
  802513:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802515:	89 d0                	mov    %edx,%eax
  802517:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80251a:	5b                   	pop    %ebx
  80251b:	5e                   	pop    %esi
  80251c:	5d                   	pop    %ebp
  80251d:	c3                   	ret    

0080251e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80251e:	55                   	push   %ebp
  80251f:	89 e5                	mov    %esp,%ebp
  802521:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802527:	50                   	push   %eax
  802528:	ff 75 08             	pushl  0x8(%ebp)
  80252b:	e8 4d ef ff ff       	call   80147d <fd_lookup>
  802530:	83 c4 10             	add    $0x10,%esp
  802533:	85 c0                	test   %eax,%eax
  802535:	78 18                	js     80254f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802537:	83 ec 0c             	sub    $0xc,%esp
  80253a:	ff 75 f4             	pushl  -0xc(%ebp)
  80253d:	e8 d5 ee ff ff       	call   801417 <fd2data>
	return _pipeisclosed(fd, p);
  802542:	89 c2                	mov    %eax,%edx
  802544:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802547:	e8 21 fd ff ff       	call   80226d <_pipeisclosed>
  80254c:	83 c4 10             	add    $0x10,%esp
}
  80254f:	c9                   	leave  
  802550:	c3                   	ret    

00802551 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802551:	55                   	push   %ebp
  802552:	89 e5                	mov    %esp,%ebp
  802554:	56                   	push   %esi
  802555:	53                   	push   %ebx
  802556:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802559:	85 f6                	test   %esi,%esi
  80255b:	75 16                	jne    802573 <wait+0x22>
  80255d:	68 f7 30 80 00       	push   $0x8030f7
  802562:	68 f7 2f 80 00       	push   $0x802ff7
  802567:	6a 09                	push   $0x9
  802569:	68 02 31 80 00       	push   $0x803102
  80256e:	e8 71 df ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  802573:	89 f3                	mov    %esi,%ebx
  802575:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80257b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80257e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802584:	eb 05                	jmp    80258b <wait+0x3a>
		sys_yield();
  802586:	e8 9b e9 ff ff       	call   800f26 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80258b:	8b 43 48             	mov    0x48(%ebx),%eax
  80258e:	39 c6                	cmp    %eax,%esi
  802590:	75 07                	jne    802599 <wait+0x48>
  802592:	8b 43 54             	mov    0x54(%ebx),%eax
  802595:	85 c0                	test   %eax,%eax
  802597:	75 ed                	jne    802586 <wait+0x35>
		sys_yield();
}
  802599:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80259c:	5b                   	pop    %ebx
  80259d:	5e                   	pop    %esi
  80259e:	5d                   	pop    %ebp
  80259f:	c3                   	ret    

008025a0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025a0:	55                   	push   %ebp
  8025a1:	89 e5                	mov    %esp,%ebp
  8025a3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025a6:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8025ad:	75 2e                	jne    8025dd <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8025af:	e8 53 e9 ff ff       	call   800f07 <sys_getenvid>
  8025b4:	83 ec 04             	sub    $0x4,%esp
  8025b7:	68 07 0e 00 00       	push   $0xe07
  8025bc:	68 00 f0 bf ee       	push   $0xeebff000
  8025c1:	50                   	push   %eax
  8025c2:	e8 7e e9 ff ff       	call   800f45 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8025c7:	e8 3b e9 ff ff       	call   800f07 <sys_getenvid>
  8025cc:	83 c4 08             	add    $0x8,%esp
  8025cf:	68 e7 25 80 00       	push   $0x8025e7
  8025d4:	50                   	push   %eax
  8025d5:	e8 b6 ea ff ff       	call   801090 <sys_env_set_pgfault_upcall>
  8025da:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e0:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8025e5:	c9                   	leave  
  8025e6:	c3                   	ret    

008025e7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025e7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025e8:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8025ed:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025ef:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8025f2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8025f6:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8025fa:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8025fd:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802600:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802601:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802604:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802605:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802606:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80260a:	c3                   	ret    

0080260b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80260b:	55                   	push   %ebp
  80260c:	89 e5                	mov    %esp,%ebp
  80260e:	56                   	push   %esi
  80260f:	53                   	push   %ebx
  802610:	8b 75 08             	mov    0x8(%ebp),%esi
  802613:	8b 45 0c             	mov    0xc(%ebp),%eax
  802616:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802619:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80261b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802620:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802623:	83 ec 0c             	sub    $0xc,%esp
  802626:	50                   	push   %eax
  802627:	e8 c9 ea ff ff       	call   8010f5 <sys_ipc_recv>

	if (from_env_store != NULL)
  80262c:	83 c4 10             	add    $0x10,%esp
  80262f:	85 f6                	test   %esi,%esi
  802631:	74 14                	je     802647 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802633:	ba 00 00 00 00       	mov    $0x0,%edx
  802638:	85 c0                	test   %eax,%eax
  80263a:	78 09                	js     802645 <ipc_recv+0x3a>
  80263c:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802642:	8b 52 74             	mov    0x74(%edx),%edx
  802645:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802647:	85 db                	test   %ebx,%ebx
  802649:	74 14                	je     80265f <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80264b:	ba 00 00 00 00       	mov    $0x0,%edx
  802650:	85 c0                	test   %eax,%eax
  802652:	78 09                	js     80265d <ipc_recv+0x52>
  802654:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80265a:	8b 52 78             	mov    0x78(%edx),%edx
  80265d:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80265f:	85 c0                	test   %eax,%eax
  802661:	78 08                	js     80266b <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802663:	a1 04 50 80 00       	mov    0x805004,%eax
  802668:	8b 40 70             	mov    0x70(%eax),%eax
}
  80266b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80266e:	5b                   	pop    %ebx
  80266f:	5e                   	pop    %esi
  802670:	5d                   	pop    %ebp
  802671:	c3                   	ret    

00802672 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802672:	55                   	push   %ebp
  802673:	89 e5                	mov    %esp,%ebp
  802675:	57                   	push   %edi
  802676:	56                   	push   %esi
  802677:	53                   	push   %ebx
  802678:	83 ec 0c             	sub    $0xc,%esp
  80267b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80267e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802681:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802684:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802686:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80268b:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80268e:	ff 75 14             	pushl  0x14(%ebp)
  802691:	53                   	push   %ebx
  802692:	56                   	push   %esi
  802693:	57                   	push   %edi
  802694:	e8 39 ea ff ff       	call   8010d2 <sys_ipc_try_send>

		if (err < 0) {
  802699:	83 c4 10             	add    $0x10,%esp
  80269c:	85 c0                	test   %eax,%eax
  80269e:	79 1e                	jns    8026be <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8026a0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026a3:	75 07                	jne    8026ac <ipc_send+0x3a>
				sys_yield();
  8026a5:	e8 7c e8 ff ff       	call   800f26 <sys_yield>
  8026aa:	eb e2                	jmp    80268e <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8026ac:	50                   	push   %eax
  8026ad:	68 0d 31 80 00       	push   $0x80310d
  8026b2:	6a 49                	push   $0x49
  8026b4:	68 1a 31 80 00       	push   $0x80311a
  8026b9:	e8 26 de ff ff       	call   8004e4 <_panic>
		}

	} while (err < 0);

}
  8026be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026c1:	5b                   	pop    %ebx
  8026c2:	5e                   	pop    %esi
  8026c3:	5f                   	pop    %edi
  8026c4:	5d                   	pop    %ebp
  8026c5:	c3                   	ret    

008026c6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026c6:	55                   	push   %ebp
  8026c7:	89 e5                	mov    %esp,%ebp
  8026c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026d1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026d4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026da:	8b 52 50             	mov    0x50(%edx),%edx
  8026dd:	39 ca                	cmp    %ecx,%edx
  8026df:	75 0d                	jne    8026ee <ipc_find_env+0x28>
			return envs[i].env_id;
  8026e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026e9:	8b 40 48             	mov    0x48(%eax),%eax
  8026ec:	eb 0f                	jmp    8026fd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026ee:	83 c0 01             	add    $0x1,%eax
  8026f1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026f6:	75 d9                	jne    8026d1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026fd:	5d                   	pop    %ebp
  8026fe:	c3                   	ret    

008026ff <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026ff:	55                   	push   %ebp
  802700:	89 e5                	mov    %esp,%ebp
  802702:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802705:	89 d0                	mov    %edx,%eax
  802707:	c1 e8 16             	shr    $0x16,%eax
  80270a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802711:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802716:	f6 c1 01             	test   $0x1,%cl
  802719:	74 1d                	je     802738 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80271b:	c1 ea 0c             	shr    $0xc,%edx
  80271e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802725:	f6 c2 01             	test   $0x1,%dl
  802728:	74 0e                	je     802738 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80272a:	c1 ea 0c             	shr    $0xc,%edx
  80272d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802734:	ef 
  802735:	0f b7 c0             	movzwl %ax,%eax
}
  802738:	5d                   	pop    %ebp
  802739:	c3                   	ret    
  80273a:	66 90                	xchg   %ax,%ax
  80273c:	66 90                	xchg   %ax,%ax
  80273e:	66 90                	xchg   %ax,%ax

00802740 <__udivdi3>:
  802740:	55                   	push   %ebp
  802741:	57                   	push   %edi
  802742:	56                   	push   %esi
  802743:	53                   	push   %ebx
  802744:	83 ec 1c             	sub    $0x1c,%esp
  802747:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80274b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80274f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802753:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802757:	85 f6                	test   %esi,%esi
  802759:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80275d:	89 ca                	mov    %ecx,%edx
  80275f:	89 f8                	mov    %edi,%eax
  802761:	75 3d                	jne    8027a0 <__udivdi3+0x60>
  802763:	39 cf                	cmp    %ecx,%edi
  802765:	0f 87 c5 00 00 00    	ja     802830 <__udivdi3+0xf0>
  80276b:	85 ff                	test   %edi,%edi
  80276d:	89 fd                	mov    %edi,%ebp
  80276f:	75 0b                	jne    80277c <__udivdi3+0x3c>
  802771:	b8 01 00 00 00       	mov    $0x1,%eax
  802776:	31 d2                	xor    %edx,%edx
  802778:	f7 f7                	div    %edi
  80277a:	89 c5                	mov    %eax,%ebp
  80277c:	89 c8                	mov    %ecx,%eax
  80277e:	31 d2                	xor    %edx,%edx
  802780:	f7 f5                	div    %ebp
  802782:	89 c1                	mov    %eax,%ecx
  802784:	89 d8                	mov    %ebx,%eax
  802786:	89 cf                	mov    %ecx,%edi
  802788:	f7 f5                	div    %ebp
  80278a:	89 c3                	mov    %eax,%ebx
  80278c:	89 d8                	mov    %ebx,%eax
  80278e:	89 fa                	mov    %edi,%edx
  802790:	83 c4 1c             	add    $0x1c,%esp
  802793:	5b                   	pop    %ebx
  802794:	5e                   	pop    %esi
  802795:	5f                   	pop    %edi
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    
  802798:	90                   	nop
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	39 ce                	cmp    %ecx,%esi
  8027a2:	77 74                	ja     802818 <__udivdi3+0xd8>
  8027a4:	0f bd fe             	bsr    %esi,%edi
  8027a7:	83 f7 1f             	xor    $0x1f,%edi
  8027aa:	0f 84 98 00 00 00    	je     802848 <__udivdi3+0x108>
  8027b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8027b5:	89 f9                	mov    %edi,%ecx
  8027b7:	89 c5                	mov    %eax,%ebp
  8027b9:	29 fb                	sub    %edi,%ebx
  8027bb:	d3 e6                	shl    %cl,%esi
  8027bd:	89 d9                	mov    %ebx,%ecx
  8027bf:	d3 ed                	shr    %cl,%ebp
  8027c1:	89 f9                	mov    %edi,%ecx
  8027c3:	d3 e0                	shl    %cl,%eax
  8027c5:	09 ee                	or     %ebp,%esi
  8027c7:	89 d9                	mov    %ebx,%ecx
  8027c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027cd:	89 d5                	mov    %edx,%ebp
  8027cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027d3:	d3 ed                	shr    %cl,%ebp
  8027d5:	89 f9                	mov    %edi,%ecx
  8027d7:	d3 e2                	shl    %cl,%edx
  8027d9:	89 d9                	mov    %ebx,%ecx
  8027db:	d3 e8                	shr    %cl,%eax
  8027dd:	09 c2                	or     %eax,%edx
  8027df:	89 d0                	mov    %edx,%eax
  8027e1:	89 ea                	mov    %ebp,%edx
  8027e3:	f7 f6                	div    %esi
  8027e5:	89 d5                	mov    %edx,%ebp
  8027e7:	89 c3                	mov    %eax,%ebx
  8027e9:	f7 64 24 0c          	mull   0xc(%esp)
  8027ed:	39 d5                	cmp    %edx,%ebp
  8027ef:	72 10                	jb     802801 <__udivdi3+0xc1>
  8027f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027f5:	89 f9                	mov    %edi,%ecx
  8027f7:	d3 e6                	shl    %cl,%esi
  8027f9:	39 c6                	cmp    %eax,%esi
  8027fb:	73 07                	jae    802804 <__udivdi3+0xc4>
  8027fd:	39 d5                	cmp    %edx,%ebp
  8027ff:	75 03                	jne    802804 <__udivdi3+0xc4>
  802801:	83 eb 01             	sub    $0x1,%ebx
  802804:	31 ff                	xor    %edi,%edi
  802806:	89 d8                	mov    %ebx,%eax
  802808:	89 fa                	mov    %edi,%edx
  80280a:	83 c4 1c             	add    $0x1c,%esp
  80280d:	5b                   	pop    %ebx
  80280e:	5e                   	pop    %esi
  80280f:	5f                   	pop    %edi
  802810:	5d                   	pop    %ebp
  802811:	c3                   	ret    
  802812:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802818:	31 ff                	xor    %edi,%edi
  80281a:	31 db                	xor    %ebx,%ebx
  80281c:	89 d8                	mov    %ebx,%eax
  80281e:	89 fa                	mov    %edi,%edx
  802820:	83 c4 1c             	add    $0x1c,%esp
  802823:	5b                   	pop    %ebx
  802824:	5e                   	pop    %esi
  802825:	5f                   	pop    %edi
  802826:	5d                   	pop    %ebp
  802827:	c3                   	ret    
  802828:	90                   	nop
  802829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802830:	89 d8                	mov    %ebx,%eax
  802832:	f7 f7                	div    %edi
  802834:	31 ff                	xor    %edi,%edi
  802836:	89 c3                	mov    %eax,%ebx
  802838:	89 d8                	mov    %ebx,%eax
  80283a:	89 fa                	mov    %edi,%edx
  80283c:	83 c4 1c             	add    $0x1c,%esp
  80283f:	5b                   	pop    %ebx
  802840:	5e                   	pop    %esi
  802841:	5f                   	pop    %edi
  802842:	5d                   	pop    %ebp
  802843:	c3                   	ret    
  802844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802848:	39 ce                	cmp    %ecx,%esi
  80284a:	72 0c                	jb     802858 <__udivdi3+0x118>
  80284c:	31 db                	xor    %ebx,%ebx
  80284e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802852:	0f 87 34 ff ff ff    	ja     80278c <__udivdi3+0x4c>
  802858:	bb 01 00 00 00       	mov    $0x1,%ebx
  80285d:	e9 2a ff ff ff       	jmp    80278c <__udivdi3+0x4c>
  802862:	66 90                	xchg   %ax,%ax
  802864:	66 90                	xchg   %ax,%ax
  802866:	66 90                	xchg   %ax,%ax
  802868:	66 90                	xchg   %ax,%ax
  80286a:	66 90                	xchg   %ax,%ax
  80286c:	66 90                	xchg   %ax,%ax
  80286e:	66 90                	xchg   %ax,%ax

00802870 <__umoddi3>:
  802870:	55                   	push   %ebp
  802871:	57                   	push   %edi
  802872:	56                   	push   %esi
  802873:	53                   	push   %ebx
  802874:	83 ec 1c             	sub    $0x1c,%esp
  802877:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80287b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80287f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802883:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802887:	85 d2                	test   %edx,%edx
  802889:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80288d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802891:	89 f3                	mov    %esi,%ebx
  802893:	89 3c 24             	mov    %edi,(%esp)
  802896:	89 74 24 04          	mov    %esi,0x4(%esp)
  80289a:	75 1c                	jne    8028b8 <__umoddi3+0x48>
  80289c:	39 f7                	cmp    %esi,%edi
  80289e:	76 50                	jbe    8028f0 <__umoddi3+0x80>
  8028a0:	89 c8                	mov    %ecx,%eax
  8028a2:	89 f2                	mov    %esi,%edx
  8028a4:	f7 f7                	div    %edi
  8028a6:	89 d0                	mov    %edx,%eax
  8028a8:	31 d2                	xor    %edx,%edx
  8028aa:	83 c4 1c             	add    $0x1c,%esp
  8028ad:	5b                   	pop    %ebx
  8028ae:	5e                   	pop    %esi
  8028af:	5f                   	pop    %edi
  8028b0:	5d                   	pop    %ebp
  8028b1:	c3                   	ret    
  8028b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028b8:	39 f2                	cmp    %esi,%edx
  8028ba:	89 d0                	mov    %edx,%eax
  8028bc:	77 52                	ja     802910 <__umoddi3+0xa0>
  8028be:	0f bd ea             	bsr    %edx,%ebp
  8028c1:	83 f5 1f             	xor    $0x1f,%ebp
  8028c4:	75 5a                	jne    802920 <__umoddi3+0xb0>
  8028c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8028ca:	0f 82 e0 00 00 00    	jb     8029b0 <__umoddi3+0x140>
  8028d0:	39 0c 24             	cmp    %ecx,(%esp)
  8028d3:	0f 86 d7 00 00 00    	jbe    8029b0 <__umoddi3+0x140>
  8028d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028e1:	83 c4 1c             	add    $0x1c,%esp
  8028e4:	5b                   	pop    %ebx
  8028e5:	5e                   	pop    %esi
  8028e6:	5f                   	pop    %edi
  8028e7:	5d                   	pop    %ebp
  8028e8:	c3                   	ret    
  8028e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028f0:	85 ff                	test   %edi,%edi
  8028f2:	89 fd                	mov    %edi,%ebp
  8028f4:	75 0b                	jne    802901 <__umoddi3+0x91>
  8028f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028fb:	31 d2                	xor    %edx,%edx
  8028fd:	f7 f7                	div    %edi
  8028ff:	89 c5                	mov    %eax,%ebp
  802901:	89 f0                	mov    %esi,%eax
  802903:	31 d2                	xor    %edx,%edx
  802905:	f7 f5                	div    %ebp
  802907:	89 c8                	mov    %ecx,%eax
  802909:	f7 f5                	div    %ebp
  80290b:	89 d0                	mov    %edx,%eax
  80290d:	eb 99                	jmp    8028a8 <__umoddi3+0x38>
  80290f:	90                   	nop
  802910:	89 c8                	mov    %ecx,%eax
  802912:	89 f2                	mov    %esi,%edx
  802914:	83 c4 1c             	add    $0x1c,%esp
  802917:	5b                   	pop    %ebx
  802918:	5e                   	pop    %esi
  802919:	5f                   	pop    %edi
  80291a:	5d                   	pop    %ebp
  80291b:	c3                   	ret    
  80291c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802920:	8b 34 24             	mov    (%esp),%esi
  802923:	bf 20 00 00 00       	mov    $0x20,%edi
  802928:	89 e9                	mov    %ebp,%ecx
  80292a:	29 ef                	sub    %ebp,%edi
  80292c:	d3 e0                	shl    %cl,%eax
  80292e:	89 f9                	mov    %edi,%ecx
  802930:	89 f2                	mov    %esi,%edx
  802932:	d3 ea                	shr    %cl,%edx
  802934:	89 e9                	mov    %ebp,%ecx
  802936:	09 c2                	or     %eax,%edx
  802938:	89 d8                	mov    %ebx,%eax
  80293a:	89 14 24             	mov    %edx,(%esp)
  80293d:	89 f2                	mov    %esi,%edx
  80293f:	d3 e2                	shl    %cl,%edx
  802941:	89 f9                	mov    %edi,%ecx
  802943:	89 54 24 04          	mov    %edx,0x4(%esp)
  802947:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80294b:	d3 e8                	shr    %cl,%eax
  80294d:	89 e9                	mov    %ebp,%ecx
  80294f:	89 c6                	mov    %eax,%esi
  802951:	d3 e3                	shl    %cl,%ebx
  802953:	89 f9                	mov    %edi,%ecx
  802955:	89 d0                	mov    %edx,%eax
  802957:	d3 e8                	shr    %cl,%eax
  802959:	89 e9                	mov    %ebp,%ecx
  80295b:	09 d8                	or     %ebx,%eax
  80295d:	89 d3                	mov    %edx,%ebx
  80295f:	89 f2                	mov    %esi,%edx
  802961:	f7 34 24             	divl   (%esp)
  802964:	89 d6                	mov    %edx,%esi
  802966:	d3 e3                	shl    %cl,%ebx
  802968:	f7 64 24 04          	mull   0x4(%esp)
  80296c:	39 d6                	cmp    %edx,%esi
  80296e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802972:	89 d1                	mov    %edx,%ecx
  802974:	89 c3                	mov    %eax,%ebx
  802976:	72 08                	jb     802980 <__umoddi3+0x110>
  802978:	75 11                	jne    80298b <__umoddi3+0x11b>
  80297a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80297e:	73 0b                	jae    80298b <__umoddi3+0x11b>
  802980:	2b 44 24 04          	sub    0x4(%esp),%eax
  802984:	1b 14 24             	sbb    (%esp),%edx
  802987:	89 d1                	mov    %edx,%ecx
  802989:	89 c3                	mov    %eax,%ebx
  80298b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80298f:	29 da                	sub    %ebx,%edx
  802991:	19 ce                	sbb    %ecx,%esi
  802993:	89 f9                	mov    %edi,%ecx
  802995:	89 f0                	mov    %esi,%eax
  802997:	d3 e0                	shl    %cl,%eax
  802999:	89 e9                	mov    %ebp,%ecx
  80299b:	d3 ea                	shr    %cl,%edx
  80299d:	89 e9                	mov    %ebp,%ecx
  80299f:	d3 ee                	shr    %cl,%esi
  8029a1:	09 d0                	or     %edx,%eax
  8029a3:	89 f2                	mov    %esi,%edx
  8029a5:	83 c4 1c             	add    $0x1c,%esp
  8029a8:	5b                   	pop    %ebx
  8029a9:	5e                   	pop    %esi
  8029aa:	5f                   	pop    %edi
  8029ab:	5d                   	pop    %ebp
  8029ac:	c3                   	ret    
  8029ad:	8d 76 00             	lea    0x0(%esi),%esi
  8029b0:	29 f9                	sub    %edi,%ecx
  8029b2:	19 d6                	sbb    %edx,%esi
  8029b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029bc:	e9 18 ff ff ff       	jmp    8028d9 <__umoddi3+0x69>
