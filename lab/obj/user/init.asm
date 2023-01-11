
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
  80006d:	68 c0 2a 80 00       	push   $0x802ac0
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 40 80 00       	push   $0x804000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 88 2b 80 00       	push   $0x802b88
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 cf 2a 80 00       	push   $0x802acf
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 60 80 00       	push   $0x806020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 c4 2b 80 00       	push   $0x802bc4
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 e6 2a 80 00       	push   $0x802ae6
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 fc 2a 80 00       	push   $0x802afc
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
  80011e:	68 08 2b 80 00       	push   $0x802b08
  800123:	56                   	push   %esi
  800124:	e8 54 09 00 00       	call   800a7d <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 48 09 00 00       	call   800a7d <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 09 2b 80 00       	push   $0x802b09
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
  800158:	68 0b 2b 80 00       	push   $0x802b0b
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 0f 2b 80 00 	movl   $0x802b0f,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 1a 11 00 00       	call   801294 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 21 2b 80 00       	push   $0x802b21
  80018c:	6a 37                	push   $0x37
  80018e:	68 2e 2b 80 00       	push   $0x802b2e
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 3a 2b 80 00       	push   $0x802b3a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 2e 2b 80 00       	push   $0x802b2e
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 2a 11 00 00       	call   8012e4 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 54 2b 80 00       	push   $0x802b54
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 2e 2b 80 00       	push   $0x802b2e
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 5c 2b 80 00       	push   $0x802b5c
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 70 2b 80 00       	push   $0x802b70
  8001ea:	68 6f 2b 80 00       	push   $0x802b6f
  8001ef:	e8 7b 1c 00 00       	call   801e6f <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 73 2b 80 00       	push   $0x802b73
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 8e 24 00 00       	call   8026a5 <wait>
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
  80022c:	68 f3 2b 80 00       	push   $0x802bf3
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
  8002fc:	e8 cf 10 00 00       	call   8013d0 <read>
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
  800326:	e8 3f 0e 00 00       	call   80116a <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 57 80 00    	mov    0x805770,%edx
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
  80034f:	e8 c7 0d 00 00       	call   80111b <fd_alloc>
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
  800378:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 5e 0d 00 00       	call   8010f4 <fd2num>
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
  8003bc:	a3 90 77 80 00       	mov    %eax,0x807790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 57 80 00       	mov    %eax,0x80578c

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
  8003eb:	e8 cf 0e 00 00       	call   8012bf <close_all>
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
  800407:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  80040d:	e8 10 0a 00 00       	call   800e22 <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 0c 2c 80 00       	push   $0x802c0c
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 35 31 80 00 	movl   $0x803135,(%esp)
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
  80053b:	e8 f0 22 00 00       	call   802830 <__udivdi3>
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
  80057e:	e8 dd 23 00 00       	call   802960 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 2f 2c 80 00 	movsbl 0x802c2f(%eax),%eax
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
  800682:	ff 24 85 80 2d 80 00 	jmp    *0x802d80(,%eax,4)
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
  800746:	8b 14 85 e0 2e 80 00 	mov    0x802ee0(,%eax,4),%edx
  80074d:	85 d2                	test   %edx,%edx
  80074f:	75 18                	jne    800769 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800751:	50                   	push   %eax
  800752:	68 47 2c 80 00       	push   $0x802c47
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
  80076a:	68 15 30 80 00       	push   $0x803015
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
  80078e:	b8 40 2c 80 00       	mov    $0x802c40,%eax
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
  800e09:	68 3f 2f 80 00       	push   $0x802f3f
  800e0e:	6a 23                	push   $0x23
  800e10:	68 5c 2f 80 00       	push   $0x802f5c
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
  800e8a:	68 3f 2f 80 00       	push   $0x802f3f
  800e8f:	6a 23                	push   $0x23
  800e91:	68 5c 2f 80 00       	push   $0x802f5c
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
  800ecc:	68 3f 2f 80 00       	push   $0x802f3f
  800ed1:	6a 23                	push   $0x23
  800ed3:	68 5c 2f 80 00       	push   $0x802f5c
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
  800f0e:	68 3f 2f 80 00       	push   $0x802f3f
  800f13:	6a 23                	push   $0x23
  800f15:	68 5c 2f 80 00       	push   $0x802f5c
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
  800f50:	68 3f 2f 80 00       	push   $0x802f3f
  800f55:	6a 23                	push   $0x23
  800f57:	68 5c 2f 80 00       	push   $0x802f5c
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
  800f92:	68 3f 2f 80 00       	push   $0x802f3f
  800f97:	6a 23                	push   $0x23
  800f99:	68 5c 2f 80 00       	push   $0x802f5c
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
  800fd4:	68 3f 2f 80 00       	push   $0x802f3f
  800fd9:	6a 23                	push   $0x23
  800fdb:	68 5c 2f 80 00       	push   $0x802f5c
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
  801038:	68 3f 2f 80 00       	push   $0x802f3f
  80103d:	6a 23                	push   $0x23
  80103f:	68 5c 2f 80 00       	push   $0x802f5c
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

00801051 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	ba 00 00 00 00       	mov    $0x0,%edx
  80105c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801061:	89 d1                	mov    %edx,%ecx
  801063:	89 d3                	mov    %edx,%ebx
  801065:	89 d7                	mov    %edx,%edi
  801067:	89 d6                	mov    %edx,%esi
  801069:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801079:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107e:	b8 0f 00 00 00       	mov    $0xf,%eax
  801083:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	89 df                	mov    %ebx,%edi
  80108b:	89 de                	mov    %ebx,%esi
  80108d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108f:	85 c0                	test   %eax,%eax
  801091:	7e 17                	jle    8010aa <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	6a 0f                	push   $0xf
  801099:	68 3f 2f 80 00       	push   $0x802f3f
  80109e:	6a 23                	push   $0x23
  8010a0:	68 5c 2f 80 00       	push   $0x802f5c
  8010a5:	e8 55 f3 ff ff       	call   8003ff <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8010aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c0:	b8 10 00 00 00       	mov    $0x10,%eax
  8010c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cb:	89 df                	mov    %ebx,%edi
  8010cd:	89 de                	mov    %ebx,%esi
  8010cf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	7e 17                	jle    8010ec <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	50                   	push   %eax
  8010d9:	6a 10                	push   $0x10
  8010db:	68 3f 2f 80 00       	push   $0x802f3f
  8010e0:	6a 23                	push   $0x23
  8010e2:	68 5c 2f 80 00       	push   $0x802f5c
  8010e7:	e8 13 f3 ff ff       	call   8003ff <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8010ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ff:	c1 e8 0c             	shr    $0xc,%eax
}
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801107:	8b 45 08             	mov    0x8(%ebp),%eax
  80110a:	05 00 00 00 30       	add    $0x30000000,%eax
  80110f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801114:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801121:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801126:	89 c2                	mov    %eax,%edx
  801128:	c1 ea 16             	shr    $0x16,%edx
  80112b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801132:	f6 c2 01             	test   $0x1,%dl
  801135:	74 11                	je     801148 <fd_alloc+0x2d>
  801137:	89 c2                	mov    %eax,%edx
  801139:	c1 ea 0c             	shr    $0xc,%edx
  80113c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801143:	f6 c2 01             	test   $0x1,%dl
  801146:	75 09                	jne    801151 <fd_alloc+0x36>
			*fd_store = fd;
  801148:	89 01                	mov    %eax,(%ecx)
			return 0;
  80114a:	b8 00 00 00 00       	mov    $0x0,%eax
  80114f:	eb 17                	jmp    801168 <fd_alloc+0x4d>
  801151:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801156:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80115b:	75 c9                	jne    801126 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80115d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801163:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801170:	83 f8 1f             	cmp    $0x1f,%eax
  801173:	77 36                	ja     8011ab <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801175:	c1 e0 0c             	shl    $0xc,%eax
  801178:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	c1 ea 16             	shr    $0x16,%edx
  801182:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801189:	f6 c2 01             	test   $0x1,%dl
  80118c:	74 24                	je     8011b2 <fd_lookup+0x48>
  80118e:	89 c2                	mov    %eax,%edx
  801190:	c1 ea 0c             	shr    $0xc,%edx
  801193:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119a:	f6 c2 01             	test   $0x1,%dl
  80119d:	74 1a                	je     8011b9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80119f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a2:	89 02                	mov    %eax,(%edx)
	return 0;
  8011a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a9:	eb 13                	jmp    8011be <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b0:	eb 0c                	jmp    8011be <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b7:	eb 05                	jmp    8011be <fd_lookup+0x54>
  8011b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c9:	ba e8 2f 80 00       	mov    $0x802fe8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ce:	eb 13                	jmp    8011e3 <dev_lookup+0x23>
  8011d0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011d3:	39 08                	cmp    %ecx,(%eax)
  8011d5:	75 0c                	jne    8011e3 <dev_lookup+0x23>
			*dev = devtab[i];
  8011d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011da:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e1:	eb 2e                	jmp    801211 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e3:	8b 02                	mov    (%edx),%eax
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	75 e7                	jne    8011d0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011e9:	a1 90 77 80 00       	mov    0x807790,%eax
  8011ee:	8b 40 48             	mov    0x48(%eax),%eax
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	51                   	push   %ecx
  8011f5:	50                   	push   %eax
  8011f6:	68 6c 2f 80 00       	push   $0x802f6c
  8011fb:	e8 d8 f2 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  801200:	8b 45 0c             	mov    0xc(%ebp),%eax
  801203:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	56                   	push   %esi
  801217:	53                   	push   %ebx
  801218:	83 ec 10             	sub    $0x10,%esp
  80121b:	8b 75 08             	mov    0x8(%ebp),%esi
  80121e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801221:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80122b:	c1 e8 0c             	shr    $0xc,%eax
  80122e:	50                   	push   %eax
  80122f:	e8 36 ff ff ff       	call   80116a <fd_lookup>
  801234:	83 c4 08             	add    $0x8,%esp
  801237:	85 c0                	test   %eax,%eax
  801239:	78 05                	js     801240 <fd_close+0x2d>
	    || fd != fd2)
  80123b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80123e:	74 0c                	je     80124c <fd_close+0x39>
		return (must_exist ? r : 0);
  801240:	84 db                	test   %bl,%bl
  801242:	ba 00 00 00 00       	mov    $0x0,%edx
  801247:	0f 44 c2             	cmove  %edx,%eax
  80124a:	eb 41                	jmp    80128d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801252:	50                   	push   %eax
  801253:	ff 36                	pushl  (%esi)
  801255:	e8 66 ff ff ff       	call   8011c0 <dev_lookup>
  80125a:	89 c3                	mov    %eax,%ebx
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 1a                	js     80127d <fd_close+0x6a>
		if (dev->dev_close)
  801263:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801266:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801269:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80126e:	85 c0                	test   %eax,%eax
  801270:	74 0b                	je     80127d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801272:	83 ec 0c             	sub    $0xc,%esp
  801275:	56                   	push   %esi
  801276:	ff d0                	call   *%eax
  801278:	89 c3                	mov    %eax,%ebx
  80127a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	56                   	push   %esi
  801281:	6a 00                	push   $0x0
  801283:	e8 5d fc ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	89 d8                	mov    %ebx,%eax
}
  80128d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801290:	5b                   	pop    %ebx
  801291:	5e                   	pop    %esi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	ff 75 08             	pushl  0x8(%ebp)
  8012a1:	e8 c4 fe ff ff       	call   80116a <fd_lookup>
  8012a6:	83 c4 08             	add    $0x8,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 10                	js     8012bd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	6a 01                	push   $0x1
  8012b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b5:	e8 59 ff ff ff       	call   801213 <fd_close>
  8012ba:	83 c4 10             	add    $0x10,%esp
}
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <close_all>:

void
close_all(void)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	53                   	push   %ebx
  8012cf:	e8 c0 ff ff ff       	call   801294 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d4:	83 c3 01             	add    $0x1,%ebx
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	83 fb 20             	cmp    $0x20,%ebx
  8012dd:	75 ec                	jne    8012cb <close_all+0xc>
		close(i);
}
  8012df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e2:	c9                   	leave  
  8012e3:	c3                   	ret    

