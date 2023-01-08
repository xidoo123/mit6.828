
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 02 27 80 00       	push   $0x802702
  80005f:	e8 7d 19 00 00       	call   8019e1 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 68 27 80 00       	mov    $0x802768,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 cb 08 00 00       	call   800949 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba 68 27 80 00       	mov    $0x802768,%edx
  80008b:	b8 00 27 80 00       	mov    $0x802700,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 0b 27 80 00       	push   $0x80270b
  80009d:	e8 3f 19 00 00       	call   8019e1 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 99 2b 80 00       	push   $0x802b99
  8000b0:	e8 2c 19 00 00       	call   8019e1 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 00 27 80 00       	push   $0x802700
  8000cf:	e8 0d 19 00 00       	call   8019e1 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 67 27 80 00       	push   $0x802767
  8000df:	e8 fd 18 00 00       	call   8019e1 <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 3e 17 00 00       	call   801843 <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 10 27 80 00       	push   $0x802710
  800118:	6a 1d                	push   $0x1d
  80011a:	68 1c 27 80 00       	push   $0x80271c
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 f2 12 00 00       	call   801456 <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 26 27 80 00       	push   $0x802726
  800178:	6a 22                	push   $0x22
  80017a:	68 1c 27 80 00       	push   $0x80271c
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 6c 27 80 00       	push   $0x80276c
  800192:	6a 24                	push   $0x24
  800194:	68 1c 27 80 00       	push   $0x80271c
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 9b 14 00 00       	call   80165b <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 41 27 80 00       	push   $0x802741
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 1c 27 80 00       	push   $0x80271c
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 4d 27 80 00       	push   $0x80274d
  800225:	e8 b7 17 00 00       	call   8019e1 <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 48 0d 00 00       	call   800f95 <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 49 0d 00 00       	call   800fc5 <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 68 27 80 00       	push   $0x802768
  800296:	68 00 27 80 00       	push   $0x802700
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002cf:	e8 73 0a 00 00       	call   800d47 <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 9f 0f 00 00       	call   8012b4 <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 e7 09 00 00       	call   800d06 <sys_env_destroy>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 10 0a 00 00       	call   800d47 <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 98 27 80 00       	push   $0x802798
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 2f 09 00 00       	call   800cc9 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 54 01 00 00       	call   800534 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 d4 08 00 00       	call   800cc9 <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 45                	ja     800486 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 0b 20 00 00       	call   802470 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 18                	jmp    800490 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb 03                	jmp    800489 <printnum+0x78>
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f e8                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049a:	ff 75 e0             	pushl  -0x20(%ebp)
  80049d:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	e8 f8 20 00 00       	call   8025a0 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 bb 27 80 00 	movsbl 0x8027bb(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c3:	83 fa 01             	cmp    $0x1,%edx
  8004c6:	7e 0e                	jle    8004d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	8b 52 04             	mov    0x4(%edx),%edx
  8004d4:	eb 22                	jmp    8004f8 <getuint+0x38>
	else if (lflag)
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 10                	je     8004ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	eb 0e                	jmp    8004f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 02                	mov    (%edx),%eax
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800500:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800504:	8b 10                	mov    (%eax),%edx
  800506:	3b 50 04             	cmp    0x4(%eax),%edx
  800509:	73 0a                	jae    800515 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050e:	89 08                	mov    %ecx,(%eax)
  800510:	8b 45 08             	mov    0x8(%ebp),%eax
  800513:	88 02                	mov    %al,(%edx)
}
  800515:	5d                   	pop    %ebp
  800516:	c3                   	ret    

