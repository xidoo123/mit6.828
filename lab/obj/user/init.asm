
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 e0 24 80 00       	push   $0x8024e0
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 a8 25 80 00       	push   $0x8025a8
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 ef 24 80 00       	push   $0x8024ef
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 50 80 00       	push   $0x805020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 e4 25 80 00       	push   $0x8025e4
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 06 25 80 00       	push   $0x802506
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 1c 25 80 00       	push   $0x80251c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 72 09 00 00       	call   800a7d <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 28 25 80 00       	push   $0x802528
  800123:	56                   	push   %esi
  800124:	e8 54 09 00 00       	call   800a7d <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 48 09 00 00       	call   800a7d <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 29 25 80 00       	push   $0x802529
  80013d:	56                   	push   %esi
  80013e:	e8 3a 09 00 00       	call   800a7d <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 2b 25 80 00       	push   $0x80252b
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 2f 25 80 00 	movl   $0x80252f,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 77 10 00 00       	call   8011f1 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 41 25 80 00       	push   $0x802541
  80018c:	6a 37                	push   $0x37
  80018e:	68 4e 25 80 00       	push   $0x80254e
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 5a 25 80 00       	push   $0x80255a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 4e 25 80 00       	push   $0x80254e
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 87 10 00 00       	call   801241 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 74 25 80 00       	push   $0x802574
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 4e 25 80 00       	push   $0x80254e
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 7c 25 80 00       	push   $0x80257c
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 90 25 80 00       	push   $0x802590
  8001ea:	68 8f 25 80 00       	push   $0x80258f
  8001ef:	e8 09 1b 00 00       	call   801cfd <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 93 25 80 00       	push   $0x802593
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 b5 1e 00 00       	call   8020cc <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 13 26 80 00       	push   $0x802613
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 24 08 00 00       	call   800a5d <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 78 09 00 00       	call   800bef <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 23 0b 00 00       	call   800da4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 94 0b 00 00       	call   800e41 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 10 0b 00 00       	call   800dc2 <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 bb 0a 00 00       	call   800da4 <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 2c 10 00 00       	call   80132d <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 9c 0d 00 00       	call   8010c7 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 24 0d 00 00       	call   801078 <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 f1 0a 00 00       	call   800e60 <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 bb 0c 00 00       	call   801051 <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8003aa:	e8 73 0a 00 00       	call   800e22 <sys_getenvid>
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 2c 0e 00 00       	call   80121c <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 e7 09 00 00       	call   800de1 <sys_env_destroy>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80040d:	e8 10 0a 00 00       	call   800e22 <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 2c 26 80 00       	push   $0x80262c
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 20 2b 80 00 	movl   $0x802b20,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 2f 09 00 00       	call   800da4 <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 54 01 00 00       	call   80060f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 d4 08 00 00       	call   800da4 <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800505:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800510:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800513:	39 d3                	cmp    %edx,%ebx
  800515:	72 05                	jb     80051c <printnum+0x30>
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 45                	ja     800561 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	ff 75 18             	pushl  0x18(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800528:	53                   	push   %ebx
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 10 1d 00 00       	call   802250 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 18                	jmp    80056b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 03                	jmp    800564 <printnum+0x78>
  800561:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	85 db                	test   %ebx,%ebx
  800569:	7f e8                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 e4             	pushl  -0x1c(%ebp)
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 75 dc             	pushl  -0x24(%ebp)
  80057b:	ff 75 d8             	pushl  -0x28(%ebp)
  80057e:	e8 fd 1d 00 00       	call   802380 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 4f 26 80 00 	movsbl 0x80264f(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
}
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 0e                	jle    8005b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	8b 52 04             	mov    0x4(%edx),%edx
  8005af:	eb 22                	jmp    8005d3 <getuint+0x38>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 10                	je     8005c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ba:	89 08                	mov    %ecx,(%eax)
  8005bc:	8b 02                	mov    (%edx),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c3:	eb 0e                	jmp    8005d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ca:	89 08                	mov    %ecx,(%eax)
  8005cc:	8b 02                	mov    (%edx),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 0a                	jae    8005f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	88 02                	mov    %al,(%edx)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 10             	pushl  0x10(%ebp)
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	e8 05 00 00 00       	call   80060f <vprintfmt>
	va_end(ap);
}
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 2c             	sub    $0x2c,%esp
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800621:	eb 12                	jmp    800635 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 84 89 03 00 00    	je     8009b4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800635:	83 c7 01             	add    $0x1,%edi
  800638:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063c:	83 f8 25             	cmp    $0x25,%eax
  80063f:	75 e2                	jne    800623 <vprintfmt+0x14>
  800641:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800645:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80064c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800653:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80065a:	ba 00 00 00 00       	mov    $0x0,%edx
  80065f:	eb 07                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800664:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8d 47 01             	lea    0x1(%edi),%eax
  80066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066e:	0f b6 07             	movzbl (%edi),%eax
  800671:	0f b6 c8             	movzbl %al,%ecx
  800674:	83 e8 23             	sub    $0x23,%eax
  800677:	3c 55                	cmp    $0x55,%al
  800679:	0f 87 1a 03 00 00    	ja     800999 <vprintfmt+0x38a>
  80067f:	0f b6 c0             	movzbl %al,%eax
  800682:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80068c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800690:	eb d6                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800695:	b8 00 00 00 00       	mov    $0x0,%eax
  80069a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80069d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006a0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006a4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006a7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006aa:	83 fa 09             	cmp    $0x9,%edx
  8006ad:	77 39                	ja     8006e8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006b2:	eb e9                	jmp    80069d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006c5:	eb 27                	jmp    8006ee <vprintfmt+0xdf>
  8006c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d1:	0f 49 c8             	cmovns %eax,%ecx
  8006d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	eb 8c                	jmp    800668 <vprintfmt+0x59>
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006e6:	eb 80                	jmp    800668 <vprintfmt+0x59>
  8006e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006eb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f2:	0f 89 70 ff ff ff    	jns    800668 <vprintfmt+0x59>
				width = precision, precision = -1;
  8006f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800705:	e9 5e ff ff ff       	jmp    800668 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80070a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800710:	e9 53 ff ff ff       	jmp    800668 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8d 50 04             	lea    0x4(%eax),%edx
  80071b:	89 55 14             	mov    %edx,0x14(%ebp)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	ff 30                	pushl  (%eax)
  800724:	ff d6                	call   *%esi
			break;
  800726:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80072c:	e9 04 ff ff ff       	jmp    800635 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	99                   	cltd   
  80073d:	31 d0                	xor    %edx,%eax
  80073f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800741:	83 f8 0f             	cmp    $0xf,%eax
  800744:	7f 0b                	jg     800751 <vprintfmt+0x142>
  800746:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  80074d:	85 d2                	test   %edx,%edx
  80074f:	75 18                	jne    800769 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800751:	50                   	push   %eax
  800752:	68 67 26 80 00       	push   $0x802667
  800757:	53                   	push   %ebx
  800758:	56                   	push   %esi
  800759:	e8 94 fe ff ff       	call   8005f2 <printfmt>
  80075e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800764:	e9 cc fe ff ff       	jmp    800635 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800769:	52                   	push   %edx
  80076a:	68 5a 2a 80 00       	push   $0x802a5a
  80076f:	53                   	push   %ebx
  800770:	56                   	push   %esi
  800771:	e8 7c fe ff ff       	call   8005f2 <printfmt>
  800776:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077c:	e9 b4 fe ff ff       	jmp    800635 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 50 04             	lea    0x4(%eax),%edx
  800787:	89 55 14             	mov    %edx,0x14(%ebp)
  80078a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80078c:	85 ff                	test   %edi,%edi
  80078e:	b8 60 26 80 00       	mov    $0x802660,%eax
  800793:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800796:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80079a:	0f 8e 94 00 00 00    	jle    800834 <vprintfmt+0x225>
  8007a0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007a4:	0f 84 98 00 00 00    	je     800842 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	ff 75 d0             	pushl  -0x30(%ebp)
  8007b0:	57                   	push   %edi
  8007b1:	e8 86 02 00 00       	call   800a3c <strnlen>
  8007b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007b9:	29 c1                	sub    %eax,%ecx
  8007bb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007be:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007c1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007cb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cd:	eb 0f                	jmp    8007de <vprintfmt+0x1cf>
					putch(padc, putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d8:	83 ef 01             	sub    $0x1,%edi
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	85 ff                	test   %edi,%edi
  8007e0:	7f ed                	jg     8007cf <vprintfmt+0x1c0>
  8007e2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007e5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007e8:	85 c9                	test   %ecx,%ecx
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	0f 49 c1             	cmovns %ecx,%eax
  8007f2:	29 c1                	sub    %eax,%ecx
  8007f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8007f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007fd:	89 cb                	mov    %ecx,%ebx
  8007ff:	eb 4d                	jmp    80084e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800801:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800805:	74 1b                	je     800822 <vprintfmt+0x213>
  800807:	0f be c0             	movsbl %al,%eax
  80080a:	83 e8 20             	sub    $0x20,%eax
  80080d:	83 f8 5e             	cmp    $0x5e,%eax
  800810:	76 10                	jbe    800822 <vprintfmt+0x213>
					putch('?', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	6a 3f                	push   $0x3f
  80081a:	ff 55 08             	call   *0x8(%ebp)
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	eb 0d                	jmp    80082f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	52                   	push   %edx
  800829:	ff 55 08             	call   *0x8(%ebp)
  80082c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082f:	83 eb 01             	sub    $0x1,%ebx
  800832:	eb 1a                	jmp    80084e <vprintfmt+0x23f>
  800834:	89 75 08             	mov    %esi,0x8(%ebp)
  800837:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80083a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80083d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800840:	eb 0c                	jmp    80084e <vprintfmt+0x23f>
  800842:	89 75 08             	mov    %esi,0x8(%ebp)
  800845:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800848:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084e:	83 c7 01             	add    $0x1,%edi
  800851:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800855:	0f be d0             	movsbl %al,%edx
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 23                	je     80087f <vprintfmt+0x270>
  80085c:	85 f6                	test   %esi,%esi
  80085e:	78 a1                	js     800801 <vprintfmt+0x1f2>
  800860:	83 ee 01             	sub    $0x1,%esi
  800863:	79 9c                	jns    800801 <vprintfmt+0x1f2>
  800865:	89 df                	mov    %ebx,%edi
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	eb 18                	jmp    800887 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 20                	push   $0x20
  800875:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800877:	83 ef 01             	sub    $0x1,%edi
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	eb 08                	jmp    800887 <vprintfmt+0x278>
  80087f:	89 df                	mov    %ebx,%edi
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800887:	85 ff                	test   %edi,%edi
  800889:	7f e4                	jg     80086f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088e:	e9 a2 fd ff ff       	jmp    800635 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800893:	83 fa 01             	cmp    $0x1,%edx
  800896:	7e 16                	jle    8008ae <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 08             	lea    0x8(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 50 04             	mov    0x4(%eax),%edx
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008ac:	eb 32                	jmp    8008e0 <vprintfmt+0x2d1>
	else if (lflag)
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	74 18                	je     8008ca <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c0:	89 c1                	mov    %eax,%ecx
  8008c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8008c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008c8:	eb 16                	jmp    8008e0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 00                	mov    (%eax),%eax
  8008d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d8:	89 c1                	mov    %eax,%ecx
  8008da:	c1 f9 1f             	sar    $0x1f,%ecx
  8008dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008ef:	79 74                	jns    800965 <vprintfmt+0x356>
				putch('-', putdat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	53                   	push   %ebx
  8008f5:	6a 2d                	push   $0x2d
  8008f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8008f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008ff:	f7 d8                	neg    %eax
  800901:	83 d2 00             	adc    $0x0,%edx
  800904:	f7 da                	neg    %edx
  800906:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800909:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80090e:	eb 55                	jmp    800965 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800910:	8d 45 14             	lea    0x14(%ebp),%eax
  800913:	e8 83 fc ff ff       	call   80059b <getuint>
			base = 10;
  800918:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80091d:	eb 46                	jmp    800965 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
  800922:	e8 74 fc ff ff       	call   80059b <getuint>
			base = 8;
  800927:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80092c:	eb 37                	jmp    800965 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	53                   	push   %ebx
  800932:	6a 30                	push   $0x30
  800934:	ff d6                	call   *%esi
			putch('x', putdat);
  800936:	83 c4 08             	add    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 78                	push   $0x78
  80093c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 50 04             	lea    0x4(%eax),%edx
  800944:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800947:	8b 00                	mov    (%eax),%eax
  800949:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80094e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800951:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800956:	eb 0d                	jmp    800965 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
  80095b:	e8 3b fc ff ff       	call   80059b <getuint>
			base = 16;
  800960:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800965:	83 ec 0c             	sub    $0xc,%esp
  800968:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80096c:	57                   	push   %edi
  80096d:	ff 75 e0             	pushl  -0x20(%ebp)
  800970:	51                   	push   %ecx
  800971:	52                   	push   %edx
  800972:	50                   	push   %eax
  800973:	89 da                	mov    %ebx,%edx
  800975:	89 f0                	mov    %esi,%eax
  800977:	e8 70 fb ff ff       	call   8004ec <printnum>
			break;
  80097c:	83 c4 20             	add    $0x20,%esp
  80097f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800982:	e9 ae fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800987:	83 ec 08             	sub    $0x8,%esp
  80098a:	53                   	push   %ebx
  80098b:	51                   	push   %ecx
  80098c:	ff d6                	call   *%esi
			break;
  80098e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800991:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800994:	e9 9c fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	53                   	push   %ebx
  80099d:	6a 25                	push   $0x25
  80099f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a1:	83 c4 10             	add    $0x10,%esp
  8009a4:	eb 03                	jmp    8009a9 <vprintfmt+0x39a>
  8009a6:	83 ef 01             	sub    $0x1,%edi
  8009a9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009ad:	75 f7                	jne    8009a6 <vprintfmt+0x397>
  8009af:	e9 81 fc ff ff       	jmp    800635 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 18             	sub    $0x18,%esp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d9:	85 c0                	test   %eax,%eax
  8009db:	74 26                	je     800a03 <vsnprintf+0x47>
  8009dd:	85 d2                	test   %edx,%edx
  8009df:	7e 22                	jle    800a03 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009e1:	ff 75 14             	pushl  0x14(%ebp)
  8009e4:	ff 75 10             	pushl  0x10(%ebp)
  8009e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ea:	50                   	push   %eax
  8009eb:	68 d5 05 80 00       	push   $0x8005d5
  8009f0:	e8 1a fc ff ff       	call   80060f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fe:	83 c4 10             	add    $0x10,%esp
  800a01:	eb 05                	jmp    800a08 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a10:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a13:	50                   	push   %eax
  800a14:	ff 75 10             	pushl  0x10(%ebp)
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	ff 75 08             	pushl  0x8(%ebp)
  800a1d:	e8 9a ff ff ff       	call   8009bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	eb 03                	jmp    800a34 <strlen+0x10>
		n++;
  800a31:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a34:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a38:	75 f7                	jne    800a31 <strlen+0xd>
		n++;
	return n;
}
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	eb 03                	jmp    800a4f <strnlen+0x13>
		n++;
  800a4c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	39 c2                	cmp    %eax,%edx
  800a51:	74 08                	je     800a5b <strnlen+0x1f>
  800a53:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a57:	75 f3                	jne    800a4c <strnlen+0x10>
  800a59:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	53                   	push   %ebx
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a67:	89 c2                	mov    %eax,%edx
  800a69:	83 c2 01             	add    $0x1,%edx
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a73:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a76:	84 db                	test   %bl,%bl
  800a78:	75 ef                	jne    800a69 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a84:	53                   	push   %ebx
  800a85:	e8 9a ff ff ff       	call   800a24 <strlen>
  800a8a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a8d:	ff 75 0c             	pushl  0xc(%ebp)
  800a90:	01 d8                	add    %ebx,%eax
  800a92:	50                   	push   %eax
  800a93:	e8 c5 ff ff ff       	call   800a5d <strcpy>
	return dst;
}
  800a98:	89 d8                	mov    %ebx,%eax
  800a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aaf:	89 f2                	mov    %esi,%edx
  800ab1:	eb 0f                	jmp    800ac2 <strncpy+0x23>
		*dst++ = *src;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800abc:	80 39 01             	cmpb   $0x1,(%ecx)
  800abf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac2:	39 da                	cmp    %ebx,%edx
  800ac4:	75 ed                	jne    800ab3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac6:	89 f0                	mov    %esi,%eax
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad7:	8b 55 10             	mov    0x10(%ebp),%edx
  800ada:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800adc:	85 d2                	test   %edx,%edx
  800ade:	74 21                	je     800b01 <strlcpy+0x35>
  800ae0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ae4:	89 f2                	mov    %esi,%edx
  800ae6:	eb 09                	jmp    800af1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ae8:	83 c2 01             	add    $0x1,%edx
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af1:	39 c2                	cmp    %eax,%edx
  800af3:	74 09                	je     800afe <strlcpy+0x32>
  800af5:	0f b6 19             	movzbl (%ecx),%ebx
  800af8:	84 db                	test   %bl,%bl
  800afa:	75 ec                	jne    800ae8 <strlcpy+0x1c>
  800afc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800afe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b01:	29 f0                	sub    %esi,%eax
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b10:	eb 06                	jmp    800b18 <strcmp+0x11>
		p++, q++;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b18:	0f b6 01             	movzbl (%ecx),%eax
  800b1b:	84 c0                	test   %al,%al
  800b1d:	74 04                	je     800b23 <strcmp+0x1c>
  800b1f:	3a 02                	cmp    (%edx),%al
  800b21:	74 ef                	je     800b12 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b23:	0f b6 c0             	movzbl %al,%eax
  800b26:	0f b6 12             	movzbl (%edx),%edx
  800b29:	29 d0                	sub    %edx,%eax
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	53                   	push   %ebx
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b37:	89 c3                	mov    %eax,%ebx
  800b39:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b3c:	eb 06                	jmp    800b44 <strncmp+0x17>
		n--, p++, q++;
  800b3e:	83 c0 01             	add    $0x1,%eax
  800b41:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b44:	39 d8                	cmp    %ebx,%eax
  800b46:	74 15                	je     800b5d <strncmp+0x30>
  800b48:	0f b6 08             	movzbl (%eax),%ecx
  800b4b:	84 c9                	test   %cl,%cl
  800b4d:	74 04                	je     800b53 <strncmp+0x26>
  800b4f:	3a 0a                	cmp    (%edx),%cl
  800b51:	74 eb                	je     800b3e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b53:	0f b6 00             	movzbl (%eax),%eax
  800b56:	0f b6 12             	movzbl (%edx),%edx
  800b59:	29 d0                	sub    %edx,%eax
  800b5b:	eb 05                	jmp    800b62 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b6f:	eb 07                	jmp    800b78 <strchr+0x13>
		if (*s == c)
  800b71:	38 ca                	cmp    %cl,%dl
  800b73:	74 0f                	je     800b84 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b75:	83 c0 01             	add    $0x1,%eax
  800b78:	0f b6 10             	movzbl (%eax),%edx
  800b7b:	84 d2                	test   %dl,%dl
  800b7d:	75 f2                	jne    800b71 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b90:	eb 03                	jmp    800b95 <strfind+0xf>
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b98:	38 ca                	cmp    %cl,%dl
  800b9a:	74 04                	je     800ba0 <strfind+0x1a>
  800b9c:	84 d2                	test   %dl,%dl
  800b9e:	75 f2                	jne    800b92 <strfind+0xc>
			break;
	return (char *) s;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bae:	85 c9                	test   %ecx,%ecx
  800bb0:	74 36                	je     800be8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb8:	75 28                	jne    800be2 <memset+0x40>
  800bba:	f6 c1 03             	test   $0x3,%cl
  800bbd:	75 23                	jne    800be2 <memset+0x40>
		c &= 0xFF;
  800bbf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	c1 e3 08             	shl    $0x8,%ebx
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	c1 e6 18             	shl    $0x18,%esi
  800bcd:	89 d0                	mov    %edx,%eax
  800bcf:	c1 e0 10             	shl    $0x10,%eax
  800bd2:	09 f0                	or     %esi,%eax
  800bd4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bd6:	89 d8                	mov    %ebx,%eax
  800bd8:	09 d0                	or     %edx,%eax
  800bda:	c1 e9 02             	shr    $0x2,%ecx
  800bdd:	fc                   	cld    
  800bde:	f3 ab                	rep stos %eax,%es:(%edi)
  800be0:	eb 06                	jmp    800be8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	fc                   	cld    
  800be6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be8:	89 f8                	mov    %edi,%eax
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bfd:	39 c6                	cmp    %eax,%esi
  800bff:	73 35                	jae    800c36 <memmove+0x47>
  800c01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c04:	39 d0                	cmp    %edx,%eax
  800c06:	73 2e                	jae    800c36 <memmove+0x47>
		s += n;
		d += n;
  800c08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	09 fe                	or     %edi,%esi
  800c0f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c15:	75 13                	jne    800c2a <memmove+0x3b>
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 0e                	jne    800c2a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c1c:	83 ef 04             	sub    $0x4,%edi
  800c1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c22:	c1 e9 02             	shr    $0x2,%ecx
  800c25:	fd                   	std    
  800c26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c28:	eb 09                	jmp    800c33 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2a:	83 ef 01             	sub    $0x1,%edi
  800c2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c30:	fd                   	std    
  800c31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c33:	fc                   	cld    
  800c34:	eb 1d                	jmp    800c53 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c36:	89 f2                	mov    %esi,%edx
  800c38:	09 c2                	or     %eax,%edx
  800c3a:	f6 c2 03             	test   $0x3,%dl
  800c3d:	75 0f                	jne    800c4e <memmove+0x5f>
  800c3f:	f6 c1 03             	test   $0x3,%cl
  800c42:	75 0a                	jne    800c4e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c44:	c1 e9 02             	shr    $0x2,%ecx
  800c47:	89 c7                	mov    %eax,%edi
  800c49:	fc                   	cld    
  800c4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4c:	eb 05                	jmp    800c53 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c4e:	89 c7                	mov    %eax,%edi
  800c50:	fc                   	cld    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c5a:	ff 75 10             	pushl  0x10(%ebp)
  800c5d:	ff 75 0c             	pushl  0xc(%ebp)
  800c60:	ff 75 08             	pushl  0x8(%ebp)
  800c63:	e8 87 ff ff ff       	call   800bef <memmove>
}
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c75:	89 c6                	mov    %eax,%esi
  800c77:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7a:	eb 1a                	jmp    800c96 <memcmp+0x2c>
		if (*s1 != *s2)
  800c7c:	0f b6 08             	movzbl (%eax),%ecx
  800c7f:	0f b6 1a             	movzbl (%edx),%ebx
  800c82:	38 d9                	cmp    %bl,%cl
  800c84:	74 0a                	je     800c90 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c86:	0f b6 c1             	movzbl %cl,%eax
  800c89:	0f b6 db             	movzbl %bl,%ebx
  800c8c:	29 d8                	sub    %ebx,%eax
  800c8e:	eb 0f                	jmp    800c9f <memcmp+0x35>
		s1++, s2++;
  800c90:	83 c0 01             	add    $0x1,%eax
  800c93:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c96:	39 f0                	cmp    %esi,%eax
  800c98:	75 e2                	jne    800c7c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	53                   	push   %ebx
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800caa:	89 c1                	mov    %eax,%ecx
  800cac:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800caf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb3:	eb 0a                	jmp    800cbf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb5:	0f b6 10             	movzbl (%eax),%edx
  800cb8:	39 da                	cmp    %ebx,%edx
  800cba:	74 07                	je     800cc3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cbc:	83 c0 01             	add    $0x1,%eax
  800cbf:	39 c8                	cmp    %ecx,%eax
  800cc1:	72 f2                	jb     800cb5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd2:	eb 03                	jmp    800cd7 <strtol+0x11>
		s++;
  800cd4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd7:	0f b6 01             	movzbl (%ecx),%eax
  800cda:	3c 20                	cmp    $0x20,%al
  800cdc:	74 f6                	je     800cd4 <strtol+0xe>
  800cde:	3c 09                	cmp    $0x9,%al
  800ce0:	74 f2                	je     800cd4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce2:	3c 2b                	cmp    $0x2b,%al
  800ce4:	75 0a                	jne    800cf0 <strtol+0x2a>
		s++;
  800ce6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cee:	eb 11                	jmp    800d01 <strtol+0x3b>
  800cf0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cf5:	3c 2d                	cmp    $0x2d,%al
  800cf7:	75 08                	jne    800d01 <strtol+0x3b>
		s++, neg = 1;
  800cf9:	83 c1 01             	add    $0x1,%ecx
  800cfc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d01:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d07:	75 15                	jne    800d1e <strtol+0x58>
  800d09:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0c:	75 10                	jne    800d1e <strtol+0x58>
  800d0e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d12:	75 7c                	jne    800d90 <strtol+0xca>
		s += 2, base = 16;
  800d14:	83 c1 02             	add    $0x2,%ecx
  800d17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d1c:	eb 16                	jmp    800d34 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d1e:	85 db                	test   %ebx,%ebx
  800d20:	75 12                	jne    800d34 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d22:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d27:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2a:	75 08                	jne    800d34 <strtol+0x6e>
		s++, base = 8;
  800d2c:	83 c1 01             	add    $0x1,%ecx
  800d2f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d34:	b8 00 00 00 00       	mov    $0x0,%eax
  800d39:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d3c:	0f b6 11             	movzbl (%ecx),%edx
  800d3f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d42:	89 f3                	mov    %esi,%ebx
  800d44:	80 fb 09             	cmp    $0x9,%bl
  800d47:	77 08                	ja     800d51 <strtol+0x8b>
			dig = *s - '0';
  800d49:	0f be d2             	movsbl %dl,%edx
  800d4c:	83 ea 30             	sub    $0x30,%edx
  800d4f:	eb 22                	jmp    800d73 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d51:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d54:	89 f3                	mov    %esi,%ebx
  800d56:	80 fb 19             	cmp    $0x19,%bl
  800d59:	77 08                	ja     800d63 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d5b:	0f be d2             	movsbl %dl,%edx
  800d5e:	83 ea 57             	sub    $0x57,%edx
  800d61:	eb 10                	jmp    800d73 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d63:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d66:	89 f3                	mov    %esi,%ebx
  800d68:	80 fb 19             	cmp    $0x19,%bl
  800d6b:	77 16                	ja     800d83 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d6d:	0f be d2             	movsbl %dl,%edx
  800d70:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d73:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d76:	7d 0b                	jge    800d83 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d78:	83 c1 01             	add    $0x1,%ecx
  800d7b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d7f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d81:	eb b9                	jmp    800d3c <strtol+0x76>

	if (endptr)
  800d83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d87:	74 0d                	je     800d96 <strtol+0xd0>
		*endptr = (char *) s;
  800d89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8c:	89 0e                	mov    %ecx,(%esi)
  800d8e:	eb 06                	jmp    800d96 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d90:	85 db                	test   %ebx,%ebx
  800d92:	74 98                	je     800d2c <strtol+0x66>
  800d94:	eb 9e                	jmp    800d34 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d96:	89 c2                	mov    %eax,%edx
  800d98:	f7 da                	neg    %edx
  800d9a:	85 ff                	test   %edi,%edi
  800d9c:	0f 45 c2             	cmovne %edx,%eax
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b8 00 00 00 00       	mov    $0x0,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 c3                	mov    %eax,%ebx
  800db7:	89 c7                	mov    %eax,%edi
  800db9:	89 c6                	mov    %eax,%esi
  800dbb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	89 d3                	mov    %edx,%ebx
  800dd6:	89 d7                	mov    %edx,%edi
  800dd8:	89 d6                	mov    %edx,%esi
  800dda:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800def:	b8 03 00 00 00       	mov    $0x3,%eax
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 cb                	mov    %ecx,%ebx
  800df9:	89 cf                	mov    %ecx,%edi
  800dfb:	89 ce                	mov    %ecx,%esi
  800dfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 17                	jle    800e1a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 03                	push   $0x3
  800e09:	68 5f 29 80 00       	push   $0x80295f
  800e0e:	6a 23                	push   $0x23
  800e10:	68 7c 29 80 00       	push   $0x80297c
  800e15:	e8 e5 f5 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e32:	89 d1                	mov    %edx,%ecx
  800e34:	89 d3                	mov    %edx,%ebx
  800e36:	89 d7                	mov    %edx,%edi
  800e38:	89 d6                	mov    %edx,%esi
  800e3a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_yield>:

void
sys_yield(void)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e47:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e51:	89 d1                	mov    %edx,%ecx
  800e53:	89 d3                	mov    %edx,%ebx
  800e55:	89 d7                	mov    %edx,%edi
  800e57:	89 d6                	mov    %edx,%esi
  800e59:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	be 00 00 00 00       	mov    $0x0,%esi
  800e6e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7c:	89 f7                	mov    %esi,%edi
  800e7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 17                	jle    800e9b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	6a 04                	push   $0x4
  800e8a:	68 5f 29 80 00       	push   $0x80295f
  800e8f:	6a 23                	push   $0x23
  800e91:	68 7c 29 80 00       	push   $0x80297c
  800e96:	e8 64 f5 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebd:	8b 75 18             	mov    0x18(%ebp),%esi
  800ec0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 17                	jle    800edd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	50                   	push   %eax
  800eca:	6a 05                	push   $0x5
  800ecc:	68 5f 29 80 00       	push   $0x80295f
  800ed1:	6a 23                	push   $0x23
  800ed3:	68 7c 29 80 00       	push   $0x80297c
  800ed8:	e8 22 f5 ff ff       	call   8003ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800edd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	89 df                	mov    %ebx,%edi
  800f00:	89 de                	mov    %ebx,%esi
  800f02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7e 17                	jle    800f1f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	50                   	push   %eax
  800f0c:	6a 06                	push   $0x6
  800f0e:	68 5f 29 80 00       	push   $0x80295f
  800f13:	6a 23                	push   $0x23
  800f15:	68 7c 29 80 00       	push   $0x80297c
  800f1a:	e8 e0 f4 ff ff       	call   8003ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f35:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	89 df                	mov    %ebx,%edi
  800f42:	89 de                	mov    %ebx,%esi
  800f44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7e 17                	jle    800f61 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	50                   	push   %eax
  800f4e:	6a 08                	push   $0x8
  800f50:	68 5f 29 80 00       	push   $0x80295f
  800f55:	6a 23                	push   $0x23
  800f57:	68 7c 29 80 00       	push   $0x80297c
  800f5c:	e8 9e f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f77:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f82:	89 df                	mov    %ebx,%edi
  800f84:	89 de                	mov    %ebx,%esi
  800f86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	7e 17                	jle    800fa3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	50                   	push   %eax
  800f90:	6a 09                	push   $0x9
  800f92:	68 5f 29 80 00       	push   $0x80295f
  800f97:	6a 23                	push   $0x23
  800f99:	68 7c 29 80 00       	push   $0x80297c
  800f9e:	e8 5c f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	57                   	push   %edi
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	89 df                	mov    %ebx,%edi
  800fc6:	89 de                	mov    %ebx,%esi
  800fc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	7e 17                	jle    800fe5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	50                   	push   %eax
  800fd2:	6a 0a                	push   $0xa
  800fd4:	68 5f 29 80 00       	push   $0x80295f
  800fd9:	6a 23                	push   $0x23
  800fdb:	68 7c 29 80 00       	push   $0x80297c
  800fe0:	e8 1a f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fe5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	57                   	push   %edi
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff3:	be 00 00 00 00       	mov    $0x0,%esi
  800ff8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ffd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801006:	8b 7d 14             	mov    0x14(%ebp),%edi
  801009:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	89 cb                	mov    %ecx,%ebx
  801028:	89 cf                	mov    %ecx,%edi
  80102a:	89 ce                	mov    %ecx,%esi
  80102c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102e:	85 c0                	test   %eax,%eax
  801030:	7e 17                	jle    801049 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	50                   	push   %eax
  801036:	6a 0d                	push   $0xd
  801038:	68 5f 29 80 00       	push   $0x80295f
  80103d:	6a 23                	push   $0x23
  80103f:	68 7c 29 80 00       	push   $0x80297c
  801044:	e8 b6 f3 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801054:	8b 45 08             	mov    0x8(%ebp),%eax
  801057:	05 00 00 00 30       	add    $0x30000000,%eax
  80105c:	c1 e8 0c             	shr    $0xc,%eax
}
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801064:	8b 45 08             	mov    0x8(%ebp),%eax
  801067:	05 00 00 00 30       	add    $0x30000000,%eax
  80106c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801071:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801083:	89 c2                	mov    %eax,%edx
  801085:	c1 ea 16             	shr    $0x16,%edx
  801088:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	74 11                	je     8010a5 <fd_alloc+0x2d>
  801094:	89 c2                	mov    %eax,%edx
  801096:	c1 ea 0c             	shr    $0xc,%edx
  801099:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a0:	f6 c2 01             	test   $0x1,%dl
  8010a3:	75 09                	jne    8010ae <fd_alloc+0x36>
			*fd_store = fd;
  8010a5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ac:	eb 17                	jmp    8010c5 <fd_alloc+0x4d>
  8010ae:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010b8:	75 c9                	jne    801083 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010ba:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010c0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c5:	5d                   	pop    %ebp
  8010c6:	c3                   	ret    