008012e4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	57                   	push   %edi
  8012e8:	56                   	push   %esi
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 2c             	sub    $0x2c,%esp
  8012ed:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	ff 75 08             	pushl  0x8(%ebp)
  8012f7:	e8 6e fe ff ff       	call   80116a <fd_lookup>
  8012fc:	83 c4 08             	add    $0x8,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	0f 88 c1 00 00 00    	js     8013c8 <dup+0xe4>
		return r;
	close(newfdnum);
  801307:	83 ec 0c             	sub    $0xc,%esp
  80130a:	56                   	push   %esi
  80130b:	e8 84 ff ff ff       	call   801294 <close>

	newfd = INDEX2FD(newfdnum);
  801310:	89 f3                	mov    %esi,%ebx
  801312:	c1 e3 0c             	shl    $0xc,%ebx
  801315:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80131b:	83 c4 04             	add    $0x4,%esp
  80131e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801321:	e8 de fd ff ff       	call   801104 <fd2data>
  801326:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801328:	89 1c 24             	mov    %ebx,(%esp)
  80132b:	e8 d4 fd ff ff       	call   801104 <fd2data>
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801336:	89 f8                	mov    %edi,%eax
  801338:	c1 e8 16             	shr    $0x16,%eax
  80133b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801342:	a8 01                	test   $0x1,%al
  801344:	74 37                	je     80137d <dup+0x99>
  801346:	89 f8                	mov    %edi,%eax
  801348:	c1 e8 0c             	shr    $0xc,%eax
  80134b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801352:	f6 c2 01             	test   $0x1,%dl
  801355:	74 26                	je     80137d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801357:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135e:	83 ec 0c             	sub    $0xc,%esp
  801361:	25 07 0e 00 00       	and    $0xe07,%eax
  801366:	50                   	push   %eax
  801367:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136a:	6a 00                	push   $0x0
  80136c:	57                   	push   %edi
  80136d:	6a 00                	push   $0x0
  80136f:	e8 2f fb ff ff       	call   800ea3 <sys_page_map>
  801374:	89 c7                	mov    %eax,%edi
  801376:	83 c4 20             	add    $0x20,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 2e                	js     8013ab <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80137d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801380:	89 d0                	mov    %edx,%eax
  801382:	c1 e8 0c             	shr    $0xc,%eax
  801385:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80138c:	83 ec 0c             	sub    $0xc,%esp
  80138f:	25 07 0e 00 00       	and    $0xe07,%eax
  801394:	50                   	push   %eax
  801395:	53                   	push   %ebx
  801396:	6a 00                	push   $0x0
  801398:	52                   	push   %edx
  801399:	6a 00                	push   $0x0
  80139b:	e8 03 fb ff ff       	call   800ea3 <sys_page_map>
  8013a0:	89 c7                	mov    %eax,%edi
  8013a2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013a5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a7:	85 ff                	test   %edi,%edi
  8013a9:	79 1d                	jns    8013c8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	53                   	push   %ebx
  8013af:	6a 00                	push   $0x0
  8013b1:	e8 2f fb ff ff       	call   800ee5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013b6:	83 c4 08             	add    $0x8,%esp
  8013b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013bc:	6a 00                	push   $0x0
  8013be:	e8 22 fb ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	89 f8                	mov    %edi,%eax
}
  8013c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013cb:	5b                   	pop    %ebx
  8013cc:	5e                   	pop    %esi
  8013cd:	5f                   	pop    %edi
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 14             	sub    $0x14,%esp
  8013d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013dd:	50                   	push   %eax
  8013de:	53                   	push   %ebx
  8013df:	e8 86 fd ff ff       	call   80116a <fd_lookup>
  8013e4:	83 c4 08             	add    $0x8,%esp
  8013e7:	89 c2                	mov    %eax,%edx
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 6d                	js     80145a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f3:	50                   	push   %eax
  8013f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f7:	ff 30                	pushl  (%eax)
  8013f9:	e8 c2 fd ff ff       	call   8011c0 <dev_lookup>
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 4c                	js     801451 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801405:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801408:	8b 42 08             	mov    0x8(%edx),%eax
  80140b:	83 e0 03             	and    $0x3,%eax
  80140e:	83 f8 01             	cmp    $0x1,%eax
  801411:	75 21                	jne    801434 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801413:	a1 90 77 80 00       	mov    0x807790,%eax
  801418:	8b 40 48             	mov    0x48(%eax),%eax
  80141b:	83 ec 04             	sub    $0x4,%esp
  80141e:	53                   	push   %ebx
  80141f:	50                   	push   %eax
  801420:	68 ad 2f 80 00       	push   $0x802fad
  801425:	e8 ae f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801432:	eb 26                	jmp    80145a <read+0x8a>
	}
	if (!dev->dev_read)
  801434:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801437:	8b 40 08             	mov    0x8(%eax),%eax
  80143a:	85 c0                	test   %eax,%eax
  80143c:	74 17                	je     801455 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80143e:	83 ec 04             	sub    $0x4,%esp
  801441:	ff 75 10             	pushl  0x10(%ebp)
  801444:	ff 75 0c             	pushl  0xc(%ebp)
  801447:	52                   	push   %edx
  801448:	ff d0                	call   *%eax
  80144a:	89 c2                	mov    %eax,%edx
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	eb 09                	jmp    80145a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801451:	89 c2                	mov    %eax,%edx
  801453:	eb 05                	jmp    80145a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801455:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80145a:	89 d0                	mov    %edx,%eax
  80145c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145f:	c9                   	leave  
  801460:	c3                   	ret    

00801461 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	57                   	push   %edi
  801465:	56                   	push   %esi
  801466:	53                   	push   %ebx
  801467:	83 ec 0c             	sub    $0xc,%esp
  80146a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80146d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801470:	bb 00 00 00 00       	mov    $0x0,%ebx
  801475:	eb 21                	jmp    801498 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	89 f0                	mov    %esi,%eax
  80147c:	29 d8                	sub    %ebx,%eax
  80147e:	50                   	push   %eax
  80147f:	89 d8                	mov    %ebx,%eax
  801481:	03 45 0c             	add    0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	57                   	push   %edi
  801486:	e8 45 ff ff ff       	call   8013d0 <read>
		if (m < 0)
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 10                	js     8014a2 <readn+0x41>
			return m;
		if (m == 0)
  801492:	85 c0                	test   %eax,%eax
  801494:	74 0a                	je     8014a0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801496:	01 c3                	add    %eax,%ebx
  801498:	39 f3                	cmp    %esi,%ebx
  80149a:	72 db                	jb     801477 <readn+0x16>
  80149c:	89 d8                	mov    %ebx,%eax
  80149e:	eb 02                	jmp    8014a2 <readn+0x41>
  8014a0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a5:	5b                   	pop    %ebx
  8014a6:	5e                   	pop    %esi
  8014a7:	5f                   	pop    %edi
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    

008014aa <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 14             	sub    $0x14,%esp
  8014b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	53                   	push   %ebx
  8014b9:	e8 ac fc ff ff       	call   80116a <fd_lookup>
  8014be:	83 c4 08             	add    $0x8,%esp
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 68                	js     80152f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d1:	ff 30                	pushl  (%eax)
  8014d3:	e8 e8 fc ff ff       	call   8011c0 <dev_lookup>
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 47                	js     801526 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014e6:	75 21                	jne    801509 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e8:	a1 90 77 80 00       	mov    0x807790,%eax
  8014ed:	8b 40 48             	mov    0x48(%eax),%eax
  8014f0:	83 ec 04             	sub    $0x4,%esp
  8014f3:	53                   	push   %ebx
  8014f4:	50                   	push   %eax
  8014f5:	68 c9 2f 80 00       	push   $0x802fc9
  8014fa:	e8 d9 ef ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801507:	eb 26                	jmp    80152f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801509:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80150c:	8b 52 0c             	mov    0xc(%edx),%edx
  80150f:	85 d2                	test   %edx,%edx
  801511:	74 17                	je     80152a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801513:	83 ec 04             	sub    $0x4,%esp
  801516:	ff 75 10             	pushl  0x10(%ebp)
  801519:	ff 75 0c             	pushl  0xc(%ebp)
  80151c:	50                   	push   %eax
  80151d:	ff d2                	call   *%edx
  80151f:	89 c2                	mov    %eax,%edx
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	eb 09                	jmp    80152f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801526:	89 c2                	mov    %eax,%edx
  801528:	eb 05                	jmp    80152f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80152a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80152f:	89 d0                	mov    %edx,%eax
  801531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801534:	c9                   	leave  
  801535:	c3                   	ret    

00801536 <seek>:

int
seek(int fdnum, off_t offset)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80153c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	ff 75 08             	pushl  0x8(%ebp)
  801543:	e8 22 fc ff ff       	call   80116a <fd_lookup>
  801548:	83 c4 08             	add    $0x8,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 0e                	js     80155d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80154f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801552:	8b 55 0c             	mov    0xc(%ebp),%edx
  801555:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801558:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	53                   	push   %ebx
  801563:	83 ec 14             	sub    $0x14,%esp
  801566:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801569:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156c:	50                   	push   %eax
  80156d:	53                   	push   %ebx
  80156e:	e8 f7 fb ff ff       	call   80116a <fd_lookup>
  801573:	83 c4 08             	add    $0x8,%esp
  801576:	89 c2                	mov    %eax,%edx
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 65                	js     8015e1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801586:	ff 30                	pushl  (%eax)
  801588:	e8 33 fc ff ff       	call   8011c0 <dev_lookup>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	78 44                	js     8015d8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801594:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801597:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159b:	75 21                	jne    8015be <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80159d:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a2:	8b 40 48             	mov    0x48(%eax),%eax
  8015a5:	83 ec 04             	sub    $0x4,%esp
  8015a8:	53                   	push   %ebx
  8015a9:	50                   	push   %eax
  8015aa:	68 8c 2f 80 00       	push   $0x802f8c
  8015af:	e8 24 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015bc:	eb 23                	jmp    8015e1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c1:	8b 52 18             	mov    0x18(%edx),%edx
  8015c4:	85 d2                	test   %edx,%edx
  8015c6:	74 14                	je     8015dc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ce:	50                   	push   %eax
  8015cf:	ff d2                	call   *%edx
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	eb 09                	jmp    8015e1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d8:	89 c2                	mov    %eax,%edx
  8015da:	eb 05                	jmp    8015e1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015e1:	89 d0                	mov    %edx,%eax
  8015e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 14             	sub    $0x14,%esp
  8015ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	ff 75 08             	pushl  0x8(%ebp)
  8015f9:	e8 6c fb ff ff       	call   80116a <fd_lookup>
  8015fe:	83 c4 08             	add    $0x8,%esp
  801601:	89 c2                	mov    %eax,%edx
  801603:	85 c0                	test   %eax,%eax
  801605:	78 58                	js     80165f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801611:	ff 30                	pushl  (%eax)
  801613:	e8 a8 fb ff ff       	call   8011c0 <dev_lookup>
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 37                	js     801656 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80161f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801622:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801626:	74 32                	je     80165a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801628:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80162b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801632:	00 00 00 
	stat->st_isdir = 0;
  801635:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80163c:	00 00 00 
	stat->st_dev = dev;
  80163f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	53                   	push   %ebx
  801649:	ff 75 f0             	pushl  -0x10(%ebp)
  80164c:	ff 50 14             	call   *0x14(%eax)
  80164f:	89 c2                	mov    %eax,%edx
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	eb 09                	jmp    80165f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801656:	89 c2                	mov    %eax,%edx
  801658:	eb 05                	jmp    80165f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80165a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80165f:	89 d0                	mov    %edx,%eax
  801661:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	56                   	push   %esi
  80166a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	6a 00                	push   $0x0
  801670:	ff 75 08             	pushl  0x8(%ebp)
  801673:	e8 d6 01 00 00       	call   80184e <open>
  801678:	89 c3                	mov    %eax,%ebx
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 1b                	js     80169c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801681:	83 ec 08             	sub    $0x8,%esp
  801684:	ff 75 0c             	pushl  0xc(%ebp)
  801687:	50                   	push   %eax
  801688:	e8 5b ff ff ff       	call   8015e8 <fstat>
  80168d:	89 c6                	mov    %eax,%esi
	close(fd);
  80168f:	89 1c 24             	mov    %ebx,(%esp)
  801692:	e8 fd fb ff ff       	call   801294 <close>
	return r;
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	89 f0                	mov    %esi,%eax
}
  80169c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169f:	5b                   	pop    %ebx
  8016a0:	5e                   	pop    %esi
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	56                   	push   %esi
  8016a7:	53                   	push   %ebx
  8016a8:	89 c6                	mov    %eax,%esi
  8016aa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ac:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016b3:	75 12                	jne    8016c7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b5:	83 ec 0c             	sub    $0xc,%esp
  8016b8:	6a 01                	push   $0x1
  8016ba:	e8 f0 10 00 00       	call   8027af <ipc_find_env>
  8016bf:	a3 00 60 80 00       	mov    %eax,0x806000
  8016c4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016c7:	6a 07                	push   $0x7
  8016c9:	68 00 80 80 00       	push   $0x808000
  8016ce:	56                   	push   %esi
  8016cf:	ff 35 00 60 80 00    	pushl  0x806000
  8016d5:	e8 81 10 00 00       	call   80275b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016da:	83 c4 0c             	add    $0xc,%esp
  8016dd:	6a 00                	push   $0x0
  8016df:	53                   	push   %ebx
  8016e0:	6a 00                	push   $0x0
  8016e2:	e8 0d 10 00 00       	call   8026f4 <ipc_recv>
}
  8016e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ea:	5b                   	pop    %ebx
  8016eb:	5e                   	pop    %esi
  8016ec:	5d                   	pop    %ebp
  8016ed:	c3                   	ret    