00800517 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800520:	50                   	push   %eax
  800521:	ff 75 10             	pushl  0x10(%ebp)
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 05 00 00 00       	call   800534 <vprintfmt>
	va_end(ap);
}
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 2c             	sub    $0x2c,%esp
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	8b 7d 10             	mov    0x10(%ebp),%edi
  800546:	eb 12                	jmp    80055a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800548:	85 c0                	test   %eax,%eax
  80054a:	0f 84 89 03 00 00    	je     8008d9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	50                   	push   %eax
  800555:	ff d6                	call   *%esi
  800557:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055a:	83 c7 01             	add    $0x1,%edi
  80055d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800561:	83 f8 25             	cmp    $0x25,%eax
  800564:	75 e2                	jne    800548 <vprintfmt+0x14>
  800566:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800571:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800578:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057f:	ba 00 00 00 00       	mov    $0x0,%edx
  800584:	eb 07                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800589:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8d 47 01             	lea    0x1(%edi),%eax
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	0f b6 07             	movzbl (%edi),%eax
  800596:	0f b6 c8             	movzbl %al,%ecx
  800599:	83 e8 23             	sub    $0x23,%eax
  80059c:	3c 55                	cmp    $0x55,%al
  80059e:	0f 87 1a 03 00 00    	ja     8008be <vprintfmt+0x38a>
  8005a4:	0f b6 c0             	movzbl %al,%eax
  8005a7:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b5:	eb d6                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005cc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005cf:	83 fa 09             	cmp    $0x9,%edx
  8005d2:	77 39                	ja     80060d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d7:	eb e9                	jmp    8005c2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8005df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ea:	eb 27                	jmp    800613 <vprintfmt+0xdf>
  8005ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f6:	0f 49 c8             	cmovns %eax,%ecx
  8005f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ff:	eb 8c                	jmp    80058d <vprintfmt+0x59>
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800604:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060b:	eb 80                	jmp    80058d <vprintfmt+0x59>
  80060d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800610:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800613:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800617:	0f 89 70 ff ff ff    	jns    80058d <vprintfmt+0x59>
				width = precision, precision = -1;
  80061d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800620:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800623:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80062a:	e9 5e ff ff ff       	jmp    80058d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800635:	e9 53 ff ff ff       	jmp    80058d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	ff 30                	pushl  (%eax)
  800649:	ff d6                	call   *%esi
			break;
  80064b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800651:	e9 04 ff ff ff       	jmp    80055a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	99                   	cltd   
  800662:	31 d0                	xor    %edx,%eax
  800664:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 0f             	cmp    $0xf,%eax
  800669:	7f 0b                	jg     800676 <vprintfmt+0x142>
  80066b:	8b 14 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	75 18                	jne    80068e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 d3 27 80 00       	push   $0x8027d3
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 94 fe ff ff       	call   800517 <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800689:	e9 cc fe ff ff       	jmp    80055a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80068e:	52                   	push   %edx
  80068f:	68 99 2b 80 00       	push   $0x802b99
  800694:	53                   	push   %ebx
  800695:	56                   	push   %esi
  800696:	e8 7c fe ff ff       	call   800517 <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a1:	e9 b4 fe ff ff       	jmp    80055a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	b8 cc 27 80 00       	mov    $0x8027cc,%eax
  8006b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bf:	0f 8e 94 00 00 00    	jle    800759 <vprintfmt+0x225>
  8006c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c9:	0f 84 98 00 00 00    	je     800767 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d5:	57                   	push   %edi
  8006d6:	e8 86 02 00 00       	call   800961 <strnlen>
  8006db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f2:	eb 0f                	jmp    800703 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fd:	83 ef 01             	sub    $0x1,%edi
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 ff                	test   %edi,%edi
  800705:	7f ed                	jg     8006f4 <vprintfmt+0x1c0>
  800707:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	0f 49 c1             	cmovns %ecx,%eax
  800717:	29 c1                	sub    %eax,%ecx
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	89 cb                	mov    %ecx,%ebx
  800724:	eb 4d                	jmp    800773 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800726:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072a:	74 1b                	je     800747 <vprintfmt+0x213>
  80072c:	0f be c0             	movsbl %al,%eax
  80072f:	83 e8 20             	sub    $0x20,%eax
  800732:	83 f8 5e             	cmp    $0x5e,%eax
  800735:	76 10                	jbe    800747 <vprintfmt+0x213>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	6a 3f                	push   $0x3f
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 0d                	jmp    800754 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	52                   	push   %edx
  80074e:	ff 55 08             	call   *0x8(%ebp)
  800751:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	eb 1a                	jmp    800773 <vprintfmt+0x23f>
  800759:	89 75 08             	mov    %esi,0x8(%ebp)
  80075c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800762:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800765:	eb 0c                	jmp    800773 <vprintfmt+0x23f>
  800767:	89 75 08             	mov    %esi,0x8(%ebp)
  80076a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800773:	83 c7 01             	add    $0x1,%edi
  800776:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077a:	0f be d0             	movsbl %al,%edx
  80077d:	85 d2                	test   %edx,%edx
  80077f:	74 23                	je     8007a4 <vprintfmt+0x270>
  800781:	85 f6                	test   %esi,%esi
  800783:	78 a1                	js     800726 <vprintfmt+0x1f2>
  800785:	83 ee 01             	sub    $0x1,%esi
  800788:	79 9c                	jns    800726 <vprintfmt+0x1f2>
  80078a:	89 df                	mov    %ebx,%edi
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800792:	eb 18                	jmp    8007ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 20                	push   $0x20
  80079a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079c:	83 ef 01             	sub    $0x1,%edi
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 08                	jmp    8007ac <vprintfmt+0x278>
  8007a4:	89 df                	mov    %ebx,%edi
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ac:	85 ff                	test   %edi,%edi
  8007ae:	7f e4                	jg     800794 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b3:	e9 a2 fd ff ff       	jmp    80055a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b8:	83 fa 01             	cmp    $0x1,%edx
  8007bb:	7e 16                	jle    8007d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 08             	lea    0x8(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c6:	8b 50 04             	mov    0x4(%eax),%edx
  8007c9:	8b 00                	mov    (%eax),%eax
  8007cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d1:	eb 32                	jmp    800805 <vprintfmt+0x2d1>
	else if (lflag)
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	74 18                	je     8007ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 c1                	mov    %eax,%ecx
  8007e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ed:	eb 16                	jmp    800805 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fd:	89 c1                	mov    %eax,%ecx
  8007ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800802:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800805:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800808:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800810:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800814:	79 74                	jns    80088a <vprintfmt+0x356>
				putch('-', putdat);
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	53                   	push   %ebx
  80081a:	6a 2d                	push   $0x2d
  80081c:	ff d6                	call   *%esi
				num = -(long long) num;
  80081e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800821:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800824:	f7 d8                	neg    %eax
  800826:	83 d2 00             	adc    $0x0,%edx
  800829:	f7 da                	neg    %edx
  80082b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80082e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800833:	eb 55                	jmp    80088a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	e8 83 fc ff ff       	call   8004c0 <getuint>
			base = 10;
  80083d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800842:	eb 46                	jmp    80088a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800844:	8d 45 14             	lea    0x14(%ebp),%eax
  800847:	e8 74 fc ff ff       	call   8004c0 <getuint>
			base = 8;
  80084c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800851:	eb 37                	jmp    80088a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 30                	push   $0x30
  800859:	ff d6                	call   *%esi
			putch('x', putdat);
  80085b:	83 c4 08             	add    $0x8,%esp
  80085e:	53                   	push   %ebx
  80085f:	6a 78                	push   $0x78
  800861:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8d 50 04             	lea    0x4(%eax),%edx
  800869:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80086c:	8b 00                	mov    (%eax),%eax
  80086e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800873:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800876:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80087b:	eb 0d                	jmp    80088a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80087d:	8d 45 14             	lea    0x14(%ebp),%eax
  800880:	e8 3b fc ff ff       	call   8004c0 <getuint>
			base = 16;
  800885:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088a:	83 ec 0c             	sub    $0xc,%esp
  80088d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800891:	57                   	push   %edi
  800892:	ff 75 e0             	pushl  -0x20(%ebp)
  800895:	51                   	push   %ecx
  800896:	52                   	push   %edx
  800897:	50                   	push   %eax
  800898:	89 da                	mov    %ebx,%edx
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	e8 70 fb ff ff       	call   800411 <printnum>
			break;
  8008a1:	83 c4 20             	add    $0x20,%esp
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a7:	e9 ae fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	51                   	push   %ecx
  8008b1:	ff d6                	call   *%esi
			break;
  8008b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008b9:	e9 9c fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	6a 25                	push   $0x25
  8008c4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c6:	83 c4 10             	add    $0x10,%esp
  8008c9:	eb 03                	jmp    8008ce <vprintfmt+0x39a>
  8008cb:	83 ef 01             	sub    $0x1,%edi
  8008ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008d2:	75 f7                	jne    8008cb <vprintfmt+0x397>
  8008d4:	e9 81 fc ff ff       	jmp    80055a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5f                   	pop    %edi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	83 ec 18             	sub    $0x18,%esp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fe:	85 c0                	test   %eax,%eax
  800900:	74 26                	je     800928 <vsnprintf+0x47>
  800902:	85 d2                	test   %edx,%edx
  800904:	7e 22                	jle    800928 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800906:	ff 75 14             	pushl  0x14(%ebp)
  800909:	ff 75 10             	pushl  0x10(%ebp)
  80090c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	68 fa 04 80 00       	push   $0x8004fa
  800915:	e8 1a fc ff ff       	call   800534 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	eb 05                	jmp    80092d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800928:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800935:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800938:	50                   	push   %eax
  800939:	ff 75 10             	pushl  0x10(%ebp)
  80093c:	ff 75 0c             	pushl  0xc(%ebp)
  80093f:	ff 75 08             	pushl  0x8(%ebp)
  800942:	e8 9a ff ff ff       	call   8008e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb 03                	jmp    800959 <strlen+0x10>
		n++;
  800956:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800959:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095d:	75 f7                	jne    800956 <strlen+0xd>
		n++;
	return n;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	eb 03                	jmp    800974 <strnlen+0x13>
		n++;
  800971:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800974:	39 c2                	cmp    %eax,%edx
  800976:	74 08                	je     800980 <strnlen+0x1f>
  800978:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80097c:	75 f3                	jne    800971 <strnlen+0x10>
  80097e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	83 c2 01             	add    $0x1,%edx
  800991:	83 c1 01             	add    $0x1,%ecx
  800994:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800998:	88 5a ff             	mov    %bl,-0x1(%edx)
  80099b:	84 db                	test   %bl,%bl
  80099d:	75 ef                	jne    80098e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a9:	53                   	push   %ebx
  8009aa:	e8 9a ff ff ff       	call   800949 <strlen>
  8009af:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009b2:	ff 75 0c             	pushl  0xc(%ebp)
  8009b5:	01 d8                	add    %ebx,%eax
  8009b7:	50                   	push   %eax
  8009b8:	e8 c5 ff ff ff       	call   800982 <strcpy>
	return dst;
}
  8009bd:	89 d8                	mov    %ebx,%eax
  8009bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d4:	89 f2                	mov    %esi,%edx
  8009d6:	eb 0f                	jmp    8009e7 <strncpy+0x23>
		*dst++ = *src;
  8009d8:	83 c2 01             	add    $0x1,%edx
  8009db:	0f b6 01             	movzbl (%ecx),%eax
  8009de:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e1:	80 39 01             	cmpb   $0x1,(%ecx)
  8009e4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e7:	39 da                	cmp    %ebx,%edx
  8009e9:	75 ed                	jne    8009d8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009eb:	89 f0                	mov    %esi,%eax
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a01:	85 d2                	test   %edx,%edx
  800a03:	74 21                	je     800a26 <strlcpy+0x35>
  800a05:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a09:	89 f2                	mov    %esi,%edx
  800a0b:	eb 09                	jmp    800a16 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a0d:	83 c2 01             	add    $0x1,%edx
  800a10:	83 c1 01             	add    $0x1,%ecx
  800a13:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a16:	39 c2                	cmp    %eax,%edx
  800a18:	74 09                	je     800a23 <strlcpy+0x32>
  800a1a:	0f b6 19             	movzbl (%ecx),%ebx
  800a1d:	84 db                	test   %bl,%bl
  800a1f:	75 ec                	jne    800a0d <strlcpy+0x1c>
  800a21:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a23:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a26:	29 f0                	sub    %esi,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a35:	eb 06                	jmp    800a3d <strcmp+0x11>
		p++, q++;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3d:	0f b6 01             	movzbl (%ecx),%eax
  800a40:	84 c0                	test   %al,%al
  800a42:	74 04                	je     800a48 <strcmp+0x1c>
  800a44:	3a 02                	cmp    (%edx),%al
  800a46:	74 ef                	je     800a37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a48:	0f b6 c0             	movzbl %al,%eax
  800a4b:	0f b6 12             	movzbl (%edx),%edx
  800a4e:	29 d0                	sub    %edx,%eax
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	53                   	push   %ebx
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a61:	eb 06                	jmp    800a69 <strncmp+0x17>
		n--, p++, q++;
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a69:	39 d8                	cmp    %ebx,%eax
  800a6b:	74 15                	je     800a82 <strncmp+0x30>
  800a6d:	0f b6 08             	movzbl (%eax),%ecx
  800a70:	84 c9                	test   %cl,%cl
  800a72:	74 04                	je     800a78 <strncmp+0x26>
  800a74:	3a 0a                	cmp    (%edx),%cl
  800a76:	74 eb                	je     800a63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a78:	0f b6 00             	movzbl (%eax),%eax
  800a7b:	0f b6 12             	movzbl (%edx),%edx
  800a7e:	29 d0                	sub    %edx,%eax
  800a80:	eb 05                	jmp    800a87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a87:	5b                   	pop    %ebx
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a94:	eb 07                	jmp    800a9d <strchr+0x13>
		if (*s == c)
  800a96:	38 ca                	cmp    %cl,%dl
  800a98:	74 0f                	je     800aa9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	75 f2                	jne    800a96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab5:	eb 03                	jmp    800aba <strfind+0xf>
  800ab7:	83 c0 01             	add    $0x1,%eax
  800aba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800abd:	38 ca                	cmp    %cl,%dl
  800abf:	74 04                	je     800ac5 <strfind+0x1a>
  800ac1:	84 d2                	test   %dl,%dl
  800ac3:	75 f2                	jne    800ab7 <strfind+0xc>
			break;
	return (char *) s;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad3:	85 c9                	test   %ecx,%ecx
  800ad5:	74 36                	je     800b0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800add:	75 28                	jne    800b07 <memset+0x40>
  800adf:	f6 c1 03             	test   $0x3,%cl
  800ae2:	75 23                	jne    800b07 <memset+0x40>
		c &= 0xFF;
  800ae4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	c1 e3 08             	shl    $0x8,%ebx
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	c1 e6 18             	shl    $0x18,%esi
  800af2:	89 d0                	mov    %edx,%eax
  800af4:	c1 e0 10             	shl    $0x10,%eax
  800af7:	09 f0                	or     %esi,%eax
  800af9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800afb:	89 d8                	mov    %ebx,%eax
  800afd:	09 d0                	or     %edx,%eax
  800aff:	c1 e9 02             	shr    $0x2,%ecx
  800b02:	fc                   	cld    
  800b03:	f3 ab                	rep stos %eax,%es:(%edi)
  800b05:	eb 06                	jmp    800b0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	fc                   	cld    
  800b0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0d:	89 f8                	mov    %edi,%eax
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b22:	39 c6                	cmp    %eax,%esi
  800b24:	73 35                	jae    800b5b <memmove+0x47>
  800b26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b29:	39 d0                	cmp    %edx,%eax
  800b2b:	73 2e                	jae    800b5b <memmove+0x47>
		s += n;
		d += n;
  800b2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	09 fe                	or     %edi,%esi
  800b34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3a:	75 13                	jne    800b4f <memmove+0x3b>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 0e                	jne    800b4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b41:	83 ef 04             	sub    $0x4,%edi
  800b44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b47:	c1 e9 02             	shr    $0x2,%ecx
  800b4a:	fd                   	std    
  800b4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4d:	eb 09                	jmp    800b58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4f:	83 ef 01             	sub    $0x1,%edi
  800b52:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b55:	fd                   	std    
  800b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b58:	fc                   	cld    
  800b59:	eb 1d                	jmp    800b78 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	09 c2                	or     %eax,%edx
  800b5f:	f6 c2 03             	test   $0x3,%dl
  800b62:	75 0f                	jne    800b73 <memmove+0x5f>
  800b64:	f6 c1 03             	test   $0x3,%cl
  800b67:	75 0a                	jne    800b73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b69:	c1 e9 02             	shr    $0x2,%ecx
  800b6c:	89 c7                	mov    %eax,%edi
  800b6e:	fc                   	cld    
  800b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b71:	eb 05                	jmp    800b78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	fc                   	cld    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b7f:	ff 75 10             	pushl  0x10(%ebp)
  800b82:	ff 75 0c             	pushl  0xc(%ebp)
  800b85:	ff 75 08             	pushl  0x8(%ebp)
  800b88:	e8 87 ff ff ff       	call   800b14 <memmove>
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9a:	89 c6                	mov    %eax,%esi
  800b9c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9f:	eb 1a                	jmp    800bbb <memcmp+0x2c>
		if (*s1 != *s2)
  800ba1:	0f b6 08             	movzbl (%eax),%ecx
  800ba4:	0f b6 1a             	movzbl (%edx),%ebx
  800ba7:	38 d9                	cmp    %bl,%cl
  800ba9:	74 0a                	je     800bb5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bab:	0f b6 c1             	movzbl %cl,%eax
  800bae:	0f b6 db             	movzbl %bl,%ebx
  800bb1:	29 d8                	sub    %ebx,%eax
  800bb3:	eb 0f                	jmp    800bc4 <memcmp+0x35>
		s1++, s2++;
  800bb5:	83 c0 01             	add    $0x1,%eax
  800bb8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbb:	39 f0                	cmp    %esi,%eax
  800bbd:	75 e2                	jne    800ba1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bcf:	89 c1                	mov    %eax,%ecx
  800bd1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd8:	eb 0a                	jmp    800be4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bda:	0f b6 10             	movzbl (%eax),%edx
  800bdd:	39 da                	cmp    %ebx,%edx
  800bdf:	74 07                	je     800be8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be1:	83 c0 01             	add    $0x1,%eax
  800be4:	39 c8                	cmp    %ecx,%eax
  800be6:	72 f2                	jb     800bda <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be8:	5b                   	pop    %ebx
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf7:	eb 03                	jmp    800bfc <strtol+0x11>
		s++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfc:	0f b6 01             	movzbl (%ecx),%eax
  800bff:	3c 20                	cmp    $0x20,%al
  800c01:	74 f6                	je     800bf9 <strtol+0xe>
  800c03:	3c 09                	cmp    $0x9,%al
  800c05:	74 f2                	je     800bf9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c07:	3c 2b                	cmp    $0x2b,%al
  800c09:	75 0a                	jne    800c15 <strtol+0x2a>
		s++;
  800c0b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c13:	eb 11                	jmp    800c26 <strtol+0x3b>
  800c15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c1a:	3c 2d                	cmp    $0x2d,%al
  800c1c:	75 08                	jne    800c26 <strtol+0x3b>
		s++, neg = 1;
  800c1e:	83 c1 01             	add    $0x1,%ecx
  800c21:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c2c:	75 15                	jne    800c43 <strtol+0x58>
  800c2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c31:	75 10                	jne    800c43 <strtol+0x58>
  800c33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c37:	75 7c                	jne    800cb5 <strtol+0xca>
		s += 2, base = 16;
  800c39:	83 c1 02             	add    $0x2,%ecx
  800c3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c41:	eb 16                	jmp    800c59 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	75 12                	jne    800c59 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c47:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4f:	75 08                	jne    800c59 <strtol+0x6e>
		s++, base = 8;
  800c51:	83 c1 01             	add    $0x1,%ecx
  800c54:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c59:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c61:	0f b6 11             	movzbl (%ecx),%edx
  800c64:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 09             	cmp    $0x9,%bl
  800c6c:	77 08                	ja     800c76 <strtol+0x8b>
			dig = *s - '0';
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 30             	sub    $0x30,%edx
  800c74:	eb 22                	jmp    800c98 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c76:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 08                	ja     800c88 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 57             	sub    $0x57,%edx
  800c86:	eb 10                	jmp    800c98 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c88:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	80 fb 19             	cmp    $0x19,%bl
  800c90:	77 16                	ja     800ca8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c92:	0f be d2             	movsbl %dl,%edx
  800c95:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c98:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c9b:	7d 0b                	jge    800ca8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ca6:	eb b9                	jmp    800c61 <strtol+0x76>

	if (endptr)
  800ca8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cac:	74 0d                	je     800cbb <strtol+0xd0>
		*endptr = (char *) s;
  800cae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb1:	89 0e                	mov    %ecx,(%esi)
  800cb3:	eb 06                	jmp    800cbb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb5:	85 db                	test   %ebx,%ebx
  800cb7:	74 98                	je     800c51 <strtol+0x66>
  800cb9:	eb 9e                	jmp    800c59 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cbb:	89 c2                	mov    %eax,%edx
  800cbd:	f7 da                	neg    %edx
  800cbf:	85 ff                	test   %edi,%edi
  800cc1:	0f 45 c2             	cmovne %edx,%eax
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 c3                	mov    %eax,%ebx
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	89 c6                	mov    %eax,%esi
  800ce0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf7:	89 d1                	mov    %edx,%ecx
  800cf9:	89 d3                	mov    %edx,%ebx
  800cfb:	89 d7                	mov    %edx,%edi
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d14:	b8 03 00 00 00       	mov    $0x3,%eax
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 cb                	mov    %ecx,%ebx
  800d1e:	89 cf                	mov    %ecx,%edi
  800d20:	89 ce                	mov    %ecx,%esi
  800d22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 17                	jle    800d3f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 03                	push   $0x3
  800d2e:	68 bf 2a 80 00       	push   $0x802abf
  800d33:	6a 23                	push   $0x23
  800d35:	68 dc 2a 80 00       	push   $0x802adc
  800d3a:	e8 e5 f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	b8 02 00 00 00       	mov    $0x2,%eax
  800d57:	89 d1                	mov    %edx,%ecx
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	89 d7                	mov    %edx,%edi
  800d5d:	89 d6                	mov    %edx,%esi
  800d5f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_yield>:

void
sys_yield(void)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d76:	89 d1                	mov    %edx,%ecx
  800d78:	89 d3                	mov    %edx,%ebx
  800d7a:	89 d7                	mov    %edx,%edi
  800d7c:	89 d6                	mov    %edx,%esi
  800d7e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	b8 04 00 00 00       	mov    $0x4,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da1:	89 f7                	mov    %esi,%edi
  800da3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 04                	push   $0x4
  800daf:	68 bf 2a 80 00       	push   $0x802abf
  800db4:	6a 23                	push   $0x23
  800db6:	68 dc 2a 80 00       	push   $0x802adc
  800dbb:	e8 64 f5 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	8b 75 18             	mov    0x18(%ebp),%esi
  800de5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 17                	jle    800e02 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 05                	push   $0x5
  800df1:	68 bf 2a 80 00       	push   $0x802abf
  800df6:	6a 23                	push   $0x23
  800df8:	68 dc 2a 80 00       	push   $0x802adc
  800dfd:	e8 22 f5 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 17                	jle    800e44 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	50                   	push   %eax
  800e31:	6a 06                	push   $0x6
  800e33:	68 bf 2a 80 00       	push   $0x802abf
  800e38:	6a 23                	push   $0x23
  800e3a:	68 dc 2a 80 00       	push   $0x802adc
  800e3f:	e8 e0 f4 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	b8 08 00 00 00       	mov    $0x8,%eax
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 17                	jle    800e86 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 08                	push   $0x8
  800e75:	68 bf 2a 80 00       	push   $0x802abf
  800e7a:	6a 23                	push   $0x23
  800e7c:	68 dc 2a 80 00       	push   $0x802adc
  800e81:	e8 9e f4 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 17                	jle    800ec8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	50                   	push   %eax
  800eb5:	6a 09                	push   $0x9
  800eb7:	68 bf 2a 80 00       	push   $0x802abf
  800ebc:	6a 23                	push   $0x23
  800ebe:	68 dc 2a 80 00       	push   $0x802adc
  800ec3:	e8 5c f4 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ede:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 de                	mov    %ebx,%esi
  800eed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	7e 17                	jle    800f0a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	50                   	push   %eax
  800ef7:	6a 0a                	push   $0xa
  800ef9:	68 bf 2a 80 00       	push   $0x802abf
  800efe:	6a 23                	push   $0x23
  800f00:	68 dc 2a 80 00       	push   $0x802adc
  800f05:	e8 1a f4 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	be 00 00 00 00       	mov    $0x0,%esi
  800f1d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f2e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f43:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	89 cb                	mov    %ecx,%ebx
  800f4d:	89 cf                	mov    %ecx,%edi
  800f4f:	89 ce                	mov    %ecx,%esi
  800f51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f53:	85 c0                	test   %eax,%eax
  800f55:	7e 17                	jle    800f6e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	50                   	push   %eax
  800f5b:	6a 0d                	push   $0xd
  800f5d:	68 bf 2a 80 00       	push   $0x802abf
  800f62:	6a 23                	push   $0x23
  800f64:	68 dc 2a 80 00       	push   $0x802adc
  800f69:	e8 b6 f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f81:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f86:	89 d1                	mov    %edx,%ecx
  800f88:	89 d3                	mov    %edx,%ebx
  800f8a:	89 d7                	mov    %edx,%edi
  800f8c:	89 d6                	mov    %edx,%esi
  800f8e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9e:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fa1:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800fa3:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fa6:	83 3a 01             	cmpl   $0x1,(%edx)
  800fa9:	7e 09                	jle    800fb4 <argstart+0x1f>
  800fab:	ba 68 27 80 00       	mov    $0x802768,%edx
  800fb0:	85 c9                	test   %ecx,%ecx
  800fb2:	75 05                	jne    800fb9 <argstart+0x24>
  800fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb9:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800fbc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <argnext>:

int
argnext(struct Argstate *args)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	53                   	push   %ebx
  800fc9:	83 ec 04             	sub    $0x4,%esp
  800fcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800fcf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800fd6:	8b 43 08             	mov    0x8(%ebx),%eax
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	74 6f                	je     80104c <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800fdd:	80 38 00             	cmpb   $0x0,(%eax)
  800fe0:	75 4e                	jne    801030 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800fe2:	8b 0b                	mov    (%ebx),%ecx
  800fe4:	83 39 01             	cmpl   $0x1,(%ecx)
  800fe7:	74 55                	je     80103e <argnext+0x79>
		    || args->argv[1][0] != '-'
  800fe9:	8b 53 04             	mov    0x4(%ebx),%edx
  800fec:	8b 42 04             	mov    0x4(%edx),%eax
  800fef:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ff2:	75 4a                	jne    80103e <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800ff4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800ff8:	74 44                	je     80103e <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800ffa:	83 c0 01             	add    $0x1,%eax
  800ffd:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801000:	83 ec 04             	sub    $0x4,%esp
  801003:	8b 01                	mov    (%ecx),%eax
  801005:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80100c:	50                   	push   %eax
  80100d:	8d 42 08             	lea    0x8(%edx),%eax
  801010:	50                   	push   %eax
  801011:	83 c2 04             	add    $0x4,%edx
  801014:	52                   	push   %edx
  801015:	e8 fa fa ff ff       	call   800b14 <memmove>
		(*args->argc)--;
  80101a:	8b 03                	mov    (%ebx),%eax
  80101c:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80101f:	8b 43 08             	mov    0x8(%ebx),%eax
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	80 38 2d             	cmpb   $0x2d,(%eax)
  801028:	75 06                	jne    801030 <argnext+0x6b>
  80102a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80102e:	74 0e                	je     80103e <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801030:	8b 53 08             	mov    0x8(%ebx),%edx
  801033:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801036:	83 c2 01             	add    $0x1,%edx
  801039:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80103c:	eb 13                	jmp    801051 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  80103e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801045:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80104a:	eb 05                	jmp    801051 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80104c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	53                   	push   %ebx
  80105a:	83 ec 04             	sub    $0x4,%esp
  80105d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801060:	8b 43 08             	mov    0x8(%ebx),%eax
  801063:	85 c0                	test   %eax,%eax
  801065:	74 58                	je     8010bf <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801067:	80 38 00             	cmpb   $0x0,(%eax)
  80106a:	74 0c                	je     801078 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80106c:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  80106f:	c7 43 08 68 27 80 00 	movl   $0x802768,0x8(%ebx)
  801076:	eb 42                	jmp    8010ba <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801078:	8b 13                	mov    (%ebx),%edx
  80107a:	83 3a 01             	cmpl   $0x1,(%edx)
  80107d:	7e 2d                	jle    8010ac <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  80107f:	8b 43 04             	mov    0x4(%ebx),%eax
  801082:	8b 48 04             	mov    0x4(%eax),%ecx
  801085:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	8b 12                	mov    (%edx),%edx
  80108d:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801094:	52                   	push   %edx
  801095:	8d 50 08             	lea    0x8(%eax),%edx
  801098:	52                   	push   %edx
  801099:	83 c0 04             	add    $0x4,%eax
  80109c:	50                   	push   %eax
  80109d:	e8 72 fa ff ff       	call   800b14 <memmove>
		(*args->argc)--;
  8010a2:	8b 03                	mov    (%ebx),%eax
  8010a4:	83 28 01             	subl   $0x1,(%eax)
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	eb 0e                	jmp    8010ba <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8010ac:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010b3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8010ba:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010bd:	eb 05                	jmp    8010c4 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c7:	c9                   	leave  
  8010c8:	c3                   	ret    

008010c9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	83 ec 08             	sub    $0x8,%esp
  8010cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010d2:	8b 51 0c             	mov    0xc(%ecx),%edx
  8010d5:	89 d0                	mov    %edx,%eax
  8010d7:	85 d2                	test   %edx,%edx
  8010d9:	75 0c                	jne    8010e7 <argvalue+0x1e>
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	51                   	push   %ecx
  8010df:	e8 72 ff ff ff       	call   801056 <argnextvalue>
  8010e4:	83 c4 10             	add    $0x10,%esp
}
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f4:	c1 e8 0c             	shr    $0xc,%eax
}
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ff:	05 00 00 00 30       	add    $0x30000000,%eax
  801104:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801109:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801116:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80111b:	89 c2                	mov    %eax,%edx
  80111d:	c1 ea 16             	shr    $0x16,%edx
  801120:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801127:	f6 c2 01             	test   $0x1,%dl
  80112a:	74 11                	je     80113d <fd_alloc+0x2d>
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	c1 ea 0c             	shr    $0xc,%edx
  801131:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801138:	f6 c2 01             	test   $0x1,%dl
  80113b:	75 09                	jne    801146 <fd_alloc+0x36>
			*fd_store = fd;
  80113d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80113f:	b8 00 00 00 00       	mov    $0x0,%eax
  801144:	eb 17                	jmp    80115d <fd_alloc+0x4d>
  801146:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80114b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801150:	75 c9                	jne    80111b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801152:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801158:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801165:	83 f8 1f             	cmp    $0x1f,%eax
  801168:	77 36                	ja     8011a0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80116a:	c1 e0 0c             	shl    $0xc,%eax
  80116d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801172:	89 c2                	mov    %eax,%edx
  801174:	c1 ea 16             	shr    $0x16,%edx
  801177:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117e:	f6 c2 01             	test   $0x1,%dl
  801181:	74 24                	je     8011a7 <fd_lookup+0x48>
  801183:	89 c2                	mov    %eax,%edx
  801185:	c1 ea 0c             	shr    $0xc,%edx
  801188:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118f:	f6 c2 01             	test   $0x1,%dl
  801192:	74 1a                	je     8011ae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801194:	8b 55 0c             	mov    0xc(%ebp),%edx
  801197:	89 02                	mov    %eax,(%edx)
	return 0;
  801199:	b8 00 00 00 00       	mov    $0x0,%eax
  80119e:	eb 13                	jmp    8011b3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a5:	eb 0c                	jmp    8011b3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ac:	eb 05                	jmp    8011b3 <fd_lookup+0x54>
  8011ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 08             	sub    $0x8,%esp
  8011bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011be:	ba 6c 2b 80 00       	mov    $0x802b6c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c3:	eb 13                	jmp    8011d8 <dev_lookup+0x23>
  8011c5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011c8:	39 08                	cmp    %ecx,(%eax)
  8011ca:	75 0c                	jne    8011d8 <dev_lookup+0x23>
			*dev = devtab[i];
  8011cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d6:	eb 2e                	jmp    801206 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d8:	8b 02                	mov    (%edx),%eax
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	75 e7                	jne    8011c5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011de:	a1 20 44 80 00       	mov    0x804420,%eax
  8011e3:	8b 40 48             	mov    0x48(%eax),%eax
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	51                   	push   %ecx
  8011ea:	50                   	push   %eax
  8011eb:	68 ec 2a 80 00       	push   $0x802aec
  8011f0:	e8 08 f2 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  8011f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 10             	sub    $0x10,%esp
  801210:	8b 75 08             	mov    0x8(%ebp),%esi
  801213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801220:	c1 e8 0c             	shr    $0xc,%eax
  801223:	50                   	push   %eax
  801224:	e8 36 ff ff ff       	call   80115f <fd_lookup>
  801229:	83 c4 08             	add    $0x8,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 05                	js     801235 <fd_close+0x2d>
	    || fd != fd2)
  801230:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801233:	74 0c                	je     801241 <fd_close+0x39>
		return (must_exist ? r : 0);
  801235:	84 db                	test   %bl,%bl
  801237:	ba 00 00 00 00       	mov    $0x0,%edx
  80123c:	0f 44 c2             	cmove  %edx,%eax
  80123f:	eb 41                	jmp    801282 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	ff 36                	pushl  (%esi)
  80124a:	e8 66 ff ff ff       	call   8011b5 <dev_lookup>
  80124f:	89 c3                	mov    %eax,%ebx
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 1a                	js     801272 <fd_close+0x6a>
		if (dev->dev_close)
  801258:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80125e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801263:	85 c0                	test   %eax,%eax
  801265:	74 0b                	je     801272 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	56                   	push   %esi
  80126b:	ff d0                	call   *%eax
  80126d:	89 c3                	mov    %eax,%ebx
  80126f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801272:	83 ec 08             	sub    $0x8,%esp
  801275:	56                   	push   %esi
  801276:	6a 00                	push   $0x0
  801278:	e8 8d fb ff ff       	call   800e0a <sys_page_unmap>
	return r;
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	89 d8                	mov    %ebx,%eax
}
  801282:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80128f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801292:	50                   	push   %eax
  801293:	ff 75 08             	pushl  0x8(%ebp)
  801296:	e8 c4 fe ff ff       	call   80115f <fd_lookup>
  80129b:	83 c4 08             	add    $0x8,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 10                	js     8012b2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	6a 01                	push   $0x1
  8012a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012aa:	e8 59 ff ff ff       	call   801208 <fd_close>
  8012af:	83 c4 10             	add    $0x10,%esp
}
  8012b2:	c9                   	leave  
  8012b3:	c3                   	ret    

008012b4 <close_all>:

void
close_all(void)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c0:	83 ec 0c             	sub    $0xc,%esp
  8012c3:	53                   	push   %ebx
  8012c4:	e8 c0 ff ff ff       	call   801289 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c9:	83 c3 01             	add    $0x1,%ebx
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	83 fb 20             	cmp    $0x20,%ebx
  8012d2:	75 ec                	jne    8012c0 <close_all+0xc>
		close(i);
}
  8012d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	57                   	push   %edi
  8012dd:	56                   	push   %esi
  8012de:	53                   	push   %ebx
  8012df:	83 ec 2c             	sub    $0x2c,%esp
  8012e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e8:	50                   	push   %eax
  8012e9:	ff 75 08             	pushl  0x8(%ebp)
  8012ec:	e8 6e fe ff ff       	call   80115f <fd_lookup>
  8012f1:	83 c4 08             	add    $0x8,%esp
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	0f 88 c1 00 00 00    	js     8013bd <dup+0xe4>
		return r;
	close(newfdnum);
  8012fc:	83 ec 0c             	sub    $0xc,%esp
  8012ff:	56                   	push   %esi
  801300:	e8 84 ff ff ff       	call   801289 <close>

	newfd = INDEX2FD(newfdnum);
  801305:	89 f3                	mov    %esi,%ebx
  801307:	c1 e3 0c             	shl    $0xc,%ebx
  80130a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801310:	83 c4 04             	add    $0x4,%esp
  801313:	ff 75 e4             	pushl  -0x1c(%ebp)
  801316:	e8 de fd ff ff       	call   8010f9 <fd2data>
  80131b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80131d:	89 1c 24             	mov    %ebx,(%esp)
  801320:	e8 d4 fd ff ff       	call   8010f9 <fd2data>
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80132b:	89 f8                	mov    %edi,%eax
  80132d:	c1 e8 16             	shr    $0x16,%eax
  801330:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801337:	a8 01                	test   $0x1,%al
  801339:	74 37                	je     801372 <dup+0x99>
  80133b:	89 f8                	mov    %edi,%eax
  80133d:	c1 e8 0c             	shr    $0xc,%eax
  801340:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801347:	f6 c2 01             	test   $0x1,%dl
  80134a:	74 26                	je     801372 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80134c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	25 07 0e 00 00       	and    $0xe07,%eax
  80135b:	50                   	push   %eax
  80135c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80135f:	6a 00                	push   $0x0
  801361:	57                   	push   %edi
  801362:	6a 00                	push   $0x0
  801364:	e8 5f fa ff ff       	call   800dc8 <sys_page_map>
  801369:	89 c7                	mov    %eax,%edi
  80136b:	83 c4 20             	add    $0x20,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 2e                	js     8013a0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801372:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801375:	89 d0                	mov    %edx,%eax
  801377:	c1 e8 0c             	shr    $0xc,%eax
  80137a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801381:	83 ec 0c             	sub    $0xc,%esp
  801384:	25 07 0e 00 00       	and    $0xe07,%eax
  801389:	50                   	push   %eax
  80138a:	53                   	push   %ebx
  80138b:	6a 00                	push   $0x0
  80138d:	52                   	push   %edx
  80138e:	6a 00                	push   $0x0
  801390:	e8 33 fa ff ff       	call   800dc8 <sys_page_map>
  801395:	89 c7                	mov    %eax,%edi
  801397:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80139a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139c:	85 ff                	test   %edi,%edi
  80139e:	79 1d                	jns    8013bd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	53                   	push   %ebx
  8013a4:	6a 00                	push   $0x0
  8013a6:	e8 5f fa ff ff       	call   800e0a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ab:	83 c4 08             	add    $0x8,%esp
  8013ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b1:	6a 00                	push   $0x0
  8013b3:	e8 52 fa ff ff       	call   800e0a <sys_page_unmap>
	return r;
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	89 f8                	mov    %edi,%eax
}
  8013bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5e                   	pop    %esi
  8013c2:	5f                   	pop    %edi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	53                   	push   %ebx
  8013c9:	83 ec 14             	sub    $0x14,%esp
  8013cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d2:	50                   	push   %eax
  8013d3:	53                   	push   %ebx
  8013d4:	e8 86 fd ff ff       	call   80115f <fd_lookup>
  8013d9:	83 c4 08             	add    $0x8,%esp
  8013dc:	89 c2                	mov    %eax,%edx
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 6d                	js     80144f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ec:	ff 30                	pushl  (%eax)
  8013ee:	e8 c2 fd ff ff       	call   8011b5 <dev_lookup>
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 4c                	js     801446 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fd:	8b 42 08             	mov    0x8(%edx),%eax
  801400:	83 e0 03             	and    $0x3,%eax
  801403:	83 f8 01             	cmp    $0x1,%eax
  801406:	75 21                	jne    801429 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801408:	a1 20 44 80 00       	mov    0x804420,%eax
  80140d:	8b 40 48             	mov    0x48(%eax),%eax
  801410:	83 ec 04             	sub    $0x4,%esp
  801413:	53                   	push   %ebx
  801414:	50                   	push   %eax
  801415:	68 30 2b 80 00       	push   $0x802b30
  80141a:	e8 de ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801427:	eb 26                	jmp    80144f <read+0x8a>
	}
	if (!dev->dev_read)
  801429:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142c:	8b 40 08             	mov    0x8(%eax),%eax
  80142f:	85 c0                	test   %eax,%eax
  801431:	74 17                	je     80144a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801433:	83 ec 04             	sub    $0x4,%esp
  801436:	ff 75 10             	pushl  0x10(%ebp)
  801439:	ff 75 0c             	pushl  0xc(%ebp)
  80143c:	52                   	push   %edx
  80143d:	ff d0                	call   *%eax
  80143f:	89 c2                	mov    %eax,%edx
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	eb 09                	jmp    80144f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801446:	89 c2                	mov    %eax,%edx
  801448:	eb 05                	jmp    80144f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80144a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80144f:	89 d0                	mov    %edx,%eax
  801451:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	57                   	push   %edi
  80145a:	56                   	push   %esi
  80145b:	53                   	push   %ebx
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801462:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801465:	bb 00 00 00 00       	mov    $0x0,%ebx
  80146a:	eb 21                	jmp    80148d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	89 f0                	mov    %esi,%eax
  801471:	29 d8                	sub    %ebx,%eax
  801473:	50                   	push   %eax
  801474:	89 d8                	mov    %ebx,%eax
  801476:	03 45 0c             	add    0xc(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	57                   	push   %edi
  80147b:	e8 45 ff ff ff       	call   8013c5 <read>
		if (m < 0)
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 10                	js     801497 <readn+0x41>
			return m;
		if (m == 0)
  801487:	85 c0                	test   %eax,%eax
  801489:	74 0a                	je     801495 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148b:	01 c3                	add    %eax,%ebx
  80148d:	39 f3                	cmp    %esi,%ebx
  80148f:	72 db                	jb     80146c <readn+0x16>
  801491:	89 d8                	mov    %ebx,%eax
  801493:	eb 02                	jmp    801497 <readn+0x41>
  801495:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	53                   	push   %ebx
  8014a3:	83 ec 14             	sub    $0x14,%esp
  8014a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	53                   	push   %ebx
  8014ae:	e8 ac fc ff ff       	call   80115f <fd_lookup>
  8014b3:	83 c4 08             	add    $0x8,%esp
  8014b6:	89 c2                	mov    %eax,%edx
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 68                	js     801524 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c6:	ff 30                	pushl  (%eax)
  8014c8:	e8 e8 fc ff ff       	call   8011b5 <dev_lookup>
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 47                	js     80151b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014db:	75 21                	jne    8014fe <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014dd:	a1 20 44 80 00       	mov    0x804420,%eax
  8014e2:	8b 40 48             	mov    0x48(%eax),%eax
  8014e5:	83 ec 04             	sub    $0x4,%esp
  8014e8:	53                   	push   %ebx
  8014e9:	50                   	push   %eax
  8014ea:	68 4c 2b 80 00       	push   $0x802b4c
  8014ef:	e8 09 ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fc:	eb 26                	jmp    801524 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801501:	8b 52 0c             	mov    0xc(%edx),%edx
  801504:	85 d2                	test   %edx,%edx
  801506:	74 17                	je     80151f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801508:	83 ec 04             	sub    $0x4,%esp
  80150b:	ff 75 10             	pushl  0x10(%ebp)
  80150e:	ff 75 0c             	pushl  0xc(%ebp)
  801511:	50                   	push   %eax
  801512:	ff d2                	call   *%edx
  801514:	89 c2                	mov    %eax,%edx
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	eb 09                	jmp    801524 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	eb 05                	jmp    801524 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80151f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801524:	89 d0                	mov    %edx,%eax
  801526:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <seek>:

int
seek(int fdnum, off_t offset)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801531:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	ff 75 08             	pushl  0x8(%ebp)
  801538:	e8 22 fc ff ff       	call   80115f <fd_lookup>
  80153d:	83 c4 08             	add    $0x8,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 0e                	js     801552 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801544:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801547:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80154d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	53                   	push   %ebx
  801558:	83 ec 14             	sub    $0x14,%esp
  80155b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	53                   	push   %ebx
  801563:	e8 f7 fb ff ff       	call   80115f <fd_lookup>
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	89 c2                	mov    %eax,%edx
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 65                	js     8015d6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801571:	83 ec 08             	sub    $0x8,%esp
  801574:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157b:	ff 30                	pushl  (%eax)
  80157d:	e8 33 fc ff ff       	call   8011b5 <dev_lookup>
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	85 c0                	test   %eax,%eax
  801587:	78 44                	js     8015cd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801589:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801590:	75 21                	jne    8015b3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801592:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801597:	8b 40 48             	mov    0x48(%eax),%eax
  80159a:	83 ec 04             	sub    $0x4,%esp
  80159d:	53                   	push   %ebx
  80159e:	50                   	push   %eax
  80159f:	68 0c 2b 80 00       	push   $0x802b0c
  8015a4:	e8 54 ee ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b1:	eb 23                	jmp    8015d6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b6:	8b 52 18             	mov    0x18(%edx),%edx
  8015b9:	85 d2                	test   %edx,%edx
  8015bb:	74 14                	je     8015d1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	ff 75 0c             	pushl  0xc(%ebp)
  8015c3:	50                   	push   %eax
  8015c4:	ff d2                	call   *%edx
  8015c6:	89 c2                	mov    %eax,%edx
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	eb 09                	jmp    8015d6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cd:	89 c2                	mov    %eax,%edx
  8015cf:	eb 05                	jmp    8015d6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015d6:	89 d0                	mov    %edx,%eax
  8015d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 14             	sub    $0x14,%esp
  8015e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	ff 75 08             	pushl  0x8(%ebp)
  8015ee:	e8 6c fb ff ff       	call   80115f <fd_lookup>
  8015f3:	83 c4 08             	add    $0x8,%esp
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 58                	js     801654 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801606:	ff 30                	pushl  (%eax)
  801608:	e8 a8 fb ff ff       	call   8011b5 <dev_lookup>
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	85 c0                	test   %eax,%eax
  801612:	78 37                	js     80164b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801614:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801617:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80161b:	74 32                	je     80164f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80161d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801620:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801627:	00 00 00 
	stat->st_isdir = 0;
  80162a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801631:	00 00 00 
	stat->st_dev = dev;
  801634:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	53                   	push   %ebx
  80163e:	ff 75 f0             	pushl  -0x10(%ebp)
  801641:	ff 50 14             	call   *0x14(%eax)
  801644:	89 c2                	mov    %eax,%edx
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	eb 09                	jmp    801654 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164b:	89 c2                	mov    %eax,%edx
  80164d:	eb 05                	jmp    801654 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80164f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801654:	89 d0                	mov    %edx,%eax
  801656:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	56                   	push   %esi
  80165f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	6a 00                	push   $0x0
  801665:	ff 75 08             	pushl  0x8(%ebp)
  801668:	e8 d6 01 00 00       	call   801843 <open>
  80166d:	89 c3                	mov    %eax,%ebx
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 1b                	js     801691 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	ff 75 0c             	pushl  0xc(%ebp)
  80167c:	50                   	push   %eax
  80167d:	e8 5b ff ff ff       	call   8015dd <fstat>
  801682:	89 c6                	mov    %eax,%esi
	close(fd);
  801684:	89 1c 24             	mov    %ebx,(%esp)
  801687:	e8 fd fb ff ff       	call   801289 <close>
	return r;
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	89 f0                	mov    %esi,%eax
}
  801691:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801694:	5b                   	pop    %ebx
  801695:	5e                   	pop    %esi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	56                   	push   %esi
  80169c:	53                   	push   %ebx
  80169d:	89 c6                	mov    %eax,%esi
  80169f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a8:	75 12                	jne    8016bc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016aa:	83 ec 0c             	sub    $0xc,%esp
  8016ad:	6a 01                	push   $0x1
  8016af:	e8 44 0d 00 00       	call   8023f8 <ipc_find_env>
  8016b4:	a3 00 40 80 00       	mov    %eax,0x804000
  8016b9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016bc:	6a 07                	push   $0x7
  8016be:	68 00 50 80 00       	push   $0x805000
  8016c3:	56                   	push   %esi
  8016c4:	ff 35 00 40 80 00    	pushl  0x804000
  8016ca:	e8 d5 0c 00 00       	call   8023a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016cf:	83 c4 0c             	add    $0xc,%esp
  8016d2:	6a 00                	push   $0x0
  8016d4:	53                   	push   %ebx
  8016d5:	6a 00                	push   $0x0
  8016d7:	e8 61 0c 00 00       	call   80233d <ipc_recv>
}
  8016dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016df:	5b                   	pop    %ebx
  8016e0:	5e                   	pop    %esi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801701:	b8 02 00 00 00       	mov    $0x2,%eax
  801706:	e8 8d ff ff ff       	call   801698 <fsipc>
}
  80170b:	c9                   	leave  
  80170c:	c3                   	ret    

0080170d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	8b 40 0c             	mov    0xc(%eax),%eax
  801719:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80171e:	ba 00 00 00 00       	mov    $0x0,%edx
  801723:	b8 06 00 00 00       	mov    $0x6,%eax
  801728:	e8 6b ff ff ff       	call   801698 <fsipc>
}
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	53                   	push   %ebx
  801733:	83 ec 04             	sub    $0x4,%esp
  801736:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801739:	8b 45 08             	mov    0x8(%ebp),%eax
  80173c:	8b 40 0c             	mov    0xc(%eax),%eax
  80173f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801744:	ba 00 00 00 00       	mov    $0x0,%edx
  801749:	b8 05 00 00 00       	mov    $0x5,%eax
  80174e:	e8 45 ff ff ff       	call   801698 <fsipc>
  801753:	85 c0                	test   %eax,%eax
  801755:	78 2c                	js     801783 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	68 00 50 80 00       	push   $0x805000
  80175f:	53                   	push   %ebx
  801760:	e8 1d f2 ff ff       	call   800982 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801765:	a1 80 50 80 00       	mov    0x805080,%eax
  80176a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801770:	a1 84 50 80 00       	mov    0x805084,%eax
  801775:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	83 ec 0c             	sub    $0xc,%esp
  80178e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801791:	8b 55 08             	mov    0x8(%ebp),%edx
  801794:	8b 52 0c             	mov    0xc(%edx),%edx
  801797:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80179d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017a2:	50                   	push   %eax
  8017a3:	ff 75 0c             	pushl  0xc(%ebp)
  8017a6:	68 08 50 80 00       	push   $0x805008
  8017ab:	e8 64 f3 ff ff       	call   800b14 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b5:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ba:	e8 d9 fe ff ff       	call   801698 <fsipc>

}
  8017bf:	c9                   	leave  
  8017c0:	c3                   	ret    