008010c7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010cd:	83 f8 1f             	cmp    $0x1f,%eax
  8010d0:	77 36                	ja     801108 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d2:	c1 e0 0c             	shl    $0xc,%eax
  8010d5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010da:	89 c2                	mov    %eax,%edx
  8010dc:	c1 ea 16             	shr    $0x16,%edx
  8010df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e6:	f6 c2 01             	test   $0x1,%dl
  8010e9:	74 24                	je     80110f <fd_lookup+0x48>
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	c1 ea 0c             	shr    $0xc,%edx
  8010f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f7:	f6 c2 01             	test   $0x1,%dl
  8010fa:	74 1a                	je     801116 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ff:	89 02                	mov    %eax,(%edx)
	return 0;
  801101:	b8 00 00 00 00       	mov    $0x0,%eax
  801106:	eb 13                	jmp    80111b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801108:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110d:	eb 0c                	jmp    80111b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801114:	eb 05                	jmp    80111b <fd_lookup+0x54>
  801116:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	83 ec 08             	sub    $0x8,%esp
  801123:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801126:	ba 08 2a 80 00       	mov    $0x802a08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80112b:	eb 13                	jmp    801140 <dev_lookup+0x23>
  80112d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801130:	39 08                	cmp    %ecx,(%eax)
  801132:	75 0c                	jne    801140 <dev_lookup+0x23>
			*dev = devtab[i];
  801134:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801137:	89 01                	mov    %eax,(%ecx)
			return 0;
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
  80113e:	eb 2e                	jmp    80116e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801140:	8b 02                	mov    (%edx),%eax
  801142:	85 c0                	test   %eax,%eax
  801144:	75 e7                	jne    80112d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801146:	a1 90 67 80 00       	mov    0x806790,%eax
  80114b:	8b 40 48             	mov    0x48(%eax),%eax
  80114e:	83 ec 04             	sub    $0x4,%esp
  801151:	51                   	push   %ecx
  801152:	50                   	push   %eax
  801153:	68 8c 29 80 00       	push   $0x80298c
  801158:	e8 7b f3 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  80115d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801160:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	83 ec 10             	sub    $0x10,%esp
  801178:	8b 75 08             	mov    0x8(%ebp),%esi
  80117b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80117e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801188:	c1 e8 0c             	shr    $0xc,%eax
  80118b:	50                   	push   %eax
  80118c:	e8 36 ff ff ff       	call   8010c7 <fd_lookup>
  801191:	83 c4 08             	add    $0x8,%esp
  801194:	85 c0                	test   %eax,%eax
  801196:	78 05                	js     80119d <fd_close+0x2d>
	    || fd != fd2)
  801198:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80119b:	74 0c                	je     8011a9 <fd_close+0x39>
		return (must_exist ? r : 0);
  80119d:	84 db                	test   %bl,%bl
  80119f:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a4:	0f 44 c2             	cmove  %edx,%eax
  8011a7:	eb 41                	jmp    8011ea <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011af:	50                   	push   %eax
  8011b0:	ff 36                	pushl  (%esi)
  8011b2:	e8 66 ff ff ff       	call   80111d <dev_lookup>
  8011b7:	89 c3                	mov    %eax,%ebx
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 1a                	js     8011da <fd_close+0x6a>
		if (dev->dev_close)
  8011c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011c6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	74 0b                	je     8011da <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011cf:	83 ec 0c             	sub    $0xc,%esp
  8011d2:	56                   	push   %esi
  8011d3:	ff d0                	call   *%eax
  8011d5:	89 c3                	mov    %eax,%ebx
  8011d7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	56                   	push   %esi
  8011de:	6a 00                	push   $0x0
  8011e0:	e8 00 fd ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	89 d8                	mov    %ebx,%eax
}
  8011ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fa:	50                   	push   %eax
  8011fb:	ff 75 08             	pushl  0x8(%ebp)
  8011fe:	e8 c4 fe ff ff       	call   8010c7 <fd_lookup>
  801203:	83 c4 08             	add    $0x8,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	78 10                	js     80121a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	6a 01                	push   $0x1
  80120f:	ff 75 f4             	pushl  -0xc(%ebp)
  801212:	e8 59 ff ff ff       	call   801170 <fd_close>
  801217:	83 c4 10             	add    $0x10,%esp
}
  80121a:	c9                   	leave  
  80121b:	c3                   	ret    

