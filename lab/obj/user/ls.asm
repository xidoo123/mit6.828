
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
  80005a:	68 82 27 80 00       	push   $0x802782
  80005f:	e8 01 1a 00 00       	call   801a65 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 e8 27 80 00       	mov    $0x8027e8,%eax
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
  800086:	ba e8 27 80 00       	mov    $0x8027e8,%edx
  80008b:	b8 80 27 80 00       	mov    $0x802780,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 8b 27 80 00       	push   $0x80278b
  80009d:	e8 c3 19 00 00       	call   801a65 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 19 2c 80 00       	push   $0x802c19
  8000b0:	e8 b0 19 00 00       	call   801a65 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 80 27 80 00       	push   $0x802780
  8000cf:	e8 91 19 00 00       	call   801a65 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 e7 27 80 00       	push   $0x8027e7
  8000df:	e8 81 19 00 00       	call   801a65 <printf>
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
  800100:	e8 c2 17 00 00       	call   8018c7 <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 90 27 80 00       	push   $0x802790
  800118:	6a 1d                	push   $0x1d
  80011a:	68 9c 27 80 00       	push   $0x80279c
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
  80015f:	e8 76 13 00 00       	call   8014da <readn>
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
  800173:	68 a6 27 80 00       	push   $0x8027a6
  800178:	6a 22                	push   $0x22
  80017a:	68 9c 27 80 00       	push   $0x80279c
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 ec 27 80 00       	push   $0x8027ec
  800192:	6a 24                	push   $0x24
  800194:	68 9c 27 80 00       	push   $0x80279c
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
  8001bb:	e8 1f 15 00 00       	call   8016df <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 c1 27 80 00       	push   $0x8027c1
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 9c 27 80 00       	push   $0x80279c
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
  800220:	68 cd 27 80 00       	push   $0x8027cd
  800225:	e8 3b 18 00 00       	call   801a65 <printf>
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
  800248:	e8 cc 0d 00 00       	call   801019 <argstart>
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
  800277:	e8 cd 0d 00 00       	call   801049 <argnext>
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
  800291:	68 e8 27 80 00       	push   $0x8027e8
  800296:	68 80 27 80 00       	push   $0x802780
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
  800310:	e8 23 10 00 00       	call   801338 <close_all>
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
  800342:	68 18 28 80 00       	push   $0x802818
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 e7 27 80 00 	movl   $0x8027e7,(%esp)
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
  800460:	e8 8b 20 00 00       	call   8024f0 <__udivdi3>
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
  8004a3:	e8 78 21 00 00       	call   802620 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 3b 28 80 00 	movsbl 0x80283b(%eax),%eax
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
  8005a7:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
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
  80066b:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	75 18                	jne    80068e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 53 28 80 00       	push   $0x802853
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
  80068f:	68 19 2c 80 00       	push   $0x802c19
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
  8006b3:	b8 4c 28 80 00       	mov    $0x80284c,%eax
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
  800d2e:	68 3f 2b 80 00       	push   $0x802b3f
  800d33:	6a 23                	push   $0x23
  800d35:	68 5c 2b 80 00       	push   $0x802b5c
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
  800daf:	68 3f 2b 80 00       	push   $0x802b3f
  800db4:	6a 23                	push   $0x23
  800db6:	68 5c 2b 80 00       	push   $0x802b5c
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
  800df1:	68 3f 2b 80 00       	push   $0x802b3f
  800df6:	6a 23                	push   $0x23
  800df8:	68 5c 2b 80 00       	push   $0x802b5c
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
  800e33:	68 3f 2b 80 00       	push   $0x802b3f
  800e38:	6a 23                	push   $0x23
  800e3a:	68 5c 2b 80 00       	push   $0x802b5c
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
  800e75:	68 3f 2b 80 00       	push   $0x802b3f
  800e7a:	6a 23                	push   $0x23
  800e7c:	68 5c 2b 80 00       	push   $0x802b5c
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
  800eb7:	68 3f 2b 80 00       	push   $0x802b3f
  800ebc:	6a 23                	push   $0x23
  800ebe:	68 5c 2b 80 00       	push   $0x802b5c
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
  800ef9:	68 3f 2b 80 00       	push   $0x802b3f
  800efe:	6a 23                	push   $0x23
  800f00:	68 5c 2b 80 00       	push   $0x802b5c
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
  800f5d:	68 3f 2b 80 00       	push   $0x802b3f
  800f62:	6a 23                	push   $0x23
  800f64:	68 5c 2b 80 00       	push   $0x802b5c
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

00800f95 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fab:	8b 55 08             	mov    0x8(%ebp),%edx
  800fae:	89 df                	mov    %ebx,%edi
  800fb0:	89 de                	mov    %ebx,%esi
  800fb2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	7e 17                	jle    800fcf <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	50                   	push   %eax
  800fbc:	6a 0f                	push   $0xf
  800fbe:	68 3f 2b 80 00       	push   $0x802b3f
  800fc3:	6a 23                	push   $0x23
  800fc5:	68 5c 2b 80 00       	push   $0x802b5c
  800fca:	e8 55 f3 ff ff       	call   800324 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800fcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd2:	5b                   	pop    %ebx
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	57                   	push   %edi
  800fdb:	56                   	push   %esi
  800fdc:	53                   	push   %ebx
  800fdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe5:	b8 10 00 00 00       	mov    $0x10,%eax
  800fea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff0:	89 df                	mov    %ebx,%edi
  800ff2:	89 de                	mov    %ebx,%esi
  800ff4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	7e 17                	jle    801011 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	50                   	push   %eax
  800ffe:	6a 10                	push   $0x10
  801000:	68 3f 2b 80 00       	push   $0x802b3f
  801005:	6a 23                	push   $0x23
  801007:	68 5c 2b 80 00       	push   $0x802b5c
  80100c:	e8 13 f3 ff ff       	call   800324 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  801011:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	8b 55 08             	mov    0x8(%ebp),%edx
  80101f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801022:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801025:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801027:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  80102a:	83 3a 01             	cmpl   $0x1,(%edx)
  80102d:	7e 09                	jle    801038 <argstart+0x1f>
  80102f:	ba e8 27 80 00       	mov    $0x8027e8,%edx
  801034:	85 c9                	test   %ecx,%ecx
  801036:	75 05                	jne    80103d <argstart+0x24>
  801038:	ba 00 00 00 00       	mov    $0x0,%edx
  80103d:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801040:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <argnext>:

int
argnext(struct Argstate *args)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	53                   	push   %ebx
  80104d:	83 ec 04             	sub    $0x4,%esp
  801050:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801053:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80105a:	8b 43 08             	mov    0x8(%ebx),%eax
  80105d:	85 c0                	test   %eax,%eax
  80105f:	74 6f                	je     8010d0 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801061:	80 38 00             	cmpb   $0x0,(%eax)
  801064:	75 4e                	jne    8010b4 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801066:	8b 0b                	mov    (%ebx),%ecx
  801068:	83 39 01             	cmpl   $0x1,(%ecx)
  80106b:	74 55                	je     8010c2 <argnext+0x79>
		    || args->argv[1][0] != '-'
  80106d:	8b 53 04             	mov    0x4(%ebx),%edx
  801070:	8b 42 04             	mov    0x4(%edx),%eax
  801073:	80 38 2d             	cmpb   $0x2d,(%eax)
  801076:	75 4a                	jne    8010c2 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801078:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80107c:	74 44                	je     8010c2 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80107e:	83 c0 01             	add    $0x1,%eax
  801081:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801084:	83 ec 04             	sub    $0x4,%esp
  801087:	8b 01                	mov    (%ecx),%eax
  801089:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801090:	50                   	push   %eax
  801091:	8d 42 08             	lea    0x8(%edx),%eax
  801094:	50                   	push   %eax
  801095:	83 c2 04             	add    $0x4,%edx
  801098:	52                   	push   %edx
  801099:	e8 76 fa ff ff       	call   800b14 <memmove>
		(*args->argc)--;
  80109e:	8b 03                	mov    (%ebx),%eax
  8010a0:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010a3:	8b 43 08             	mov    0x8(%ebx),%eax
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010ac:	75 06                	jne    8010b4 <argnext+0x6b>
  8010ae:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010b2:	74 0e                	je     8010c2 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8010b4:	8b 53 08             	mov    0x8(%ebx),%edx
  8010b7:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8010ba:	83 c2 01             	add    $0x1,%edx
  8010bd:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8010c0:	eb 13                	jmp    8010d5 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  8010c2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8010c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010ce:	eb 05                	jmp    8010d5 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8010d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8010d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d8:	c9                   	leave  
  8010d9:	c3                   	ret    

008010da <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 04             	sub    $0x4,%esp
  8010e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8010e4:	8b 43 08             	mov    0x8(%ebx),%eax
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	74 58                	je     801143 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8010eb:	80 38 00             	cmpb   $0x0,(%eax)
  8010ee:	74 0c                	je     8010fc <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8010f0:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8010f3:	c7 43 08 e8 27 80 00 	movl   $0x8027e8,0x8(%ebx)
  8010fa:	eb 42                	jmp    80113e <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8010fc:	8b 13                	mov    (%ebx),%edx
  8010fe:	83 3a 01             	cmpl   $0x1,(%edx)
  801101:	7e 2d                	jle    801130 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801103:	8b 43 04             	mov    0x4(%ebx),%eax
  801106:	8b 48 04             	mov    0x4(%eax),%ecx
  801109:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	8b 12                	mov    (%edx),%edx
  801111:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801118:	52                   	push   %edx
  801119:	8d 50 08             	lea    0x8(%eax),%edx
  80111c:	52                   	push   %edx
  80111d:	83 c0 04             	add    $0x4,%eax
  801120:	50                   	push   %eax
  801121:	e8 ee f9 ff ff       	call   800b14 <memmove>
		(*args->argc)--;
  801126:	8b 03                	mov    (%ebx),%eax
  801128:	83 28 01             	subl   $0x1,(%eax)
  80112b:	83 c4 10             	add    $0x10,%esp
  80112e:	eb 0e                	jmp    80113e <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801130:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801137:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80113e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801141:	eb 05                	jmp    801148 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801143:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114b:	c9                   	leave  
  80114c:	c3                   	ret    

0080114d <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	83 ec 08             	sub    $0x8,%esp
  801153:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801156:	8b 51 0c             	mov    0xc(%ecx),%edx
  801159:	89 d0                	mov    %edx,%eax
  80115b:	85 d2                	test   %edx,%edx
  80115d:	75 0c                	jne    80116b <argvalue+0x1e>
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	51                   	push   %ecx
  801163:	e8 72 ff ff ff       	call   8010da <argnextvalue>
  801168:	83 c4 10             	add    $0x10,%esp
}
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    