008016ee <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fa:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  8016ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801702:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801707:	ba 00 00 00 00       	mov    $0x0,%edx
  80170c:	b8 02 00 00 00       	mov    $0x2,%eax
  801711:	e8 8d ff ff ff       	call   8016a3 <fsipc>
}
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80171e:	8b 45 08             	mov    0x8(%ebp),%eax
  801721:	8b 40 0c             	mov    0xc(%eax),%eax
  801724:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801729:	ba 00 00 00 00       	mov    $0x0,%edx
  80172e:	b8 06 00 00 00       	mov    $0x6,%eax
  801733:	e8 6b ff ff ff       	call   8016a3 <fsipc>
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	83 ec 04             	sub    $0x4,%esp
  801741:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801744:	8b 45 08             	mov    0x8(%ebp),%eax
  801747:	8b 40 0c             	mov    0xc(%eax),%eax
  80174a:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80174f:	ba 00 00 00 00       	mov    $0x0,%edx
  801754:	b8 05 00 00 00       	mov    $0x5,%eax
  801759:	e8 45 ff ff ff       	call   8016a3 <fsipc>
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 2c                	js     80178e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801762:	83 ec 08             	sub    $0x8,%esp
  801765:	68 00 80 80 00       	push   $0x808000
  80176a:	53                   	push   %ebx
  80176b:	e8 ed f2 ff ff       	call   800a5d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801770:	a1 80 80 80 00       	mov    0x808080,%eax
  801775:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80177b:	a1 84 80 80 00       	mov    0x808084,%eax
  801780:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	83 ec 0c             	sub    $0xc,%esp
  801799:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80179c:	8b 55 08             	mov    0x8(%ebp),%edx
  80179f:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a2:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = n;
  8017a8:	a3 04 80 80 00       	mov    %eax,0x808004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017ad:	50                   	push   %eax
  8017ae:	ff 75 0c             	pushl  0xc(%ebp)
  8017b1:	68 08 80 80 00       	push   $0x808008
  8017b6:	e8 34 f4 ff ff       	call   800bef <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c5:	e8 d9 fe ff ff       	call   8016a3 <fsipc>

}
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017da:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  8017df:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ef:	e8 af fe ff ff       	call   8016a3 <fsipc>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 4b                	js     801845 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017fa:	39 c6                	cmp    %eax,%esi
  8017fc:	73 16                	jae    801814 <devfile_read+0x48>
  8017fe:	68 fc 2f 80 00       	push   $0x802ffc
  801803:	68 03 30 80 00       	push   $0x803003
  801808:	6a 7c                	push   $0x7c
  80180a:	68 18 30 80 00       	push   $0x803018
  80180f:	e8 eb eb ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  801814:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801819:	7e 16                	jle    801831 <devfile_read+0x65>
  80181b:	68 23 30 80 00       	push   $0x803023
  801820:	68 03 30 80 00       	push   $0x803003
  801825:	6a 7d                	push   $0x7d
  801827:	68 18 30 80 00       	push   $0x803018
  80182c:	e8 ce eb ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801831:	83 ec 04             	sub    $0x4,%esp
  801834:	50                   	push   %eax
  801835:	68 00 80 80 00       	push   $0x808000
  80183a:	ff 75 0c             	pushl  0xc(%ebp)
  80183d:	e8 ad f3 ff ff       	call   800bef <memmove>
	return r;
  801842:	83 c4 10             	add    $0x10,%esp
}
  801845:	89 d8                	mov    %ebx,%eax
  801847:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184a:	5b                   	pop    %ebx
  80184b:	5e                   	pop    %esi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	53                   	push   %ebx
  801852:	83 ec 20             	sub    $0x20,%esp
  801855:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801858:	53                   	push   %ebx
  801859:	e8 c6 f1 ff ff       	call   800a24 <strlen>
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801866:	7f 67                	jg     8018cf <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801868:	83 ec 0c             	sub    $0xc,%esp
  80186b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186e:	50                   	push   %eax
  80186f:	e8 a7 f8 ff ff       	call   80111b <fd_alloc>
  801874:	83 c4 10             	add    $0x10,%esp
		return r;
  801877:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 57                	js     8018d4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80187d:	83 ec 08             	sub    $0x8,%esp
  801880:	53                   	push   %ebx
  801881:	68 00 80 80 00       	push   $0x808000
  801886:	e8 d2 f1 ff ff       	call   800a5d <strcpy>
	fsipcbuf.open.req_omode = mode;
  80188b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188e:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801893:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801896:	b8 01 00 00 00       	mov    $0x1,%eax
  80189b:	e8 03 fe ff ff       	call   8016a3 <fsipc>
  8018a0:	89 c3                	mov    %eax,%ebx
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	79 14                	jns    8018bd <open+0x6f>
		fd_close(fd, 0);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	6a 00                	push   $0x0
  8018ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b1:	e8 5d f9 ff ff       	call   801213 <fd_close>
		return r;
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	89 da                	mov    %ebx,%edx
  8018bb:	eb 17                	jmp    8018d4 <open+0x86>
	}

	return fd2num(fd);
  8018bd:	83 ec 0c             	sub    $0xc,%esp
  8018c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c3:	e8 2c f8 ff ff       	call   8010f4 <fd2num>
  8018c8:	89 c2                	mov    %eax,%edx
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	eb 05                	jmp    8018d4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018cf:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018d4:	89 d0                	mov    %edx,%eax
  8018d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e6:	b8 08 00 00 00       	mov    $0x8,%eax
  8018eb:	e8 b3 fd ff ff       	call   8016a3 <fsipc>
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	57                   	push   %edi
  8018f6:	56                   	push   %esi
  8018f7:	53                   	push   %ebx
  8018f8:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018fe:	6a 00                	push   $0x0
  801900:	ff 75 08             	pushl  0x8(%ebp)
  801903:	e8 46 ff ff ff       	call   80184e <open>
  801908:	89 c7                	mov    %eax,%edi
  80190a:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	85 c0                	test   %eax,%eax
  801915:	0f 88 97 04 00 00    	js     801db2 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80191b:	83 ec 04             	sub    $0x4,%esp
  80191e:	68 00 02 00 00       	push   $0x200
  801923:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801929:	50                   	push   %eax
  80192a:	57                   	push   %edi
  80192b:	e8 31 fb ff ff       	call   801461 <readn>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	3d 00 02 00 00       	cmp    $0x200,%eax
  801938:	75 0c                	jne    801946 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80193a:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801941:	45 4c 46 
  801944:	74 33                	je     801979 <spawn+0x87>
		close(fd);
  801946:	83 ec 0c             	sub    $0xc,%esp
  801949:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80194f:	e8 40 f9 ff ff       	call   801294 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801954:	83 c4 0c             	add    $0xc,%esp
  801957:	68 7f 45 4c 46       	push   $0x464c457f
  80195c:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801962:	68 2f 30 80 00       	push   $0x80302f
  801967:	e8 6c eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801974:	e9 ec 04 00 00       	jmp    801e65 <spawn+0x573>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801979:	b8 07 00 00 00       	mov    $0x7,%eax
  80197e:	cd 30                	int    $0x30
  801980:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801986:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80198c:	85 c0                	test   %eax,%eax
  80198e:	0f 88 29 04 00 00    	js     801dbd <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801994:	89 c6                	mov    %eax,%esi
  801996:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80199c:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80199f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019a5:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019ab:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019b2:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019b8:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019be:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019c3:	be 00 00 00 00       	mov    $0x0,%esi
  8019c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019cb:	eb 13                	jmp    8019e0 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019cd:	83 ec 0c             	sub    $0xc,%esp
  8019d0:	50                   	push   %eax
  8019d1:	e8 4e f0 ff ff       	call   800a24 <strlen>
  8019d6:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019da:	83 c3 01             	add    $0x1,%ebx
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019e7:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	75 df                	jne    8019cd <spawn+0xdb>
  8019ee:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019f4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019fa:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019ff:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a01:	89 fa                	mov    %edi,%edx
  801a03:	83 e2 fc             	and    $0xfffffffc,%edx
  801a06:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a0d:	29 c2                	sub    %eax,%edx
  801a0f:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a15:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a18:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a1d:	0f 86 b0 03 00 00    	jbe    801dd3 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a23:	83 ec 04             	sub    $0x4,%esp
  801a26:	6a 07                	push   $0x7
  801a28:	68 00 00 40 00       	push   $0x400000
  801a2d:	6a 00                	push   $0x0
  801a2f:	e8 2c f4 ff ff       	call   800e60 <sys_page_alloc>
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	85 c0                	test   %eax,%eax
  801a39:	0f 88 9e 03 00 00    	js     801ddd <spawn+0x4eb>
  801a3f:	be 00 00 00 00       	mov    $0x0,%esi
  801a44:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a4d:	eb 30                	jmp    801a7f <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a4f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a55:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a5b:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a64:	57                   	push   %edi
  801a65:	e8 f3 ef ff ff       	call   800a5d <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a6a:	83 c4 04             	add    $0x4,%esp
  801a6d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a70:	e8 af ef ff ff       	call   800a24 <strlen>
  801a75:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a79:	83 c6 01             	add    $0x1,%esi
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a85:	7f c8                	jg     801a4f <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a87:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a8d:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801a93:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a9a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801aa0:	74 19                	je     801abb <spawn+0x1c9>
  801aa2:	68 bc 30 80 00       	push   $0x8030bc
  801aa7:	68 03 30 80 00       	push   $0x803003
  801aac:	68 f2 00 00 00       	push   $0xf2
  801ab1:	68 49 30 80 00       	push   $0x803049
  801ab6:	e8 44 e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801abb:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801ac1:	89 f8                	mov    %edi,%eax
  801ac3:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ac8:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801acb:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ad1:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ad4:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801ada:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ae0:	83 ec 0c             	sub    $0xc,%esp
  801ae3:	6a 07                	push   $0x7
  801ae5:	68 00 d0 bf ee       	push   $0xeebfd000
  801aea:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801af0:	68 00 00 40 00       	push   $0x400000
  801af5:	6a 00                	push   $0x0
  801af7:	e8 a7 f3 ff ff       	call   800ea3 <sys_page_map>
  801afc:	89 c3                	mov    %eax,%ebx
  801afe:	83 c4 20             	add    $0x20,%esp
  801b01:	85 c0                	test   %eax,%eax
  801b03:	0f 88 4a 03 00 00    	js     801e53 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	68 00 00 40 00       	push   $0x400000
  801b11:	6a 00                	push   $0x0
  801b13:	e8 cd f3 ff ff       	call   800ee5 <sys_page_unmap>
  801b18:	89 c3                	mov    %eax,%ebx
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	0f 88 2e 03 00 00    	js     801e53 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b25:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b2b:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b32:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b38:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b3f:	00 00 00 
  801b42:	e9 8a 01 00 00       	jmp    801cd1 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801b47:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b4d:	83 38 01             	cmpl   $0x1,(%eax)
  801b50:	0f 85 6d 01 00 00    	jne    801cc3 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b56:	89 c7                	mov    %eax,%edi
  801b58:	8b 40 18             	mov    0x18(%eax),%eax
  801b5b:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b61:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b64:	83 f8 01             	cmp    $0x1,%eax
  801b67:	19 c0                	sbb    %eax,%eax
  801b69:	83 e0 fe             	and    $0xfffffffe,%eax
  801b6c:	83 c0 07             	add    $0x7,%eax
  801b6f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b75:	89 f8                	mov    %edi,%eax
  801b77:	8b 7f 04             	mov    0x4(%edi),%edi
  801b7a:	89 f9                	mov    %edi,%ecx
  801b7c:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b82:	8b 78 10             	mov    0x10(%eax),%edi
  801b85:	8b 70 14             	mov    0x14(%eax),%esi
  801b88:	89 f3                	mov    %esi,%ebx
  801b8a:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b90:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b93:	89 f0                	mov    %esi,%eax
  801b95:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b9a:	74 14                	je     801bb0 <spawn+0x2be>
		va -= i;
  801b9c:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b9e:	01 c3                	add    %eax,%ebx
  801ba0:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801ba6:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ba8:	29 c1                	sub    %eax,%ecx
  801baa:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb5:	e9 f7 00 00 00       	jmp    801cb1 <spawn+0x3bf>
		if (i >= filesz) {
  801bba:	39 df                	cmp    %ebx,%edi
  801bbc:	77 27                	ja     801be5 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801bbe:	83 ec 04             	sub    $0x4,%esp
  801bc1:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bc7:	56                   	push   %esi
  801bc8:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bce:	e8 8d f2 ff ff       	call   800e60 <sys_page_alloc>
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	0f 89 c7 00 00 00    	jns    801ca5 <spawn+0x3b3>
  801bde:	89 c3                	mov    %eax,%ebx
  801be0:	e9 09 02 00 00       	jmp    801dee <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801be5:	83 ec 04             	sub    $0x4,%esp
  801be8:	6a 07                	push   $0x7
  801bea:	68 00 00 40 00       	push   $0x400000
  801bef:	6a 00                	push   $0x0
  801bf1:	e8 6a f2 ff ff       	call   800e60 <sys_page_alloc>
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	0f 88 e3 01 00 00    	js     801de4 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c01:	83 ec 08             	sub    $0x8,%esp
  801c04:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c0a:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c10:	50                   	push   %eax
  801c11:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c17:	e8 1a f9 ff ff       	call   801536 <seek>
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	0f 88 c1 01 00 00    	js     801de8 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c27:	83 ec 04             	sub    $0x4,%esp
  801c2a:	89 f8                	mov    %edi,%eax
  801c2c:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c32:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c37:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c3c:	0f 47 c1             	cmova  %ecx,%eax
  801c3f:	50                   	push   %eax
  801c40:	68 00 00 40 00       	push   $0x400000
  801c45:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c4b:	e8 11 f8 ff ff       	call   801461 <readn>
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	85 c0                	test   %eax,%eax
  801c55:	0f 88 91 01 00 00    	js     801dec <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c5b:	83 ec 0c             	sub    $0xc,%esp
  801c5e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c64:	56                   	push   %esi
  801c65:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c6b:	68 00 00 40 00       	push   $0x400000
  801c70:	6a 00                	push   $0x0
  801c72:	e8 2c f2 ff ff       	call   800ea3 <sys_page_map>
  801c77:	83 c4 20             	add    $0x20,%esp
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	79 15                	jns    801c93 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801c7e:	50                   	push   %eax
  801c7f:	68 55 30 80 00       	push   $0x803055
  801c84:	68 25 01 00 00       	push   $0x125
  801c89:	68 49 30 80 00       	push   $0x803049
  801c8e:	e8 6c e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c93:	83 ec 08             	sub    $0x8,%esp
  801c96:	68 00 00 40 00       	push   $0x400000
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 43 f2 ff ff       	call   800ee5 <sys_page_unmap>
  801ca2:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ca5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cab:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cb1:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801cb7:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801cbd:	0f 87 f7 fe ff ff    	ja     801bba <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cc3:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801cca:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801cd1:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cd8:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801cde:	0f 8c 63 fe ff ff    	jl     801b47 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ced:	e8 a2 f5 ff ff       	call   801294 <close>
  801cf2:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801cf5:	bb 00 08 00 00       	mov    $0x800,%ebx
  801cfa:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  801d00:	89 d8                	mov    %ebx,%eax
  801d02:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801d05:	89 c2                	mov    %eax,%edx
  801d07:	c1 ea 16             	shr    $0x16,%edx
  801d0a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d11:	f6 c2 01             	test   $0x1,%dl
  801d14:	74 4b                	je     801d61 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801d16:	89 c2                	mov    %eax,%edx
  801d18:	c1 ea 0c             	shr    $0xc,%edx
  801d1b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801d22:	f6 c1 01             	test   $0x1,%cl
  801d25:	74 3a                	je     801d61 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801d27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d2e:	f6 c6 04             	test   $0x4,%dh
  801d31:	74 2e                	je     801d61 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801d33:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801d3a:	8b 0d 90 77 80 00    	mov    0x807790,%ecx
  801d40:	8b 49 48             	mov    0x48(%ecx),%ecx
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d4c:	52                   	push   %edx
  801d4d:	50                   	push   %eax
  801d4e:	56                   	push   %esi
  801d4f:	50                   	push   %eax
  801d50:	51                   	push   %ecx
  801d51:	e8 4d f1 ff ff       	call   800ea3 <sys_page_map>
					if (r < 0)
  801d56:	83 c4 20             	add    $0x20,%esp
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	0f 88 ae 00 00 00    	js     801e0f <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801d61:	83 c3 01             	add    $0x1,%ebx
  801d64:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801d6a:	75 94                	jne    801d00 <spawn+0x40e>
  801d6c:	e9 b3 00 00 00       	jmp    801e24 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d71:	50                   	push   %eax
  801d72:	68 72 30 80 00       	push   $0x803072
  801d77:	68 86 00 00 00       	push   $0x86
  801d7c:	68 49 30 80 00       	push   $0x803049
  801d81:	e8 79 e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d86:	83 ec 08             	sub    $0x8,%esp
  801d89:	6a 02                	push   $0x2
  801d8b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d91:	e8 91 f1 ff ff       	call   800f27 <sys_env_set_status>
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	79 2b                	jns    801dc8 <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801d9d:	50                   	push   %eax
  801d9e:	68 8c 30 80 00       	push   $0x80308c
  801da3:	68 89 00 00 00       	push   $0x89
  801da8:	68 49 30 80 00       	push   $0x803049
  801dad:	e8 4d e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801db2:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801db8:	e9 a8 00 00 00       	jmp    801e65 <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801dbd:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801dc3:	e9 9d 00 00 00       	jmp    801e65 <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801dc8:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801dce:	e9 92 00 00 00       	jmp    801e65 <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801dd3:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801dd8:	e9 88 00 00 00       	jmp    801e65 <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801ddd:	89 c3                	mov    %eax,%ebx
  801ddf:	e9 81 00 00 00       	jmp    801e65 <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	eb 06                	jmp    801dee <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801de8:	89 c3                	mov    %eax,%ebx
  801dea:	eb 02                	jmp    801dee <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801dec:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801dee:	83 ec 0c             	sub    $0xc,%esp
  801df1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801df7:	e8 e5 ef ff ff       	call   800de1 <sys_env_destroy>
	close(fd);
  801dfc:	83 c4 04             	add    $0x4,%esp
  801dff:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e05:	e8 8a f4 ff ff       	call   801294 <close>
	return r;
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	eb 56                	jmp    801e65 <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e0f:	50                   	push   %eax
  801e10:	68 a3 30 80 00       	push   $0x8030a3
  801e15:	68 82 00 00 00       	push   $0x82
  801e1a:	68 49 30 80 00       	push   $0x803049
  801e1f:	e8 db e5 ff ff       	call   8003ff <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e24:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e2b:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e2e:	83 ec 08             	sub    $0x8,%esp
  801e31:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e37:	50                   	push   %eax
  801e38:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e3e:	e8 26 f1 ff ff       	call   800f69 <sys_env_set_trapframe>
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	85 c0                	test   %eax,%eax
  801e48:	0f 89 38 ff ff ff    	jns    801d86 <spawn+0x494>
  801e4e:	e9 1e ff ff ff       	jmp    801d71 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e53:	83 ec 08             	sub    $0x8,%esp
  801e56:	68 00 00 40 00       	push   $0x400000
  801e5b:	6a 00                	push   $0x0
  801e5d:	e8 83 f0 ff ff       	call   800ee5 <sys_page_unmap>
  801e62:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e65:	89 d8                	mov    %ebx,%eax
  801e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e6a:	5b                   	pop    %ebx
  801e6b:	5e                   	pop    %esi
  801e6c:	5f                   	pop    %edi
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    

00801e6f <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e74:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e77:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e7c:	eb 03                	jmp    801e81 <spawnl+0x12>
		argc++;
  801e7e:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e81:	83 c2 04             	add    $0x4,%edx
  801e84:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e88:	75 f4                	jne    801e7e <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e8a:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e91:	83 e2 f0             	and    $0xfffffff0,%edx
  801e94:	29 d4                	sub    %edx,%esp
  801e96:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e9a:	c1 ea 02             	shr    $0x2,%edx
  801e9d:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ea4:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea9:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801eb0:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801eb7:	00 
  801eb8:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801eba:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebf:	eb 0a                	jmp    801ecb <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ec1:	83 c0 01             	add    $0x1,%eax
  801ec4:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ec8:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ecb:	39 d0                	cmp    %edx,%eax
  801ecd:	75 f2                	jne    801ec1 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801ecf:	83 ec 08             	sub    $0x8,%esp
  801ed2:	56                   	push   %esi
  801ed3:	ff 75 08             	pushl  0x8(%ebp)
  801ed6:	e8 17 fa ff ff       	call   8018f2 <spawn>
}
  801edb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    