0080121c <close_all>:

void
close_all(void)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	53                   	push   %ebx
  801220:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801223:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801228:	83 ec 0c             	sub    $0xc,%esp
  80122b:	53                   	push   %ebx
  80122c:	e8 c0 ff ff ff       	call   8011f1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801231:	83 c3 01             	add    $0x1,%ebx
  801234:	83 c4 10             	add    $0x10,%esp
  801237:	83 fb 20             	cmp    $0x20,%ebx
  80123a:	75 ec                	jne    801228 <close_all+0xc>
		close(i);
}
  80123c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	57                   	push   %edi
  801245:	56                   	push   %esi
  801246:	53                   	push   %ebx
  801247:	83 ec 2c             	sub    $0x2c,%esp
  80124a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80124d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	ff 75 08             	pushl  0x8(%ebp)
  801254:	e8 6e fe ff ff       	call   8010c7 <fd_lookup>
  801259:	83 c4 08             	add    $0x8,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	0f 88 c1 00 00 00    	js     801325 <dup+0xe4>
		return r;
	close(newfdnum);
  801264:	83 ec 0c             	sub    $0xc,%esp
  801267:	56                   	push   %esi
  801268:	e8 84 ff ff ff       	call   8011f1 <close>

	newfd = INDEX2FD(newfdnum);
  80126d:	89 f3                	mov    %esi,%ebx
  80126f:	c1 e3 0c             	shl    $0xc,%ebx
  801272:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801278:	83 c4 04             	add    $0x4,%esp
  80127b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80127e:	e8 de fd ff ff       	call   801061 <fd2data>
  801283:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801285:	89 1c 24             	mov    %ebx,(%esp)
  801288:	e8 d4 fd ff ff       	call   801061 <fd2data>
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801293:	89 f8                	mov    %edi,%eax
  801295:	c1 e8 16             	shr    $0x16,%eax
  801298:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80129f:	a8 01                	test   $0x1,%al
  8012a1:	74 37                	je     8012da <dup+0x99>
  8012a3:	89 f8                	mov    %edi,%eax
  8012a5:	c1 e8 0c             	shr    $0xc,%eax
  8012a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012af:	f6 c2 01             	test   $0x1,%dl
  8012b2:	74 26                	je     8012da <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c3:	50                   	push   %eax
  8012c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012c7:	6a 00                	push   $0x0
  8012c9:	57                   	push   %edi
  8012ca:	6a 00                	push   $0x0
  8012cc:	e8 d2 fb ff ff       	call   800ea3 <sys_page_map>
  8012d1:	89 c7                	mov    %eax,%edi
  8012d3:	83 c4 20             	add    $0x20,%esp
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 2e                	js     801308 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012dd:	89 d0                	mov    %edx,%eax
  8012df:	c1 e8 0c             	shr    $0xc,%eax
  8012e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e9:	83 ec 0c             	sub    $0xc,%esp
  8012ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f1:	50                   	push   %eax
  8012f2:	53                   	push   %ebx
  8012f3:	6a 00                	push   $0x0
  8012f5:	52                   	push   %edx
  8012f6:	6a 00                	push   $0x0
  8012f8:	e8 a6 fb ff ff       	call   800ea3 <sys_page_map>
  8012fd:	89 c7                	mov    %eax,%edi
  8012ff:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801302:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801304:	85 ff                	test   %edi,%edi
  801306:	79 1d                	jns    801325 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	53                   	push   %ebx
  80130c:	6a 00                	push   $0x0
  80130e:	e8 d2 fb ff ff       	call   800ee5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	ff 75 d4             	pushl  -0x2c(%ebp)
  801319:	6a 00                	push   $0x0
  80131b:	e8 c5 fb ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	89 f8                	mov    %edi,%eax
}
  801325:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5f                   	pop    %edi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	53                   	push   %ebx
  801331:	83 ec 14             	sub    $0x14,%esp
  801334:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801337:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	53                   	push   %ebx
  80133c:	e8 86 fd ff ff       	call   8010c7 <fd_lookup>
  801341:	83 c4 08             	add    $0x8,%esp
  801344:	89 c2                	mov    %eax,%edx
  801346:	85 c0                	test   %eax,%eax
  801348:	78 6d                	js     8013b7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801350:	50                   	push   %eax
  801351:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801354:	ff 30                	pushl  (%eax)
  801356:	e8 c2 fd ff ff       	call   80111d <dev_lookup>
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 4c                	js     8013ae <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801362:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801365:	8b 42 08             	mov    0x8(%edx),%eax
  801368:	83 e0 03             	and    $0x3,%eax
  80136b:	83 f8 01             	cmp    $0x1,%eax
  80136e:	75 21                	jne    801391 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801370:	a1 90 67 80 00       	mov    0x806790,%eax
  801375:	8b 40 48             	mov    0x48(%eax),%eax
  801378:	83 ec 04             	sub    $0x4,%esp
  80137b:	53                   	push   %ebx
  80137c:	50                   	push   %eax
  80137d:	68 cd 29 80 00       	push   $0x8029cd
  801382:	e8 51 f1 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80138f:	eb 26                	jmp    8013b7 <read+0x8a>
	}
	if (!dev->dev_read)
  801391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801394:	8b 40 08             	mov    0x8(%eax),%eax
  801397:	85 c0                	test   %eax,%eax
  801399:	74 17                	je     8013b2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80139b:	83 ec 04             	sub    $0x4,%esp
  80139e:	ff 75 10             	pushl  0x10(%ebp)
  8013a1:	ff 75 0c             	pushl  0xc(%ebp)
  8013a4:	52                   	push   %edx
  8013a5:	ff d0                	call   *%eax
  8013a7:	89 c2                	mov    %eax,%edx
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	eb 09                	jmp    8013b7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	eb 05                	jmp    8013b7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013b7:	89 d0                	mov    %edx,%eax
  8013b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	57                   	push   %edi
  8013c2:	56                   	push   %esi
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 0c             	sub    $0xc,%esp
  8013c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d2:	eb 21                	jmp    8013f5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d4:	83 ec 04             	sub    $0x4,%esp
  8013d7:	89 f0                	mov    %esi,%eax
  8013d9:	29 d8                	sub    %ebx,%eax
  8013db:	50                   	push   %eax
  8013dc:	89 d8                	mov    %ebx,%eax
  8013de:	03 45 0c             	add    0xc(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	57                   	push   %edi
  8013e3:	e8 45 ff ff ff       	call   80132d <read>
		if (m < 0)
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 10                	js     8013ff <readn+0x41>
			return m;
		if (m == 0)
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	74 0a                	je     8013fd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f3:	01 c3                	add    %eax,%ebx
  8013f5:	39 f3                	cmp    %esi,%ebx
  8013f7:	72 db                	jb     8013d4 <readn+0x16>
  8013f9:	89 d8                	mov    %ebx,%eax
  8013fb:	eb 02                	jmp    8013ff <readn+0x41>
  8013fd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801402:	5b                   	pop    %ebx
  801403:	5e                   	pop    %esi
  801404:	5f                   	pop    %edi
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	53                   	push   %ebx
  80140b:	83 ec 14             	sub    $0x14,%esp
  80140e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801411:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	53                   	push   %ebx
  801416:	e8 ac fc ff ff       	call   8010c7 <fd_lookup>
  80141b:	83 c4 08             	add    $0x8,%esp
  80141e:	89 c2                	mov    %eax,%edx
  801420:	85 c0                	test   %eax,%eax
  801422:	78 68                	js     80148c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142e:	ff 30                	pushl  (%eax)
  801430:	e8 e8 fc ff ff       	call   80111d <dev_lookup>
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 47                	js     801483 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801443:	75 21                	jne    801466 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801445:	a1 90 67 80 00       	mov    0x806790,%eax
  80144a:	8b 40 48             	mov    0x48(%eax),%eax
  80144d:	83 ec 04             	sub    $0x4,%esp
  801450:	53                   	push   %ebx
  801451:	50                   	push   %eax
  801452:	68 e9 29 80 00       	push   $0x8029e9
  801457:	e8 7c f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801464:	eb 26                	jmp    80148c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801466:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801469:	8b 52 0c             	mov    0xc(%edx),%edx
  80146c:	85 d2                	test   %edx,%edx
  80146e:	74 17                	je     801487 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801470:	83 ec 04             	sub    $0x4,%esp
  801473:	ff 75 10             	pushl  0x10(%ebp)
  801476:	ff 75 0c             	pushl  0xc(%ebp)
  801479:	50                   	push   %eax
  80147a:	ff d2                	call   *%edx
  80147c:	89 c2                	mov    %eax,%edx
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	eb 09                	jmp    80148c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801483:	89 c2                	mov    %eax,%edx
  801485:	eb 05                	jmp    80148c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801487:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80148c:	89 d0                	mov    %edx,%eax
  80148e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <seek>:

int
seek(int fdnum, off_t offset)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801499:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	ff 75 08             	pushl  0x8(%ebp)
  8014a0:	e8 22 fc ff ff       	call   8010c7 <fd_lookup>
  8014a5:	83 c4 08             	add    $0x8,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 0e                	js     8014ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 14             	sub    $0x14,%esp
  8014c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	53                   	push   %ebx
  8014cb:	e8 f7 fb ff ff       	call   8010c7 <fd_lookup>
  8014d0:	83 c4 08             	add    $0x8,%esp
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 65                	js     80153e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e3:	ff 30                	pushl  (%eax)
  8014e5:	e8 33 fc ff ff       	call   80111d <dev_lookup>
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 44                	js     801535 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f8:	75 21                	jne    80151b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014fa:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014ff:	8b 40 48             	mov    0x48(%eax),%eax
  801502:	83 ec 04             	sub    $0x4,%esp
  801505:	53                   	push   %ebx
  801506:	50                   	push   %eax
  801507:	68 ac 29 80 00       	push   $0x8029ac
  80150c:	e8 c7 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801519:	eb 23                	jmp    80153e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80151b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151e:	8b 52 18             	mov    0x18(%edx),%edx
  801521:	85 d2                	test   %edx,%edx
  801523:	74 14                	je     801539 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	ff 75 0c             	pushl  0xc(%ebp)
  80152b:	50                   	push   %eax
  80152c:	ff d2                	call   *%edx
  80152e:	89 c2                	mov    %eax,%edx
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	eb 09                	jmp    80153e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801535:	89 c2                	mov    %eax,%edx
  801537:	eb 05                	jmp    80153e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801539:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80153e:	89 d0                	mov    %edx,%eax
  801540:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	53                   	push   %ebx
  801549:	83 ec 14             	sub    $0x14,%esp
  80154c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	ff 75 08             	pushl  0x8(%ebp)
  801556:	e8 6c fb ff ff       	call   8010c7 <fd_lookup>
  80155b:	83 c4 08             	add    $0x8,%esp
  80155e:	89 c2                	mov    %eax,%edx
  801560:	85 c0                	test   %eax,%eax
  801562:	78 58                	js     8015bc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156e:	ff 30                	pushl  (%eax)
  801570:	e8 a8 fb ff ff       	call   80111d <dev_lookup>
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 37                	js     8015b3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80157c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801583:	74 32                	je     8015b7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801585:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801588:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80158f:	00 00 00 
	stat->st_isdir = 0;
  801592:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801599:	00 00 00 
	stat->st_dev = dev;
  80159c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015a2:	83 ec 08             	sub    $0x8,%esp
  8015a5:	53                   	push   %ebx
  8015a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a9:	ff 50 14             	call   *0x14(%eax)
  8015ac:	89 c2                	mov    %eax,%edx
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	eb 09                	jmp    8015bc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	89 c2                	mov    %eax,%edx
  8015b5:	eb 05                	jmp    8015bc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015bc:	89 d0                	mov    %edx,%eax
  8015be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	6a 00                	push   $0x0
  8015cd:	ff 75 08             	pushl  0x8(%ebp)
  8015d0:	e8 b7 01 00 00       	call   80178c <open>
  8015d5:	89 c3                	mov    %eax,%ebx
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 1b                	js     8015f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	ff 75 0c             	pushl  0xc(%ebp)
  8015e4:	50                   	push   %eax
  8015e5:	e8 5b ff ff ff       	call   801545 <fstat>
  8015ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ec:	89 1c 24             	mov    %ebx,(%esp)
  8015ef:	e8 fd fb ff ff       	call   8011f1 <close>
	return r;
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	89 f0                	mov    %esi,%eax
}
  8015f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5e                   	pop    %esi
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    