0080116d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	05 00 00 00 30       	add    $0x30000000,%eax
  801178:	c1 e8 0c             	shr    $0xc,%eax
}
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	05 00 00 00 30       	add    $0x30000000,%eax
  801188:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80118d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	c1 ea 16             	shr    $0x16,%edx
  8011a4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ab:	f6 c2 01             	test   $0x1,%dl
  8011ae:	74 11                	je     8011c1 <fd_alloc+0x2d>
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	c1 ea 0c             	shr    $0xc,%edx
  8011b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bc:	f6 c2 01             	test   $0x1,%dl
  8011bf:	75 09                	jne    8011ca <fd_alloc+0x36>
			*fd_store = fd;
  8011c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c8:	eb 17                	jmp    8011e1 <fd_alloc+0x4d>
  8011ca:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011cf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d4:	75 c9                	jne    80119f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011d6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011dc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011e9:	83 f8 1f             	cmp    $0x1f,%eax
  8011ec:	77 36                	ja     801224 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ee:	c1 e0 0c             	shl    $0xc,%eax
  8011f1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	c1 ea 16             	shr    $0x16,%edx
  8011fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801202:	f6 c2 01             	test   $0x1,%dl
  801205:	74 24                	je     80122b <fd_lookup+0x48>
  801207:	89 c2                	mov    %eax,%edx
  801209:	c1 ea 0c             	shr    $0xc,%edx
  80120c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801213:	f6 c2 01             	test   $0x1,%dl
  801216:	74 1a                	je     801232 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801218:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121b:	89 02                	mov    %eax,(%edx)
	return 0;
  80121d:	b8 00 00 00 00       	mov    $0x0,%eax
  801222:	eb 13                	jmp    801237 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801224:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801229:	eb 0c                	jmp    801237 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801230:	eb 05                	jmp    801237 <fd_lookup+0x54>
  801232:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801242:	ba ec 2b 80 00       	mov    $0x802bec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801247:	eb 13                	jmp    80125c <dev_lookup+0x23>
  801249:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80124c:	39 08                	cmp    %ecx,(%eax)
  80124e:	75 0c                	jne    80125c <dev_lookup+0x23>
			*dev = devtab[i];
  801250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801253:	89 01                	mov    %eax,(%ecx)
			return 0;
  801255:	b8 00 00 00 00       	mov    $0x0,%eax
  80125a:	eb 2e                	jmp    80128a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80125c:	8b 02                	mov    (%edx),%eax
  80125e:	85 c0                	test   %eax,%eax
  801260:	75 e7                	jne    801249 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801262:	a1 20 44 80 00       	mov    0x804420,%eax
  801267:	8b 40 48             	mov    0x48(%eax),%eax
  80126a:	83 ec 04             	sub    $0x4,%esp
  80126d:	51                   	push   %ecx
  80126e:	50                   	push   %eax
  80126f:	68 6c 2b 80 00       	push   $0x802b6c
  801274:	e8 84 f1 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  801279:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128a:	c9                   	leave  
  80128b:	c3                   	ret    

0080128c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	56                   	push   %esi
  801290:	53                   	push   %ebx
  801291:	83 ec 10             	sub    $0x10,%esp
  801294:	8b 75 08             	mov    0x8(%ebp),%esi
  801297:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012a4:	c1 e8 0c             	shr    $0xc,%eax
  8012a7:	50                   	push   %eax
  8012a8:	e8 36 ff ff ff       	call   8011e3 <fd_lookup>
  8012ad:	83 c4 08             	add    $0x8,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 05                	js     8012b9 <fd_close+0x2d>
	    || fd != fd2)
  8012b4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012b7:	74 0c                	je     8012c5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012b9:	84 db                	test   %bl,%bl
  8012bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c0:	0f 44 c2             	cmove  %edx,%eax
  8012c3:	eb 41                	jmp    801306 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c5:	83 ec 08             	sub    $0x8,%esp
  8012c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cb:	50                   	push   %eax
  8012cc:	ff 36                	pushl  (%esi)
  8012ce:	e8 66 ff ff ff       	call   801239 <dev_lookup>
  8012d3:	89 c3                	mov    %eax,%ebx
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 1a                	js     8012f6 <fd_close+0x6a>
		if (dev->dev_close)
  8012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012df:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012e2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	74 0b                	je     8012f6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012eb:	83 ec 0c             	sub    $0xc,%esp
  8012ee:	56                   	push   %esi
  8012ef:	ff d0                	call   *%eax
  8012f1:	89 c3                	mov    %eax,%ebx
  8012f3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	56                   	push   %esi
  8012fa:	6a 00                	push   $0x0
  8012fc:	e8 09 fb ff ff       	call   800e0a <sys_page_unmap>
	return r;
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	89 d8                	mov    %ebx,%eax
}
  801306:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801313:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801316:	50                   	push   %eax
  801317:	ff 75 08             	pushl  0x8(%ebp)
  80131a:	e8 c4 fe ff ff       	call   8011e3 <fd_lookup>
  80131f:	83 c4 08             	add    $0x8,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 10                	js     801336 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	6a 01                	push   $0x1
  80132b:	ff 75 f4             	pushl  -0xc(%ebp)
  80132e:	e8 59 ff ff ff       	call   80128c <fd_close>
  801333:	83 c4 10             	add    $0x10,%esp
}
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <close_all>:

void
close_all(void)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80133f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801344:	83 ec 0c             	sub    $0xc,%esp
  801347:	53                   	push   %ebx
  801348:	e8 c0 ff ff ff       	call   80130d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80134d:	83 c3 01             	add    $0x1,%ebx
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	83 fb 20             	cmp    $0x20,%ebx
  801356:	75 ec                	jne    801344 <close_all+0xc>
		close(i);
}
  801358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	57                   	push   %edi
  801361:	56                   	push   %esi
  801362:	53                   	push   %ebx
  801363:	83 ec 2c             	sub    $0x2c,%esp
  801366:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801369:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	ff 75 08             	pushl  0x8(%ebp)
  801370:	e8 6e fe ff ff       	call   8011e3 <fd_lookup>
  801375:	83 c4 08             	add    $0x8,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	0f 88 c1 00 00 00    	js     801441 <dup+0xe4>
		return r;
	close(newfdnum);
  801380:	83 ec 0c             	sub    $0xc,%esp
  801383:	56                   	push   %esi
  801384:	e8 84 ff ff ff       	call   80130d <close>

	newfd = INDEX2FD(newfdnum);
  801389:	89 f3                	mov    %esi,%ebx
  80138b:	c1 e3 0c             	shl    $0xc,%ebx
  80138e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801394:	83 c4 04             	add    $0x4,%esp
  801397:	ff 75 e4             	pushl  -0x1c(%ebp)
  80139a:	e8 de fd ff ff       	call   80117d <fd2data>
  80139f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013a1:	89 1c 24             	mov    %ebx,(%esp)
  8013a4:	e8 d4 fd ff ff       	call   80117d <fd2data>
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013af:	89 f8                	mov    %edi,%eax
  8013b1:	c1 e8 16             	shr    $0x16,%eax
  8013b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013bb:	a8 01                	test   $0x1,%al
  8013bd:	74 37                	je     8013f6 <dup+0x99>
  8013bf:	89 f8                	mov    %edi,%eax
  8013c1:	c1 e8 0c             	shr    $0xc,%eax
  8013c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013cb:	f6 c2 01             	test   $0x1,%dl
  8013ce:	74 26                	je     8013f6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d7:	83 ec 0c             	sub    $0xc,%esp
  8013da:	25 07 0e 00 00       	and    $0xe07,%eax
  8013df:	50                   	push   %eax
  8013e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e3:	6a 00                	push   $0x0
  8013e5:	57                   	push   %edi
  8013e6:	6a 00                	push   $0x0
  8013e8:	e8 db f9 ff ff       	call   800dc8 <sys_page_map>
  8013ed:	89 c7                	mov    %eax,%edi
  8013ef:	83 c4 20             	add    $0x20,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 2e                	js     801424 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013f9:	89 d0                	mov    %edx,%eax
  8013fb:	c1 e8 0c             	shr    $0xc,%eax
  8013fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801405:	83 ec 0c             	sub    $0xc,%esp
  801408:	25 07 0e 00 00       	and    $0xe07,%eax
  80140d:	50                   	push   %eax
  80140e:	53                   	push   %ebx
  80140f:	6a 00                	push   $0x0
  801411:	52                   	push   %edx
  801412:	6a 00                	push   $0x0
  801414:	e8 af f9 ff ff       	call   800dc8 <sys_page_map>
  801419:	89 c7                	mov    %eax,%edi
  80141b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80141e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801420:	85 ff                	test   %edi,%edi
  801422:	79 1d                	jns    801441 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	53                   	push   %ebx
  801428:	6a 00                	push   $0x0
  80142a:	e8 db f9 ff ff       	call   800e0a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80142f:	83 c4 08             	add    $0x8,%esp
  801432:	ff 75 d4             	pushl  -0x2c(%ebp)
  801435:	6a 00                	push   $0x0
  801437:	e8 ce f9 ff ff       	call   800e0a <sys_page_unmap>
	return r;
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	89 f8                	mov    %edi,%eax
}
  801441:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801444:	5b                   	pop    %ebx
  801445:	5e                   	pop    %esi
  801446:	5f                   	pop    %edi
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    