008017c1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	56                   	push   %esi
  8017c5:	53                   	push   %ebx
  8017c6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017d4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017da:	ba 00 00 00 00       	mov    $0x0,%edx
  8017df:	b8 03 00 00 00       	mov    $0x3,%eax
  8017e4:	e8 af fe ff ff       	call   801698 <fsipc>
  8017e9:	89 c3                	mov    %eax,%ebx
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 4b                	js     80183a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017ef:	39 c6                	cmp    %eax,%esi
  8017f1:	73 16                	jae    801809 <devfile_read+0x48>
  8017f3:	68 80 2b 80 00       	push   $0x802b80
  8017f8:	68 87 2b 80 00       	push   $0x802b87
  8017fd:	6a 7c                	push   $0x7c
  8017ff:	68 9c 2b 80 00       	push   $0x802b9c
  801804:	e8 1b eb ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  801809:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80180e:	7e 16                	jle    801826 <devfile_read+0x65>
  801810:	68 a7 2b 80 00       	push   $0x802ba7
  801815:	68 87 2b 80 00       	push   $0x802b87
  80181a:	6a 7d                	push   $0x7d
  80181c:	68 9c 2b 80 00       	push   $0x802b9c
  801821:	e8 fe ea ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801826:	83 ec 04             	sub    $0x4,%esp
  801829:	50                   	push   %eax
  80182a:	68 00 50 80 00       	push   $0x805000
  80182f:	ff 75 0c             	pushl  0xc(%ebp)
  801832:	e8 dd f2 ff ff       	call   800b14 <memmove>
	return r;
  801837:	83 c4 10             	add    $0x10,%esp
}
  80183a:	89 d8                	mov    %ebx,%eax
  80183c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	53                   	push   %ebx
  801847:	83 ec 20             	sub    $0x20,%esp
  80184a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80184d:	53                   	push   %ebx
  80184e:	e8 f6 f0 ff ff       	call   800949 <strlen>
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80185b:	7f 67                	jg     8018c4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80185d:	83 ec 0c             	sub    $0xc,%esp
  801860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801863:	50                   	push   %eax
  801864:	e8 a7 f8 ff ff       	call   801110 <fd_alloc>
  801869:	83 c4 10             	add    $0x10,%esp
		return r;
  80186c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 57                	js     8018c9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801872:	83 ec 08             	sub    $0x8,%esp
  801875:	53                   	push   %ebx
  801876:	68 00 50 80 00       	push   $0x805000
  80187b:	e8 02 f1 ff ff       	call   800982 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801880:	8b 45 0c             	mov    0xc(%ebp),%eax
  801883:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801888:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80188b:	b8 01 00 00 00       	mov    $0x1,%eax
  801890:	e8 03 fe ff ff       	call   801698 <fsipc>
  801895:	89 c3                	mov    %eax,%ebx
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	79 14                	jns    8018b2 <open+0x6f>
		fd_close(fd, 0);
  80189e:	83 ec 08             	sub    $0x8,%esp
  8018a1:	6a 00                	push   $0x0
  8018a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a6:	e8 5d f9 ff ff       	call   801208 <fd_close>
		return r;
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	89 da                	mov    %ebx,%edx
  8018b0:	eb 17                	jmp    8018c9 <open+0x86>
	}

	return fd2num(fd);
  8018b2:	83 ec 0c             	sub    $0xc,%esp
  8018b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b8:	e8 2c f8 ff ff       	call   8010e9 <fd2num>
  8018bd:	89 c2                	mov    %eax,%edx
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	eb 05                	jmp    8018c9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018c4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018c9:	89 d0                	mov    %edx,%eax
  8018cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018db:	b8 08 00 00 00       	mov    $0x8,%eax
  8018e0:	e8 b3 fd ff ff       	call   801698 <fsipc>
}
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    

008018e7 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8018e7:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018eb:	7e 37                	jle    801924 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	53                   	push   %ebx
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018f6:	ff 70 04             	pushl  0x4(%eax)
  8018f9:	8d 40 10             	lea    0x10(%eax),%eax
  8018fc:	50                   	push   %eax
  8018fd:	ff 33                	pushl  (%ebx)
  8018ff:	e8 9b fb ff ff       	call   80149f <write>
		if (result > 0)
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	7e 03                	jle    80190e <writebuf+0x27>
			b->result += result;
  80190b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80190e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801911:	74 0d                	je     801920 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801913:	85 c0                	test   %eax,%eax
  801915:	ba 00 00 00 00       	mov    $0x0,%edx
  80191a:	0f 4f c2             	cmovg  %edx,%eax
  80191d:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801920:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801923:	c9                   	leave  
  801924:	f3 c3                	repz ret 

00801926 <putch>:

static void
putch(int ch, void *thunk)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	53                   	push   %ebx
  80192a:	83 ec 04             	sub    $0x4,%esp
  80192d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801930:	8b 53 04             	mov    0x4(%ebx),%edx
  801933:	8d 42 01             	lea    0x1(%edx),%eax
  801936:	89 43 04             	mov    %eax,0x4(%ebx)
  801939:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80193c:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801940:	3d 00 01 00 00       	cmp    $0x100,%eax
  801945:	75 0e                	jne    801955 <putch+0x2f>
		writebuf(b);
  801947:	89 d8                	mov    %ebx,%eax
  801949:	e8 99 ff ff ff       	call   8018e7 <writebuf>
		b->idx = 0;
  80194e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801955:	83 c4 04             	add    $0x4,%esp
  801958:	5b                   	pop    %ebx
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801964:	8b 45 08             	mov    0x8(%ebp),%eax
  801967:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80196d:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801974:	00 00 00 
	b.result = 0;
  801977:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80197e:	00 00 00 
	b.error = 1;
  801981:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801988:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80198b:	ff 75 10             	pushl  0x10(%ebp)
  80198e:	ff 75 0c             	pushl  0xc(%ebp)
  801991:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801997:	50                   	push   %eax
  801998:	68 26 19 80 00       	push   $0x801926
  80199d:	e8 92 eb ff ff       	call   800534 <vprintfmt>
	if (b.idx > 0)
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019ac:	7e 0b                	jle    8019b9 <vfprintf+0x5e>
		writebuf(&b);
  8019ae:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019b4:	e8 2e ff ff ff       	call   8018e7 <writebuf>

	return (b.result ? b.result : b.error);
  8019b9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019d0:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8019d3:	50                   	push   %eax
  8019d4:	ff 75 0c             	pushl  0xc(%ebp)
  8019d7:	ff 75 08             	pushl  0x8(%ebp)
  8019da:	e8 7c ff ff ff       	call   80195b <vfprintf>
	va_end(ap);

	return cnt;
}
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    

008019e1 <printf>:

int
printf(const char *fmt, ...)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019e7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019ea:	50                   	push   %eax
  8019eb:	ff 75 08             	pushl  0x8(%ebp)
  8019ee:	6a 01                	push   $0x1
  8019f0:	e8 66 ff ff ff       	call   80195b <vfprintf>
	va_end(ap);

	return cnt;
}
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019fd:	68 b3 2b 80 00       	push   $0x802bb3
  801a02:	ff 75 0c             	pushl  0xc(%ebp)
  801a05:	e8 78 ef ff ff       	call   800982 <strcpy>
	return 0;
}
  801a0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	53                   	push   %ebx
  801a15:	83 ec 10             	sub    $0x10,%esp
  801a18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a1b:	53                   	push   %ebx
  801a1c:	e8 10 0a 00 00       	call   802431 <pageref>
  801a21:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a24:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a29:	83 f8 01             	cmp    $0x1,%eax
  801a2c:	75 10                	jne    801a3e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	ff 73 0c             	pushl  0xc(%ebx)
  801a34:	e8 c0 02 00 00       	call   801cf9 <nsipc_close>
  801a39:	89 c2                	mov    %eax,%edx
  801a3b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a3e:	89 d0                	mov    %edx,%eax
  801a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a4b:	6a 00                	push   $0x0
  801a4d:	ff 75 10             	pushl  0x10(%ebp)
  801a50:	ff 75 0c             	pushl  0xc(%ebp)
  801a53:	8b 45 08             	mov    0x8(%ebp),%eax
  801a56:	ff 70 0c             	pushl  0xc(%eax)
  801a59:	e8 78 03 00 00       	call   801dd6 <nsipc_send>
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a66:	6a 00                	push   $0x0
  801a68:	ff 75 10             	pushl  0x10(%ebp)
  801a6b:	ff 75 0c             	pushl  0xc(%ebp)
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	ff 70 0c             	pushl  0xc(%eax)
  801a74:	e8 f1 02 00 00       	call   801d6a <nsipc_recv>
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a81:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a84:	52                   	push   %edx
  801a85:	50                   	push   %eax
  801a86:	e8 d4 f6 ff ff       	call   80115f <fd_lookup>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 17                	js     801aa9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a95:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a9b:	39 08                	cmp    %ecx,(%eax)
  801a9d:	75 05                	jne    801aa4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a9f:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa2:	eb 05                	jmp    801aa9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801aa4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801aa9:	c9                   	leave  
  801aaa:	c3                   	ret    

00801aab <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	56                   	push   %esi
  801aaf:	53                   	push   %ebx
  801ab0:	83 ec 1c             	sub    $0x1c,%esp
  801ab3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ab5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	e8 52 f6 ff ff       	call   801110 <fd_alloc>
  801abe:	89 c3                	mov    %eax,%ebx
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 1b                	js     801ae2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ac7:	83 ec 04             	sub    $0x4,%esp
  801aca:	68 07 04 00 00       	push   $0x407
  801acf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad2:	6a 00                	push   $0x0
  801ad4:	e8 ac f2 ff ff       	call   800d85 <sys_page_alloc>
  801ad9:	89 c3                	mov    %eax,%ebx
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	79 10                	jns    801af2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	56                   	push   %esi
  801ae6:	e8 0e 02 00 00       	call   801cf9 <nsipc_close>
		return r;
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	89 d8                	mov    %ebx,%eax
  801af0:	eb 24                	jmp    801b16 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801af2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b07:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	50                   	push   %eax
  801b0e:	e8 d6 f5 ff ff       	call   8010e9 <fd2num>
  801b13:	83 c4 10             	add    $0x10,%esp
}
  801b16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	e8 50 ff ff ff       	call   801a7b <fd2sockid>
		return r;
  801b2b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 1f                	js     801b50 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b31:	83 ec 04             	sub    $0x4,%esp
  801b34:	ff 75 10             	pushl  0x10(%ebp)
  801b37:	ff 75 0c             	pushl  0xc(%ebp)
  801b3a:	50                   	push   %eax
  801b3b:	e8 12 01 00 00       	call   801c52 <nsipc_accept>
  801b40:	83 c4 10             	add    $0x10,%esp
		return r;
  801b43:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 07                	js     801b50 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b49:	e8 5d ff ff ff       	call   801aab <alloc_sockfd>
  801b4e:	89 c1                	mov    %eax,%ecx
}
  801b50:	89 c8                	mov    %ecx,%eax
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	e8 19 ff ff ff       	call   801a7b <fd2sockid>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 12                	js     801b78 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b66:	83 ec 04             	sub    $0x4,%esp
  801b69:	ff 75 10             	pushl  0x10(%ebp)
  801b6c:	ff 75 0c             	pushl  0xc(%ebp)
  801b6f:	50                   	push   %eax
  801b70:	e8 2d 01 00 00       	call   801ca2 <nsipc_bind>
  801b75:	83 c4 10             	add    $0x10,%esp
}
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <shutdown>:

int
shutdown(int s, int how)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b80:	8b 45 08             	mov    0x8(%ebp),%eax
  801b83:	e8 f3 fe ff ff       	call   801a7b <fd2sockid>
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 0f                	js     801b9b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	ff 75 0c             	pushl  0xc(%ebp)
  801b92:	50                   	push   %eax
  801b93:	e8 3f 01 00 00       	call   801cd7 <nsipc_shutdown>
  801b98:	83 c4 10             	add    $0x10,%esp
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba6:	e8 d0 fe ff ff       	call   801a7b <fd2sockid>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	78 12                	js     801bc1 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801baf:	83 ec 04             	sub    $0x4,%esp
  801bb2:	ff 75 10             	pushl  0x10(%ebp)
  801bb5:	ff 75 0c             	pushl  0xc(%ebp)
  801bb8:	50                   	push   %eax
  801bb9:	e8 55 01 00 00       	call   801d13 <nsipc_connect>
  801bbe:	83 c4 10             	add    $0x10,%esp
}
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <listen>:

int
listen(int s, int backlog)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	e8 aa fe ff ff       	call   801a7b <fd2sockid>
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	78 0f                	js     801be4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	ff 75 0c             	pushl  0xc(%ebp)
  801bdb:	50                   	push   %eax
  801bdc:	e8 67 01 00 00       	call   801d48 <nsipc_listen>
  801be1:	83 c4 10             	add    $0x10,%esp
}
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bec:	ff 75 10             	pushl  0x10(%ebp)
  801bef:	ff 75 0c             	pushl  0xc(%ebp)
  801bf2:	ff 75 08             	pushl  0x8(%ebp)
  801bf5:	e8 3a 02 00 00       	call   801e34 <nsipc_socket>
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	78 05                	js     801c06 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c01:	e8 a5 fe ff ff       	call   801aab <alloc_sockfd>
}
  801c06:	c9                   	leave  
  801c07:	c3                   	ret    