00801600 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	89 c6                	mov    %eax,%esi
  801607:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801609:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801610:	75 12                	jne    801624 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	6a 01                	push   $0x1
  801617:	e8 ba 0b 00 00       	call   8021d6 <ipc_find_env>
  80161c:	a3 00 50 80 00       	mov    %eax,0x805000
  801621:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801624:	6a 07                	push   $0x7
  801626:	68 00 70 80 00       	push   $0x807000
  80162b:	56                   	push   %esi
  80162c:	ff 35 00 50 80 00    	pushl  0x805000
  801632:	e8 4b 0b 00 00       	call   802182 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801637:	83 c4 0c             	add    $0xc,%esp
  80163a:	6a 00                	push   $0x0
  80163c:	53                   	push   %ebx
  80163d:	6a 00                	push   $0x0
  80163f:	e8 d7 0a 00 00       	call   80211b <ipc_recv>
}
  801644:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801651:	8b 45 08             	mov    0x8(%ebp),%eax
  801654:	8b 40 0c             	mov    0xc(%eax),%eax
  801657:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80165c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165f:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801664:	ba 00 00 00 00       	mov    $0x0,%edx
  801669:	b8 02 00 00 00       	mov    $0x2,%eax
  80166e:	e8 8d ff ff ff       	call   801600 <fsipc>
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	8b 40 0c             	mov    0xc(%eax),%eax
  801681:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801686:	ba 00 00 00 00       	mov    $0x0,%edx
  80168b:	b8 06 00 00 00       	mov    $0x6,%eax
  801690:	e8 6b ff ff ff       	call   801600 <fsipc>
}
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 04             	sub    $0x4,%esp
  80169e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a7:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b6:	e8 45 ff ff ff       	call   801600 <fsipc>
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 2c                	js     8016eb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	68 00 70 80 00       	push   $0x807000
  8016c7:	53                   	push   %ebx
  8016c8:	e8 90 f3 ff ff       	call   800a5d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016cd:	a1 80 70 80 00       	mov    0x807080,%eax
  8016d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d8:	a1 84 70 80 00       	mov    0x807084,%eax
  8016dd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8016f6:	68 18 2a 80 00       	push   $0x802a18
  8016fb:	68 90 00 00 00       	push   $0x90
  801700:	68 36 2a 80 00       	push   $0x802a36
  801705:	e8 f5 ec ff ff       	call   8003ff <_panic>