00801449 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	53                   	push   %ebx
  80144d:	83 ec 14             	sub    $0x14,%esp
  801450:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801453:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	53                   	push   %ebx
  801458:	e8 86 fd ff ff       	call   8011e3 <fd_lookup>
  80145d:	83 c4 08             	add    $0x8,%esp
  801460:	89 c2                	mov    %eax,%edx
  801462:	85 c0                	test   %eax,%eax
  801464:	78 6d                	js     8014d3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801470:	ff 30                	pushl  (%eax)
  801472:	e8 c2 fd ff ff       	call   801239 <dev_lookup>
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 4c                	js     8014ca <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80147e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801481:	8b 42 08             	mov    0x8(%edx),%eax
  801484:	83 e0 03             	and    $0x3,%eax
  801487:	83 f8 01             	cmp    $0x1,%eax
  80148a:	75 21                	jne    8014ad <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80148c:	a1 20 44 80 00       	mov    0x804420,%eax
  801491:	8b 40 48             	mov    0x48(%eax),%eax
  801494:	83 ec 04             	sub    $0x4,%esp
  801497:	53                   	push   %ebx
  801498:	50                   	push   %eax
  801499:	68 b0 2b 80 00       	push   $0x802bb0
  80149e:	e8 5a ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ab:	eb 26                	jmp    8014d3 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b0:	8b 40 08             	mov    0x8(%eax),%eax
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	74 17                	je     8014ce <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014b7:	83 ec 04             	sub    $0x4,%esp
  8014ba:	ff 75 10             	pushl  0x10(%ebp)
  8014bd:	ff 75 0c             	pushl  0xc(%ebp)
  8014c0:	52                   	push   %edx
  8014c1:	ff d0                	call   *%eax
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	eb 09                	jmp    8014d3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	eb 05                	jmp    8014d3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014d3:	89 d0                	mov    %edx,%eax
  8014d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	57                   	push   %edi
  8014de:	56                   	push   %esi
  8014df:	53                   	push   %ebx
  8014e0:	83 ec 0c             	sub    $0xc,%esp
  8014e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ee:	eb 21                	jmp    801511 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f0:	83 ec 04             	sub    $0x4,%esp
  8014f3:	89 f0                	mov    %esi,%eax
  8014f5:	29 d8                	sub    %ebx,%eax
  8014f7:	50                   	push   %eax
  8014f8:	89 d8                	mov    %ebx,%eax
  8014fa:	03 45 0c             	add    0xc(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	57                   	push   %edi
  8014ff:	e8 45 ff ff ff       	call   801449 <read>
		if (m < 0)
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 10                	js     80151b <readn+0x41>
			return m;
		if (m == 0)
  80150b:	85 c0                	test   %eax,%eax
  80150d:	74 0a                	je     801519 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150f:	01 c3                	add    %eax,%ebx
  801511:	39 f3                	cmp    %esi,%ebx
  801513:	72 db                	jb     8014f0 <readn+0x16>
  801515:	89 d8                	mov    %ebx,%eax
  801517:	eb 02                	jmp    80151b <readn+0x41>
  801519:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80151b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5e                   	pop    %esi
  801520:	5f                   	pop    %edi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 14             	sub    $0x14,%esp
  80152a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	53                   	push   %ebx
  801532:	e8 ac fc ff ff       	call   8011e3 <fd_lookup>
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 68                	js     8015a8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	ff 30                	pushl  (%eax)
  80154c:	e8 e8 fc ff ff       	call   801239 <dev_lookup>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 47                	js     80159f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155f:	75 21                	jne    801582 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801561:	a1 20 44 80 00       	mov    0x804420,%eax
  801566:	8b 40 48             	mov    0x48(%eax),%eax
  801569:	83 ec 04             	sub    $0x4,%esp
  80156c:	53                   	push   %ebx
  80156d:	50                   	push   %eax
  80156e:	68 cc 2b 80 00       	push   $0x802bcc
  801573:	e8 85 ee ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801580:	eb 26                	jmp    8015a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	8b 52 0c             	mov    0xc(%edx),%edx
  801588:	85 d2                	test   %edx,%edx
  80158a:	74 17                	je     8015a3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80158c:	83 ec 04             	sub    $0x4,%esp
  80158f:	ff 75 10             	pushl  0x10(%ebp)
  801592:	ff 75 0c             	pushl  0xc(%ebp)
  801595:	50                   	push   %eax
  801596:	ff d2                	call   *%edx
  801598:	89 c2                	mov    %eax,%edx
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	eb 09                	jmp    8015a8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159f:	89 c2                	mov    %eax,%edx
  8015a1:	eb 05                	jmp    8015a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015a8:	89 d0                	mov    %edx,%eax
  8015aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <seek>:

int
seek(int fdnum, off_t offset)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	ff 75 08             	pushl  0x8(%ebp)
  8015bc:	e8 22 fc ff ff       	call   8011e3 <fd_lookup>
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 0e                	js     8015d6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ce:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 14             	sub    $0x14,%esp
  8015df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	53                   	push   %ebx
  8015e7:	e8 f7 fb ff ff       	call   8011e3 <fd_lookup>
  8015ec:	83 c4 08             	add    $0x8,%esp
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 65                	js     80165a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ff:	ff 30                	pushl  (%eax)
  801601:	e8 33 fc ff ff       	call   801239 <dev_lookup>
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 44                	js     801651 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801610:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801614:	75 21                	jne    801637 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801616:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161b:	8b 40 48             	mov    0x48(%eax),%eax
  80161e:	83 ec 04             	sub    $0x4,%esp
  801621:	53                   	push   %ebx
  801622:	50                   	push   %eax
  801623:	68 8c 2b 80 00       	push   $0x802b8c
  801628:	e8 d0 ed ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801635:	eb 23                	jmp    80165a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801637:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163a:	8b 52 18             	mov    0x18(%edx),%edx
  80163d:	85 d2                	test   %edx,%edx
  80163f:	74 14                	je     801655 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	ff 75 0c             	pushl  0xc(%ebp)
  801647:	50                   	push   %eax
  801648:	ff d2                	call   *%edx
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	eb 09                	jmp    80165a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801651:	89 c2                	mov    %eax,%edx
  801653:	eb 05                	jmp    80165a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801655:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80165a:	89 d0                	mov    %edx,%eax
  80165c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	53                   	push   %ebx
  801665:	83 ec 14             	sub    $0x14,%esp
  801668:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	ff 75 08             	pushl  0x8(%ebp)
  801672:	e8 6c fb ff ff       	call   8011e3 <fd_lookup>
  801677:	83 c4 08             	add    $0x8,%esp
  80167a:	89 c2                	mov    %eax,%edx
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 58                	js     8016d8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801686:	50                   	push   %eax
  801687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168a:	ff 30                	pushl  (%eax)
  80168c:	e8 a8 fb ff ff       	call   801239 <dev_lookup>
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	85 c0                	test   %eax,%eax
  801696:	78 37                	js     8016cf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80169f:	74 32                	je     8016d3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ab:	00 00 00 
	stat->st_isdir = 0;
  8016ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b5:	00 00 00 
	stat->st_dev = dev;
  8016b8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	53                   	push   %ebx
  8016c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c5:	ff 50 14             	call   *0x14(%eax)
  8016c8:	89 c2                	mov    %eax,%edx
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	eb 09                	jmp    8016d8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cf:	89 c2                	mov    %eax,%edx
  8016d1:	eb 05                	jmp    8016d8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016d8:	89 d0                	mov    %edx,%eax
  8016da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	56                   	push   %esi
  8016e3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016e4:	83 ec 08             	sub    $0x8,%esp
  8016e7:	6a 00                	push   $0x0
  8016e9:	ff 75 08             	pushl  0x8(%ebp)
  8016ec:	e8 d6 01 00 00       	call   8018c7 <open>
  8016f1:	89 c3                	mov    %eax,%ebx
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 1b                	js     801715 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	ff 75 0c             	pushl  0xc(%ebp)
  801700:	50                   	push   %eax
  801701:	e8 5b ff ff ff       	call   801661 <fstat>
  801706:	89 c6                	mov    %eax,%esi
	close(fd);
  801708:	89 1c 24             	mov    %ebx,(%esp)
  80170b:	e8 fd fb ff ff       	call   80130d <close>
	return r;
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	89 f0                	mov    %esi,%eax
}
  801715:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801718:	5b                   	pop    %ebx
  801719:	5e                   	pop    %esi
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	89 c6                	mov    %eax,%esi
  801723:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801725:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80172c:	75 12                	jne    801740 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80172e:	83 ec 0c             	sub    $0xc,%esp
  801731:	6a 01                	push   $0x1
  801733:	e8 44 0d 00 00       	call   80247c <ipc_find_env>
  801738:	a3 00 40 80 00       	mov    %eax,0x804000
  80173d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801740:	6a 07                	push   $0x7
  801742:	68 00 50 80 00       	push   $0x805000
  801747:	56                   	push   %esi
  801748:	ff 35 00 40 80 00    	pushl  0x804000
  80174e:	e8 d5 0c 00 00       	call   802428 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801753:	83 c4 0c             	add    $0xc,%esp
  801756:	6a 00                	push   $0x0
  801758:	53                   	push   %ebx
  801759:	6a 00                	push   $0x0
  80175b:	e8 61 0c 00 00       	call   8023c1 <ipc_recv>
}
  801760:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801763:	5b                   	pop    %ebx
  801764:	5e                   	pop    %esi
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80176d:	8b 45 08             	mov    0x8(%ebp),%eax
  801770:	8b 40 0c             	mov    0xc(%eax),%eax
  801773:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801778:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801780:	ba 00 00 00 00       	mov    $0x0,%edx
  801785:	b8 02 00 00 00       	mov    $0x2,%eax
  80178a:	e8 8d ff ff ff       	call   80171c <fsipc>
}
  80178f:	c9                   	leave  
  801790:	c3                   	ret    

00801791 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801797:	8b 45 08             	mov    0x8(%ebp),%eax
  80179a:	8b 40 0c             	mov    0xc(%eax),%eax
  80179d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ac:	e8 6b ff ff ff       	call   80171c <fsipc>
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d2:	e8 45 ff ff ff       	call   80171c <fsipc>
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	78 2c                	js     801807 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017db:	83 ec 08             	sub    $0x8,%esp
  8017de:	68 00 50 80 00       	push   $0x805000
  8017e3:	53                   	push   %ebx
  8017e4:	e8 99 f1 ff ff       	call   800982 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017e9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f4:	a1 84 50 80 00       	mov    0x805084,%eax
  8017f9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    

0080180c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	83 ec 0c             	sub    $0xc,%esp
  801812:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801815:	8b 55 08             	mov    0x8(%ebp),%edx
  801818:	8b 52 0c             	mov    0xc(%edx),%edx
  80181b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801821:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801826:	50                   	push   %eax
  801827:	ff 75 0c             	pushl  0xc(%ebp)
  80182a:	68 08 50 80 00       	push   $0x805008
  80182f:	e8 e0 f2 ff ff       	call   800b14 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801834:	ba 00 00 00 00       	mov    $0x0,%edx
  801839:	b8 04 00 00 00       	mov    $0x4,%eax
  80183e:	e8 d9 fe ff ff       	call   80171c <fsipc>

}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	8b 40 0c             	mov    0xc(%eax),%eax
  801853:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801858:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80185e:	ba 00 00 00 00       	mov    $0x0,%edx
  801863:	b8 03 00 00 00       	mov    $0x3,%eax
  801868:	e8 af fe ff ff       	call   80171c <fsipc>
  80186d:	89 c3                	mov    %eax,%ebx
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 4b                	js     8018be <devfile_read+0x79>
		return r;
	assert(r <= n);
  801873:	39 c6                	cmp    %eax,%esi
  801875:	73 16                	jae    80188d <devfile_read+0x48>
  801877:	68 00 2c 80 00       	push   $0x802c00
  80187c:	68 07 2c 80 00       	push   $0x802c07
  801881:	6a 7c                	push   $0x7c
  801883:	68 1c 2c 80 00       	push   $0x802c1c
  801888:	e8 97 ea ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  80188d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801892:	7e 16                	jle    8018aa <devfile_read+0x65>
  801894:	68 27 2c 80 00       	push   $0x802c27
  801899:	68 07 2c 80 00       	push   $0x802c07
  80189e:	6a 7d                	push   $0x7d
  8018a0:	68 1c 2c 80 00       	push   $0x802c1c
  8018a5:	e8 7a ea ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018aa:	83 ec 04             	sub    $0x4,%esp
  8018ad:	50                   	push   %eax
  8018ae:	68 00 50 80 00       	push   $0x805000
  8018b3:	ff 75 0c             	pushl  0xc(%ebp)
  8018b6:	e8 59 f2 ff ff       	call   800b14 <memmove>
	return r;
  8018bb:	83 c4 10             	add    $0x10,%esp
}
  8018be:	89 d8                	mov    %ebx,%eax
  8018c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	53                   	push   %ebx
  8018cb:	83 ec 20             	sub    $0x20,%esp
  8018ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d1:	53                   	push   %ebx
  8018d2:	e8 72 f0 ff ff       	call   800949 <strlen>
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018df:	7f 67                	jg     801948 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e7:	50                   	push   %eax
  8018e8:	e8 a7 f8 ff ff       	call   801194 <fd_alloc>
  8018ed:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	78 57                	js     80194d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f6:	83 ec 08             	sub    $0x8,%esp
  8018f9:	53                   	push   %ebx
  8018fa:	68 00 50 80 00       	push   $0x805000
  8018ff:	e8 7e f0 ff ff       	call   800982 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801904:	8b 45 0c             	mov    0xc(%ebp),%eax
  801907:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80190c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190f:	b8 01 00 00 00       	mov    $0x1,%eax
  801914:	e8 03 fe ff ff       	call   80171c <fsipc>
  801919:	89 c3                	mov    %eax,%ebx
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	85 c0                	test   %eax,%eax
  801920:	79 14                	jns    801936 <open+0x6f>
		fd_close(fd, 0);
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	6a 00                	push   $0x0
  801927:	ff 75 f4             	pushl  -0xc(%ebp)
  80192a:	e8 5d f9 ff ff       	call   80128c <fd_close>
		return r;
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	89 da                	mov    %ebx,%edx
  801934:	eb 17                	jmp    80194d <open+0x86>
	}

	return fd2num(fd);
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	ff 75 f4             	pushl  -0xc(%ebp)
  80193c:	e8 2c f8 ff ff       	call   80116d <fd2num>
  801941:	89 c2                	mov    %eax,%edx
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	eb 05                	jmp    80194d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801948:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80194d:	89 d0                	mov    %edx,%eax
  80194f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195a:	ba 00 00 00 00       	mov    $0x0,%edx
  80195f:	b8 08 00 00 00       	mov    $0x8,%eax
  801964:	e8 b3 fd ff ff       	call   80171c <fsipc>
}
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80196b:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80196f:	7e 37                	jle    8019a8 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	53                   	push   %ebx
  801975:	83 ec 08             	sub    $0x8,%esp
  801978:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80197a:	ff 70 04             	pushl  0x4(%eax)
  80197d:	8d 40 10             	lea    0x10(%eax),%eax
  801980:	50                   	push   %eax
  801981:	ff 33                	pushl  (%ebx)
  801983:	e8 9b fb ff ff       	call   801523 <write>
		if (result > 0)
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	7e 03                	jle    801992 <writebuf+0x27>
			b->result += result;
  80198f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801992:	3b 43 04             	cmp    0x4(%ebx),%eax
  801995:	74 0d                	je     8019a4 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801997:	85 c0                	test   %eax,%eax
  801999:	ba 00 00 00 00       	mov    $0x0,%edx
  80199e:	0f 4f c2             	cmovg  %edx,%eax
  8019a1:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8019a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a7:	c9                   	leave  
  8019a8:	f3 c3                	repz ret 