00801c08 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c11:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c18:	75 12                	jne    801c2c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c1a:	83 ec 0c             	sub    $0xc,%esp
  801c1d:	6a 02                	push   $0x2
  801c1f:	e8 d4 07 00 00       	call   8023f8 <ipc_find_env>
  801c24:	a3 04 40 80 00       	mov    %eax,0x804004
  801c29:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c2c:	6a 07                	push   $0x7
  801c2e:	68 00 60 80 00       	push   $0x806000
  801c33:	53                   	push   %ebx
  801c34:	ff 35 04 40 80 00    	pushl  0x804004
  801c3a:	e8 65 07 00 00       	call   8023a4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c3f:	83 c4 0c             	add    $0xc,%esp
  801c42:	6a 00                	push   $0x0
  801c44:	6a 00                	push   $0x0
  801c46:	6a 00                	push   $0x0
  801c48:	e8 f0 06 00 00       	call   80233d <ipc_recv>
}
  801c4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	56                   	push   %esi
  801c56:	53                   	push   %ebx
  801c57:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c62:	8b 06                	mov    (%esi),%eax
  801c64:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c69:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6e:	e8 95 ff ff ff       	call   801c08 <nsipc>
  801c73:	89 c3                	mov    %eax,%ebx
  801c75:	85 c0                	test   %eax,%eax
  801c77:	78 20                	js     801c99 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c79:	83 ec 04             	sub    $0x4,%esp
  801c7c:	ff 35 10 60 80 00    	pushl  0x806010
  801c82:	68 00 60 80 00       	push   $0x806000
  801c87:	ff 75 0c             	pushl  0xc(%ebp)
  801c8a:	e8 85 ee ff ff       	call   800b14 <memmove>
		*addrlen = ret->ret_addrlen;
  801c8f:	a1 10 60 80 00       	mov    0x806010,%eax
  801c94:	89 06                	mov    %eax,(%esi)
  801c96:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c99:	89 d8                	mov    %ebx,%eax
  801c9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9e:	5b                   	pop    %ebx
  801c9f:	5e                   	pop    %esi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 08             	sub    $0x8,%esp
  801ca9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cac:	8b 45 08             	mov    0x8(%ebp),%eax
  801caf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cb4:	53                   	push   %ebx
  801cb5:	ff 75 0c             	pushl  0xc(%ebp)
  801cb8:	68 04 60 80 00       	push   $0x806004
  801cbd:	e8 52 ee ff ff       	call   800b14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cc2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cc8:	b8 02 00 00 00       	mov    $0x2,%eax
  801ccd:	e8 36 ff ff ff       	call   801c08 <nsipc>
}
  801cd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd5:	c9                   	leave  
  801cd6:	c3                   	ret    

00801cd7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ced:	b8 03 00 00 00       	mov    $0x3,%eax
  801cf2:	e8 11 ff ff ff       	call   801c08 <nsipc>
}
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    

00801cf9 <nsipc_close>:

int
nsipc_close(int s)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d07:	b8 04 00 00 00       	mov    $0x4,%eax
  801d0c:	e8 f7 fe ff ff       	call   801c08 <nsipc>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 08             	sub    $0x8,%esp
  801d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d25:	53                   	push   %ebx
  801d26:	ff 75 0c             	pushl  0xc(%ebp)
  801d29:	68 04 60 80 00       	push   $0x806004
  801d2e:	e8 e1 ed ff ff       	call   800b14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d33:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d39:	b8 05 00 00 00       	mov    $0x5,%eax
  801d3e:	e8 c5 fe ff ff       	call   801c08 <nsipc>
}
  801d43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d51:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d59:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d5e:	b8 06 00 00 00       	mov    $0x6,%eax
  801d63:	e8 a0 fe ff ff       	call   801c08 <nsipc>
}
  801d68:	c9                   	leave  
  801d69:	c3                   	ret    

00801d6a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	56                   	push   %esi
  801d6e:	53                   	push   %ebx
  801d6f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d72:	8b 45 08             	mov    0x8(%ebp),%eax
  801d75:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d7a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d80:	8b 45 14             	mov    0x14(%ebp),%eax
  801d83:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d88:	b8 07 00 00 00       	mov    $0x7,%eax
  801d8d:	e8 76 fe ff ff       	call   801c08 <nsipc>
  801d92:	89 c3                	mov    %eax,%ebx
  801d94:	85 c0                	test   %eax,%eax
  801d96:	78 35                	js     801dcd <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d98:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d9d:	7f 04                	jg     801da3 <nsipc_recv+0x39>
  801d9f:	39 c6                	cmp    %eax,%esi
  801da1:	7d 16                	jge    801db9 <nsipc_recv+0x4f>
  801da3:	68 bf 2b 80 00       	push   $0x802bbf
  801da8:	68 87 2b 80 00       	push   $0x802b87
  801dad:	6a 62                	push   $0x62
  801daf:	68 d4 2b 80 00       	push   $0x802bd4
  801db4:	e8 6b e5 ff ff       	call   800324 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801db9:	83 ec 04             	sub    $0x4,%esp
  801dbc:	50                   	push   %eax
  801dbd:	68 00 60 80 00       	push   $0x806000
  801dc2:	ff 75 0c             	pushl  0xc(%ebp)
  801dc5:	e8 4a ed ff ff       	call   800b14 <memmove>
  801dca:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dcd:	89 d8                	mov    %ebx,%eax
  801dcf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	53                   	push   %ebx
  801dda:	83 ec 04             	sub    $0x4,%esp
  801ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801de0:	8b 45 08             	mov    0x8(%ebp),%eax
  801de3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801de8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dee:	7e 16                	jle    801e06 <nsipc_send+0x30>
  801df0:	68 e0 2b 80 00       	push   $0x802be0
  801df5:	68 87 2b 80 00       	push   $0x802b87
  801dfa:	6a 6d                	push   $0x6d
  801dfc:	68 d4 2b 80 00       	push   $0x802bd4
  801e01:	e8 1e e5 ff ff       	call   800324 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e06:	83 ec 04             	sub    $0x4,%esp
  801e09:	53                   	push   %ebx
  801e0a:	ff 75 0c             	pushl  0xc(%ebp)
  801e0d:	68 0c 60 80 00       	push   $0x80600c
  801e12:	e8 fd ec ff ff       	call   800b14 <memmove>
	nsipcbuf.send.req_size = size;
  801e17:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e1d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e20:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e25:	b8 08 00 00 00       	mov    $0x8,%eax
  801e2a:	e8 d9 fd ff ff       	call   801c08 <nsipc>
}
  801e2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e32:	c9                   	leave  
  801e33:	c3                   	ret    

00801e34 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e45:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e4d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e52:	b8 09 00 00 00       	mov    $0x9,%eax
  801e57:	e8 ac fd ff ff       	call   801c08 <nsipc>
}
  801e5c:	c9                   	leave  
  801e5d:	c3                   	ret    

00801e5e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	56                   	push   %esi
  801e62:	53                   	push   %ebx
  801e63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	ff 75 08             	pushl  0x8(%ebp)
  801e6c:	e8 88 f2 ff ff       	call   8010f9 <fd2data>
  801e71:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e73:	83 c4 08             	add    $0x8,%esp
  801e76:	68 ec 2b 80 00       	push   $0x802bec
  801e7b:	53                   	push   %ebx
  801e7c:	e8 01 eb ff ff       	call   800982 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e81:	8b 46 04             	mov    0x4(%esi),%eax
  801e84:	2b 06                	sub    (%esi),%eax
  801e86:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e8c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e93:	00 00 00 
	stat->st_dev = &devpipe;
  801e96:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e9d:	30 80 00 
	return 0;
}
  801ea0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    

00801eac <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	53                   	push   %ebx
  801eb0:	83 ec 0c             	sub    $0xc,%esp
  801eb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eb6:	53                   	push   %ebx
  801eb7:	6a 00                	push   $0x0
  801eb9:	e8 4c ef ff ff       	call   800e0a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ebe:	89 1c 24             	mov    %ebx,(%esp)
  801ec1:	e8 33 f2 ff ff       	call   8010f9 <fd2data>
  801ec6:	83 c4 08             	add    $0x8,%esp
  801ec9:	50                   	push   %eax
  801eca:	6a 00                	push   $0x0
  801ecc:	e8 39 ef ff ff       	call   800e0a <sys_page_unmap>
}
  801ed1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    

00801ed6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	57                   	push   %edi
  801eda:	56                   	push   %esi
  801edb:	53                   	push   %ebx
  801edc:	83 ec 1c             	sub    $0x1c,%esp
  801edf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ee2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ee4:	a1 20 44 80 00       	mov    0x804420,%eax
  801ee9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801eec:	83 ec 0c             	sub    $0xc,%esp
  801eef:	ff 75 e0             	pushl  -0x20(%ebp)
  801ef2:	e8 3a 05 00 00       	call   802431 <pageref>
  801ef7:	89 c3                	mov    %eax,%ebx
  801ef9:	89 3c 24             	mov    %edi,(%esp)
  801efc:	e8 30 05 00 00       	call   802431 <pageref>
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	39 c3                	cmp    %eax,%ebx
  801f06:	0f 94 c1             	sete   %cl
  801f09:	0f b6 c9             	movzbl %cl,%ecx
  801f0c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f0f:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801f15:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f18:	39 ce                	cmp    %ecx,%esi
  801f1a:	74 1b                	je     801f37 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f1c:	39 c3                	cmp    %eax,%ebx
  801f1e:	75 c4                	jne    801ee4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f20:	8b 42 58             	mov    0x58(%edx),%eax
  801f23:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f26:	50                   	push   %eax
  801f27:	56                   	push   %esi
  801f28:	68 f3 2b 80 00       	push   $0x802bf3
  801f2d:	e8 cb e4 ff ff       	call   8003fd <cprintf>
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	eb ad                	jmp    801ee4 <_pipeisclosed+0xe>
	}
}
  801f37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5e                   	pop    %esi
  801f3f:	5f                   	pop    %edi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	57                   	push   %edi
  801f46:	56                   	push   %esi
  801f47:	53                   	push   %ebx
  801f48:	83 ec 28             	sub    $0x28,%esp
  801f4b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f4e:	56                   	push   %esi
  801f4f:	e8 a5 f1 ff ff       	call   8010f9 <fd2data>
  801f54:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	bf 00 00 00 00       	mov    $0x0,%edi
  801f5e:	eb 4b                	jmp    801fab <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f60:	89 da                	mov    %ebx,%edx
  801f62:	89 f0                	mov    %esi,%eax
  801f64:	e8 6d ff ff ff       	call   801ed6 <_pipeisclosed>
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	75 48                	jne    801fb5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f6d:	e8 f4 ed ff ff       	call   800d66 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f72:	8b 43 04             	mov    0x4(%ebx),%eax
  801f75:	8b 0b                	mov    (%ebx),%ecx
  801f77:	8d 51 20             	lea    0x20(%ecx),%edx
  801f7a:	39 d0                	cmp    %edx,%eax
  801f7c:	73 e2                	jae    801f60 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f81:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f85:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f88:	89 c2                	mov    %eax,%edx
  801f8a:	c1 fa 1f             	sar    $0x1f,%edx
  801f8d:	89 d1                	mov    %edx,%ecx
  801f8f:	c1 e9 1b             	shr    $0x1b,%ecx
  801f92:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f95:	83 e2 1f             	and    $0x1f,%edx
  801f98:	29 ca                	sub    %ecx,%edx
  801f9a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f9e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fa2:	83 c0 01             	add    $0x1,%eax
  801fa5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa8:	83 c7 01             	add    $0x1,%edi
  801fab:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fae:	75 c2                	jne    801f72 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb3:	eb 05                	jmp    801fba <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fb5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fbd:	5b                   	pop    %ebx
  801fbe:	5e                   	pop    %esi
  801fbf:	5f                   	pop    %edi
  801fc0:	5d                   	pop    %ebp
  801fc1:	c3                   	ret    