0080170a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	56                   	push   %esi
  80170e:	53                   	push   %ebx
  80170f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 40 0c             	mov    0xc(%eax),%eax
  801718:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80171d:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801723:	ba 00 00 00 00       	mov    $0x0,%edx
  801728:	b8 03 00 00 00       	mov    $0x3,%eax
  80172d:	e8 ce fe ff ff       	call   801600 <fsipc>
  801732:	89 c3                	mov    %eax,%ebx
  801734:	85 c0                	test   %eax,%eax
  801736:	78 4b                	js     801783 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801738:	39 c6                	cmp    %eax,%esi
  80173a:	73 16                	jae    801752 <devfile_read+0x48>
  80173c:	68 41 2a 80 00       	push   $0x802a41
  801741:	68 48 2a 80 00       	push   $0x802a48
  801746:	6a 7c                	push   $0x7c
  801748:	68 36 2a 80 00       	push   $0x802a36
  80174d:	e8 ad ec ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  801752:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801757:	7e 16                	jle    80176f <devfile_read+0x65>
  801759:	68 5d 2a 80 00       	push   $0x802a5d
  80175e:	68 48 2a 80 00       	push   $0x802a48
  801763:	6a 7d                	push   $0x7d
  801765:	68 36 2a 80 00       	push   $0x802a36
  80176a:	e8 90 ec ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80176f:	83 ec 04             	sub    $0x4,%esp
  801772:	50                   	push   %eax
  801773:	68 00 70 80 00       	push   $0x807000
  801778:	ff 75 0c             	pushl  0xc(%ebp)
  80177b:	e8 6f f4 ff ff       	call   800bef <memmove>
	return r;
  801780:	83 c4 10             	add    $0x10,%esp
}
  801783:	89 d8                	mov    %ebx,%eax
  801785:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	53                   	push   %ebx
  801790:	83 ec 20             	sub    $0x20,%esp
  801793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801796:	53                   	push   %ebx
  801797:	e8 88 f2 ff ff       	call   800a24 <strlen>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a4:	7f 67                	jg     80180d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ac:	50                   	push   %eax
  8017ad:	e8 c6 f8 ff ff       	call   801078 <fd_alloc>
  8017b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 57                	js     801812 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	53                   	push   %ebx
  8017bf:	68 00 70 80 00       	push   $0x807000
  8017c4:	e8 94 f2 ff ff       	call   800a5d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cc:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d9:	e8 22 fe ff ff       	call   801600 <fsipc>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	79 14                	jns    8017fb <open+0x6f>
		fd_close(fd, 0);
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	6a 00                	push   $0x0
  8017ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ef:	e8 7c f9 ff ff       	call   801170 <fd_close>
		return r;
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	89 da                	mov    %ebx,%edx
  8017f9:	eb 17                	jmp    801812 <open+0x86>
	}

	return fd2num(fd);
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801801:	e8 4b f8 ff ff       	call   801051 <fd2num>
  801806:	89 c2                	mov    %eax,%edx
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	eb 05                	jmp    801812 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80180d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801812:	89 d0                	mov    %edx,%eax
  801814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80181f:	ba 00 00 00 00       	mov    $0x0,%edx
  801824:	b8 08 00 00 00       	mov    $0x8,%eax
  801829:	e8 d2 fd ff ff       	call   801600 <fsipc>
}
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	57                   	push   %edi
  801834:	56                   	push   %esi
  801835:	53                   	push   %ebx
  801836:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80183c:	6a 00                	push   $0x0
  80183e:	ff 75 08             	pushl  0x8(%ebp)
  801841:	e8 46 ff ff ff       	call   80178c <open>
  801846:	89 c7                	mov    %eax,%edi
  801848:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	85 c0                	test   %eax,%eax
  801853:	0f 88 3a 04 00 00    	js     801c93 <spawn+0x463>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801859:	83 ec 04             	sub    $0x4,%esp
  80185c:	68 00 02 00 00       	push   $0x200
  801861:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801867:	50                   	push   %eax
  801868:	57                   	push   %edi
  801869:	e8 50 fb ff ff       	call   8013be <readn>
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	3d 00 02 00 00       	cmp    $0x200,%eax
  801876:	75 0c                	jne    801884 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801878:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80187f:	45 4c 46 
  801882:	74 33                	je     8018b7 <spawn+0x87>
		close(fd);
  801884:	83 ec 0c             	sub    $0xc,%esp
  801887:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80188d:	e8 5f f9 ff ff       	call   8011f1 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801892:	83 c4 0c             	add    $0xc,%esp
  801895:	68 7f 45 4c 46       	push   $0x464c457f
  80189a:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8018a0:	68 69 2a 80 00       	push   $0x802a69
  8018a5:	e8 2e ec ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8018b2:	e9 3c 04 00 00       	jmp    801cf3 <spawn+0x4c3>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018b7:	b8 07 00 00 00       	mov    $0x7,%eax
  8018bc:	cd 30                	int    $0x30
  8018be:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8018c4:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	0f 88 c9 03 00 00    	js     801c9b <spawn+0x46b>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8018d2:	89 c6                	mov    %eax,%esi
  8018d4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8018da:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8018dd:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8018e3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8018e9:	b9 11 00 00 00       	mov    $0x11,%ecx
  8018ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8018f0:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8018f6:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018fc:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801901:	be 00 00 00 00       	mov    $0x0,%esi
  801906:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801909:	eb 13                	jmp    80191e <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80190b:	83 ec 0c             	sub    $0xc,%esp
  80190e:	50                   	push   %eax
  80190f:	e8 10 f1 ff ff       	call   800a24 <strlen>
  801914:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801918:	83 c3 01             	add    $0x1,%ebx
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801925:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801928:	85 c0                	test   %eax,%eax
  80192a:	75 df                	jne    80190b <spawn+0xdb>
  80192c:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801932:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801938:	bf 00 10 40 00       	mov    $0x401000,%edi
  80193d:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80193f:	89 fa                	mov    %edi,%edx
  801941:	83 e2 fc             	and    $0xfffffffc,%edx
  801944:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80194b:	29 c2                	sub    %eax,%edx
  80194d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801953:	8d 42 f8             	lea    -0x8(%edx),%eax
  801956:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80195b:	0f 86 4a 03 00 00    	jbe    801cab <spawn+0x47b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801961:	83 ec 04             	sub    $0x4,%esp
  801964:	6a 07                	push   $0x7
  801966:	68 00 00 40 00       	push   $0x400000
  80196b:	6a 00                	push   $0x0
  80196d:	e8 ee f4 ff ff       	call   800e60 <sys_page_alloc>
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	0f 88 35 03 00 00    	js     801cb2 <spawn+0x482>
  80197d:	be 00 00 00 00       	mov    $0x0,%esi
  801982:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801988:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80198b:	eb 30                	jmp    8019bd <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80198d:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801993:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801999:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80199c:	83 ec 08             	sub    $0x8,%esp
  80199f:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019a2:	57                   	push   %edi
  8019a3:	e8 b5 f0 ff ff       	call   800a5d <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019a8:	83 c4 04             	add    $0x4,%esp
  8019ab:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019ae:	e8 71 f0 ff ff       	call   800a24 <strlen>
  8019b3:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8019b7:	83 c6 01             	add    $0x1,%esi
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8019c3:	7f c8                	jg     80198d <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8019c5:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8019cb:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8019d1:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8019d8:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8019de:	74 19                	je     8019f9 <spawn+0x1c9>
  8019e0:	68 e0 2a 80 00       	push   $0x802ae0
  8019e5:	68 48 2a 80 00       	push   $0x802a48
  8019ea:	68 f2 00 00 00       	push   $0xf2
  8019ef:	68 83 2a 80 00       	push   $0x802a83
  8019f4:	e8 06 ea ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8019f9:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8019ff:	89 c8                	mov    %ecx,%eax
  801a01:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a06:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801a09:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a0f:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a12:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801a18:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	6a 07                	push   $0x7
  801a23:	68 00 d0 bf ee       	push   $0xeebfd000
  801a28:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a2e:	68 00 00 40 00       	push   $0x400000
  801a33:	6a 00                	push   $0x0
  801a35:	e8 69 f4 ff ff       	call   800ea3 <sys_page_map>
  801a3a:	89 c3                	mov    %eax,%ebx
  801a3c:	83 c4 20             	add    $0x20,%esp
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	0f 88 9a 02 00 00    	js     801ce1 <spawn+0x4b1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a47:	83 ec 08             	sub    $0x8,%esp
  801a4a:	68 00 00 40 00       	push   $0x400000
  801a4f:	6a 00                	push   $0x0
  801a51:	e8 8f f4 ff ff       	call   800ee5 <sys_page_unmap>
  801a56:	89 c3                	mov    %eax,%ebx
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	0f 88 7e 02 00 00    	js     801ce1 <spawn+0x4b1>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801a63:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801a69:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801a70:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a76:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801a7d:	00 00 00 
  801a80:	e9 86 01 00 00       	jmp    801c0b <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  801a85:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801a8b:	83 38 01             	cmpl   $0x1,(%eax)
  801a8e:	0f 85 69 01 00 00    	jne    801bfd <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a94:	89 c1                	mov    %eax,%ecx
  801a96:	8b 40 18             	mov    0x18(%eax),%eax
  801a99:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801a9f:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801aa2:	83 f8 01             	cmp    $0x1,%eax
  801aa5:	19 c0                	sbb    %eax,%eax
  801aa7:	83 e0 fe             	and    $0xfffffffe,%eax
  801aaa:	83 c0 07             	add    $0x7,%eax
  801aad:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ab3:	89 c8                	mov    %ecx,%eax
  801ab5:	8b 49 04             	mov    0x4(%ecx),%ecx
  801ab8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801abe:	8b 78 10             	mov    0x10(%eax),%edi
  801ac1:	8b 50 14             	mov    0x14(%eax),%edx
  801ac4:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801aca:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801acd:	89 f0                	mov    %esi,%eax
  801acf:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ad4:	74 14                	je     801aea <spawn+0x2ba>
		va -= i;
  801ad6:	29 c6                	sub    %eax,%esi
		memsz += i;
  801ad8:	01 c2                	add    %eax,%edx
  801ada:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801ae0:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ae2:	29 c1                	sub    %eax,%ecx
  801ae4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801aea:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aef:	e9 f7 00 00 00       	jmp    801beb <spawn+0x3bb>
		if (i >= filesz) {
  801af4:	39 df                	cmp    %ebx,%edi
  801af6:	77 27                	ja     801b1f <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801af8:	83 ec 04             	sub    $0x4,%esp
  801afb:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b01:	56                   	push   %esi
  801b02:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b08:	e8 53 f3 ff ff       	call   800e60 <sys_page_alloc>
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	85 c0                	test   %eax,%eax
  801b12:	0f 89 c7 00 00 00    	jns    801bdf <spawn+0x3af>
  801b18:	89 c3                	mov    %eax,%ebx
  801b1a:	e9 a1 01 00 00       	jmp    801cc0 <spawn+0x490>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b1f:	83 ec 04             	sub    $0x4,%esp
  801b22:	6a 07                	push   $0x7
  801b24:	68 00 00 40 00       	push   $0x400000
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 30 f3 ff ff       	call   800e60 <sys_page_alloc>
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	85 c0                	test   %eax,%eax
  801b35:	0f 88 7b 01 00 00    	js     801cb6 <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b3b:	83 ec 08             	sub    $0x8,%esp
  801b3e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b44:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801b4a:	50                   	push   %eax
  801b4b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b51:	e8 3d f9 ff ff       	call   801493 <seek>
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	0f 88 59 01 00 00    	js     801cba <spawn+0x48a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b61:	83 ec 04             	sub    $0x4,%esp
  801b64:	89 f8                	mov    %edi,%eax
  801b66:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801b6c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b71:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801b76:	0f 47 c1             	cmova  %ecx,%eax
  801b79:	50                   	push   %eax
  801b7a:	68 00 00 40 00       	push   $0x400000
  801b7f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b85:	e8 34 f8 ff ff       	call   8013be <readn>
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	0f 88 29 01 00 00    	js     801cbe <spawn+0x48e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b95:	83 ec 0c             	sub    $0xc,%esp
  801b98:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b9e:	56                   	push   %esi
  801b9f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ba5:	68 00 00 40 00       	push   $0x400000
  801baa:	6a 00                	push   $0x0
  801bac:	e8 f2 f2 ff ff       	call   800ea3 <sys_page_map>
  801bb1:	83 c4 20             	add    $0x20,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	79 15                	jns    801bcd <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  801bb8:	50                   	push   %eax
  801bb9:	68 8f 2a 80 00       	push   $0x802a8f
  801bbe:	68 25 01 00 00       	push   $0x125
  801bc3:	68 83 2a 80 00       	push   $0x802a83
  801bc8:	e8 32 e8 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801bcd:	83 ec 08             	sub    $0x8,%esp
  801bd0:	68 00 00 40 00       	push   $0x400000
  801bd5:	6a 00                	push   $0x0
  801bd7:	e8 09 f3 ff ff       	call   800ee5 <sys_page_unmap>
  801bdc:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bdf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801be5:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801beb:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801bf1:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801bf7:	0f 87 f7 fe ff ff    	ja     801af4 <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bfd:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c04:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c0b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c12:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c18:	0f 8c 67 fe ff ff    	jl     801a85 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c1e:	83 ec 0c             	sub    $0xc,%esp
  801c21:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c27:	e8 c5 f5 ff ff       	call   8011f1 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801c2c:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801c33:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801c36:	83 c4 08             	add    $0x8,%esp
  801c39:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801c3f:	50                   	push   %eax
  801c40:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c46:	e8 1e f3 ff ff       	call   800f69 <sys_env_set_trapframe>
  801c4b:	83 c4 10             	add    $0x10,%esp
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	79 15                	jns    801c67 <spawn+0x437>
		panic("sys_env_set_trapframe: %e", r);
  801c52:	50                   	push   %eax
  801c53:	68 ac 2a 80 00       	push   $0x802aac
  801c58:	68 86 00 00 00       	push   $0x86
  801c5d:	68 83 2a 80 00       	push   $0x802a83
  801c62:	e8 98 e7 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801c67:	83 ec 08             	sub    $0x8,%esp
  801c6a:	6a 02                	push   $0x2
  801c6c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c72:	e8 b0 f2 ff ff       	call   800f27 <sys_env_set_status>
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	79 25                	jns    801ca3 <spawn+0x473>
		panic("sys_env_set_status: %e", r);
  801c7e:	50                   	push   %eax
  801c7f:	68 c6 2a 80 00       	push   $0x802ac6
  801c84:	68 89 00 00 00       	push   $0x89
  801c89:	68 83 2a 80 00       	push   $0x802a83
  801c8e:	e8 6c e7 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801c93:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801c99:	eb 58                	jmp    801cf3 <spawn+0x4c3>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801c9b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801ca1:	eb 50                	jmp    801cf3 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801ca3:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801ca9:	eb 48                	jmp    801cf3 <spawn+0x4c3>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801cab:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801cb0:	eb 41                	jmp    801cf3 <spawn+0x4c3>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801cb2:	89 c3                	mov    %eax,%ebx
  801cb4:	eb 3d                	jmp    801cf3 <spawn+0x4c3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	eb 06                	jmp    801cc0 <spawn+0x490>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cba:	89 c3                	mov    %eax,%ebx
  801cbc:	eb 02                	jmp    801cc0 <spawn+0x490>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cbe:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801cc0:	83 ec 0c             	sub    $0xc,%esp
  801cc3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801cc9:	e8 13 f1 ff ff       	call   800de1 <sys_env_destroy>
	close(fd);
  801cce:	83 c4 04             	add    $0x4,%esp
  801cd1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cd7:	e8 15 f5 ff ff       	call   8011f1 <close>
	return r;
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	eb 12                	jmp    801cf3 <spawn+0x4c3>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ce1:	83 ec 08             	sub    $0x8,%esp
  801ce4:	68 00 00 40 00       	push   $0x400000
  801ce9:	6a 00                	push   $0x0
  801ceb:	e8 f5 f1 ff ff       	call   800ee5 <sys_page_unmap>
  801cf0:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801cf3:	89 d8                	mov    %ebx,%eax
  801cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf8:	5b                   	pop    %ebx
  801cf9:	5e                   	pop    %esi
  801cfa:	5f                   	pop    %edi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    

00801cfd <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801cfd:	55                   	push   %ebp
  801cfe:	89 e5                	mov    %esp,%ebp
  801d00:	56                   	push   %esi
  801d01:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d02:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d05:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d0a:	eb 03                	jmp    801d0f <spawnl+0x12>
		argc++;
  801d0c:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d0f:	83 c2 04             	add    $0x4,%edx
  801d12:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801d16:	75 f4                	jne    801d0c <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d18:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801d1f:	83 e2 f0             	and    $0xfffffff0,%edx
  801d22:	29 d4                	sub    %edx,%esp
  801d24:	8d 54 24 03          	lea    0x3(%esp),%edx
  801d28:	c1 ea 02             	shr    $0x2,%edx
  801d2b:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801d32:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d37:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801d3e:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801d45:	00 
  801d46:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d48:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4d:	eb 0a                	jmp    801d59 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801d4f:	83 c0 01             	add    $0x1,%eax
  801d52:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801d56:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d59:	39 d0                	cmp    %edx,%eax
  801d5b:	75 f2                	jne    801d4f <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801d5d:	83 ec 08             	sub    $0x8,%esp
  801d60:	56                   	push   %esi
  801d61:	ff 75 08             	pushl  0x8(%ebp)
  801d64:	e8 c7 fa ff ff       	call   801830 <spawn>
}
  801d69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	56                   	push   %esi
  801d74:	53                   	push   %ebx
  801d75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d78:	83 ec 0c             	sub    $0xc,%esp
  801d7b:	ff 75 08             	pushl  0x8(%ebp)
  801d7e:	e8 de f2 ff ff       	call   801061 <fd2data>
  801d83:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d85:	83 c4 08             	add    $0x8,%esp
  801d88:	68 08 2b 80 00       	push   $0x802b08
  801d8d:	53                   	push   %ebx
  801d8e:	e8 ca ec ff ff       	call   800a5d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d93:	8b 46 04             	mov    0x4(%esi),%eax
  801d96:	2b 06                	sub    (%esi),%eax
  801d98:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d9e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801da5:	00 00 00 
	stat->st_dev = &devpipe;
  801da8:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801daf:	47 80 00 
	return 0;
}
  801db2:	b8 00 00 00 00       	mov    $0x0,%eax
  801db7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	53                   	push   %ebx
  801dc2:	83 ec 0c             	sub    $0xc,%esp
  801dc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dc8:	53                   	push   %ebx
  801dc9:	6a 00                	push   $0x0
  801dcb:	e8 15 f1 ff ff       	call   800ee5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dd0:	89 1c 24             	mov    %ebx,(%esp)
  801dd3:	e8 89 f2 ff ff       	call   801061 <fd2data>
  801dd8:	83 c4 08             	add    $0x8,%esp
  801ddb:	50                   	push   %eax
  801ddc:	6a 00                	push   $0x0
  801dde:	e8 02 f1 ff ff       	call   800ee5 <sys_page_unmap>
}
  801de3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	57                   	push   %edi
  801dec:	56                   	push   %esi
  801ded:	53                   	push   %ebx
  801dee:	83 ec 1c             	sub    $0x1c,%esp
  801df1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801df4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801df6:	a1 90 67 80 00       	mov    0x806790,%eax
  801dfb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801dfe:	83 ec 0c             	sub    $0xc,%esp
  801e01:	ff 75 e0             	pushl  -0x20(%ebp)
  801e04:	e8 06 04 00 00       	call   80220f <pageref>
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	89 3c 24             	mov    %edi,(%esp)
  801e0e:	e8 fc 03 00 00       	call   80220f <pageref>
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	39 c3                	cmp    %eax,%ebx
  801e18:	0f 94 c1             	sete   %cl
  801e1b:	0f b6 c9             	movzbl %cl,%ecx
  801e1e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e21:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801e27:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e2a:	39 ce                	cmp    %ecx,%esi
  801e2c:	74 1b                	je     801e49 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e2e:	39 c3                	cmp    %eax,%ebx
  801e30:	75 c4                	jne    801df6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e32:	8b 42 58             	mov    0x58(%edx),%eax
  801e35:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e38:	50                   	push   %eax
  801e39:	56                   	push   %esi
  801e3a:	68 0f 2b 80 00       	push   $0x802b0f
  801e3f:	e8 94 e6 ff ff       	call   8004d8 <cprintf>
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	eb ad                	jmp    801df6 <_pipeisclosed+0xe>
	}
}
  801e49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	57                   	push   %edi
  801e58:	56                   	push   %esi
  801e59:	53                   	push   %ebx
  801e5a:	83 ec 28             	sub    $0x28,%esp
  801e5d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e60:	56                   	push   %esi
  801e61:	e8 fb f1 ff ff       	call   801061 <fd2data>
  801e66:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	bf 00 00 00 00       	mov    $0x0,%edi
  801e70:	eb 4b                	jmp    801ebd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e72:	89 da                	mov    %ebx,%edx
  801e74:	89 f0                	mov    %esi,%eax
  801e76:	e8 6d ff ff ff       	call   801de8 <_pipeisclosed>
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	75 48                	jne    801ec7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e7f:	e8 bd ef ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e84:	8b 43 04             	mov    0x4(%ebx),%eax
  801e87:	8b 0b                	mov    (%ebx),%ecx
  801e89:	8d 51 20             	lea    0x20(%ecx),%edx
  801e8c:	39 d0                	cmp    %edx,%eax
  801e8e:	73 e2                	jae    801e72 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e93:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e97:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	c1 fa 1f             	sar    $0x1f,%edx
  801e9f:	89 d1                	mov    %edx,%ecx
  801ea1:	c1 e9 1b             	shr    $0x1b,%ecx
  801ea4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ea7:	83 e2 1f             	and    $0x1f,%edx
  801eaa:	29 ca                	sub    %ecx,%edx
  801eac:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801eb0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801eb4:	83 c0 01             	add    $0x1,%eax
  801eb7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eba:	83 c7 01             	add    $0x1,%edi
  801ebd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ec0:	75 c2                	jne    801e84 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ec2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec5:	eb 05                	jmp    801ecc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ec7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ecc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5f                   	pop    %edi
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	57                   	push   %edi
  801ed8:	56                   	push   %esi
  801ed9:	53                   	push   %ebx
  801eda:	83 ec 18             	sub    $0x18,%esp
  801edd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ee0:	57                   	push   %edi
  801ee1:	e8 7b f1 ff ff       	call   801061 <fd2data>
  801ee6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ef0:	eb 3d                	jmp    801f2f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ef2:	85 db                	test   %ebx,%ebx
  801ef4:	74 04                	je     801efa <devpipe_read+0x26>
				return i;
  801ef6:	89 d8                	mov    %ebx,%eax
  801ef8:	eb 44                	jmp    801f3e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801efa:	89 f2                	mov    %esi,%edx
  801efc:	89 f8                	mov    %edi,%eax
  801efe:	e8 e5 fe ff ff       	call   801de8 <_pipeisclosed>
  801f03:	85 c0                	test   %eax,%eax
  801f05:	75 32                	jne    801f39 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f07:	e8 35 ef ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f0c:	8b 06                	mov    (%esi),%eax
  801f0e:	3b 46 04             	cmp    0x4(%esi),%eax
  801f11:	74 df                	je     801ef2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f13:	99                   	cltd   
  801f14:	c1 ea 1b             	shr    $0x1b,%edx
  801f17:	01 d0                	add    %edx,%eax
  801f19:	83 e0 1f             	and    $0x1f,%eax
  801f1c:	29 d0                	sub    %edx,%eax
  801f1e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f26:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f29:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2c:	83 c3 01             	add    $0x1,%ebx
  801f2f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f32:	75 d8                	jne    801f0c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f34:	8b 45 10             	mov    0x10(%ebp),%eax
  801f37:	eb 05                	jmp    801f3e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f41:	5b                   	pop    %ebx
  801f42:	5e                   	pop    %esi
  801f43:	5f                   	pop    %edi
  801f44:	5d                   	pop    %ebp
  801f45:	c3                   	ret    