008019aa <putch>:

static void
putch(int ch, void *thunk)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	53                   	push   %ebx
  8019ae:	83 ec 04             	sub    $0x4,%esp
  8019b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019b4:	8b 53 04             	mov    0x4(%ebx),%edx
  8019b7:	8d 42 01             	lea    0x1(%edx),%eax
  8019ba:	89 43 04             	mov    %eax,0x4(%ebx)
  8019bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019c0:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019c4:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019c9:	75 0e                	jne    8019d9 <putch+0x2f>
		writebuf(b);
  8019cb:	89 d8                	mov    %ebx,%eax
  8019cd:	e8 99 ff ff ff       	call   80196b <writebuf>
		b->idx = 0;
  8019d2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8019d9:	83 c4 04             	add    $0x4,%esp
  8019dc:	5b                   	pop    %ebx
  8019dd:	5d                   	pop    %ebp
  8019de:	c3                   	ret    

008019df <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019f1:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019f8:	00 00 00 
	b.result = 0;
  8019fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a02:	00 00 00 
	b.error = 1;
  801a05:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a0c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a0f:	ff 75 10             	pushl  0x10(%ebp)
  801a12:	ff 75 0c             	pushl  0xc(%ebp)
  801a15:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a1b:	50                   	push   %eax
  801a1c:	68 aa 19 80 00       	push   $0x8019aa
  801a21:	e8 0e eb ff ff       	call   800534 <vprintfmt>
	if (b.idx > 0)
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a30:	7e 0b                	jle    801a3d <vfprintf+0x5e>
		writebuf(&b);
  801a32:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a38:	e8 2e ff ff ff       	call   80196b <writebuf>

	return (b.result ? b.result : b.error);
  801a3d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a43:	85 c0                	test   %eax,%eax
  801a45:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a54:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a57:	50                   	push   %eax
  801a58:	ff 75 0c             	pushl  0xc(%ebp)
  801a5b:	ff 75 08             	pushl  0x8(%ebp)
  801a5e:	e8 7c ff ff ff       	call   8019df <vfprintf>
	va_end(ap);

	return cnt;
}
  801a63:	c9                   	leave  
  801a64:	c3                   	ret    

00801a65 <printf>:

int
printf(const char *fmt, ...)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a6b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a6e:	50                   	push   %eax
  801a6f:	ff 75 08             	pushl  0x8(%ebp)
  801a72:	6a 01                	push   $0x1
  801a74:	e8 66 ff ff ff       	call   8019df <vfprintf>
	va_end(ap);

	return cnt;
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a81:	68 33 2c 80 00       	push   $0x802c33
  801a86:	ff 75 0c             	pushl  0xc(%ebp)
  801a89:	e8 f4 ee ff ff       	call   800982 <strcpy>
	return 0;
}
  801a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a93:	c9                   	leave  
  801a94:	c3                   	ret    

00801a95 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	53                   	push   %ebx
  801a99:	83 ec 10             	sub    $0x10,%esp
  801a9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a9f:	53                   	push   %ebx
  801aa0:	e8 10 0a 00 00       	call   8024b5 <pageref>
  801aa5:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801aa8:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801aad:	83 f8 01             	cmp    $0x1,%eax
  801ab0:	75 10                	jne    801ac2 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	ff 73 0c             	pushl  0xc(%ebx)
  801ab8:	e8 c0 02 00 00       	call   801d7d <nsipc_close>
  801abd:	89 c2                	mov    %eax,%edx
  801abf:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ac2:	89 d0                	mov    %edx,%eax
  801ac4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801acf:	6a 00                	push   $0x0
  801ad1:	ff 75 10             	pushl  0x10(%ebp)
  801ad4:	ff 75 0c             	pushl  0xc(%ebp)
  801ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ada:	ff 70 0c             	pushl  0xc(%eax)
  801add:	e8 78 03 00 00       	call   801e5a <nsipc_send>
}
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801aea:	6a 00                	push   $0x0
  801aec:	ff 75 10             	pushl  0x10(%ebp)
  801aef:	ff 75 0c             	pushl  0xc(%ebp)
  801af2:	8b 45 08             	mov    0x8(%ebp),%eax
  801af5:	ff 70 0c             	pushl  0xc(%eax)
  801af8:	e8 f1 02 00 00       	call   801dee <nsipc_recv>
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b05:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b08:	52                   	push   %edx
  801b09:	50                   	push   %eax
  801b0a:	e8 d4 f6 ff ff       	call   8011e3 <fd_lookup>
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 17                	js     801b2d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b19:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b1f:	39 08                	cmp    %ecx,(%eax)
  801b21:	75 05                	jne    801b28 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b23:	8b 40 0c             	mov    0xc(%eax),%eax
  801b26:	eb 05                	jmp    801b2d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b28:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	83 ec 1c             	sub    $0x1c,%esp
  801b37:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3c:	50                   	push   %eax
  801b3d:	e8 52 f6 ff ff       	call   801194 <fd_alloc>
  801b42:	89 c3                	mov    %eax,%ebx
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	85 c0                	test   %eax,%eax
  801b49:	78 1b                	js     801b66 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b4b:	83 ec 04             	sub    $0x4,%esp
  801b4e:	68 07 04 00 00       	push   $0x407
  801b53:	ff 75 f4             	pushl  -0xc(%ebp)
  801b56:	6a 00                	push   $0x0
  801b58:	e8 28 f2 ff ff       	call   800d85 <sys_page_alloc>
  801b5d:	89 c3                	mov    %eax,%ebx
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	85 c0                	test   %eax,%eax
  801b64:	79 10                	jns    801b76 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b66:	83 ec 0c             	sub    $0xc,%esp
  801b69:	56                   	push   %esi
  801b6a:	e8 0e 02 00 00       	call   801d7d <nsipc_close>
		return r;
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	89 d8                	mov    %ebx,%eax
  801b74:	eb 24                	jmp    801b9a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b76:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b84:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b8b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	50                   	push   %eax
  801b92:	e8 d6 f5 ff ff       	call   80116d <fd2num>
  801b97:	83 c4 10             	add    $0x10,%esp
}
  801b9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  801baa:	e8 50 ff ff ff       	call   801aff <fd2sockid>
		return r;
  801baf:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 1f                	js     801bd4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	ff 75 10             	pushl  0x10(%ebp)
  801bbb:	ff 75 0c             	pushl  0xc(%ebp)
  801bbe:	50                   	push   %eax
  801bbf:	e8 12 01 00 00       	call   801cd6 <nsipc_accept>
  801bc4:	83 c4 10             	add    $0x10,%esp
		return r;
  801bc7:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	78 07                	js     801bd4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bcd:	e8 5d ff ff ff       	call   801b2f <alloc_sockfd>
  801bd2:	89 c1                	mov    %eax,%ecx
}
  801bd4:	89 c8                	mov    %ecx,%eax
  801bd6:	c9                   	leave  
  801bd7:	c3                   	ret    

00801bd8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bde:	8b 45 08             	mov    0x8(%ebp),%eax
  801be1:	e8 19 ff ff ff       	call   801aff <fd2sockid>
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 12                	js     801bfc <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801bea:	83 ec 04             	sub    $0x4,%esp
  801bed:	ff 75 10             	pushl  0x10(%ebp)
  801bf0:	ff 75 0c             	pushl  0xc(%ebp)
  801bf3:	50                   	push   %eax
  801bf4:	e8 2d 01 00 00       	call   801d26 <nsipc_bind>
  801bf9:	83 c4 10             	add    $0x10,%esp
}
  801bfc:	c9                   	leave  
  801bfd:	c3                   	ret    

00801bfe <shutdown>:

int
shutdown(int s, int how)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	e8 f3 fe ff ff       	call   801aff <fd2sockid>
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	78 0f                	js     801c1f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c10:	83 ec 08             	sub    $0x8,%esp
  801c13:	ff 75 0c             	pushl  0xc(%ebp)
  801c16:	50                   	push   %eax
  801c17:	e8 3f 01 00 00       	call   801d5b <nsipc_shutdown>
  801c1c:	83 c4 10             	add    $0x10,%esp
}
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    

00801c21 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c27:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2a:	e8 d0 fe ff ff       	call   801aff <fd2sockid>
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	78 12                	js     801c45 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c33:	83 ec 04             	sub    $0x4,%esp
  801c36:	ff 75 10             	pushl  0x10(%ebp)
  801c39:	ff 75 0c             	pushl  0xc(%ebp)
  801c3c:	50                   	push   %eax
  801c3d:	e8 55 01 00 00       	call   801d97 <nsipc_connect>
  801c42:	83 c4 10             	add    $0x10,%esp
}
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <listen>:

int
listen(int s, int backlog)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	e8 aa fe ff ff       	call   801aff <fd2sockid>
  801c55:	85 c0                	test   %eax,%eax
  801c57:	78 0f                	js     801c68 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c59:	83 ec 08             	sub    $0x8,%esp
  801c5c:	ff 75 0c             	pushl  0xc(%ebp)
  801c5f:	50                   	push   %eax
  801c60:	e8 67 01 00 00       	call   801dcc <nsipc_listen>
  801c65:	83 c4 10             	add    $0x10,%esp
}
  801c68:	c9                   	leave  
  801c69:	c3                   	ret    