00801ee2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ee8:	68 e4 30 80 00       	push   $0x8030e4
  801eed:	ff 75 0c             	pushl  0xc(%ebp)
  801ef0:	e8 68 eb ff ff       	call   800a5d <strcpy>
	return 0;
}
  801ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	53                   	push   %ebx
  801f00:	83 ec 10             	sub    $0x10,%esp
  801f03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f06:	53                   	push   %ebx
  801f07:	e8 dc 08 00 00       	call   8027e8 <pageref>
  801f0c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801f0f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801f14:	83 f8 01             	cmp    $0x1,%eax
  801f17:	75 10                	jne    801f29 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801f19:	83 ec 0c             	sub    $0xc,%esp
  801f1c:	ff 73 0c             	pushl  0xc(%ebx)
  801f1f:	e8 c0 02 00 00       	call   8021e4 <nsipc_close>
  801f24:	89 c2                	mov    %eax,%edx
  801f26:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801f29:	89 d0                	mov    %edx,%eax
  801f2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2e:	c9                   	leave  
  801f2f:	c3                   	ret    

00801f30 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f36:	6a 00                	push   $0x0
  801f38:	ff 75 10             	pushl  0x10(%ebp)
  801f3b:	ff 75 0c             	pushl  0xc(%ebp)
  801f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f41:	ff 70 0c             	pushl  0xc(%eax)
  801f44:	e8 78 03 00 00       	call   8022c1 <nsipc_send>
}
  801f49:	c9                   	leave  
  801f4a:	c3                   	ret    

00801f4b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f51:	6a 00                	push   $0x0
  801f53:	ff 75 10             	pushl  0x10(%ebp)
  801f56:	ff 75 0c             	pushl  0xc(%ebp)
  801f59:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5c:	ff 70 0c             	pushl  0xc(%eax)
  801f5f:	e8 f1 02 00 00       	call   802255 <nsipc_recv>
}
  801f64:	c9                   	leave  
  801f65:	c3                   	ret    

00801f66 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f6c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f6f:	52                   	push   %edx
  801f70:	50                   	push   %eax
  801f71:	e8 f4 f1 ff ff       	call   80116a <fd_lookup>
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	78 17                	js     801f94 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f80:	8b 0d ac 57 80 00    	mov    0x8057ac,%ecx
  801f86:	39 08                	cmp    %ecx,(%eax)
  801f88:	75 05                	jne    801f8f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f8a:	8b 40 0c             	mov    0xc(%eax),%eax
  801f8d:	eb 05                	jmp    801f94 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f8f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    