00801f46 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	56                   	push   %esi
  801f4a:	53                   	push   %ebx
  801f4b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f51:	50                   	push   %eax
  801f52:	e8 21 f1 ff ff       	call   801078 <fd_alloc>
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	89 c2                	mov    %eax,%edx
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	0f 88 2c 01 00 00    	js     802090 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f64:	83 ec 04             	sub    $0x4,%esp
  801f67:	68 07 04 00 00       	push   $0x407
  801f6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 ea ee ff ff       	call   800e60 <sys_page_alloc>
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	89 c2                	mov    %eax,%edx
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	0f 88 0d 01 00 00    	js     802090 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f83:	83 ec 0c             	sub    $0xc,%esp
  801f86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f89:	50                   	push   %eax
  801f8a:	e8 e9 f0 ff ff       	call   801078 <fd_alloc>
  801f8f:	89 c3                	mov    %eax,%ebx
  801f91:	83 c4 10             	add    $0x10,%esp
  801f94:	85 c0                	test   %eax,%eax
  801f96:	0f 88 e2 00 00 00    	js     80207e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9c:	83 ec 04             	sub    $0x4,%esp
  801f9f:	68 07 04 00 00       	push   $0x407
  801fa4:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa7:	6a 00                	push   $0x0
  801fa9:	e8 b2 ee ff ff       	call   800e60 <sys_page_alloc>
  801fae:	89 c3                	mov    %eax,%ebx
  801fb0:	83 c4 10             	add    $0x10,%esp
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	0f 88 c3 00 00 00    	js     80207e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fbb:	83 ec 0c             	sub    $0xc,%esp
  801fbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc1:	e8 9b f0 ff ff       	call   801061 <fd2data>
  801fc6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc8:	83 c4 0c             	add    $0xc,%esp
  801fcb:	68 07 04 00 00       	push   $0x407
  801fd0:	50                   	push   %eax
  801fd1:	6a 00                	push   $0x0
  801fd3:	e8 88 ee ff ff       	call   800e60 <sys_page_alloc>
  801fd8:	89 c3                	mov    %eax,%ebx
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	0f 88 89 00 00 00    	js     80206e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe5:	83 ec 0c             	sub    $0xc,%esp
  801fe8:	ff 75 f0             	pushl  -0x10(%ebp)
  801feb:	e8 71 f0 ff ff       	call   801061 <fd2data>
  801ff0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ff7:	50                   	push   %eax
  801ff8:	6a 00                	push   $0x0
  801ffa:	56                   	push   %esi
  801ffb:	6a 00                	push   $0x0
  801ffd:	e8 a1 ee ff ff       	call   800ea3 <sys_page_map>
  802002:	89 c3                	mov    %eax,%ebx
  802004:	83 c4 20             	add    $0x20,%esp
  802007:	85 c0                	test   %eax,%eax
  802009:	78 55                	js     802060 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80200b:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802014:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802019:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802020:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802026:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802029:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80202b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80202e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802035:	83 ec 0c             	sub    $0xc,%esp
  802038:	ff 75 f4             	pushl  -0xc(%ebp)
  80203b:	e8 11 f0 ff ff       	call   801051 <fd2num>
  802040:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802043:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802045:	83 c4 04             	add    $0x4,%esp
  802048:	ff 75 f0             	pushl  -0x10(%ebp)
  80204b:	e8 01 f0 ff ff       	call   801051 <fd2num>
  802050:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802053:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802056:	83 c4 10             	add    $0x10,%esp
  802059:	ba 00 00 00 00       	mov    $0x0,%edx
  80205e:	eb 30                	jmp    802090 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802060:	83 ec 08             	sub    $0x8,%esp
  802063:	56                   	push   %esi
  802064:	6a 00                	push   $0x0
  802066:	e8 7a ee ff ff       	call   800ee5 <sys_page_unmap>
  80206b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80206e:	83 ec 08             	sub    $0x8,%esp
  802071:	ff 75 f0             	pushl  -0x10(%ebp)
  802074:	6a 00                	push   $0x0
  802076:	e8 6a ee ff ff       	call   800ee5 <sys_page_unmap>
  80207b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80207e:	83 ec 08             	sub    $0x8,%esp
  802081:	ff 75 f4             	pushl  -0xc(%ebp)
  802084:	6a 00                	push   $0x0
  802086:	e8 5a ee ff ff       	call   800ee5 <sys_page_unmap>
  80208b:	83 c4 10             	add    $0x10,%esp
  80208e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802090:	89 d0                	mov    %edx,%eax
  802092:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802095:	5b                   	pop    %ebx
  802096:	5e                   	pop    %esi
  802097:	5d                   	pop    %ebp
  802098:	c3                   	ret    