00801c6a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c70:	ff 75 10             	pushl  0x10(%ebp)
  801c73:	ff 75 0c             	pushl  0xc(%ebp)
  801c76:	ff 75 08             	pushl  0x8(%ebp)
  801c79:	e8 3a 02 00 00       	call   801eb8 <nsipc_socket>
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 05                	js     801c8a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c85:	e8 a5 fe ff ff       	call   801b2f <alloc_sockfd>
}
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	53                   	push   %ebx
  801c90:	83 ec 04             	sub    $0x4,%esp
  801c93:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c95:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c9c:	75 12                	jne    801cb0 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c9e:	83 ec 0c             	sub    $0xc,%esp
  801ca1:	6a 02                	push   $0x2
  801ca3:	e8 d4 07 00 00       	call   80247c <ipc_find_env>
  801ca8:	a3 04 40 80 00       	mov    %eax,0x804004
  801cad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cb0:	6a 07                	push   $0x7
  801cb2:	68 00 60 80 00       	push   $0x806000
  801cb7:	53                   	push   %ebx
  801cb8:	ff 35 04 40 80 00    	pushl  0x804004
  801cbe:	e8 65 07 00 00       	call   802428 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cc3:	83 c4 0c             	add    $0xc,%esp
  801cc6:	6a 00                	push   $0x0
  801cc8:	6a 00                	push   $0x0
  801cca:	6a 00                	push   $0x0
  801ccc:	e8 f0 06 00 00       	call   8023c1 <ipc_recv>
}
  801cd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd4:	c9                   	leave  
  801cd5:	c3                   	ret    

00801cd6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	56                   	push   %esi
  801cda:	53                   	push   %ebx
  801cdb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ce6:	8b 06                	mov    (%esi),%eax
  801ce8:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ced:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf2:	e8 95 ff ff ff       	call   801c8c <nsipc>
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	78 20                	js     801d1d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cfd:	83 ec 04             	sub    $0x4,%esp
  801d00:	ff 35 10 60 80 00    	pushl  0x806010
  801d06:	68 00 60 80 00       	push   $0x806000
  801d0b:	ff 75 0c             	pushl  0xc(%ebp)
  801d0e:	e8 01 ee ff ff       	call   800b14 <memmove>
		*addrlen = ret->ret_addrlen;
  801d13:	a1 10 60 80 00       	mov    0x806010,%eax
  801d18:	89 06                	mov    %eax,(%esi)
  801d1a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d1d:	89 d8                	mov    %ebx,%eax
  801d1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5e                   	pop    %esi
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    

00801d26 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	53                   	push   %ebx
  801d2a:	83 ec 08             	sub    $0x8,%esp
  801d2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d30:	8b 45 08             	mov    0x8(%ebp),%eax
  801d33:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d38:	53                   	push   %ebx
  801d39:	ff 75 0c             	pushl  0xc(%ebp)
  801d3c:	68 04 60 80 00       	push   $0x806004
  801d41:	e8 ce ed ff ff       	call   800b14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d46:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d4c:	b8 02 00 00 00       	mov    $0x2,%eax
  801d51:	e8 36 ff ff ff       	call   801c8c <nsipc>
}
  801d56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d61:	8b 45 08             	mov    0x8(%ebp),%eax
  801d64:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d71:	b8 03 00 00 00       	mov    $0x3,%eax
  801d76:	e8 11 ff ff ff       	call   801c8c <nsipc>
}
  801d7b:	c9                   	leave  
  801d7c:	c3                   	ret    

00801d7d <nsipc_close>:

int
nsipc_close(int s)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d83:	8b 45 08             	mov    0x8(%ebp),%eax
  801d86:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d8b:	b8 04 00 00 00       	mov    $0x4,%eax
  801d90:	e8 f7 fe ff ff       	call   801c8c <nsipc>
}
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	53                   	push   %ebx
  801d9b:	83 ec 08             	sub    $0x8,%esp
  801d9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801da1:	8b 45 08             	mov    0x8(%ebp),%eax
  801da4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801da9:	53                   	push   %ebx
  801daa:	ff 75 0c             	pushl  0xc(%ebp)
  801dad:	68 04 60 80 00       	push   $0x806004
  801db2:	e8 5d ed ff ff       	call   800b14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801db7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801dbd:	b8 05 00 00 00       	mov    $0x5,%eax
  801dc2:	e8 c5 fe ff ff       	call   801c8c <nsipc>
}
  801dc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801de2:	b8 06 00 00 00       	mov    $0x6,%eax
  801de7:	e8 a0 fe ff ff       	call   801c8c <nsipc>
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	56                   	push   %esi
  801df2:	53                   	push   %ebx
  801df3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801df6:	8b 45 08             	mov    0x8(%ebp),%eax
  801df9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dfe:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e04:	8b 45 14             	mov    0x14(%ebp),%eax
  801e07:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e0c:	b8 07 00 00 00       	mov    $0x7,%eax
  801e11:	e8 76 fe ff ff       	call   801c8c <nsipc>
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	78 35                	js     801e51 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e1c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e21:	7f 04                	jg     801e27 <nsipc_recv+0x39>
  801e23:	39 c6                	cmp    %eax,%esi
  801e25:	7d 16                	jge    801e3d <nsipc_recv+0x4f>
  801e27:	68 3f 2c 80 00       	push   $0x802c3f
  801e2c:	68 07 2c 80 00       	push   $0x802c07
  801e31:	6a 62                	push   $0x62
  801e33:	68 54 2c 80 00       	push   $0x802c54
  801e38:	e8 e7 e4 ff ff       	call   800324 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e3d:	83 ec 04             	sub    $0x4,%esp
  801e40:	50                   	push   %eax
  801e41:	68 00 60 80 00       	push   $0x806000
  801e46:	ff 75 0c             	pushl  0xc(%ebp)
  801e49:	e8 c6 ec ff ff       	call   800b14 <memmove>
  801e4e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e51:	89 d8                	mov    %ebx,%eax
  801e53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e56:	5b                   	pop    %ebx
  801e57:	5e                   	pop    %esi
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    

00801e5a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	53                   	push   %ebx
  801e5e:	83 ec 04             	sub    $0x4,%esp
  801e61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e64:	8b 45 08             	mov    0x8(%ebp),%eax
  801e67:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e6c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e72:	7e 16                	jle    801e8a <nsipc_send+0x30>
  801e74:	68 60 2c 80 00       	push   $0x802c60
  801e79:	68 07 2c 80 00       	push   $0x802c07
  801e7e:	6a 6d                	push   $0x6d
  801e80:	68 54 2c 80 00       	push   $0x802c54
  801e85:	e8 9a e4 ff ff       	call   800324 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e8a:	83 ec 04             	sub    $0x4,%esp
  801e8d:	53                   	push   %ebx
  801e8e:	ff 75 0c             	pushl  0xc(%ebp)
  801e91:	68 0c 60 80 00       	push   $0x80600c
  801e96:	e8 79 ec ff ff       	call   800b14 <memmove>
	nsipcbuf.send.req_size = size;
  801e9b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ea1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ea4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ea9:	b8 08 00 00 00       	mov    $0x8,%eax
  801eae:	e8 d9 fd ff ff       	call   801c8c <nsipc>
}
  801eb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec9:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ece:	8b 45 10             	mov    0x10(%ebp),%eax
  801ed1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ed6:	b8 09 00 00 00       	mov    $0x9,%eax
  801edb:	e8 ac fd ff ff       	call   801c8c <nsipc>
}
  801ee0:	c9                   	leave  
  801ee1:	c3                   	ret    

00801ee2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	56                   	push   %esi
  801ee6:	53                   	push   %ebx
  801ee7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	ff 75 08             	pushl  0x8(%ebp)
  801ef0:	e8 88 f2 ff ff       	call   80117d <fd2data>
  801ef5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ef7:	83 c4 08             	add    $0x8,%esp
  801efa:	68 6c 2c 80 00       	push   $0x802c6c
  801eff:	53                   	push   %ebx
  801f00:	e8 7d ea ff ff       	call   800982 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f05:	8b 46 04             	mov    0x4(%esi),%eax
  801f08:	2b 06                	sub    (%esi),%eax
  801f0a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f10:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f17:	00 00 00 
	stat->st_dev = &devpipe;
  801f1a:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f21:	30 80 00 
	return 0;
}
  801f24:	b8 00 00 00 00       	mov    $0x0,%eax
  801f29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2c:	5b                   	pop    %ebx
  801f2d:	5e                   	pop    %esi
  801f2e:	5d                   	pop    %ebp
  801f2f:	c3                   	ret    

00801f30 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	53                   	push   %ebx
  801f34:	83 ec 0c             	sub    $0xc,%esp
  801f37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f3a:	53                   	push   %ebx
  801f3b:	6a 00                	push   $0x0
  801f3d:	e8 c8 ee ff ff       	call   800e0a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f42:	89 1c 24             	mov    %ebx,(%esp)
  801f45:	e8 33 f2 ff ff       	call   80117d <fd2data>
  801f4a:	83 c4 08             	add    $0x8,%esp
  801f4d:	50                   	push   %eax
  801f4e:	6a 00                	push   $0x0
  801f50:	e8 b5 ee ff ff       	call   800e0a <sys_page_unmap>
}
  801f55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f58:	c9                   	leave  
  801f59:	c3                   	ret    

00801f5a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	57                   	push   %edi
  801f5e:	56                   	push   %esi
  801f5f:	53                   	push   %ebx
  801f60:	83 ec 1c             	sub    $0x1c,%esp
  801f63:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f66:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f68:	a1 20 44 80 00       	mov    0x804420,%eax
  801f6d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	ff 75 e0             	pushl  -0x20(%ebp)
  801f76:	e8 3a 05 00 00       	call   8024b5 <pageref>
  801f7b:	89 c3                	mov    %eax,%ebx
  801f7d:	89 3c 24             	mov    %edi,(%esp)
  801f80:	e8 30 05 00 00       	call   8024b5 <pageref>
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	39 c3                	cmp    %eax,%ebx
  801f8a:	0f 94 c1             	sete   %cl
  801f8d:	0f b6 c9             	movzbl %cl,%ecx
  801f90:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f93:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801f99:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f9c:	39 ce                	cmp    %ecx,%esi
  801f9e:	74 1b                	je     801fbb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fa0:	39 c3                	cmp    %eax,%ebx
  801fa2:	75 c4                	jne    801f68 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fa4:	8b 42 58             	mov    0x58(%edx),%eax
  801fa7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801faa:	50                   	push   %eax
  801fab:	56                   	push   %esi
  801fac:	68 73 2c 80 00       	push   $0x802c73
  801fb1:	e8 47 e4 ff ff       	call   8003fd <cprintf>
  801fb6:	83 c4 10             	add    $0x10,%esp
  801fb9:	eb ad                	jmp    801f68 <_pipeisclosed+0xe>
	}
}
  801fbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc1:	5b                   	pop    %ebx
  801fc2:	5e                   	pop    %esi
  801fc3:	5f                   	pop    %edi
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    