00801f96 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	83 ec 1c             	sub    $0x1c,%esp
  801f9e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa3:	50                   	push   %eax
  801fa4:	e8 72 f1 ff ff       	call   80111b <fd_alloc>
  801fa9:	89 c3                	mov    %eax,%ebx
  801fab:	83 c4 10             	add    $0x10,%esp
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	78 1b                	js     801fcd <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801fb2:	83 ec 04             	sub    $0x4,%esp
  801fb5:	68 07 04 00 00       	push   $0x407
  801fba:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbd:	6a 00                	push   $0x0
  801fbf:	e8 9c ee ff ff       	call   800e60 <sys_page_alloc>
  801fc4:	89 c3                	mov    %eax,%ebx
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	79 10                	jns    801fdd <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801fcd:	83 ec 0c             	sub    $0xc,%esp
  801fd0:	56                   	push   %esi
  801fd1:	e8 0e 02 00 00       	call   8021e4 <nsipc_close>
		return r;
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	89 d8                	mov    %ebx,%eax
  801fdb:	eb 24                	jmp    802001 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801fdd:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  801fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801feb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ff2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ff5:	83 ec 0c             	sub    $0xc,%esp
  801ff8:	50                   	push   %eax
  801ff9:	e8 f6 f0 ff ff       	call   8010f4 <fd2num>
  801ffe:	83 c4 10             	add    $0x10,%esp
}
  802001:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    

00802008 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80200e:	8b 45 08             	mov    0x8(%ebp),%eax
  802011:	e8 50 ff ff ff       	call   801f66 <fd2sockid>
		return r;
  802016:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802018:	85 c0                	test   %eax,%eax
  80201a:	78 1f                	js     80203b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80201c:	83 ec 04             	sub    $0x4,%esp
  80201f:	ff 75 10             	pushl  0x10(%ebp)
  802022:	ff 75 0c             	pushl  0xc(%ebp)
  802025:	50                   	push   %eax
  802026:	e8 12 01 00 00       	call   80213d <nsipc_accept>
  80202b:	83 c4 10             	add    $0x10,%esp
		return r;
  80202e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802030:	85 c0                	test   %eax,%eax
  802032:	78 07                	js     80203b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802034:	e8 5d ff ff ff       	call   801f96 <alloc_sockfd>
  802039:	89 c1                	mov    %eax,%ecx
}
  80203b:	89 c8                	mov    %ecx,%eax
  80203d:	c9                   	leave  
  80203e:	c3                   	ret    

0080203f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802045:	8b 45 08             	mov    0x8(%ebp),%eax
  802048:	e8 19 ff ff ff       	call   801f66 <fd2sockid>
  80204d:	85 c0                	test   %eax,%eax
  80204f:	78 12                	js     802063 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802051:	83 ec 04             	sub    $0x4,%esp
  802054:	ff 75 10             	pushl  0x10(%ebp)
  802057:	ff 75 0c             	pushl  0xc(%ebp)
  80205a:	50                   	push   %eax
  80205b:	e8 2d 01 00 00       	call   80218d <nsipc_bind>
  802060:	83 c4 10             	add    $0x10,%esp
}
  802063:	c9                   	leave  
  802064:	c3                   	ret    

00802065 <shutdown>:

int
shutdown(int s, int how)
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80206b:	8b 45 08             	mov    0x8(%ebp),%eax
  80206e:	e8 f3 fe ff ff       	call   801f66 <fd2sockid>
  802073:	85 c0                	test   %eax,%eax
  802075:	78 0f                	js     802086 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802077:	83 ec 08             	sub    $0x8,%esp
  80207a:	ff 75 0c             	pushl  0xc(%ebp)
  80207d:	50                   	push   %eax
  80207e:	e8 3f 01 00 00       	call   8021c2 <nsipc_shutdown>
  802083:	83 c4 10             	add    $0x10,%esp
}
  802086:	c9                   	leave  
  802087:	c3                   	ret    

00802088 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80208e:	8b 45 08             	mov    0x8(%ebp),%eax
  802091:	e8 d0 fe ff ff       	call   801f66 <fd2sockid>
  802096:	85 c0                	test   %eax,%eax
  802098:	78 12                	js     8020ac <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80209a:	83 ec 04             	sub    $0x4,%esp
  80209d:	ff 75 10             	pushl  0x10(%ebp)
  8020a0:	ff 75 0c             	pushl  0xc(%ebp)
  8020a3:	50                   	push   %eax
  8020a4:	e8 55 01 00 00       	call   8021fe <nsipc_connect>
  8020a9:	83 c4 10             	add    $0x10,%esp
}
  8020ac:	c9                   	leave  
  8020ad:	c3                   	ret    

008020ae <listen>:

int
listen(int s, int backlog)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b7:	e8 aa fe ff ff       	call   801f66 <fd2sockid>
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	78 0f                	js     8020cf <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8020c0:	83 ec 08             	sub    $0x8,%esp
  8020c3:	ff 75 0c             	pushl  0xc(%ebp)
  8020c6:	50                   	push   %eax
  8020c7:	e8 67 01 00 00       	call   802233 <nsipc_listen>
  8020cc:	83 c4 10             	add    $0x10,%esp
}
  8020cf:	c9                   	leave  
  8020d0:	c3                   	ret    

008020d1 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020d1:	55                   	push   %ebp
  8020d2:	89 e5                	mov    %esp,%ebp
  8020d4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020d7:	ff 75 10             	pushl  0x10(%ebp)
  8020da:	ff 75 0c             	pushl  0xc(%ebp)
  8020dd:	ff 75 08             	pushl  0x8(%ebp)
  8020e0:	e8 3a 02 00 00       	call   80231f <nsipc_socket>
  8020e5:	83 c4 10             	add    $0x10,%esp
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	78 05                	js     8020f1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8020ec:	e8 a5 fe ff ff       	call   801f96 <alloc_sockfd>
}
  8020f1:	c9                   	leave  
  8020f2:	c3                   	ret    

008020f3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	53                   	push   %ebx
  8020f7:	83 ec 04             	sub    $0x4,%esp
  8020fa:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020fc:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  802103:	75 12                	jne    802117 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802105:	83 ec 0c             	sub    $0xc,%esp
  802108:	6a 02                	push   $0x2
  80210a:	e8 a0 06 00 00       	call   8027af <ipc_find_env>
  80210f:	a3 04 60 80 00       	mov    %eax,0x806004
  802114:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802117:	6a 07                	push   $0x7
  802119:	68 00 90 80 00       	push   $0x809000
  80211e:	53                   	push   %ebx
  80211f:	ff 35 04 60 80 00    	pushl  0x806004
  802125:	e8 31 06 00 00       	call   80275b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80212a:	83 c4 0c             	add    $0xc,%esp
  80212d:	6a 00                	push   $0x0
  80212f:	6a 00                	push   $0x0
  802131:	6a 00                	push   $0x0
  802133:	e8 bc 05 00 00       	call   8026f4 <ipc_recv>
}
  802138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80213b:	c9                   	leave  
  80213c:	c3                   	ret    

0080213d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80213d:	55                   	push   %ebp
  80213e:	89 e5                	mov    %esp,%ebp
  802140:	56                   	push   %esi
  802141:	53                   	push   %ebx
  802142:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802145:	8b 45 08             	mov    0x8(%ebp),%eax
  802148:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80214d:	8b 06                	mov    (%esi),%eax
  80214f:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802154:	b8 01 00 00 00       	mov    $0x1,%eax
  802159:	e8 95 ff ff ff       	call   8020f3 <nsipc>
  80215e:	89 c3                	mov    %eax,%ebx
  802160:	85 c0                	test   %eax,%eax
  802162:	78 20                	js     802184 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802164:	83 ec 04             	sub    $0x4,%esp
  802167:	ff 35 10 90 80 00    	pushl  0x809010
  80216d:	68 00 90 80 00       	push   $0x809000
  802172:	ff 75 0c             	pushl  0xc(%ebp)
  802175:	e8 75 ea ff ff       	call   800bef <memmove>
		*addrlen = ret->ret_addrlen;
  80217a:	a1 10 90 80 00       	mov    0x809010,%eax
  80217f:	89 06                	mov    %eax,(%esi)
  802181:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802184:	89 d8                	mov    %ebx,%eax
  802186:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802189:	5b                   	pop    %ebx
  80218a:	5e                   	pop    %esi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    

0080218d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80218d:	55                   	push   %ebp
  80218e:	89 e5                	mov    %esp,%ebp
  802190:	53                   	push   %ebx
  802191:	83 ec 08             	sub    $0x8,%esp
  802194:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802197:	8b 45 08             	mov    0x8(%ebp),%eax
  80219a:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80219f:	53                   	push   %ebx
  8021a0:	ff 75 0c             	pushl  0xc(%ebp)
  8021a3:	68 04 90 80 00       	push   $0x809004
  8021a8:	e8 42 ea ff ff       	call   800bef <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8021ad:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  8021b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8021b8:	e8 36 ff ff ff       	call   8020f3 <nsipc>
}
  8021bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c0:	c9                   	leave  
  8021c1:	c3                   	ret    

008021c2 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cb:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  8021d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d3:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  8021d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8021dd:	e8 11 ff ff ff       	call   8020f3 <nsipc>
}
  8021e2:	c9                   	leave  
  8021e3:	c3                   	ret    

008021e4 <nsipc_close>:

int
nsipc_close(int s)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ed:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  8021f2:	b8 04 00 00 00       	mov    $0x4,%eax
  8021f7:	e8 f7 fe ff ff       	call   8020f3 <nsipc>
}
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    

008021fe <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	53                   	push   %ebx
  802202:	83 ec 08             	sub    $0x8,%esp
  802205:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802208:	8b 45 08             	mov    0x8(%ebp),%eax
  80220b:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802210:	53                   	push   %ebx
  802211:	ff 75 0c             	pushl  0xc(%ebp)
  802214:	68 04 90 80 00       	push   $0x809004
  802219:	e8 d1 e9 ff ff       	call   800bef <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80221e:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  802224:	b8 05 00 00 00       	mov    $0x5,%eax
  802229:	e8 c5 fe ff ff       	call   8020f3 <nsipc>
}
  80222e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802231:	c9                   	leave  
  802232:	c3                   	ret    

00802233 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
  802236:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802239:	8b 45 08             	mov    0x8(%ebp),%eax
  80223c:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  802241:	8b 45 0c             	mov    0xc(%ebp),%eax
  802244:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  802249:	b8 06 00 00 00       	mov    $0x6,%eax
  80224e:	e8 a0 fe ff ff       	call   8020f3 <nsipc>
}
  802253:	c9                   	leave  
  802254:	c3                   	ret    

00802255 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	56                   	push   %esi
  802259:	53                   	push   %ebx
  80225a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80225d:	8b 45 08             	mov    0x8(%ebp),%eax
  802260:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  802265:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  80226b:	8b 45 14             	mov    0x14(%ebp),%eax
  80226e:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802273:	b8 07 00 00 00       	mov    $0x7,%eax
  802278:	e8 76 fe ff ff       	call   8020f3 <nsipc>
  80227d:	89 c3                	mov    %eax,%ebx
  80227f:	85 c0                	test   %eax,%eax
  802281:	78 35                	js     8022b8 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802283:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802288:	7f 04                	jg     80228e <nsipc_recv+0x39>
  80228a:	39 c6                	cmp    %eax,%esi
  80228c:	7d 16                	jge    8022a4 <nsipc_recv+0x4f>
  80228e:	68 f0 30 80 00       	push   $0x8030f0
  802293:	68 03 30 80 00       	push   $0x803003
  802298:	6a 62                	push   $0x62
  80229a:	68 05 31 80 00       	push   $0x803105
  80229f:	e8 5b e1 ff ff       	call   8003ff <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8022a4:	83 ec 04             	sub    $0x4,%esp
  8022a7:	50                   	push   %eax
  8022a8:	68 00 90 80 00       	push   $0x809000
  8022ad:	ff 75 0c             	pushl  0xc(%ebp)
  8022b0:	e8 3a e9 ff ff       	call   800bef <memmove>
  8022b5:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5d                   	pop    %ebp
  8022c0:	c3                   	ret    