00801fc2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fc2:	55                   	push   %ebp
  801fc3:	89 e5                	mov    %esp,%ebp
  801fc5:	57                   	push   %edi
  801fc6:	56                   	push   %esi
  801fc7:	53                   	push   %ebx
  801fc8:	83 ec 18             	sub    $0x18,%esp
  801fcb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fce:	57                   	push   %edi
  801fcf:	e8 25 f1 ff ff       	call   8010f9 <fd2data>
  801fd4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fde:	eb 3d                	jmp    80201d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fe0:	85 db                	test   %ebx,%ebx
  801fe2:	74 04                	je     801fe8 <devpipe_read+0x26>
				return i;
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	eb 44                	jmp    80202c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fe8:	89 f2                	mov    %esi,%edx
  801fea:	89 f8                	mov    %edi,%eax
  801fec:	e8 e5 fe ff ff       	call   801ed6 <_pipeisclosed>
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	75 32                	jne    802027 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ff5:	e8 6c ed ff ff       	call   800d66 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ffa:	8b 06                	mov    (%esi),%eax
  801ffc:	3b 46 04             	cmp    0x4(%esi),%eax
  801fff:	74 df                	je     801fe0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802001:	99                   	cltd   
  802002:	c1 ea 1b             	shr    $0x1b,%edx
  802005:	01 d0                	add    %edx,%eax
  802007:	83 e0 1f             	and    $0x1f,%eax
  80200a:	29 d0                	sub    %edx,%eax
  80200c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802011:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802014:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802017:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80201a:	83 c3 01             	add    $0x1,%ebx
  80201d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802020:	75 d8                	jne    801ffa <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802022:	8b 45 10             	mov    0x10(%ebp),%eax
  802025:	eb 05                	jmp    80202c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802027:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80202c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	56                   	push   %esi
  802038:	53                   	push   %ebx
  802039:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80203c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203f:	50                   	push   %eax
  802040:	e8 cb f0 ff ff       	call   801110 <fd_alloc>
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	89 c2                	mov    %eax,%edx
  80204a:	85 c0                	test   %eax,%eax
  80204c:	0f 88 2c 01 00 00    	js     80217e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802052:	83 ec 04             	sub    $0x4,%esp
  802055:	68 07 04 00 00       	push   $0x407
  80205a:	ff 75 f4             	pushl  -0xc(%ebp)
  80205d:	6a 00                	push   $0x0
  80205f:	e8 21 ed ff ff       	call   800d85 <sys_page_alloc>
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	89 c2                	mov    %eax,%edx
  802069:	85 c0                	test   %eax,%eax
  80206b:	0f 88 0d 01 00 00    	js     80217e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802071:	83 ec 0c             	sub    $0xc,%esp
  802074:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802077:	50                   	push   %eax
  802078:	e8 93 f0 ff ff       	call   801110 <fd_alloc>
  80207d:	89 c3                	mov    %eax,%ebx
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	85 c0                	test   %eax,%eax
  802084:	0f 88 e2 00 00 00    	js     80216c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80208a:	83 ec 04             	sub    $0x4,%esp
  80208d:	68 07 04 00 00       	push   $0x407
  802092:	ff 75 f0             	pushl  -0x10(%ebp)
  802095:	6a 00                	push   $0x0
  802097:	e8 e9 ec ff ff       	call   800d85 <sys_page_alloc>
  80209c:	89 c3                	mov    %eax,%ebx
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	0f 88 c3 00 00 00    	js     80216c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020a9:	83 ec 0c             	sub    $0xc,%esp
  8020ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8020af:	e8 45 f0 ff ff       	call   8010f9 <fd2data>
  8020b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b6:	83 c4 0c             	add    $0xc,%esp
  8020b9:	68 07 04 00 00       	push   $0x407
  8020be:	50                   	push   %eax
  8020bf:	6a 00                	push   $0x0
  8020c1:	e8 bf ec ff ff       	call   800d85 <sys_page_alloc>
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	0f 88 89 00 00 00    	js     80215c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d3:	83 ec 0c             	sub    $0xc,%esp
  8020d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d9:	e8 1b f0 ff ff       	call   8010f9 <fd2data>
  8020de:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020e5:	50                   	push   %eax
  8020e6:	6a 00                	push   $0x0
  8020e8:	56                   	push   %esi
  8020e9:	6a 00                	push   $0x0
  8020eb:	e8 d8 ec ff ff       	call   800dc8 <sys_page_map>
  8020f0:	89 c3                	mov    %eax,%ebx
  8020f2:	83 c4 20             	add    $0x20,%esp
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	78 55                	js     80214e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020f9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802102:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802104:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802107:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80210e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802114:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802117:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802119:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80211c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802123:	83 ec 0c             	sub    $0xc,%esp
  802126:	ff 75 f4             	pushl  -0xc(%ebp)
  802129:	e8 bb ef ff ff       	call   8010e9 <fd2num>
  80212e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802131:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802133:	83 c4 04             	add    $0x4,%esp
  802136:	ff 75 f0             	pushl  -0x10(%ebp)
  802139:	e8 ab ef ff ff       	call   8010e9 <fd2num>
  80213e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802141:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802144:	83 c4 10             	add    $0x10,%esp
  802147:	ba 00 00 00 00       	mov    $0x0,%edx
  80214c:	eb 30                	jmp    80217e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80214e:	83 ec 08             	sub    $0x8,%esp
  802151:	56                   	push   %esi
  802152:	6a 00                	push   $0x0
  802154:	e8 b1 ec ff ff       	call   800e0a <sys_page_unmap>
  802159:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80215c:	83 ec 08             	sub    $0x8,%esp
  80215f:	ff 75 f0             	pushl  -0x10(%ebp)
  802162:	6a 00                	push   $0x0
  802164:	e8 a1 ec ff ff       	call   800e0a <sys_page_unmap>
  802169:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80216c:	83 ec 08             	sub    $0x8,%esp
  80216f:	ff 75 f4             	pushl  -0xc(%ebp)
  802172:	6a 00                	push   $0x0
  802174:	e8 91 ec ff ff       	call   800e0a <sys_page_unmap>
  802179:	83 c4 10             	add    $0x10,%esp
  80217c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80217e:	89 d0                	mov    %edx,%eax
  802180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5d                   	pop    %ebp
  802186:	c3                   	ret    

00802187 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802187:	55                   	push   %ebp
  802188:	89 e5                	mov    %esp,%ebp
  80218a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80218d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802190:	50                   	push   %eax
  802191:	ff 75 08             	pushl  0x8(%ebp)
  802194:	e8 c6 ef ff ff       	call   80115f <fd_lookup>
  802199:	83 c4 10             	add    $0x10,%esp
  80219c:	85 c0                	test   %eax,%eax
  80219e:	78 18                	js     8021b8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021a0:	83 ec 0c             	sub    $0xc,%esp
  8021a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a6:	e8 4e ef ff ff       	call   8010f9 <fd2data>
	return _pipeisclosed(fd, p);
  8021ab:	89 c2                	mov    %eax,%edx
  8021ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b0:	e8 21 fd ff ff       	call   801ed6 <_pipeisclosed>
  8021b5:	83 c4 10             	add    $0x10,%esp
}
  8021b8:	c9                   	leave  
  8021b9:	c3                   	ret    

008021ba <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    

008021c4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021ca:	68 0b 2c 80 00       	push   $0x802c0b
  8021cf:	ff 75 0c             	pushl  0xc(%ebp)
  8021d2:	e8 ab e7 ff ff       	call   800982 <strcpy>
	return 0;
}
  8021d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8021dc:	c9                   	leave  
  8021dd:	c3                   	ret    

008021de <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ea:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ef:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021f5:	eb 2d                	jmp    802224 <devcons_write+0x46>
		m = n - tot;
  8021f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021fa:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021fc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021ff:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802204:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802207:	83 ec 04             	sub    $0x4,%esp
  80220a:	53                   	push   %ebx
  80220b:	03 45 0c             	add    0xc(%ebp),%eax
  80220e:	50                   	push   %eax
  80220f:	57                   	push   %edi
  802210:	e8 ff e8 ff ff       	call   800b14 <memmove>
		sys_cputs(buf, m);
  802215:	83 c4 08             	add    $0x8,%esp
  802218:	53                   	push   %ebx
  802219:	57                   	push   %edi
  80221a:	e8 aa ea ff ff       	call   800cc9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80221f:	01 de                	add    %ebx,%esi
  802221:	83 c4 10             	add    $0x10,%esp
  802224:	89 f0                	mov    %esi,%eax
  802226:	3b 75 10             	cmp    0x10(%ebp),%esi
  802229:	72 cc                	jb     8021f7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80222b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80222e:	5b                   	pop    %ebx
  80222f:	5e                   	pop    %esi
  802230:	5f                   	pop    %edi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    

00802233 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
  802236:	83 ec 08             	sub    $0x8,%esp
  802239:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80223e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802242:	74 2a                	je     80226e <devcons_read+0x3b>
  802244:	eb 05                	jmp    80224b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802246:	e8 1b eb ff ff       	call   800d66 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80224b:	e8 97 ea ff ff       	call   800ce7 <sys_cgetc>
  802250:	85 c0                	test   %eax,%eax
  802252:	74 f2                	je     802246 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802254:	85 c0                	test   %eax,%eax
  802256:	78 16                	js     80226e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802258:	83 f8 04             	cmp    $0x4,%eax
  80225b:	74 0c                	je     802269 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80225d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802260:	88 02                	mov    %al,(%edx)
	return 1;
  802262:	b8 01 00 00 00       	mov    $0x1,%eax
  802267:	eb 05                	jmp    80226e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80226e:	c9                   	leave  
  80226f:	c3                   	ret    

00802270 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802276:	8b 45 08             	mov    0x8(%ebp),%eax
  802279:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80227c:	6a 01                	push   $0x1
  80227e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802281:	50                   	push   %eax
  802282:	e8 42 ea ff ff       	call   800cc9 <sys_cputs>
}
  802287:	83 c4 10             	add    $0x10,%esp
  80228a:	c9                   	leave  
  80228b:	c3                   	ret    

0080228c <getchar>:

int
getchar(void)
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802292:	6a 01                	push   $0x1
  802294:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802297:	50                   	push   %eax
  802298:	6a 00                	push   $0x0
  80229a:	e8 26 f1 ff ff       	call   8013c5 <read>
	if (r < 0)
  80229f:	83 c4 10             	add    $0x10,%esp
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	78 0f                	js     8022b5 <getchar+0x29>
		return r;
	if (r < 1)
  8022a6:	85 c0                	test   %eax,%eax
  8022a8:	7e 06                	jle    8022b0 <getchar+0x24>
		return -E_EOF;
	return c;
  8022aa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022ae:	eb 05                	jmp    8022b5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022b0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022b5:	c9                   	leave  
  8022b6:	c3                   	ret    

008022b7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c0:	50                   	push   %eax
  8022c1:	ff 75 08             	pushl  0x8(%ebp)
  8022c4:	e8 96 ee ff ff       	call   80115f <fd_lookup>
  8022c9:	83 c4 10             	add    $0x10,%esp
  8022cc:	85 c0                	test   %eax,%eax
  8022ce:	78 11                	js     8022e1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022d9:	39 10                	cmp    %edx,(%eax)
  8022db:	0f 94 c0             	sete   %al
  8022de:	0f b6 c0             	movzbl %al,%eax
}
  8022e1:	c9                   	leave  
  8022e2:	c3                   	ret    

008022e3 <opencons>:

int
opencons(void)
{
  8022e3:	55                   	push   %ebp
  8022e4:	89 e5                	mov    %esp,%ebp
  8022e6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ec:	50                   	push   %eax
  8022ed:	e8 1e ee ff ff       	call   801110 <fd_alloc>
  8022f2:	83 c4 10             	add    $0x10,%esp
		return r;
  8022f5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	78 3e                	js     802339 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022fb:	83 ec 04             	sub    $0x4,%esp
  8022fe:	68 07 04 00 00       	push   $0x407
  802303:	ff 75 f4             	pushl  -0xc(%ebp)
  802306:	6a 00                	push   $0x0
  802308:	e8 78 ea ff ff       	call   800d85 <sys_page_alloc>
  80230d:	83 c4 10             	add    $0x10,%esp
		return r;
  802310:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802312:	85 c0                	test   %eax,%eax
  802314:	78 23                	js     802339 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802316:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80231c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802321:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802324:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80232b:	83 ec 0c             	sub    $0xc,%esp
  80232e:	50                   	push   %eax
  80232f:	e8 b5 ed ff ff       	call   8010e9 <fd2num>
  802334:	89 c2                	mov    %eax,%edx
  802336:	83 c4 10             	add    $0x10,%esp
}
  802339:	89 d0                	mov    %edx,%eax
  80233b:	c9                   	leave  
  80233c:	c3                   	ret    

0080233d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	56                   	push   %esi
  802341:	53                   	push   %ebx
  802342:	8b 75 08             	mov    0x8(%ebp),%esi
  802345:	8b 45 0c             	mov    0xc(%ebp),%eax
  802348:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80234b:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80234d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802352:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802355:	83 ec 0c             	sub    $0xc,%esp
  802358:	50                   	push   %eax
  802359:	e8 d7 eb ff ff       	call   800f35 <sys_ipc_recv>

	if (from_env_store != NULL)
  80235e:	83 c4 10             	add    $0x10,%esp
  802361:	85 f6                	test   %esi,%esi
  802363:	74 14                	je     802379 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802365:	ba 00 00 00 00       	mov    $0x0,%edx
  80236a:	85 c0                	test   %eax,%eax
  80236c:	78 09                	js     802377 <ipc_recv+0x3a>
  80236e:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802374:	8b 52 74             	mov    0x74(%edx),%edx
  802377:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802379:	85 db                	test   %ebx,%ebx
  80237b:	74 14                	je     802391 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80237d:	ba 00 00 00 00       	mov    $0x0,%edx
  802382:	85 c0                	test   %eax,%eax
  802384:	78 09                	js     80238f <ipc_recv+0x52>
  802386:	8b 15 20 44 80 00    	mov    0x804420,%edx
  80238c:	8b 52 78             	mov    0x78(%edx),%edx
  80238f:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802391:	85 c0                	test   %eax,%eax
  802393:	78 08                	js     80239d <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802395:	a1 20 44 80 00       	mov    0x804420,%eax
  80239a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80239d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a0:	5b                   	pop    %ebx
  8023a1:	5e                   	pop    %esi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    

008023a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	57                   	push   %edi
  8023a8:	56                   	push   %esi
  8023a9:	53                   	push   %ebx
  8023aa:	83 ec 0c             	sub    $0xc,%esp
  8023ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8023b6:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8023b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023bd:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8023c0:	ff 75 14             	pushl  0x14(%ebp)
  8023c3:	53                   	push   %ebx
  8023c4:	56                   	push   %esi
  8023c5:	57                   	push   %edi
  8023c6:	e8 47 eb ff ff       	call   800f12 <sys_ipc_try_send>

		if (err < 0) {
  8023cb:	83 c4 10             	add    $0x10,%esp
  8023ce:	85 c0                	test   %eax,%eax
  8023d0:	79 1e                	jns    8023f0 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8023d2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023d5:	75 07                	jne    8023de <ipc_send+0x3a>
				sys_yield();
  8023d7:	e8 8a e9 ff ff       	call   800d66 <sys_yield>
  8023dc:	eb e2                	jmp    8023c0 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8023de:	50                   	push   %eax
  8023df:	68 17 2c 80 00       	push   $0x802c17
  8023e4:	6a 49                	push   $0x49
  8023e6:	68 24 2c 80 00       	push   $0x802c24
  8023eb:	e8 34 df ff ff       	call   800324 <_panic>
		}

	} while (err < 0);

}
  8023f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023f3:	5b                   	pop    %ebx
  8023f4:	5e                   	pop    %esi
  8023f5:	5f                   	pop    %edi
  8023f6:	5d                   	pop    %ebp
  8023f7:	c3                   	ret    