00801fc6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	57                   	push   %edi
  801fca:	56                   	push   %esi
  801fcb:	53                   	push   %ebx
  801fcc:	83 ec 28             	sub    $0x28,%esp
  801fcf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fd2:	56                   	push   %esi
  801fd3:	e8 a5 f1 ff ff       	call   80117d <fd2data>
  801fd8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	bf 00 00 00 00       	mov    $0x0,%edi
  801fe2:	eb 4b                	jmp    80202f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fe4:	89 da                	mov    %ebx,%edx
  801fe6:	89 f0                	mov    %esi,%eax
  801fe8:	e8 6d ff ff ff       	call   801f5a <_pipeisclosed>
  801fed:	85 c0                	test   %eax,%eax
  801fef:	75 48                	jne    802039 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ff1:	e8 70 ed ff ff       	call   800d66 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ff6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ff9:	8b 0b                	mov    (%ebx),%ecx
  801ffb:	8d 51 20             	lea    0x20(%ecx),%edx
  801ffe:	39 d0                	cmp    %edx,%eax
  802000:	73 e2                	jae    801fe4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802002:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802005:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802009:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80200c:	89 c2                	mov    %eax,%edx
  80200e:	c1 fa 1f             	sar    $0x1f,%edx
  802011:	89 d1                	mov    %edx,%ecx
  802013:	c1 e9 1b             	shr    $0x1b,%ecx
  802016:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802019:	83 e2 1f             	and    $0x1f,%edx
  80201c:	29 ca                	sub    %ecx,%edx
  80201e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802022:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802026:	83 c0 01             	add    $0x1,%eax
  802029:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80202c:	83 c7 01             	add    $0x1,%edi
  80202f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802032:	75 c2                	jne    801ff6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802034:	8b 45 10             	mov    0x10(%ebp),%eax
  802037:	eb 05                	jmp    80203e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802039:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80203e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802041:	5b                   	pop    %ebx
  802042:	5e                   	pop    %esi
  802043:	5f                   	pop    %edi
  802044:	5d                   	pop    %ebp
  802045:	c3                   	ret    

00802046 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	57                   	push   %edi
  80204a:	56                   	push   %esi
  80204b:	53                   	push   %ebx
  80204c:	83 ec 18             	sub    $0x18,%esp
  80204f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802052:	57                   	push   %edi
  802053:	e8 25 f1 ff ff       	call   80117d <fd2data>
  802058:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80205a:	83 c4 10             	add    $0x10,%esp
  80205d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802062:	eb 3d                	jmp    8020a1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802064:	85 db                	test   %ebx,%ebx
  802066:	74 04                	je     80206c <devpipe_read+0x26>
				return i;
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	eb 44                	jmp    8020b0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80206c:	89 f2                	mov    %esi,%edx
  80206e:	89 f8                	mov    %edi,%eax
  802070:	e8 e5 fe ff ff       	call   801f5a <_pipeisclosed>
  802075:	85 c0                	test   %eax,%eax
  802077:	75 32                	jne    8020ab <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802079:	e8 e8 ec ff ff       	call   800d66 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80207e:	8b 06                	mov    (%esi),%eax
  802080:	3b 46 04             	cmp    0x4(%esi),%eax
  802083:	74 df                	je     802064 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802085:	99                   	cltd   
  802086:	c1 ea 1b             	shr    $0x1b,%edx
  802089:	01 d0                	add    %edx,%eax
  80208b:	83 e0 1f             	and    $0x1f,%eax
  80208e:	29 d0                	sub    %edx,%eax
  802090:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802095:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802098:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80209b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80209e:	83 c3 01             	add    $0x1,%ebx
  8020a1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020a4:	75 d8                	jne    80207e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8020a9:	eb 05                	jmp    8020b0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020ab:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	56                   	push   %esi
  8020bc:	53                   	push   %ebx
  8020bd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c3:	50                   	push   %eax
  8020c4:	e8 cb f0 ff ff       	call   801194 <fd_alloc>
  8020c9:	83 c4 10             	add    $0x10,%esp
  8020cc:	89 c2                	mov    %eax,%edx
  8020ce:	85 c0                	test   %eax,%eax
  8020d0:	0f 88 2c 01 00 00    	js     802202 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d6:	83 ec 04             	sub    $0x4,%esp
  8020d9:	68 07 04 00 00       	push   $0x407
  8020de:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e1:	6a 00                	push   $0x0
  8020e3:	e8 9d ec ff ff       	call   800d85 <sys_page_alloc>
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	89 c2                	mov    %eax,%edx
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	0f 88 0d 01 00 00    	js     802202 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020f5:	83 ec 0c             	sub    $0xc,%esp
  8020f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020fb:	50                   	push   %eax
  8020fc:	e8 93 f0 ff ff       	call   801194 <fd_alloc>
  802101:	89 c3                	mov    %eax,%ebx
  802103:	83 c4 10             	add    $0x10,%esp
  802106:	85 c0                	test   %eax,%eax
  802108:	0f 88 e2 00 00 00    	js     8021f0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80210e:	83 ec 04             	sub    $0x4,%esp
  802111:	68 07 04 00 00       	push   $0x407
  802116:	ff 75 f0             	pushl  -0x10(%ebp)
  802119:	6a 00                	push   $0x0
  80211b:	e8 65 ec ff ff       	call   800d85 <sys_page_alloc>
  802120:	89 c3                	mov    %eax,%ebx
  802122:	83 c4 10             	add    $0x10,%esp
  802125:	85 c0                	test   %eax,%eax
  802127:	0f 88 c3 00 00 00    	js     8021f0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80212d:	83 ec 0c             	sub    $0xc,%esp
  802130:	ff 75 f4             	pushl  -0xc(%ebp)
  802133:	e8 45 f0 ff ff       	call   80117d <fd2data>
  802138:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80213a:	83 c4 0c             	add    $0xc,%esp
  80213d:	68 07 04 00 00       	push   $0x407
  802142:	50                   	push   %eax
  802143:	6a 00                	push   $0x0
  802145:	e8 3b ec ff ff       	call   800d85 <sys_page_alloc>
  80214a:	89 c3                	mov    %eax,%ebx
  80214c:	83 c4 10             	add    $0x10,%esp
  80214f:	85 c0                	test   %eax,%eax
  802151:	0f 88 89 00 00 00    	js     8021e0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802157:	83 ec 0c             	sub    $0xc,%esp
  80215a:	ff 75 f0             	pushl  -0x10(%ebp)
  80215d:	e8 1b f0 ff ff       	call   80117d <fd2data>
  802162:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802169:	50                   	push   %eax
  80216a:	6a 00                	push   $0x0
  80216c:	56                   	push   %esi
  80216d:	6a 00                	push   $0x0
  80216f:	e8 54 ec ff ff       	call   800dc8 <sys_page_map>
  802174:	89 c3                	mov    %eax,%ebx
  802176:	83 c4 20             	add    $0x20,%esp
  802179:	85 c0                	test   %eax,%eax
  80217b:	78 55                	js     8021d2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80217d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802183:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802186:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802192:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802198:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80219b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80219d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021a7:	83 ec 0c             	sub    $0xc,%esp
  8021aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ad:	e8 bb ef ff ff       	call   80116d <fd2num>
  8021b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021b5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021b7:	83 c4 04             	add    $0x4,%esp
  8021ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8021bd:	e8 ab ef ff ff       	call   80116d <fd2num>
  8021c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021c5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021c8:	83 c4 10             	add    $0x10,%esp
  8021cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8021d0:	eb 30                	jmp    802202 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021d2:	83 ec 08             	sub    $0x8,%esp
  8021d5:	56                   	push   %esi
  8021d6:	6a 00                	push   $0x0
  8021d8:	e8 2d ec ff ff       	call   800e0a <sys_page_unmap>
  8021dd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021e0:	83 ec 08             	sub    $0x8,%esp
  8021e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8021e6:	6a 00                	push   $0x0
  8021e8:	e8 1d ec ff ff       	call   800e0a <sys_page_unmap>
  8021ed:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021f0:	83 ec 08             	sub    $0x8,%esp
  8021f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f6:	6a 00                	push   $0x0
  8021f8:	e8 0d ec ff ff       	call   800e0a <sys_page_unmap>
  8021fd:	83 c4 10             	add    $0x10,%esp
  802200:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802202:	89 d0                	mov    %edx,%eax
  802204:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    

0080220b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802214:	50                   	push   %eax
  802215:	ff 75 08             	pushl  0x8(%ebp)
  802218:	e8 c6 ef ff ff       	call   8011e3 <fd_lookup>
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	85 c0                	test   %eax,%eax
  802222:	78 18                	js     80223c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802224:	83 ec 0c             	sub    $0xc,%esp
  802227:	ff 75 f4             	pushl  -0xc(%ebp)
  80222a:	e8 4e ef ff ff       	call   80117d <fd2data>
	return _pipeisclosed(fd, p);
  80222f:	89 c2                	mov    %eax,%edx
  802231:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802234:	e8 21 fd ff ff       	call   801f5a <_pipeisclosed>
  802239:	83 c4 10             	add    $0x10,%esp
}
  80223c:	c9                   	leave  
  80223d:	c3                   	ret    

0080223e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80223e:	55                   	push   %ebp
  80223f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802241:	b8 00 00 00 00       	mov    $0x0,%eax
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    

00802248 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80224e:	68 8b 2c 80 00       	push   $0x802c8b
  802253:	ff 75 0c             	pushl  0xc(%ebp)
  802256:	e8 27 e7 ff ff       	call   800982 <strcpy>
	return 0;
}
  80225b:	b8 00 00 00 00       	mov    $0x0,%eax
  802260:	c9                   	leave  
  802261:	c3                   	ret    

00802262 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	57                   	push   %edi
  802266:	56                   	push   %esi
  802267:	53                   	push   %ebx
  802268:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80226e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802273:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802279:	eb 2d                	jmp    8022a8 <devcons_write+0x46>
		m = n - tot;
  80227b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80227e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802280:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802283:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802288:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80228b:	83 ec 04             	sub    $0x4,%esp
  80228e:	53                   	push   %ebx
  80228f:	03 45 0c             	add    0xc(%ebp),%eax
  802292:	50                   	push   %eax
  802293:	57                   	push   %edi
  802294:	e8 7b e8 ff ff       	call   800b14 <memmove>
		sys_cputs(buf, m);
  802299:	83 c4 08             	add    $0x8,%esp
  80229c:	53                   	push   %ebx
  80229d:	57                   	push   %edi
  80229e:	e8 26 ea ff ff       	call   800cc9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022a3:	01 de                	add    %ebx,%esi
  8022a5:	83 c4 10             	add    $0x10,%esp
  8022a8:	89 f0                	mov    %esi,%eax
  8022aa:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022ad:	72 cc                	jb     80227b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022b2:	5b                   	pop    %ebx
  8022b3:	5e                   	pop    %esi
  8022b4:	5f                   	pop    %edi
  8022b5:	5d                   	pop    %ebp
  8022b6:	c3                   	ret    

008022b7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	83 ec 08             	sub    $0x8,%esp
  8022bd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022c6:	74 2a                	je     8022f2 <devcons_read+0x3b>
  8022c8:	eb 05                	jmp    8022cf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022ca:	e8 97 ea ff ff       	call   800d66 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022cf:	e8 13 ea ff ff       	call   800ce7 <sys_cgetc>
  8022d4:	85 c0                	test   %eax,%eax
  8022d6:	74 f2                	je     8022ca <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	78 16                	js     8022f2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022dc:	83 f8 04             	cmp    $0x4,%eax
  8022df:	74 0c                	je     8022ed <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022e4:	88 02                	mov    %al,(%edx)
	return 1;
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	eb 05                	jmp    8022f2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022ed:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022f2:	c9                   	leave  
  8022f3:	c3                   	ret    