008022c1 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022c1:	55                   	push   %ebp
  8022c2:	89 e5                	mov    %esp,%ebp
  8022c4:	53                   	push   %ebx
  8022c5:	83 ec 04             	sub    $0x4,%esp
  8022c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ce:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  8022d3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022d9:	7e 16                	jle    8022f1 <nsipc_send+0x30>
  8022db:	68 11 31 80 00       	push   $0x803111
  8022e0:	68 03 30 80 00       	push   $0x803003
  8022e5:	6a 6d                	push   $0x6d
  8022e7:	68 05 31 80 00       	push   $0x803105
  8022ec:	e8 0e e1 ff ff       	call   8003ff <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022f1:	83 ec 04             	sub    $0x4,%esp
  8022f4:	53                   	push   %ebx
  8022f5:	ff 75 0c             	pushl  0xc(%ebp)
  8022f8:	68 0c 90 80 00       	push   $0x80900c
  8022fd:	e8 ed e8 ff ff       	call   800bef <memmove>
	nsipcbuf.send.req_size = size;
  802302:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  802308:	8b 45 14             	mov    0x14(%ebp),%eax
  80230b:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  802310:	b8 08 00 00 00       	mov    $0x8,%eax
  802315:	e8 d9 fd ff ff       	call   8020f3 <nsipc>
}
  80231a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80231d:	c9                   	leave  
  80231e:	c3                   	ret    

0080231f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80231f:	55                   	push   %ebp
  802320:	89 e5                	mov    %esp,%ebp
  802322:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802325:	8b 45 08             	mov    0x8(%ebp),%eax
  802328:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  80232d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802330:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  802335:	8b 45 10             	mov    0x10(%ebp),%eax
  802338:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  80233d:	b8 09 00 00 00       	mov    $0x9,%eax
  802342:	e8 ac fd ff ff       	call   8020f3 <nsipc>
}
  802347:	c9                   	leave  
  802348:	c3                   	ret    

00802349 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802349:	55                   	push   %ebp
  80234a:	89 e5                	mov    %esp,%ebp
  80234c:	56                   	push   %esi
  80234d:	53                   	push   %ebx
  80234e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802351:	83 ec 0c             	sub    $0xc,%esp
  802354:	ff 75 08             	pushl  0x8(%ebp)
  802357:	e8 a8 ed ff ff       	call   801104 <fd2data>
  80235c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80235e:	83 c4 08             	add    $0x8,%esp
  802361:	68 1d 31 80 00       	push   $0x80311d
  802366:	53                   	push   %ebx
  802367:	e8 f1 e6 ff ff       	call   800a5d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80236c:	8b 46 04             	mov    0x4(%esi),%eax
  80236f:	2b 06                	sub    (%esi),%eax
  802371:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802377:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80237e:	00 00 00 
	stat->st_dev = &devpipe;
  802381:	c7 83 88 00 00 00 c8 	movl   $0x8057c8,0x88(%ebx)
  802388:	57 80 00 
	return 0;
}
  80238b:	b8 00 00 00 00       	mov    $0x0,%eax
  802390:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802393:	5b                   	pop    %ebx
  802394:	5e                   	pop    %esi
  802395:	5d                   	pop    %ebp
  802396:	c3                   	ret    

00802397 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802397:	55                   	push   %ebp
  802398:	89 e5                	mov    %esp,%ebp
  80239a:	53                   	push   %ebx
  80239b:	83 ec 0c             	sub    $0xc,%esp
  80239e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8023a1:	53                   	push   %ebx
  8023a2:	6a 00                	push   $0x0
  8023a4:	e8 3c eb ff ff       	call   800ee5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8023a9:	89 1c 24             	mov    %ebx,(%esp)
  8023ac:	e8 53 ed ff ff       	call   801104 <fd2data>
  8023b1:	83 c4 08             	add    $0x8,%esp
  8023b4:	50                   	push   %eax
  8023b5:	6a 00                	push   $0x0
  8023b7:	e8 29 eb ff ff       	call   800ee5 <sys_page_unmap>
}
  8023bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023bf:	c9                   	leave  
  8023c0:	c3                   	ret    

008023c1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8023c1:	55                   	push   %ebp
  8023c2:	89 e5                	mov    %esp,%ebp
  8023c4:	57                   	push   %edi
  8023c5:	56                   	push   %esi
  8023c6:	53                   	push   %ebx
  8023c7:	83 ec 1c             	sub    $0x1c,%esp
  8023ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8023cd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8023cf:	a1 90 77 80 00       	mov    0x807790,%eax
  8023d4:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8023d7:	83 ec 0c             	sub    $0xc,%esp
  8023da:	ff 75 e0             	pushl  -0x20(%ebp)
  8023dd:	e8 06 04 00 00       	call   8027e8 <pageref>
  8023e2:	89 c3                	mov    %eax,%ebx
  8023e4:	89 3c 24             	mov    %edi,(%esp)
  8023e7:	e8 fc 03 00 00       	call   8027e8 <pageref>
  8023ec:	83 c4 10             	add    $0x10,%esp
  8023ef:	39 c3                	cmp    %eax,%ebx
  8023f1:	0f 94 c1             	sete   %cl
  8023f4:	0f b6 c9             	movzbl %cl,%ecx
  8023f7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8023fa:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802400:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802403:	39 ce                	cmp    %ecx,%esi
  802405:	74 1b                	je     802422 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802407:	39 c3                	cmp    %eax,%ebx
  802409:	75 c4                	jne    8023cf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80240b:	8b 42 58             	mov    0x58(%edx),%eax
  80240e:	ff 75 e4             	pushl  -0x1c(%ebp)
  802411:	50                   	push   %eax
  802412:	56                   	push   %esi
  802413:	68 24 31 80 00       	push   $0x803124
  802418:	e8 bb e0 ff ff       	call   8004d8 <cprintf>
  80241d:	83 c4 10             	add    $0x10,%esp
  802420:	eb ad                	jmp    8023cf <_pipeisclosed+0xe>
	}
}
  802422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802425:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802428:	5b                   	pop    %ebx
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    

0080242d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80242d:	55                   	push   %ebp
  80242e:	89 e5                	mov    %esp,%ebp
  802430:	57                   	push   %edi
  802431:	56                   	push   %esi
  802432:	53                   	push   %ebx
  802433:	83 ec 28             	sub    $0x28,%esp
  802436:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802439:	56                   	push   %esi
  80243a:	e8 c5 ec ff ff       	call   801104 <fd2data>
  80243f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802441:	83 c4 10             	add    $0x10,%esp
  802444:	bf 00 00 00 00       	mov    $0x0,%edi
  802449:	eb 4b                	jmp    802496 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80244b:	89 da                	mov    %ebx,%edx
  80244d:	89 f0                	mov    %esi,%eax
  80244f:	e8 6d ff ff ff       	call   8023c1 <_pipeisclosed>
  802454:	85 c0                	test   %eax,%eax
  802456:	75 48                	jne    8024a0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802458:	e8 e4 e9 ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80245d:	8b 43 04             	mov    0x4(%ebx),%eax
  802460:	8b 0b                	mov    (%ebx),%ecx
  802462:	8d 51 20             	lea    0x20(%ecx),%edx
  802465:	39 d0                	cmp    %edx,%eax
  802467:	73 e2                	jae    80244b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802469:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80246c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802470:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802473:	89 c2                	mov    %eax,%edx
  802475:	c1 fa 1f             	sar    $0x1f,%edx
  802478:	89 d1                	mov    %edx,%ecx
  80247a:	c1 e9 1b             	shr    $0x1b,%ecx
  80247d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802480:	83 e2 1f             	and    $0x1f,%edx
  802483:	29 ca                	sub    %ecx,%edx
  802485:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802489:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80248d:	83 c0 01             	add    $0x1,%eax
  802490:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802493:	83 c7 01             	add    $0x1,%edi
  802496:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802499:	75 c2                	jne    80245d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80249b:	8b 45 10             	mov    0x10(%ebp),%eax
  80249e:	eb 05                	jmp    8024a5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024a0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8024a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a8:	5b                   	pop    %ebx
  8024a9:	5e                   	pop    %esi
  8024aa:	5f                   	pop    %edi
  8024ab:	5d                   	pop    %ebp
  8024ac:	c3                   	ret    

008024ad <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
  8024b0:	57                   	push   %edi
  8024b1:	56                   	push   %esi
  8024b2:	53                   	push   %ebx
  8024b3:	83 ec 18             	sub    $0x18,%esp
  8024b6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8024b9:	57                   	push   %edi
  8024ba:	e8 45 ec ff ff       	call   801104 <fd2data>
  8024bf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024c1:	83 c4 10             	add    $0x10,%esp
  8024c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024c9:	eb 3d                	jmp    802508 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8024cb:	85 db                	test   %ebx,%ebx
  8024cd:	74 04                	je     8024d3 <devpipe_read+0x26>
				return i;
  8024cf:	89 d8                	mov    %ebx,%eax
  8024d1:	eb 44                	jmp    802517 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8024d3:	89 f2                	mov    %esi,%edx
  8024d5:	89 f8                	mov    %edi,%eax
  8024d7:	e8 e5 fe ff ff       	call   8023c1 <_pipeisclosed>
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	75 32                	jne    802512 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8024e0:	e8 5c e9 ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8024e5:	8b 06                	mov    (%esi),%eax
  8024e7:	3b 46 04             	cmp    0x4(%esi),%eax
  8024ea:	74 df                	je     8024cb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8024ec:	99                   	cltd   
  8024ed:	c1 ea 1b             	shr    $0x1b,%edx
  8024f0:	01 d0                	add    %edx,%eax
  8024f2:	83 e0 1f             	and    $0x1f,%eax
  8024f5:	29 d0                	sub    %edx,%eax
  8024f7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8024fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024ff:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802502:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802505:	83 c3 01             	add    $0x1,%ebx
  802508:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80250b:	75 d8                	jne    8024e5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80250d:	8b 45 10             	mov    0x10(%ebp),%eax
  802510:	eb 05                	jmp    802517 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802512:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802517:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80251a:	5b                   	pop    %ebx
  80251b:	5e                   	pop    %esi
  80251c:	5f                   	pop    %edi
  80251d:	5d                   	pop    %ebp
  80251e:	c3                   	ret    

0080251f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80251f:	55                   	push   %ebp
  802520:	89 e5                	mov    %esp,%ebp
  802522:	56                   	push   %esi
  802523:	53                   	push   %ebx
  802524:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80252a:	50                   	push   %eax
  80252b:	e8 eb eb ff ff       	call   80111b <fd_alloc>
  802530:	83 c4 10             	add    $0x10,%esp
  802533:	89 c2                	mov    %eax,%edx
  802535:	85 c0                	test   %eax,%eax
  802537:	0f 88 2c 01 00 00    	js     802669 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80253d:	83 ec 04             	sub    $0x4,%esp
  802540:	68 07 04 00 00       	push   $0x407
  802545:	ff 75 f4             	pushl  -0xc(%ebp)
  802548:	6a 00                	push   $0x0
  80254a:	e8 11 e9 ff ff       	call   800e60 <sys_page_alloc>
  80254f:	83 c4 10             	add    $0x10,%esp
  802552:	89 c2                	mov    %eax,%edx
  802554:	85 c0                	test   %eax,%eax
  802556:	0f 88 0d 01 00 00    	js     802669 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80255c:	83 ec 0c             	sub    $0xc,%esp
  80255f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802562:	50                   	push   %eax
  802563:	e8 b3 eb ff ff       	call   80111b <fd_alloc>
  802568:	89 c3                	mov    %eax,%ebx
  80256a:	83 c4 10             	add    $0x10,%esp
  80256d:	85 c0                	test   %eax,%eax
  80256f:	0f 88 e2 00 00 00    	js     802657 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802575:	83 ec 04             	sub    $0x4,%esp
  802578:	68 07 04 00 00       	push   $0x407
  80257d:	ff 75 f0             	pushl  -0x10(%ebp)
  802580:	6a 00                	push   $0x0
  802582:	e8 d9 e8 ff ff       	call   800e60 <sys_page_alloc>
  802587:	89 c3                	mov    %eax,%ebx
  802589:	83 c4 10             	add    $0x10,%esp
  80258c:	85 c0                	test   %eax,%eax
  80258e:	0f 88 c3 00 00 00    	js     802657 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802594:	83 ec 0c             	sub    $0xc,%esp
  802597:	ff 75 f4             	pushl  -0xc(%ebp)
  80259a:	e8 65 eb ff ff       	call   801104 <fd2data>
  80259f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025a1:	83 c4 0c             	add    $0xc,%esp
  8025a4:	68 07 04 00 00       	push   $0x407
  8025a9:	50                   	push   %eax
  8025aa:	6a 00                	push   $0x0
  8025ac:	e8 af e8 ff ff       	call   800e60 <sys_page_alloc>
  8025b1:	89 c3                	mov    %eax,%ebx
  8025b3:	83 c4 10             	add    $0x10,%esp
  8025b6:	85 c0                	test   %eax,%eax
  8025b8:	0f 88 89 00 00 00    	js     802647 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025be:	83 ec 0c             	sub    $0xc,%esp
  8025c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8025c4:	e8 3b eb ff ff       	call   801104 <fd2data>
  8025c9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8025d0:	50                   	push   %eax
  8025d1:	6a 00                	push   $0x0
  8025d3:	56                   	push   %esi
  8025d4:	6a 00                	push   $0x0
  8025d6:	e8 c8 e8 ff ff       	call   800ea3 <sys_page_map>
  8025db:	89 c3                	mov    %eax,%ebx
  8025dd:	83 c4 20             	add    $0x20,%esp
  8025e0:	85 c0                	test   %eax,%eax
  8025e2:	78 55                	js     802639 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025e4:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  8025ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ed:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8025ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8025f9:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  8025ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802602:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802604:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802607:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80260e:	83 ec 0c             	sub    $0xc,%esp
  802611:	ff 75 f4             	pushl  -0xc(%ebp)
  802614:	e8 db ea ff ff       	call   8010f4 <fd2num>
  802619:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80261c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80261e:	83 c4 04             	add    $0x4,%esp
  802621:	ff 75 f0             	pushl  -0x10(%ebp)
  802624:	e8 cb ea ff ff       	call   8010f4 <fd2num>
  802629:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80262c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80262f:	83 c4 10             	add    $0x10,%esp
  802632:	ba 00 00 00 00       	mov    $0x0,%edx
  802637:	eb 30                	jmp    802669 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802639:	83 ec 08             	sub    $0x8,%esp
  80263c:	56                   	push   %esi
  80263d:	6a 00                	push   $0x0
  80263f:	e8 a1 e8 ff ff       	call   800ee5 <sys_page_unmap>
  802644:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802647:	83 ec 08             	sub    $0x8,%esp
  80264a:	ff 75 f0             	pushl  -0x10(%ebp)
  80264d:	6a 00                	push   $0x0
  80264f:	e8 91 e8 ff ff       	call   800ee5 <sys_page_unmap>
  802654:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802657:	83 ec 08             	sub    $0x8,%esp
  80265a:	ff 75 f4             	pushl  -0xc(%ebp)
  80265d:	6a 00                	push   $0x0
  80265f:	e8 81 e8 ff ff       	call   800ee5 <sys_page_unmap>
  802664:	83 c4 10             	add    $0x10,%esp
  802667:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802669:	89 d0                	mov    %edx,%eax
  80266b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80266e:	5b                   	pop    %ebx
  80266f:	5e                   	pop    %esi
  802670:	5d                   	pop    %ebp
  802671:	c3                   	ret    