008023f8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023f8:	55                   	push   %ebp
  8023f9:	89 e5                	mov    %esp,%ebp
  8023fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023fe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802403:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802406:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80240c:	8b 52 50             	mov    0x50(%edx),%edx
  80240f:	39 ca                	cmp    %ecx,%edx
  802411:	75 0d                	jne    802420 <ipc_find_env+0x28>
			return envs[i].env_id;
  802413:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802416:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80241b:	8b 40 48             	mov    0x48(%eax),%eax
  80241e:	eb 0f                	jmp    80242f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802420:	83 c0 01             	add    $0x1,%eax
  802423:	3d 00 04 00 00       	cmp    $0x400,%eax
  802428:	75 d9                	jne    802403 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80242a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80242f:	5d                   	pop    %ebp
  802430:	c3                   	ret    

00802431 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802431:	55                   	push   %ebp
  802432:	89 e5                	mov    %esp,%ebp
  802434:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802437:	89 d0                	mov    %edx,%eax
  802439:	c1 e8 16             	shr    $0x16,%eax
  80243c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802443:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802448:	f6 c1 01             	test   $0x1,%cl
  80244b:	74 1d                	je     80246a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80244d:	c1 ea 0c             	shr    $0xc,%edx
  802450:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802457:	f6 c2 01             	test   $0x1,%dl
  80245a:	74 0e                	je     80246a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80245c:	c1 ea 0c             	shr    $0xc,%edx
  80245f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802466:	ef 
  802467:	0f b7 c0             	movzwl %ax,%eax
}
  80246a:	5d                   	pop    %ebp
  80246b:	c3                   	ret    
  80246c:	66 90                	xchg   %ax,%ax
  80246e:	66 90                	xchg   %ax,%ax

00802470 <__udivdi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	53                   	push   %ebx
  802474:	83 ec 1c             	sub    $0x1c,%esp
  802477:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80247b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80247f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802487:	85 f6                	test   %esi,%esi
  802489:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80248d:	89 ca                	mov    %ecx,%edx
  80248f:	89 f8                	mov    %edi,%eax
  802491:	75 3d                	jne    8024d0 <__udivdi3+0x60>
  802493:	39 cf                	cmp    %ecx,%edi
  802495:	0f 87 c5 00 00 00    	ja     802560 <__udivdi3+0xf0>
  80249b:	85 ff                	test   %edi,%edi
  80249d:	89 fd                	mov    %edi,%ebp
  80249f:	75 0b                	jne    8024ac <__udivdi3+0x3c>
  8024a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a6:	31 d2                	xor    %edx,%edx
  8024a8:	f7 f7                	div    %edi
  8024aa:	89 c5                	mov    %eax,%ebp
  8024ac:	89 c8                	mov    %ecx,%eax
  8024ae:	31 d2                	xor    %edx,%edx
  8024b0:	f7 f5                	div    %ebp
  8024b2:	89 c1                	mov    %eax,%ecx
  8024b4:	89 d8                	mov    %ebx,%eax
  8024b6:	89 cf                	mov    %ecx,%edi
  8024b8:	f7 f5                	div    %ebp
  8024ba:	89 c3                	mov    %eax,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	39 ce                	cmp    %ecx,%esi
  8024d2:	77 74                	ja     802548 <__udivdi3+0xd8>
  8024d4:	0f bd fe             	bsr    %esi,%edi
  8024d7:	83 f7 1f             	xor    $0x1f,%edi
  8024da:	0f 84 98 00 00 00    	je     802578 <__udivdi3+0x108>
  8024e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	89 c5                	mov    %eax,%ebp
  8024e9:	29 fb                	sub    %edi,%ebx
  8024eb:	d3 e6                	shl    %cl,%esi
  8024ed:	89 d9                	mov    %ebx,%ecx
  8024ef:	d3 ed                	shr    %cl,%ebp
  8024f1:	89 f9                	mov    %edi,%ecx
  8024f3:	d3 e0                	shl    %cl,%eax
  8024f5:	09 ee                	or     %ebp,%esi
  8024f7:	89 d9                	mov    %ebx,%ecx
  8024f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024fd:	89 d5                	mov    %edx,%ebp
  8024ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802503:	d3 ed                	shr    %cl,%ebp
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e2                	shl    %cl,%edx
  802509:	89 d9                	mov    %ebx,%ecx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	09 c2                	or     %eax,%edx
  80250f:	89 d0                	mov    %edx,%eax
  802511:	89 ea                	mov    %ebp,%edx
  802513:	f7 f6                	div    %esi
  802515:	89 d5                	mov    %edx,%ebp
  802517:	89 c3                	mov    %eax,%ebx
  802519:	f7 64 24 0c          	mull   0xc(%esp)
  80251d:	39 d5                	cmp    %edx,%ebp
  80251f:	72 10                	jb     802531 <__udivdi3+0xc1>
  802521:	8b 74 24 08          	mov    0x8(%esp),%esi
  802525:	89 f9                	mov    %edi,%ecx
  802527:	d3 e6                	shl    %cl,%esi
  802529:	39 c6                	cmp    %eax,%esi
  80252b:	73 07                	jae    802534 <__udivdi3+0xc4>
  80252d:	39 d5                	cmp    %edx,%ebp
  80252f:	75 03                	jne    802534 <__udivdi3+0xc4>
  802531:	83 eb 01             	sub    $0x1,%ebx
  802534:	31 ff                	xor    %edi,%edi
  802536:	89 d8                	mov    %ebx,%eax
  802538:	89 fa                	mov    %edi,%edx
  80253a:	83 c4 1c             	add    $0x1c,%esp
  80253d:	5b                   	pop    %ebx
  80253e:	5e                   	pop    %esi
  80253f:	5f                   	pop    %edi
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    
  802542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802548:	31 ff                	xor    %edi,%edi
  80254a:	31 db                	xor    %ebx,%ebx
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
  802560:	89 d8                	mov    %ebx,%eax
  802562:	f7 f7                	div    %edi
  802564:	31 ff                	xor    %edi,%edi
  802566:	89 c3                	mov    %eax,%ebx
  802568:	89 d8                	mov    %ebx,%eax
  80256a:	89 fa                	mov    %edi,%edx
  80256c:	83 c4 1c             	add    $0x1c,%esp
  80256f:	5b                   	pop    %ebx
  802570:	5e                   	pop    %esi
  802571:	5f                   	pop    %edi
  802572:	5d                   	pop    %ebp
  802573:	c3                   	ret    
  802574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802578:	39 ce                	cmp    %ecx,%esi
  80257a:	72 0c                	jb     802588 <__udivdi3+0x118>
  80257c:	31 db                	xor    %ebx,%ebx
  80257e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802582:	0f 87 34 ff ff ff    	ja     8024bc <__udivdi3+0x4c>
  802588:	bb 01 00 00 00       	mov    $0x1,%ebx
  80258d:	e9 2a ff ff ff       	jmp    8024bc <__udivdi3+0x4c>
  802592:	66 90                	xchg   %ax,%ax
  802594:	66 90                	xchg   %ax,%ax
  802596:	66 90                	xchg   %ax,%ax
  802598:	66 90                	xchg   %ax,%ax
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__umoddi3>:
  8025a0:	55                   	push   %ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
  8025a4:	83 ec 1c             	sub    $0x1c,%esp
  8025a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025b7:	85 d2                	test   %edx,%edx
  8025b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025c1:	89 f3                	mov    %esi,%ebx
  8025c3:	89 3c 24             	mov    %edi,(%esp)
  8025c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ca:	75 1c                	jne    8025e8 <__umoddi3+0x48>
  8025cc:	39 f7                	cmp    %esi,%edi
  8025ce:	76 50                	jbe    802620 <__umoddi3+0x80>
  8025d0:	89 c8                	mov    %ecx,%eax
  8025d2:	89 f2                	mov    %esi,%edx
  8025d4:	f7 f7                	div    %edi
  8025d6:	89 d0                	mov    %edx,%eax
  8025d8:	31 d2                	xor    %edx,%edx
  8025da:	83 c4 1c             	add    $0x1c,%esp
  8025dd:	5b                   	pop    %ebx
  8025de:	5e                   	pop    %esi
  8025df:	5f                   	pop    %edi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    
  8025e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e8:	39 f2                	cmp    %esi,%edx
  8025ea:	89 d0                	mov    %edx,%eax
  8025ec:	77 52                	ja     802640 <__umoddi3+0xa0>
  8025ee:	0f bd ea             	bsr    %edx,%ebp
  8025f1:	83 f5 1f             	xor    $0x1f,%ebp
  8025f4:	75 5a                	jne    802650 <__umoddi3+0xb0>
  8025f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025fa:	0f 82 e0 00 00 00    	jb     8026e0 <__umoddi3+0x140>
  802600:	39 0c 24             	cmp    %ecx,(%esp)
  802603:	0f 86 d7 00 00 00    	jbe    8026e0 <__umoddi3+0x140>
  802609:	8b 44 24 08          	mov    0x8(%esp),%eax
  80260d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802611:	83 c4 1c             	add    $0x1c,%esp
  802614:	5b                   	pop    %ebx
  802615:	5e                   	pop    %esi
  802616:	5f                   	pop    %edi
  802617:	5d                   	pop    %ebp
  802618:	c3                   	ret    
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	85 ff                	test   %edi,%edi
  802622:	89 fd                	mov    %edi,%ebp
  802624:	75 0b                	jne    802631 <__umoddi3+0x91>
  802626:	b8 01 00 00 00       	mov    $0x1,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	f7 f7                	div    %edi
  80262f:	89 c5                	mov    %eax,%ebp
  802631:	89 f0                	mov    %esi,%eax
  802633:	31 d2                	xor    %edx,%edx
  802635:	f7 f5                	div    %ebp
  802637:	89 c8                	mov    %ecx,%eax
  802639:	f7 f5                	div    %ebp
  80263b:	89 d0                	mov    %edx,%eax
  80263d:	eb 99                	jmp    8025d8 <__umoddi3+0x38>
  80263f:	90                   	nop
  802640:	89 c8                	mov    %ecx,%eax
  802642:	89 f2                	mov    %esi,%edx
  802644:	83 c4 1c             	add    $0x1c,%esp
  802647:	5b                   	pop    %ebx
  802648:	5e                   	pop    %esi
  802649:	5f                   	pop    %edi
  80264a:	5d                   	pop    %ebp
  80264b:	c3                   	ret    
  80264c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802650:	8b 34 24             	mov    (%esp),%esi
  802653:	bf 20 00 00 00       	mov    $0x20,%edi
  802658:	89 e9                	mov    %ebp,%ecx
  80265a:	29 ef                	sub    %ebp,%edi
  80265c:	d3 e0                	shl    %cl,%eax
  80265e:	89 f9                	mov    %edi,%ecx
  802660:	89 f2                	mov    %esi,%edx
  802662:	d3 ea                	shr    %cl,%edx
  802664:	89 e9                	mov    %ebp,%ecx
  802666:	09 c2                	or     %eax,%edx
  802668:	89 d8                	mov    %ebx,%eax
  80266a:	89 14 24             	mov    %edx,(%esp)
  80266d:	89 f2                	mov    %esi,%edx
  80266f:	d3 e2                	shl    %cl,%edx
  802671:	89 f9                	mov    %edi,%ecx
  802673:	89 54 24 04          	mov    %edx,0x4(%esp)
  802677:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80267b:	d3 e8                	shr    %cl,%eax
  80267d:	89 e9                	mov    %ebp,%ecx
  80267f:	89 c6                	mov    %eax,%esi
  802681:	d3 e3                	shl    %cl,%ebx
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 d0                	mov    %edx,%eax
  802687:	d3 e8                	shr    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	09 d8                	or     %ebx,%eax
  80268d:	89 d3                	mov    %edx,%ebx
  80268f:	89 f2                	mov    %esi,%edx
  802691:	f7 34 24             	divl   (%esp)
  802694:	89 d6                	mov    %edx,%esi
  802696:	d3 e3                	shl    %cl,%ebx
  802698:	f7 64 24 04          	mull   0x4(%esp)
  80269c:	39 d6                	cmp    %edx,%esi
  80269e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026a2:	89 d1                	mov    %edx,%ecx
  8026a4:	89 c3                	mov    %eax,%ebx
  8026a6:	72 08                	jb     8026b0 <__umoddi3+0x110>
  8026a8:	75 11                	jne    8026bb <__umoddi3+0x11b>
  8026aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ae:	73 0b                	jae    8026bb <__umoddi3+0x11b>
  8026b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026b4:	1b 14 24             	sbb    (%esp),%edx
  8026b7:	89 d1                	mov    %edx,%ecx
  8026b9:	89 c3                	mov    %eax,%ebx
  8026bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026bf:	29 da                	sub    %ebx,%edx
  8026c1:	19 ce                	sbb    %ecx,%esi
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 f0                	mov    %esi,%eax
  8026c7:	d3 e0                	shl    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	d3 ea                	shr    %cl,%edx
  8026cd:	89 e9                	mov    %ebp,%ecx
  8026cf:	d3 ee                	shr    %cl,%esi
  8026d1:	09 d0                	or     %edx,%eax
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	83 c4 1c             	add    $0x1c,%esp
  8026d8:	5b                   	pop    %ebx
  8026d9:	5e                   	pop    %esi
  8026da:	5f                   	pop    %edi
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    
  8026dd:	8d 76 00             	lea    0x0(%esi),%esi
  8026e0:	29 f9                	sub    %edi,%ecx
  8026e2:	19 d6                	sbb    %edx,%esi
  8026e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ec:	e9 18 ff ff ff       	jmp    802609 <__umoddi3+0x69>