00802099 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80209f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a2:	50                   	push   %eax
  8020a3:	ff 75 08             	pushl  0x8(%ebp)
  8020a6:	e8 1c f0 ff ff       	call   8010c7 <fd_lookup>
  8020ab:	83 c4 10             	add    $0x10,%esp
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	78 18                	js     8020ca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020b2:	83 ec 0c             	sub    $0xc,%esp
  8020b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b8:	e8 a4 ef ff ff       	call   801061 <fd2data>
	return _pipeisclosed(fd, p);
  8020bd:	89 c2                	mov    %eax,%edx
  8020bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c2:	e8 21 fd ff ff       	call   801de8 <_pipeisclosed>
  8020c7:	83 c4 10             	add    $0x10,%esp
}
  8020ca:	c9                   	leave  
  8020cb:	c3                   	ret    

008020cc <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	56                   	push   %esi
  8020d0:	53                   	push   %ebx
  8020d1:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8020d4:	85 f6                	test   %esi,%esi
  8020d6:	75 16                	jne    8020ee <wait+0x22>
  8020d8:	68 27 2b 80 00       	push   $0x802b27
  8020dd:	68 48 2a 80 00       	push   $0x802a48
  8020e2:	6a 09                	push   $0x9
  8020e4:	68 32 2b 80 00       	push   $0x802b32
  8020e9:	e8 11 e3 ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  8020ee:	89 f3                	mov    %esi,%ebx
  8020f0:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8020f6:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8020f9:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8020ff:	eb 05                	jmp    802106 <wait+0x3a>
		sys_yield();
  802101:	e8 3b ed ff ff       	call   800e41 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802106:	8b 43 48             	mov    0x48(%ebx),%eax
  802109:	39 c6                	cmp    %eax,%esi
  80210b:	75 07                	jne    802114 <wait+0x48>
  80210d:	8b 43 54             	mov    0x54(%ebx),%eax
  802110:	85 c0                	test   %eax,%eax
  802112:	75 ed                	jne    802101 <wait+0x35>
		sys_yield();
}
  802114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5d                   	pop    %ebp
  80211a:	c3                   	ret    

0080211b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80211b:	55                   	push   %ebp
  80211c:	89 e5                	mov    %esp,%ebp
  80211e:	56                   	push   %esi
  80211f:	53                   	push   %ebx
  802120:	8b 75 08             	mov    0x8(%ebp),%esi
  802123:	8b 45 0c             	mov    0xc(%ebp),%eax
  802126:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802129:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80212b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802130:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802133:	83 ec 0c             	sub    $0xc,%esp
  802136:	50                   	push   %eax
  802137:	e8 d4 ee ff ff       	call   801010 <sys_ipc_recv>

	if (from_env_store != NULL)
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	85 f6                	test   %esi,%esi
  802141:	74 14                	je     802157 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802143:	ba 00 00 00 00       	mov    $0x0,%edx
  802148:	85 c0                	test   %eax,%eax
  80214a:	78 09                	js     802155 <ipc_recv+0x3a>
  80214c:	8b 15 90 67 80 00    	mov    0x806790,%edx
  802152:	8b 52 74             	mov    0x74(%edx),%edx
  802155:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802157:	85 db                	test   %ebx,%ebx
  802159:	74 14                	je     80216f <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80215b:	ba 00 00 00 00       	mov    $0x0,%edx
  802160:	85 c0                	test   %eax,%eax
  802162:	78 09                	js     80216d <ipc_recv+0x52>
  802164:	8b 15 90 67 80 00    	mov    0x806790,%edx
  80216a:	8b 52 78             	mov    0x78(%edx),%edx
  80216d:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80216f:	85 c0                	test   %eax,%eax
  802171:	78 08                	js     80217b <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802173:	a1 90 67 80 00       	mov    0x806790,%eax
  802178:	8b 40 70             	mov    0x70(%eax),%eax
}
  80217b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80217e:	5b                   	pop    %ebx
  80217f:	5e                   	pop    %esi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    

00802182 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	57                   	push   %edi
  802186:	56                   	push   %esi
  802187:	53                   	push   %ebx
  802188:	83 ec 0c             	sub    $0xc,%esp
  80218b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80218e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802191:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802194:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802196:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80219b:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80219e:	ff 75 14             	pushl  0x14(%ebp)
  8021a1:	53                   	push   %ebx
  8021a2:	56                   	push   %esi
  8021a3:	57                   	push   %edi
  8021a4:	e8 44 ee ff ff       	call   800fed <sys_ipc_try_send>

		if (err < 0) {
  8021a9:	83 c4 10             	add    $0x10,%esp
  8021ac:	85 c0                	test   %eax,%eax
  8021ae:	79 1e                	jns    8021ce <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8021b0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021b3:	75 07                	jne    8021bc <ipc_send+0x3a>
				sys_yield();
  8021b5:	e8 87 ec ff ff       	call   800e41 <sys_yield>
  8021ba:	eb e2                	jmp    80219e <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8021bc:	50                   	push   %eax
  8021bd:	68 3d 2b 80 00       	push   $0x802b3d
  8021c2:	6a 49                	push   $0x49
  8021c4:	68 4a 2b 80 00       	push   $0x802b4a
  8021c9:	e8 31 e2 ff ff       	call   8003ff <_panic>
		}

	} while (err < 0);

}
  8021ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d1:	5b                   	pop    %ebx
  8021d2:	5e                   	pop    %esi
  8021d3:	5f                   	pop    %edi
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021dc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021e1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021e4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021ea:	8b 52 50             	mov    0x50(%edx),%edx
  8021ed:	39 ca                	cmp    %ecx,%edx
  8021ef:	75 0d                	jne    8021fe <ipc_find_env+0x28>
			return envs[i].env_id;
  8021f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021f9:	8b 40 48             	mov    0x48(%eax),%eax
  8021fc:	eb 0f                	jmp    80220d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021fe:	83 c0 01             	add    $0x1,%eax
  802201:	3d 00 04 00 00       	cmp    $0x400,%eax
  802206:	75 d9                	jne    8021e1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802208:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    