00802672 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802672:	55                   	push   %ebp
  802673:	89 e5                	mov    %esp,%ebp
  802675:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802678:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80267b:	50                   	push   %eax
  80267c:	ff 75 08             	pushl  0x8(%ebp)
  80267f:	e8 e6 ea ff ff       	call   80116a <fd_lookup>
  802684:	83 c4 10             	add    $0x10,%esp
  802687:	85 c0                	test   %eax,%eax
  802689:	78 18                	js     8026a3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80268b:	83 ec 0c             	sub    $0xc,%esp
  80268e:	ff 75 f4             	pushl  -0xc(%ebp)
  802691:	e8 6e ea ff ff       	call   801104 <fd2data>
	return _pipeisclosed(fd, p);
  802696:	89 c2                	mov    %eax,%edx
  802698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269b:	e8 21 fd ff ff       	call   8023c1 <_pipeisclosed>
  8026a0:	83 c4 10             	add    $0x10,%esp
}
  8026a3:	c9                   	leave  
  8026a4:	c3                   	ret    

008026a5 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8026a5:	55                   	push   %ebp
  8026a6:	89 e5                	mov    %esp,%ebp
  8026a8:	56                   	push   %esi
  8026a9:	53                   	push   %ebx
  8026aa:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8026ad:	85 f6                	test   %esi,%esi
  8026af:	75 16                	jne    8026c7 <wait+0x22>
  8026b1:	68 3c 31 80 00       	push   $0x80313c
  8026b6:	68 03 30 80 00       	push   $0x803003
  8026bb:	6a 09                	push   $0x9
  8026bd:	68 47 31 80 00       	push   $0x803147
  8026c2:	e8 38 dd ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  8026c7:	89 f3                	mov    %esi,%ebx
  8026c9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026cf:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8026d2:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8026d8:	eb 05                	jmp    8026df <wait+0x3a>
		sys_yield();
  8026da:	e8 62 e7 ff ff       	call   800e41 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026df:	8b 43 48             	mov    0x48(%ebx),%eax
  8026e2:	39 c6                	cmp    %eax,%esi
  8026e4:	75 07                	jne    8026ed <wait+0x48>
  8026e6:	8b 43 54             	mov    0x54(%ebx),%eax
  8026e9:	85 c0                	test   %eax,%eax
  8026eb:	75 ed                	jne    8026da <wait+0x35>
		sys_yield();
}
  8026ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026f0:	5b                   	pop    %ebx
  8026f1:	5e                   	pop    %esi
  8026f2:	5d                   	pop    %ebp
  8026f3:	c3                   	ret    

008026f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026f4:	55                   	push   %ebp
  8026f5:	89 e5                	mov    %esp,%ebp
  8026f7:	56                   	push   %esi
  8026f8:	53                   	push   %ebx
  8026f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8026fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802702:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802704:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802709:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80270c:	83 ec 0c             	sub    $0xc,%esp
  80270f:	50                   	push   %eax
  802710:	e8 fb e8 ff ff       	call   801010 <sys_ipc_recv>

	if (from_env_store != NULL)
  802715:	83 c4 10             	add    $0x10,%esp
  802718:	85 f6                	test   %esi,%esi
  80271a:	74 14                	je     802730 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80271c:	ba 00 00 00 00       	mov    $0x0,%edx
  802721:	85 c0                	test   %eax,%eax
  802723:	78 09                	js     80272e <ipc_recv+0x3a>
  802725:	8b 15 90 77 80 00    	mov    0x807790,%edx
  80272b:	8b 52 74             	mov    0x74(%edx),%edx
  80272e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802730:	85 db                	test   %ebx,%ebx
  802732:	74 14                	je     802748 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802734:	ba 00 00 00 00       	mov    $0x0,%edx
  802739:	85 c0                	test   %eax,%eax
  80273b:	78 09                	js     802746 <ipc_recv+0x52>
  80273d:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802743:	8b 52 78             	mov    0x78(%edx),%edx
  802746:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802748:	85 c0                	test   %eax,%eax
  80274a:	78 08                	js     802754 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80274c:	a1 90 77 80 00       	mov    0x807790,%eax
  802751:	8b 40 70             	mov    0x70(%eax),%eax
}
  802754:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802757:	5b                   	pop    %ebx
  802758:	5e                   	pop    %esi
  802759:	5d                   	pop    %ebp
  80275a:	c3                   	ret    

0080275b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80275b:	55                   	push   %ebp
  80275c:	89 e5                	mov    %esp,%ebp
  80275e:	57                   	push   %edi
  80275f:	56                   	push   %esi
  802760:	53                   	push   %ebx
  802761:	83 ec 0c             	sub    $0xc,%esp
  802764:	8b 7d 08             	mov    0x8(%ebp),%edi
  802767:	8b 75 0c             	mov    0xc(%ebp),%esi
  80276a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80276d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80276f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802774:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802777:	ff 75 14             	pushl  0x14(%ebp)
  80277a:	53                   	push   %ebx
  80277b:	56                   	push   %esi
  80277c:	57                   	push   %edi
  80277d:	e8 6b e8 ff ff       	call   800fed <sys_ipc_try_send>

		if (err < 0) {
  802782:	83 c4 10             	add    $0x10,%esp
  802785:	85 c0                	test   %eax,%eax
  802787:	79 1e                	jns    8027a7 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802789:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80278c:	75 07                	jne    802795 <ipc_send+0x3a>
				sys_yield();
  80278e:	e8 ae e6 ff ff       	call   800e41 <sys_yield>
  802793:	eb e2                	jmp    802777 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802795:	50                   	push   %eax
  802796:	68 52 31 80 00       	push   $0x803152
  80279b:	6a 49                	push   $0x49
  80279d:	68 5f 31 80 00       	push   $0x80315f
  8027a2:	e8 58 dc ff ff       	call   8003ff <_panic>
		}

	} while (err < 0);

}
  8027a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027aa:	5b                   	pop    %ebx
  8027ab:	5e                   	pop    %esi
  8027ac:	5f                   	pop    %edi
  8027ad:	5d                   	pop    %ebp
  8027ae:	c3                   	ret    

008027af <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027af:	55                   	push   %ebp
  8027b0:	89 e5                	mov    %esp,%ebp
  8027b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027b5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027ba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027bd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027c3:	8b 52 50             	mov    0x50(%edx),%edx
  8027c6:	39 ca                	cmp    %ecx,%edx
  8027c8:	75 0d                	jne    8027d7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8027ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027d2:	8b 40 48             	mov    0x48(%eax),%eax
  8027d5:	eb 0f                	jmp    8027e6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027d7:	83 c0 01             	add    $0x1,%eax
  8027da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027df:	75 d9                	jne    8027ba <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027e6:	5d                   	pop    %ebp
  8027e7:	c3                   	ret    

008027e8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027e8:	55                   	push   %ebp
  8027e9:	89 e5                	mov    %esp,%ebp
  8027eb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027ee:	89 d0                	mov    %edx,%eax
  8027f0:	c1 e8 16             	shr    $0x16,%eax
  8027f3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8027fa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027ff:	f6 c1 01             	test   $0x1,%cl
  802802:	74 1d                	je     802821 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802804:	c1 ea 0c             	shr    $0xc,%edx
  802807:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80280e:	f6 c2 01             	test   $0x1,%dl
  802811:	74 0e                	je     802821 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802813:	c1 ea 0c             	shr    $0xc,%edx
  802816:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80281d:	ef 
  80281e:	0f b7 c0             	movzwl %ax,%eax
}
  802821:	5d                   	pop    %ebp
  802822:	c3                   	ret    
  802823:	66 90                	xchg   %ax,%ax
  802825:	66 90                	xchg   %ax,%ax
  802827:	66 90                	xchg   %ax,%ax
  802829:	66 90                	xchg   %ax,%ax
  80282b:	66 90                	xchg   %ax,%ax
  80282d:	66 90                	xchg   %ax,%ax
  80282f:	90                   	nop