008022f4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022f4:	55                   	push   %ebp
  8022f5:	89 e5                	mov    %esp,%ebp
  8022f7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802300:	6a 01                	push   $0x1
  802302:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802305:	50                   	push   %eax
  802306:	e8 be e9 ff ff       	call   800cc9 <sys_cputs>
}
  80230b:	83 c4 10             	add    $0x10,%esp
  80230e:	c9                   	leave  
  80230f:	c3                   	ret    

00802310 <getchar>:

int
getchar(void)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802316:	6a 01                	push   $0x1
  802318:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80231b:	50                   	push   %eax
  80231c:	6a 00                	push   $0x0
  80231e:	e8 26 f1 ff ff       	call   801449 <read>
	if (r < 0)
  802323:	83 c4 10             	add    $0x10,%esp
  802326:	85 c0                	test   %eax,%eax
  802328:	78 0f                	js     802339 <getchar+0x29>
		return r;
	if (r < 1)
  80232a:	85 c0                	test   %eax,%eax
  80232c:	7e 06                	jle    802334 <getchar+0x24>
		return -E_EOF;
	return c;
  80232e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802332:	eb 05                	jmp    802339 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802334:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802339:	c9                   	leave  
  80233a:	c3                   	ret    

0080233b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
  80233e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802341:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802344:	50                   	push   %eax
  802345:	ff 75 08             	pushl  0x8(%ebp)
  802348:	e8 96 ee ff ff       	call   8011e3 <fd_lookup>
  80234d:	83 c4 10             	add    $0x10,%esp
  802350:	85 c0                	test   %eax,%eax
  802352:	78 11                	js     802365 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802354:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802357:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80235d:	39 10                	cmp    %edx,(%eax)
  80235f:	0f 94 c0             	sete   %al
  802362:	0f b6 c0             	movzbl %al,%eax
}
  802365:	c9                   	leave  
  802366:	c3                   	ret    

00802367 <opencons>:

int
opencons(void)
{
  802367:	55                   	push   %ebp
  802368:	89 e5                	mov    %esp,%ebp
  80236a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80236d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802370:	50                   	push   %eax
  802371:	e8 1e ee ff ff       	call   801194 <fd_alloc>
  802376:	83 c4 10             	add    $0x10,%esp
		return r;
  802379:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80237b:	85 c0                	test   %eax,%eax
  80237d:	78 3e                	js     8023bd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80237f:	83 ec 04             	sub    $0x4,%esp
  802382:	68 07 04 00 00       	push   $0x407
  802387:	ff 75 f4             	pushl  -0xc(%ebp)
  80238a:	6a 00                	push   $0x0
  80238c:	e8 f4 e9 ff ff       	call   800d85 <sys_page_alloc>
  802391:	83 c4 10             	add    $0x10,%esp
		return r;
  802394:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802396:	85 c0                	test   %eax,%eax
  802398:	78 23                	js     8023bd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80239a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023af:	83 ec 0c             	sub    $0xc,%esp
  8023b2:	50                   	push   %eax
  8023b3:	e8 b5 ed ff ff       	call   80116d <fd2num>
  8023b8:	89 c2                	mov    %eax,%edx
  8023ba:	83 c4 10             	add    $0x10,%esp
}
  8023bd:	89 d0                	mov    %edx,%eax
  8023bf:	c9                   	leave  
  8023c0:	c3                   	ret    

008023c1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023c1:	55                   	push   %ebp
  8023c2:	89 e5                	mov    %esp,%ebp
  8023c4:	56                   	push   %esi
  8023c5:	53                   	push   %ebx
  8023c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8023c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8023cf:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8023d1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023d6:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8023d9:	83 ec 0c             	sub    $0xc,%esp
  8023dc:	50                   	push   %eax
  8023dd:	e8 53 eb ff ff       	call   800f35 <sys_ipc_recv>

	if (from_env_store != NULL)
  8023e2:	83 c4 10             	add    $0x10,%esp
  8023e5:	85 f6                	test   %esi,%esi
  8023e7:	74 14                	je     8023fd <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8023e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ee:	85 c0                	test   %eax,%eax
  8023f0:	78 09                	js     8023fb <ipc_recv+0x3a>
  8023f2:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8023f8:	8b 52 74             	mov    0x74(%edx),%edx
  8023fb:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8023fd:	85 db                	test   %ebx,%ebx
  8023ff:	74 14                	je     802415 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802401:	ba 00 00 00 00       	mov    $0x0,%edx
  802406:	85 c0                	test   %eax,%eax
  802408:	78 09                	js     802413 <ipc_recv+0x52>
  80240a:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802410:	8b 52 78             	mov    0x78(%edx),%edx
  802413:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802415:	85 c0                	test   %eax,%eax
  802417:	78 08                	js     802421 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802419:	a1 20 44 80 00       	mov    0x804420,%eax
  80241e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802421:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5d                   	pop    %ebp
  802427:	c3                   	ret    

00802428 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802428:	55                   	push   %ebp
  802429:	89 e5                	mov    %esp,%ebp
  80242b:	57                   	push   %edi
  80242c:	56                   	push   %esi
  80242d:	53                   	push   %ebx
  80242e:	83 ec 0c             	sub    $0xc,%esp
  802431:	8b 7d 08             	mov    0x8(%ebp),%edi
  802434:	8b 75 0c             	mov    0xc(%ebp),%esi
  802437:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80243a:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80243c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802441:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802444:	ff 75 14             	pushl  0x14(%ebp)
  802447:	53                   	push   %ebx
  802448:	56                   	push   %esi
  802449:	57                   	push   %edi
  80244a:	e8 c3 ea ff ff       	call   800f12 <sys_ipc_try_send>

		if (err < 0) {
  80244f:	83 c4 10             	add    $0x10,%esp
  802452:	85 c0                	test   %eax,%eax
  802454:	79 1e                	jns    802474 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802456:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802459:	75 07                	jne    802462 <ipc_send+0x3a>
				sys_yield();
  80245b:	e8 06 e9 ff ff       	call   800d66 <sys_yield>
  802460:	eb e2                	jmp    802444 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802462:	50                   	push   %eax
  802463:	68 97 2c 80 00       	push   $0x802c97
  802468:	6a 49                	push   $0x49
  80246a:	68 a4 2c 80 00       	push   $0x802ca4
  80246f:	e8 b0 de ff ff       	call   800324 <_panic>
		}

	} while (err < 0);

}
  802474:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802477:	5b                   	pop    %ebx
  802478:	5e                   	pop    %esi
  802479:	5f                   	pop    %edi
  80247a:	5d                   	pop    %ebp
  80247b:	c3                   	ret    

0080247c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80247c:	55                   	push   %ebp
  80247d:	89 e5                	mov    %esp,%ebp
  80247f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802482:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802487:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80248a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802490:	8b 52 50             	mov    0x50(%edx),%edx
  802493:	39 ca                	cmp    %ecx,%edx
  802495:	75 0d                	jne    8024a4 <ipc_find_env+0x28>
			return envs[i].env_id;
  802497:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80249a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80249f:	8b 40 48             	mov    0x48(%eax),%eax
  8024a2:	eb 0f                	jmp    8024b3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024a4:	83 c0 01             	add    $0x1,%eax
  8024a7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024ac:	75 d9                	jne    802487 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024b3:	5d                   	pop    %ebp
  8024b4:	c3                   	ret    

008024b5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024b5:	55                   	push   %ebp
  8024b6:	89 e5                	mov    %esp,%ebp
  8024b8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024bb:	89 d0                	mov    %edx,%eax
  8024bd:	c1 e8 16             	shr    $0x16,%eax
  8024c0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024c7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024cc:	f6 c1 01             	test   $0x1,%cl
  8024cf:	74 1d                	je     8024ee <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024d1:	c1 ea 0c             	shr    $0xc,%edx
  8024d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024db:	f6 c2 01             	test   $0x1,%dl
  8024de:	74 0e                	je     8024ee <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024e0:	c1 ea 0c             	shr    $0xc,%edx
  8024e3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024ea:	ef 
  8024eb:	0f b7 c0             	movzwl %ax,%eax
}
  8024ee:	5d                   	pop    %ebp
  8024ef:	c3                   	ret    