0080220f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80220f:	55                   	push   %ebp
  802210:	89 e5                	mov    %esp,%ebp
  802212:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802215:	89 d0                	mov    %edx,%eax
  802217:	c1 e8 16             	shr    $0x16,%eax
  80221a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802221:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802226:	f6 c1 01             	test   $0x1,%cl
  802229:	74 1d                	je     802248 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80222b:	c1 ea 0c             	shr    $0xc,%edx
  80222e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802235:	f6 c2 01             	test   $0x1,%dl
  802238:	74 0e                	je     802248 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80223a:	c1 ea 0c             	shr    $0xc,%edx
  80223d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802244:	ef 
  802245:	0f b7 c0             	movzwl %ax,%eax
}
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__udivdi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80225b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80225f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 f6                	test   %esi,%esi
  802269:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80226d:	89 ca                	mov    %ecx,%edx
  80226f:	89 f8                	mov    %edi,%eax
  802271:	75 3d                	jne    8022b0 <__udivdi3+0x60>
  802273:	39 cf                	cmp    %ecx,%edi
  802275:	0f 87 c5 00 00 00    	ja     802340 <__udivdi3+0xf0>
  80227b:	85 ff                	test   %edi,%edi
  80227d:	89 fd                	mov    %edi,%ebp
  80227f:	75 0b                	jne    80228c <__udivdi3+0x3c>
  802281:	b8 01 00 00 00       	mov    $0x1,%eax
  802286:	31 d2                	xor    %edx,%edx
  802288:	f7 f7                	div    %edi
  80228a:	89 c5                	mov    %eax,%ebp
  80228c:	89 c8                	mov    %ecx,%eax
  80228e:	31 d2                	xor    %edx,%edx
  802290:	f7 f5                	div    %ebp
  802292:	89 c1                	mov    %eax,%ecx
  802294:	89 d8                	mov    %ebx,%eax
  802296:	89 cf                	mov    %ecx,%edi
  802298:	f7 f5                	div    %ebp
  80229a:	89 c3                	mov    %eax,%ebx
  80229c:	89 d8                	mov    %ebx,%eax
  80229e:	89 fa                	mov    %edi,%edx
  8022a0:	83 c4 1c             	add    $0x1c,%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
  8022a8:	90                   	nop
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	39 ce                	cmp    %ecx,%esi
  8022b2:	77 74                	ja     802328 <__udivdi3+0xd8>
  8022b4:	0f bd fe             	bsr    %esi,%edi
  8022b7:	83 f7 1f             	xor    $0x1f,%edi
  8022ba:	0f 84 98 00 00 00    	je     802358 <__udivdi3+0x108>
  8022c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	89 c5                	mov    %eax,%ebp
  8022c9:	29 fb                	sub    %edi,%ebx
  8022cb:	d3 e6                	shl    %cl,%esi
  8022cd:	89 d9                	mov    %ebx,%ecx
  8022cf:	d3 ed                	shr    %cl,%ebp
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	d3 e0                	shl    %cl,%eax
  8022d5:	09 ee                	or     %ebp,%esi
  8022d7:	89 d9                	mov    %ebx,%ecx
  8022d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022dd:	89 d5                	mov    %edx,%ebp
  8022df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022e3:	d3 ed                	shr    %cl,%ebp
  8022e5:	89 f9                	mov    %edi,%ecx
  8022e7:	d3 e2                	shl    %cl,%edx
  8022e9:	89 d9                	mov    %ebx,%ecx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	09 c2                	or     %eax,%edx
  8022ef:	89 d0                	mov    %edx,%eax
  8022f1:	89 ea                	mov    %ebp,%edx
  8022f3:	f7 f6                	div    %esi
  8022f5:	89 d5                	mov    %edx,%ebp
  8022f7:	89 c3                	mov    %eax,%ebx
  8022f9:	f7 64 24 0c          	mull   0xc(%esp)
  8022fd:	39 d5                	cmp    %edx,%ebp
  8022ff:	72 10                	jb     802311 <__udivdi3+0xc1>
  802301:	8b 74 24 08          	mov    0x8(%esp),%esi
  802305:	89 f9                	mov    %edi,%ecx
  802307:	d3 e6                	shl    %cl,%esi
  802309:	39 c6                	cmp    %eax,%esi
  80230b:	73 07                	jae    802314 <__udivdi3+0xc4>
  80230d:	39 d5                	cmp    %edx,%ebp
  80230f:	75 03                	jne    802314 <__udivdi3+0xc4>
  802311:	83 eb 01             	sub    $0x1,%ebx
  802314:	31 ff                	xor    %edi,%edi
  802316:	89 d8                	mov    %ebx,%eax
  802318:	89 fa                	mov    %edi,%edx
  80231a:	83 c4 1c             	add    $0x1c,%esp
  80231d:	5b                   	pop    %ebx
  80231e:	5e                   	pop    %esi
  80231f:	5f                   	pop    %edi
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    
  802322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802328:	31 ff                	xor    %edi,%edi
  80232a:	31 db                	xor    %ebx,%ebx
  80232c:	89 d8                	mov    %ebx,%eax
  80232e:	89 fa                	mov    %edi,%edx
  802330:	83 c4 1c             	add    $0x1c,%esp
  802333:	5b                   	pop    %ebx
  802334:	5e                   	pop    %esi
  802335:	5f                   	pop    %edi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
  802338:	90                   	nop
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	89 d8                	mov    %ebx,%eax
  802342:	f7 f7                	div    %edi
  802344:	31 ff                	xor    %edi,%edi
  802346:	89 c3                	mov    %eax,%ebx
  802348:	89 d8                	mov    %ebx,%eax
  80234a:	89 fa                	mov    %edi,%edx
  80234c:	83 c4 1c             	add    $0x1c,%esp
  80234f:	5b                   	pop    %ebx
  802350:	5e                   	pop    %esi
  802351:	5f                   	pop    %edi
  802352:	5d                   	pop    %ebp
  802353:	c3                   	ret    
  802354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802358:	39 ce                	cmp    %ecx,%esi
  80235a:	72 0c                	jb     802368 <__udivdi3+0x118>
  80235c:	31 db                	xor    %ebx,%ebx
  80235e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802362:	0f 87 34 ff ff ff    	ja     80229c <__udivdi3+0x4c>
  802368:	bb 01 00 00 00       	mov    $0x1,%ebx
  80236d:	e9 2a ff ff ff       	jmp    80229c <__udivdi3+0x4c>
  802372:	66 90                	xchg   %ax,%ax
  802374:	66 90                	xchg   %ax,%ax
  802376:	66 90                	xchg   %ax,%ax
  802378:	66 90                	xchg   %ax,%ax
  80237a:	66 90                	xchg   %ax,%ax
  80237c:	66 90                	xchg   %ax,%ax
  80237e:	66 90                	xchg   %ax,%ax

00802380 <__umoddi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80238b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80238f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802397:	85 d2                	test   %edx,%edx
  802399:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80239d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023a1:	89 f3                	mov    %esi,%ebx
  8023a3:	89 3c 24             	mov    %edi,(%esp)
  8023a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023aa:	75 1c                	jne    8023c8 <__umoddi3+0x48>
  8023ac:	39 f7                	cmp    %esi,%edi
  8023ae:	76 50                	jbe    802400 <__umoddi3+0x80>
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	f7 f7                	div    %edi
  8023b6:	89 d0                	mov    %edx,%eax
  8023b8:	31 d2                	xor    %edx,%edx
  8023ba:	83 c4 1c             	add    $0x1c,%esp
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5f                   	pop    %edi
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    
  8023c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023c8:	39 f2                	cmp    %esi,%edx
  8023ca:	89 d0                	mov    %edx,%eax
  8023cc:	77 52                	ja     802420 <__umoddi3+0xa0>
  8023ce:	0f bd ea             	bsr    %edx,%ebp
  8023d1:	83 f5 1f             	xor    $0x1f,%ebp
  8023d4:	75 5a                	jne    802430 <__umoddi3+0xb0>
  8023d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023da:	0f 82 e0 00 00 00    	jb     8024c0 <__umoddi3+0x140>
  8023e0:	39 0c 24             	cmp    %ecx,(%esp)
  8023e3:	0f 86 d7 00 00 00    	jbe    8024c0 <__umoddi3+0x140>
  8023e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023f1:	83 c4 1c             	add    $0x1c,%esp
  8023f4:	5b                   	pop    %ebx
  8023f5:	5e                   	pop    %esi
  8023f6:	5f                   	pop    %edi
  8023f7:	5d                   	pop    %ebp
  8023f8:	c3                   	ret    
  8023f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802400:	85 ff                	test   %edi,%edi
  802402:	89 fd                	mov    %edi,%ebp
  802404:	75 0b                	jne    802411 <__umoddi3+0x91>
  802406:	b8 01 00 00 00       	mov    $0x1,%eax
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	f7 f7                	div    %edi
  80240f:	89 c5                	mov    %eax,%ebp
  802411:	89 f0                	mov    %esi,%eax
  802413:	31 d2                	xor    %edx,%edx
  802415:	f7 f5                	div    %ebp
  802417:	89 c8                	mov    %ecx,%eax
  802419:	f7 f5                	div    %ebp
  80241b:	89 d0                	mov    %edx,%eax
  80241d:	eb 99                	jmp    8023b8 <__umoddi3+0x38>
  80241f:	90                   	nop
  802420:	89 c8                	mov    %ecx,%eax
  802422:	89 f2                	mov    %esi,%edx
  802424:	83 c4 1c             	add    $0x1c,%esp
  802427:	5b                   	pop    %ebx
  802428:	5e                   	pop    %esi
  802429:	5f                   	pop    %edi
  80242a:	5d                   	pop    %ebp
  80242b:	c3                   	ret    
  80242c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802430:	8b 34 24             	mov    (%esp),%esi
  802433:	bf 20 00 00 00       	mov    $0x20,%edi
  802438:	89 e9                	mov    %ebp,%ecx
  80243a:	29 ef                	sub    %ebp,%edi
  80243c:	d3 e0                	shl    %cl,%eax
  80243e:	89 f9                	mov    %edi,%ecx
  802440:	89 f2                	mov    %esi,%edx
  802442:	d3 ea                	shr    %cl,%edx
  802444:	89 e9                	mov    %ebp,%ecx
  802446:	09 c2                	or     %eax,%edx
  802448:	89 d8                	mov    %ebx,%eax
  80244a:	89 14 24             	mov    %edx,(%esp)
  80244d:	89 f2                	mov    %esi,%edx
  80244f:	d3 e2                	shl    %cl,%edx
  802451:	89 f9                	mov    %edi,%ecx
  802453:	89 54 24 04          	mov    %edx,0x4(%esp)
  802457:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80245b:	d3 e8                	shr    %cl,%eax
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	89 c6                	mov    %eax,%esi
  802461:	d3 e3                	shl    %cl,%ebx
  802463:	89 f9                	mov    %edi,%ecx
  802465:	89 d0                	mov    %edx,%eax
  802467:	d3 e8                	shr    %cl,%eax
  802469:	89 e9                	mov    %ebp,%ecx
  80246b:	09 d8                	or     %ebx,%eax
  80246d:	89 d3                	mov    %edx,%ebx
  80246f:	89 f2                	mov    %esi,%edx
  802471:	f7 34 24             	divl   (%esp)
  802474:	89 d6                	mov    %edx,%esi
  802476:	d3 e3                	shl    %cl,%ebx
  802478:	f7 64 24 04          	mull   0x4(%esp)
  80247c:	39 d6                	cmp    %edx,%esi
  80247e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802482:	89 d1                	mov    %edx,%ecx
  802484:	89 c3                	mov    %eax,%ebx
  802486:	72 08                	jb     802490 <__umoddi3+0x110>
  802488:	75 11                	jne    80249b <__umoddi3+0x11b>
  80248a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80248e:	73 0b                	jae    80249b <__umoddi3+0x11b>
  802490:	2b 44 24 04          	sub    0x4(%esp),%eax
  802494:	1b 14 24             	sbb    (%esp),%edx
  802497:	89 d1                	mov    %edx,%ecx
  802499:	89 c3                	mov    %eax,%ebx
  80249b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80249f:	29 da                	sub    %ebx,%edx
  8024a1:	19 ce                	sbb    %ecx,%esi
  8024a3:	89 f9                	mov    %edi,%ecx
  8024a5:	89 f0                	mov    %esi,%eax
  8024a7:	d3 e0                	shl    %cl,%eax
  8024a9:	89 e9                	mov    %ebp,%ecx
  8024ab:	d3 ea                	shr    %cl,%edx
  8024ad:	89 e9                	mov    %ebp,%ecx
  8024af:	d3 ee                	shr    %cl,%esi
  8024b1:	09 d0                	or     %edx,%eax
  8024b3:	89 f2                	mov    %esi,%edx
  8024b5:	83 c4 1c             	add    $0x1c,%esp
  8024b8:	5b                   	pop    %ebx
  8024b9:	5e                   	pop    %esi
  8024ba:	5f                   	pop    %edi
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    
  8024bd:	8d 76 00             	lea    0x0(%esi),%esi
  8024c0:	29 f9                	sub    %edi,%ecx
  8024c2:	19 d6                	sbb    %edx,%esi
  8024c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024cc:	e9 18 ff ff ff       	jmp    8023e9 <__umoddi3+0x69>