00802830 <__udivdi3>:
  802830:	55                   	push   %ebp
  802831:	57                   	push   %edi
  802832:	56                   	push   %esi
  802833:	53                   	push   %ebx
  802834:	83 ec 1c             	sub    $0x1c,%esp
  802837:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80283b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80283f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802843:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802847:	85 f6                	test   %esi,%esi
  802849:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80284d:	89 ca                	mov    %ecx,%edx
  80284f:	89 f8                	mov    %edi,%eax
  802851:	75 3d                	jne    802890 <__udivdi3+0x60>
  802853:	39 cf                	cmp    %ecx,%edi
  802855:	0f 87 c5 00 00 00    	ja     802920 <__udivdi3+0xf0>
  80285b:	85 ff                	test   %edi,%edi
  80285d:	89 fd                	mov    %edi,%ebp
  80285f:	75 0b                	jne    80286c <__udivdi3+0x3c>
  802861:	b8 01 00 00 00       	mov    $0x1,%eax
  802866:	31 d2                	xor    %edx,%edx
  802868:	f7 f7                	div    %edi
  80286a:	89 c5                	mov    %eax,%ebp
  80286c:	89 c8                	mov    %ecx,%eax
  80286e:	31 d2                	xor    %edx,%edx
  802870:	f7 f5                	div    %ebp
  802872:	89 c1                	mov    %eax,%ecx
  802874:	89 d8                	mov    %ebx,%eax
  802876:	89 cf                	mov    %ecx,%edi
  802878:	f7 f5                	div    %ebp
  80287a:	89 c3                	mov    %eax,%ebx
  80287c:	89 d8                	mov    %ebx,%eax
  80287e:	89 fa                	mov    %edi,%edx
  802880:	83 c4 1c             	add    $0x1c,%esp
  802883:	5b                   	pop    %ebx
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
  802888:	90                   	nop
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	39 ce                	cmp    %ecx,%esi
  802892:	77 74                	ja     802908 <__udivdi3+0xd8>
  802894:	0f bd fe             	bsr    %esi,%edi
  802897:	83 f7 1f             	xor    $0x1f,%edi
  80289a:	0f 84 98 00 00 00    	je     802938 <__udivdi3+0x108>
  8028a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8028a5:	89 f9                	mov    %edi,%ecx
  8028a7:	89 c5                	mov    %eax,%ebp
  8028a9:	29 fb                	sub    %edi,%ebx
  8028ab:	d3 e6                	shl    %cl,%esi
  8028ad:	89 d9                	mov    %ebx,%ecx
  8028af:	d3 ed                	shr    %cl,%ebp
  8028b1:	89 f9                	mov    %edi,%ecx
  8028b3:	d3 e0                	shl    %cl,%eax
  8028b5:	09 ee                	or     %ebp,%esi
  8028b7:	89 d9                	mov    %ebx,%ecx
  8028b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028bd:	89 d5                	mov    %edx,%ebp
  8028bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028c3:	d3 ed                	shr    %cl,%ebp
  8028c5:	89 f9                	mov    %edi,%ecx
  8028c7:	d3 e2                	shl    %cl,%edx
  8028c9:	89 d9                	mov    %ebx,%ecx
  8028cb:	d3 e8                	shr    %cl,%eax
  8028cd:	09 c2                	or     %eax,%edx
  8028cf:	89 d0                	mov    %edx,%eax
  8028d1:	89 ea                	mov    %ebp,%edx
  8028d3:	f7 f6                	div    %esi
  8028d5:	89 d5                	mov    %edx,%ebp
  8028d7:	89 c3                	mov    %eax,%ebx
  8028d9:	f7 64 24 0c          	mull   0xc(%esp)
  8028dd:	39 d5                	cmp    %edx,%ebp
  8028df:	72 10                	jb     8028f1 <__udivdi3+0xc1>
  8028e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8028e5:	89 f9                	mov    %edi,%ecx
  8028e7:	d3 e6                	shl    %cl,%esi
  8028e9:	39 c6                	cmp    %eax,%esi
  8028eb:	73 07                	jae    8028f4 <__udivdi3+0xc4>
  8028ed:	39 d5                	cmp    %edx,%ebp
  8028ef:	75 03                	jne    8028f4 <__udivdi3+0xc4>
  8028f1:	83 eb 01             	sub    $0x1,%ebx
  8028f4:	31 ff                	xor    %edi,%edi
  8028f6:	89 d8                	mov    %ebx,%eax
  8028f8:	89 fa                	mov    %edi,%edx
  8028fa:	83 c4 1c             	add    $0x1c,%esp
  8028fd:	5b                   	pop    %ebx
  8028fe:	5e                   	pop    %esi
  8028ff:	5f                   	pop    %edi
  802900:	5d                   	pop    %ebp
  802901:	c3                   	ret    
  802902:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802908:	31 ff                	xor    %edi,%edi
  80290a:	31 db                	xor    %ebx,%ebx
  80290c:	89 d8                	mov    %ebx,%eax
  80290e:	89 fa                	mov    %edi,%edx
  802910:	83 c4 1c             	add    $0x1c,%esp
  802913:	5b                   	pop    %ebx
  802914:	5e                   	pop    %esi
  802915:	5f                   	pop    %edi
  802916:	5d                   	pop    %ebp
  802917:	c3                   	ret    
  802918:	90                   	nop
  802919:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802920:	89 d8                	mov    %ebx,%eax
  802922:	f7 f7                	div    %edi
  802924:	31 ff                	xor    %edi,%edi
  802926:	89 c3                	mov    %eax,%ebx
  802928:	89 d8                	mov    %ebx,%eax
  80292a:	89 fa                	mov    %edi,%edx
  80292c:	83 c4 1c             	add    $0x1c,%esp
  80292f:	5b                   	pop    %ebx
  802930:	5e                   	pop    %esi
  802931:	5f                   	pop    %edi
  802932:	5d                   	pop    %ebp
  802933:	c3                   	ret    
  802934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802938:	39 ce                	cmp    %ecx,%esi
  80293a:	72 0c                	jb     802948 <__udivdi3+0x118>
  80293c:	31 db                	xor    %ebx,%ebx
  80293e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802942:	0f 87 34 ff ff ff    	ja     80287c <__udivdi3+0x4c>
  802948:	bb 01 00 00 00       	mov    $0x1,%ebx
  80294d:	e9 2a ff ff ff       	jmp    80287c <__udivdi3+0x4c>
  802952:	66 90                	xchg   %ax,%ax
  802954:	66 90                	xchg   %ax,%ax
  802956:	66 90                	xchg   %ax,%ax
  802958:	66 90                	xchg   %ax,%ax
  80295a:	66 90                	xchg   %ax,%ax
  80295c:	66 90                	xchg   %ax,%ax
  80295e:	66 90                	xchg   %ax,%ax

00802960 <__umoddi3>:
  802960:	55                   	push   %ebp
  802961:	57                   	push   %edi
  802962:	56                   	push   %esi
  802963:	53                   	push   %ebx
  802964:	83 ec 1c             	sub    $0x1c,%esp
  802967:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80296b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80296f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802973:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802977:	85 d2                	test   %edx,%edx
  802979:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80297d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802981:	89 f3                	mov    %esi,%ebx
  802983:	89 3c 24             	mov    %edi,(%esp)
  802986:	89 74 24 04          	mov    %esi,0x4(%esp)
  80298a:	75 1c                	jne    8029a8 <__umoddi3+0x48>
  80298c:	39 f7                	cmp    %esi,%edi
  80298e:	76 50                	jbe    8029e0 <__umoddi3+0x80>
  802990:	89 c8                	mov    %ecx,%eax
  802992:	89 f2                	mov    %esi,%edx
  802994:	f7 f7                	div    %edi
  802996:	89 d0                	mov    %edx,%eax
  802998:	31 d2                	xor    %edx,%edx
  80299a:	83 c4 1c             	add    $0x1c,%esp
  80299d:	5b                   	pop    %ebx
  80299e:	5e                   	pop    %esi
  80299f:	5f                   	pop    %edi
  8029a0:	5d                   	pop    %ebp
  8029a1:	c3                   	ret    
  8029a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029a8:	39 f2                	cmp    %esi,%edx
  8029aa:	89 d0                	mov    %edx,%eax
  8029ac:	77 52                	ja     802a00 <__umoddi3+0xa0>
  8029ae:	0f bd ea             	bsr    %edx,%ebp
  8029b1:	83 f5 1f             	xor    $0x1f,%ebp
  8029b4:	75 5a                	jne    802a10 <__umoddi3+0xb0>
  8029b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8029ba:	0f 82 e0 00 00 00    	jb     802aa0 <__umoddi3+0x140>
  8029c0:	39 0c 24             	cmp    %ecx,(%esp)
  8029c3:	0f 86 d7 00 00 00    	jbe    802aa0 <__umoddi3+0x140>
  8029c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029d1:	83 c4 1c             	add    $0x1c,%esp
  8029d4:	5b                   	pop    %ebx
  8029d5:	5e                   	pop    %esi
  8029d6:	5f                   	pop    %edi
  8029d7:	5d                   	pop    %ebp
  8029d8:	c3                   	ret    
  8029d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029e0:	85 ff                	test   %edi,%edi
  8029e2:	89 fd                	mov    %edi,%ebp
  8029e4:	75 0b                	jne    8029f1 <__umoddi3+0x91>
  8029e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029eb:	31 d2                	xor    %edx,%edx
  8029ed:	f7 f7                	div    %edi
  8029ef:	89 c5                	mov    %eax,%ebp
  8029f1:	89 f0                	mov    %esi,%eax
  8029f3:	31 d2                	xor    %edx,%edx
  8029f5:	f7 f5                	div    %ebp
  8029f7:	89 c8                	mov    %ecx,%eax
  8029f9:	f7 f5                	div    %ebp
  8029fb:	89 d0                	mov    %edx,%eax
  8029fd:	eb 99                	jmp    802998 <__umoddi3+0x38>
  8029ff:	90                   	nop
  802a00:	89 c8                	mov    %ecx,%eax
  802a02:	89 f2                	mov    %esi,%edx
  802a04:	83 c4 1c             	add    $0x1c,%esp
  802a07:	5b                   	pop    %ebx
  802a08:	5e                   	pop    %esi
  802a09:	5f                   	pop    %edi
  802a0a:	5d                   	pop    %ebp
  802a0b:	c3                   	ret    
  802a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a10:	8b 34 24             	mov    (%esp),%esi
  802a13:	bf 20 00 00 00       	mov    $0x20,%edi
  802a18:	89 e9                	mov    %ebp,%ecx
  802a1a:	29 ef                	sub    %ebp,%edi
  802a1c:	d3 e0                	shl    %cl,%eax
  802a1e:	89 f9                	mov    %edi,%ecx
  802a20:	89 f2                	mov    %esi,%edx
  802a22:	d3 ea                	shr    %cl,%edx
  802a24:	89 e9                	mov    %ebp,%ecx
  802a26:	09 c2                	or     %eax,%edx
  802a28:	89 d8                	mov    %ebx,%eax
  802a2a:	89 14 24             	mov    %edx,(%esp)
  802a2d:	89 f2                	mov    %esi,%edx
  802a2f:	d3 e2                	shl    %cl,%edx
  802a31:	89 f9                	mov    %edi,%ecx
  802a33:	89 54 24 04          	mov    %edx,0x4(%esp)
  802a37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802a3b:	d3 e8                	shr    %cl,%eax
  802a3d:	89 e9                	mov    %ebp,%ecx
  802a3f:	89 c6                	mov    %eax,%esi
  802a41:	d3 e3                	shl    %cl,%ebx
  802a43:	89 f9                	mov    %edi,%ecx
  802a45:	89 d0                	mov    %edx,%eax
  802a47:	d3 e8                	shr    %cl,%eax
  802a49:	89 e9                	mov    %ebp,%ecx
  802a4b:	09 d8                	or     %ebx,%eax
  802a4d:	89 d3                	mov    %edx,%ebx
  802a4f:	89 f2                	mov    %esi,%edx
  802a51:	f7 34 24             	divl   (%esp)
  802a54:	89 d6                	mov    %edx,%esi
  802a56:	d3 e3                	shl    %cl,%ebx
  802a58:	f7 64 24 04          	mull   0x4(%esp)
  802a5c:	39 d6                	cmp    %edx,%esi
  802a5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a62:	89 d1                	mov    %edx,%ecx
  802a64:	89 c3                	mov    %eax,%ebx
  802a66:	72 08                	jb     802a70 <__umoddi3+0x110>
  802a68:	75 11                	jne    802a7b <__umoddi3+0x11b>
  802a6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802a6e:	73 0b                	jae    802a7b <__umoddi3+0x11b>
  802a70:	2b 44 24 04          	sub    0x4(%esp),%eax
  802a74:	1b 14 24             	sbb    (%esp),%edx
  802a77:	89 d1                	mov    %edx,%ecx
  802a79:	89 c3                	mov    %eax,%ebx
  802a7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802a7f:	29 da                	sub    %ebx,%edx
  802a81:	19 ce                	sbb    %ecx,%esi
  802a83:	89 f9                	mov    %edi,%ecx
  802a85:	89 f0                	mov    %esi,%eax
  802a87:	d3 e0                	shl    %cl,%eax
  802a89:	89 e9                	mov    %ebp,%ecx
  802a8b:	d3 ea                	shr    %cl,%edx
  802a8d:	89 e9                	mov    %ebp,%ecx
  802a8f:	d3 ee                	shr    %cl,%esi
  802a91:	09 d0                	or     %edx,%eax
  802a93:	89 f2                	mov    %esi,%edx
  802a95:	83 c4 1c             	add    $0x1c,%esp
  802a98:	5b                   	pop    %ebx
  802a99:	5e                   	pop    %esi
  802a9a:	5f                   	pop    %edi
  802a9b:	5d                   	pop    %ebp
  802a9c:	c3                   	ret    
  802a9d:	8d 76 00             	lea    0x0(%esi),%esi
  802aa0:	29 f9                	sub    %edi,%ecx
  802aa2:	19 d6                	sbb    %edx,%esi
  802aa4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802aa8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802aac:	e9 18 ff ff ff       	jmp    8029c9 <__umoddi3+0x69>