008024f0 <__udivdi3>:
  8024f0:	55                   	push   %ebp
  8024f1:	57                   	push   %edi
  8024f2:	56                   	push   %esi
  8024f3:	53                   	push   %ebx
  8024f4:	83 ec 1c             	sub    $0x1c,%esp
  8024f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802503:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802507:	85 f6                	test   %esi,%esi
  802509:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80250d:	89 ca                	mov    %ecx,%edx
  80250f:	89 f8                	mov    %edi,%eax
  802511:	75 3d                	jne    802550 <__udivdi3+0x60>
  802513:	39 cf                	cmp    %ecx,%edi
  802515:	0f 87 c5 00 00 00    	ja     8025e0 <__udivdi3+0xf0>
  80251b:	85 ff                	test   %edi,%edi
  80251d:	89 fd                	mov    %edi,%ebp
  80251f:	75 0b                	jne    80252c <__udivdi3+0x3c>
  802521:	b8 01 00 00 00       	mov    $0x1,%eax
  802526:	31 d2                	xor    %edx,%edx
  802528:	f7 f7                	div    %edi
  80252a:	89 c5                	mov    %eax,%ebp
  80252c:	89 c8                	mov    %ecx,%eax
  80252e:	31 d2                	xor    %edx,%edx
  802530:	f7 f5                	div    %ebp
  802532:	89 c1                	mov    %eax,%ecx
  802534:	89 d8                	mov    %ebx,%eax
  802536:	89 cf                	mov    %ecx,%edi
  802538:	f7 f5                	div    %ebp
  80253a:	89 c3                	mov    %eax,%ebx
  80253c:	89 d8                	mov    %ebx,%eax
  80253e:	89 fa                	mov    %edi,%edx
  802540:	83 c4 1c             	add    $0x1c,%esp
  802543:	5b                   	pop    %ebx
  802544:	5e                   	pop    %esi
  802545:	5f                   	pop    %edi
  802546:	5d                   	pop    %ebp
  802547:	c3                   	ret    
  802548:	90                   	nop
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	39 ce                	cmp    %ecx,%esi
  802552:	77 74                	ja     8025c8 <__udivdi3+0xd8>
  802554:	0f bd fe             	bsr    %esi,%edi
  802557:	83 f7 1f             	xor    $0x1f,%edi
  80255a:	0f 84 98 00 00 00    	je     8025f8 <__udivdi3+0x108>
  802560:	bb 20 00 00 00       	mov    $0x20,%ebx
  802565:	89 f9                	mov    %edi,%ecx
  802567:	89 c5                	mov    %eax,%ebp
  802569:	29 fb                	sub    %edi,%ebx
  80256b:	d3 e6                	shl    %cl,%esi
  80256d:	89 d9                	mov    %ebx,%ecx
  80256f:	d3 ed                	shr    %cl,%ebp
  802571:	89 f9                	mov    %edi,%ecx
  802573:	d3 e0                	shl    %cl,%eax
  802575:	09 ee                	or     %ebp,%esi
  802577:	89 d9                	mov    %ebx,%ecx
  802579:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80257d:	89 d5                	mov    %edx,%ebp
  80257f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802583:	d3 ed                	shr    %cl,%ebp
  802585:	89 f9                	mov    %edi,%ecx
  802587:	d3 e2                	shl    %cl,%edx
  802589:	89 d9                	mov    %ebx,%ecx
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	09 c2                	or     %eax,%edx
  80258f:	89 d0                	mov    %edx,%eax
  802591:	89 ea                	mov    %ebp,%edx
  802593:	f7 f6                	div    %esi
  802595:	89 d5                	mov    %edx,%ebp
  802597:	89 c3                	mov    %eax,%ebx
  802599:	f7 64 24 0c          	mull   0xc(%esp)
  80259d:	39 d5                	cmp    %edx,%ebp
  80259f:	72 10                	jb     8025b1 <__udivdi3+0xc1>
  8025a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025a5:	89 f9                	mov    %edi,%ecx
  8025a7:	d3 e6                	shl    %cl,%esi
  8025a9:	39 c6                	cmp    %eax,%esi
  8025ab:	73 07                	jae    8025b4 <__udivdi3+0xc4>
  8025ad:	39 d5                	cmp    %edx,%ebp
  8025af:	75 03                	jne    8025b4 <__udivdi3+0xc4>
  8025b1:	83 eb 01             	sub    $0x1,%ebx
  8025b4:	31 ff                	xor    %edi,%edi
  8025b6:	89 d8                	mov    %ebx,%eax
  8025b8:	89 fa                	mov    %edi,%edx
  8025ba:	83 c4 1c             	add    $0x1c,%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5f                   	pop    %edi
  8025c0:	5d                   	pop    %ebp
  8025c1:	c3                   	ret    
  8025c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025c8:	31 ff                	xor    %edi,%edi
  8025ca:	31 db                	xor    %ebx,%ebx
  8025cc:	89 d8                	mov    %ebx,%eax
  8025ce:	89 fa                	mov    %edi,%edx
  8025d0:	83 c4 1c             	add    $0x1c,%esp
  8025d3:	5b                   	pop    %ebx
  8025d4:	5e                   	pop    %esi
  8025d5:	5f                   	pop    %edi
  8025d6:	5d                   	pop    %ebp
  8025d7:	c3                   	ret    
  8025d8:	90                   	nop
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	89 d8                	mov    %ebx,%eax
  8025e2:	f7 f7                	div    %edi
  8025e4:	31 ff                	xor    %edi,%edi
  8025e6:	89 c3                	mov    %eax,%ebx
  8025e8:	89 d8                	mov    %ebx,%eax
  8025ea:	89 fa                	mov    %edi,%edx
  8025ec:	83 c4 1c             	add    $0x1c,%esp
  8025ef:	5b                   	pop    %ebx
  8025f0:	5e                   	pop    %esi
  8025f1:	5f                   	pop    %edi
  8025f2:	5d                   	pop    %ebp
  8025f3:	c3                   	ret    
  8025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f8:	39 ce                	cmp    %ecx,%esi
  8025fa:	72 0c                	jb     802608 <__udivdi3+0x118>
  8025fc:	31 db                	xor    %ebx,%ebx
  8025fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802602:	0f 87 34 ff ff ff    	ja     80253c <__udivdi3+0x4c>
  802608:	bb 01 00 00 00       	mov    $0x1,%ebx
  80260d:	e9 2a ff ff ff       	jmp    80253c <__udivdi3+0x4c>
  802612:	66 90                	xchg   %ax,%ax
  802614:	66 90                	xchg   %ax,%ax
  802616:	66 90                	xchg   %ax,%ax
  802618:	66 90                	xchg   %ax,%ax
  80261a:	66 90                	xchg   %ax,%ax
  80261c:	66 90                	xchg   %ax,%ax
  80261e:	66 90                	xchg   %ax,%ax

00802620 <__umoddi3>:
  802620:	55                   	push   %ebp
  802621:	57                   	push   %edi
  802622:	56                   	push   %esi
  802623:	53                   	push   %ebx
  802624:	83 ec 1c             	sub    $0x1c,%esp
  802627:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80262b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80262f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802633:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802637:	85 d2                	test   %edx,%edx
  802639:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80263d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802641:	89 f3                	mov    %esi,%ebx
  802643:	89 3c 24             	mov    %edi,(%esp)
  802646:	89 74 24 04          	mov    %esi,0x4(%esp)
  80264a:	75 1c                	jne    802668 <__umoddi3+0x48>
  80264c:	39 f7                	cmp    %esi,%edi
  80264e:	76 50                	jbe    8026a0 <__umoddi3+0x80>
  802650:	89 c8                	mov    %ecx,%eax
  802652:	89 f2                	mov    %esi,%edx
  802654:	f7 f7                	div    %edi
  802656:	89 d0                	mov    %edx,%eax
  802658:	31 d2                	xor    %edx,%edx
  80265a:	83 c4 1c             	add    $0x1c,%esp
  80265d:	5b                   	pop    %ebx
  80265e:	5e                   	pop    %esi
  80265f:	5f                   	pop    %edi
  802660:	5d                   	pop    %ebp
  802661:	c3                   	ret    
  802662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802668:	39 f2                	cmp    %esi,%edx
  80266a:	89 d0                	mov    %edx,%eax
  80266c:	77 52                	ja     8026c0 <__umoddi3+0xa0>
  80266e:	0f bd ea             	bsr    %edx,%ebp
  802671:	83 f5 1f             	xor    $0x1f,%ebp
  802674:	75 5a                	jne    8026d0 <__umoddi3+0xb0>
  802676:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80267a:	0f 82 e0 00 00 00    	jb     802760 <__umoddi3+0x140>
  802680:	39 0c 24             	cmp    %ecx,(%esp)
  802683:	0f 86 d7 00 00 00    	jbe    802760 <__umoddi3+0x140>
  802689:	8b 44 24 08          	mov    0x8(%esp),%eax
  80268d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802691:	83 c4 1c             	add    $0x1c,%esp
  802694:	5b                   	pop    %ebx
  802695:	5e                   	pop    %esi
  802696:	5f                   	pop    %edi
  802697:	5d                   	pop    %ebp
  802698:	c3                   	ret    
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	85 ff                	test   %edi,%edi
  8026a2:	89 fd                	mov    %edi,%ebp
  8026a4:	75 0b                	jne    8026b1 <__umoddi3+0x91>
  8026a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ab:	31 d2                	xor    %edx,%edx
  8026ad:	f7 f7                	div    %edi
  8026af:	89 c5                	mov    %eax,%ebp
  8026b1:	89 f0                	mov    %esi,%eax
  8026b3:	31 d2                	xor    %edx,%edx
  8026b5:	f7 f5                	div    %ebp
  8026b7:	89 c8                	mov    %ecx,%eax
  8026b9:	f7 f5                	div    %ebp
  8026bb:	89 d0                	mov    %edx,%eax
  8026bd:	eb 99                	jmp    802658 <__umoddi3+0x38>
  8026bf:	90                   	nop
  8026c0:	89 c8                	mov    %ecx,%eax
  8026c2:	89 f2                	mov    %esi,%edx
  8026c4:	83 c4 1c             	add    $0x1c,%esp
  8026c7:	5b                   	pop    %ebx
  8026c8:	5e                   	pop    %esi
  8026c9:	5f                   	pop    %edi
  8026ca:	5d                   	pop    %ebp
  8026cb:	c3                   	ret    
  8026cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	8b 34 24             	mov    (%esp),%esi
  8026d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026d8:	89 e9                	mov    %ebp,%ecx
  8026da:	29 ef                	sub    %ebp,%edi
  8026dc:	d3 e0                	shl    %cl,%eax
  8026de:	89 f9                	mov    %edi,%ecx
  8026e0:	89 f2                	mov    %esi,%edx
  8026e2:	d3 ea                	shr    %cl,%edx
  8026e4:	89 e9                	mov    %ebp,%ecx
  8026e6:	09 c2                	or     %eax,%edx
  8026e8:	89 d8                	mov    %ebx,%eax
  8026ea:	89 14 24             	mov    %edx,(%esp)
  8026ed:	89 f2                	mov    %esi,%edx
  8026ef:	d3 e2                	shl    %cl,%edx
  8026f1:	89 f9                	mov    %edi,%ecx
  8026f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026fb:	d3 e8                	shr    %cl,%eax
  8026fd:	89 e9                	mov    %ebp,%ecx
  8026ff:	89 c6                	mov    %eax,%esi
  802701:	d3 e3                	shl    %cl,%ebx
  802703:	89 f9                	mov    %edi,%ecx
  802705:	89 d0                	mov    %edx,%eax
  802707:	d3 e8                	shr    %cl,%eax
  802709:	89 e9                	mov    %ebp,%ecx
  80270b:	09 d8                	or     %ebx,%eax
  80270d:	89 d3                	mov    %edx,%ebx
  80270f:	89 f2                	mov    %esi,%edx
  802711:	f7 34 24             	divl   (%esp)
  802714:	89 d6                	mov    %edx,%esi
  802716:	d3 e3                	shl    %cl,%ebx
  802718:	f7 64 24 04          	mull   0x4(%esp)
  80271c:	39 d6                	cmp    %edx,%esi
  80271e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802722:	89 d1                	mov    %edx,%ecx
  802724:	89 c3                	mov    %eax,%ebx
  802726:	72 08                	jb     802730 <__umoddi3+0x110>
  802728:	75 11                	jne    80273b <__umoddi3+0x11b>
  80272a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80272e:	73 0b                	jae    80273b <__umoddi3+0x11b>
  802730:	2b 44 24 04          	sub    0x4(%esp),%eax
  802734:	1b 14 24             	sbb    (%esp),%edx
  802737:	89 d1                	mov    %edx,%ecx
  802739:	89 c3                	mov    %eax,%ebx
  80273b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80273f:	29 da                	sub    %ebx,%edx
  802741:	19 ce                	sbb    %ecx,%esi
  802743:	89 f9                	mov    %edi,%ecx
  802745:	89 f0                	mov    %esi,%eax
  802747:	d3 e0                	shl    %cl,%eax
  802749:	89 e9                	mov    %ebp,%ecx
  80274b:	d3 ea                	shr    %cl,%edx
  80274d:	89 e9                	mov    %ebp,%ecx
  80274f:	d3 ee                	shr    %cl,%esi
  802751:	09 d0                	or     %edx,%eax
  802753:	89 f2                	mov    %esi,%edx
  802755:	83 c4 1c             	add    $0x1c,%esp
  802758:	5b                   	pop    %ebx
  802759:	5e                   	pop    %esi
  80275a:	5f                   	pop    %edi
  80275b:	5d                   	pop    %ebp
  80275c:	c3                   	ret    
  80275d:	8d 76 00             	lea    0x0(%esi),%esi
  802760:	29 f9                	sub    %edi,%ecx
  802762:	19 d6                	sbb    %edx,%esi
  802764:	89 74 24 04          	mov    %esi,0x4(%esp)
  802768:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80276c:	e9 18 ff ff ff       	jmp    802689 <__umoddi3+0x69>
