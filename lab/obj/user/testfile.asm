
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 07 06 00 00       	call   800638 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 af 0c 00 00       	call   800cf6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 4c 13 00 00       	call   8013a5 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 e9 12 00 00       	call   801351 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 71 12 00 00       	call   8012ea <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 80 23 80 00       	mov    $0x802380,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 8b 23 80 00       	push   $0x80238b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 a5 23 80 00       	push   $0x8023a5
  8000b4:	e8 df 05 00 00       	call   800698 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 20 25 80 00       	push   $0x802520
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 a5 23 80 00       	push   $0x8023a5
  8000cc:	e8 c7 05 00 00       	call   800698 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 b5 23 80 00       	mov    $0x8023b5,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 be 23 80 00       	push   $0x8023be
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 a5 23 80 00       	push   $0x8023a5
  8000f1:	e8 a2 05 00 00       	call   800698 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 44 25 80 00       	push   $0x802544
  800119:	6a 27                	push   $0x27
  80011b:	68 a5 23 80 00       	push   $0x8023a5
  800120:	e8 73 05 00 00       	call   800698 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 d6 23 80 00       	push   $0x8023d6
  80012d:	e8 3f 06 00 00       	call   800771 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 ea 23 80 00       	push   $0x8023ea
  800154:	6a 2b                	push   $0x2b
  800156:	68 a5 23 80 00       	push   $0x8023a5
  80015b:	e8 38 05 00 00       	call   800698 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 4f 0b 00 00       	call   800cbd <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 39 0b 00 00       	call   800cbd <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 74 25 80 00       	push   $0x802574
  80018f:	6a 2d                	push   $0x2d
  800191:	68 a5 23 80 00       	push   $0x8023a5
  800196:	e8 fd 04 00 00       	call   800698 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 f8 23 80 00       	push   $0x8023f8
  8001a3:	e8 c9 05 00 00       	call   800771 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 7d 0c 00 00       	call   800e3b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 0b 24 80 00       	push   $0x80240b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 a5 23 80 00       	push   $0x8023a5
  8001e6:	e8 ad 04 00 00       	call   800698 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 a0 0b 00 00       	call   800da0 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 24                	je     80022b <umain+0x1ad>
		panic("file_read returned wrong data, buf[%d]: %s\n", strlen(buf), buf);
  800207:	83 ec 0c             	sub    $0xc,%esp
  80020a:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800210:	53                   	push   %ebx
  800211:	e8 a7 0a 00 00       	call   800cbd <strlen>
  800216:	89 1c 24             	mov    %ebx,(%esp)
  800219:	50                   	push   %eax
  80021a:	68 9c 25 80 00       	push   $0x80259c
  80021f:	6a 34                	push   $0x34
  800221:	68 a5 23 80 00       	push   $0x8023a5
  800226:	e8 6d 04 00 00       	call   800698 <_panic>
	cprintf("file_read is good\n");
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	68 19 24 80 00       	push   $0x802419
  800233:	e8 39 05 00 00       	call   800771 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800238:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80023f:	ff 15 18 30 80 00    	call   *0x803018
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	85 c0                	test   %eax,%eax
  80024a:	79 12                	jns    80025e <umain+0x1e0>
		panic("file_close: %e", r);
  80024c:	50                   	push   %eax
  80024d:	68 2c 24 80 00       	push   $0x80242c
  800252:	6a 38                	push   $0x38
  800254:	68 a5 23 80 00       	push   $0x8023a5
  800259:	e8 3a 04 00 00       	call   800698 <_panic>
	cprintf("file_close is good\n");
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	68 3b 24 80 00       	push   $0x80243b
  800266:	e8 06 05 00 00       	call   800771 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80026b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800270:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800273:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800278:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80027b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800280:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800283:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800288:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80028b:	83 c4 08             	add    $0x8,%esp
  80028e:	68 00 c0 cc cc       	push   $0xccccc000
  800293:	6a 00                	push   $0x0
  800295:	e8 e4 0e 00 00       	call   80117e <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80029a:	83 c4 0c             	add    $0xc,%esp
  80029d:	68 00 02 00 00       	push   $0x200
  8002a2:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8002a8:	50                   	push   %eax
  8002a9:	8d 45 d8             	lea    -0x28(%ebp),%eax
  8002ac:	50                   	push   %eax
  8002ad:	ff 15 10 30 80 00    	call   *0x803010
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002b9:	74 12                	je     8002cd <umain+0x24f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002bb:	50                   	push   %eax
  8002bc:	68 c8 25 80 00       	push   $0x8025c8
  8002c1:	6a 43                	push   $0x43
  8002c3:	68 a5 23 80 00       	push   $0x8023a5
  8002c8:	e8 cb 03 00 00       	call   800698 <_panic>
	cprintf("stale fileid is good\n");
  8002cd:	83 ec 0c             	sub    $0xc,%esp
  8002d0:	68 4f 24 80 00       	push   $0x80244f
  8002d5:	e8 97 04 00 00       	call   800771 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002da:	ba 02 01 00 00       	mov    $0x102,%edx
  8002df:	b8 65 24 80 00       	mov    $0x802465,%eax
  8002e4:	e8 4a fd ff ff       	call   800033 <xopen>
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	79 12                	jns    800302 <umain+0x284>
		panic("serve_open /new-file: %e", r);
  8002f0:	50                   	push   %eax
  8002f1:	68 6f 24 80 00       	push   $0x80246f
  8002f6:	6a 48                	push   $0x48
  8002f8:	68 a5 23 80 00       	push   $0x8023a5
  8002fd:	e8 96 03 00 00       	call   800698 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800302:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  800308:	83 ec 0c             	sub    $0xc,%esp
  80030b:	ff 35 00 30 80 00    	pushl  0x803000
  800311:	e8 a7 09 00 00       	call   800cbd <strlen>
  800316:	83 c4 0c             	add    $0xc,%esp
  800319:	50                   	push   %eax
  80031a:	ff 35 00 30 80 00    	pushl  0x803000
  800320:	68 00 c0 cc cc       	push   $0xccccc000
  800325:	ff d3                	call   *%ebx
  800327:	89 c3                	mov    %eax,%ebx
  800329:	83 c4 04             	add    $0x4,%esp
  80032c:	ff 35 00 30 80 00    	pushl  0x803000
  800332:	e8 86 09 00 00       	call   800cbd <strlen>
  800337:	83 c4 10             	add    $0x10,%esp
  80033a:	39 c3                	cmp    %eax,%ebx
  80033c:	74 12                	je     800350 <umain+0x2d2>
		panic("file_write: %e", r);
  80033e:	53                   	push   %ebx
  80033f:	68 88 24 80 00       	push   $0x802488
  800344:	6a 4b                	push   $0x4b
  800346:	68 a5 23 80 00       	push   $0x8023a5
  80034b:	e8 48 03 00 00       	call   800698 <_panic>
	cprintf("file_write is good\n");
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	68 97 24 80 00       	push   $0x802497
  800358:	e8 14 04 00 00       	call   800771 <cprintf>

	FVA->fd_offset = 0;
  80035d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800364:	00 00 00 
	memset(buf, 0, sizeof buf);
  800367:	83 c4 0c             	add    $0xc,%esp
  80036a:	68 00 02 00 00       	push   $0x200
  80036f:	6a 00                	push   $0x0
  800371:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800377:	53                   	push   %ebx
  800378:	e8 be 0a 00 00       	call   800e3b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80037d:	83 c4 0c             	add    $0xc,%esp
  800380:	68 00 02 00 00       	push   $0x200
  800385:	53                   	push   %ebx
  800386:	68 00 c0 cc cc       	push   $0xccccc000
  80038b:	ff 15 10 30 80 00    	call   *0x803010
  800391:	89 c3                	mov    %eax,%ebx
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	85 c0                	test   %eax,%eax
  800398:	79 12                	jns    8003ac <umain+0x32e>
		panic("file_read after file_write: %e", r);
  80039a:	50                   	push   %eax
  80039b:	68 00 26 80 00       	push   $0x802600
  8003a0:	6a 51                	push   $0x51
  8003a2:	68 a5 23 80 00       	push   $0x8023a5
  8003a7:	e8 ec 02 00 00       	call   800698 <_panic>
	if (r != strlen(msg))
  8003ac:	83 ec 0c             	sub    $0xc,%esp
  8003af:	ff 35 00 30 80 00    	pushl  0x803000
  8003b5:	e8 03 09 00 00       	call   800cbd <strlen>
  8003ba:	83 c4 10             	add    $0x10,%esp
  8003bd:	39 c3                	cmp    %eax,%ebx
  8003bf:	74 12                	je     8003d3 <umain+0x355>
		panic("file_read after file_write returned wrong length: %d", r);
  8003c1:	53                   	push   %ebx
  8003c2:	68 20 26 80 00       	push   $0x802620
  8003c7:	6a 53                	push   $0x53
  8003c9:	68 a5 23 80 00       	push   $0x8023a5
  8003ce:	e8 c5 02 00 00       	call   800698 <_panic>
	if (strcmp(buf, msg) != 0)
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	ff 35 00 30 80 00    	pushl  0x803000
  8003dc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003e2:	50                   	push   %eax
  8003e3:	e8 b8 09 00 00       	call   800da0 <strcmp>
  8003e8:	83 c4 10             	add    $0x10,%esp
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	74 14                	je     800403 <umain+0x385>
		panic("file_read after file_write returned wrong data");
  8003ef:	83 ec 04             	sub    $0x4,%esp
  8003f2:	68 58 26 80 00       	push   $0x802658
  8003f7:	6a 55                	push   $0x55
  8003f9:	68 a5 23 80 00       	push   $0x8023a5
  8003fe:	e8 95 02 00 00       	call   800698 <_panic>
	cprintf("file_read after file_write is good\n");
  800403:	83 ec 0c             	sub    $0xc,%esp
  800406:	68 88 26 80 00       	push   $0x802688
  80040b:	e8 61 03 00 00       	call   800771 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800410:	83 c4 08             	add    $0x8,%esp
  800413:	6a 00                	push   $0x0
  800415:	68 80 23 80 00       	push   $0x802380
  80041a:	e8 fa 16 00 00       	call   801b19 <open>
  80041f:	83 c4 10             	add    $0x10,%esp
  800422:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800425:	74 1b                	je     800442 <umain+0x3c4>
  800427:	89 c2                	mov    %eax,%edx
  800429:	c1 ea 1f             	shr    $0x1f,%edx
  80042c:	84 d2                	test   %dl,%dl
  80042e:	74 12                	je     800442 <umain+0x3c4>
		panic("open /not-found: %e", r);
  800430:	50                   	push   %eax
  800431:	68 91 23 80 00       	push   $0x802391
  800436:	6a 5a                	push   $0x5a
  800438:	68 a5 23 80 00       	push   $0x8023a5
  80043d:	e8 56 02 00 00       	call   800698 <_panic>
	else if (r >= 0)
  800442:	85 c0                	test   %eax,%eax
  800444:	78 14                	js     80045a <umain+0x3dc>
		panic("open /not-found succeeded!");
  800446:	83 ec 04             	sub    $0x4,%esp
  800449:	68 ab 24 80 00       	push   $0x8024ab
  80044e:	6a 5c                	push   $0x5c
  800450:	68 a5 23 80 00       	push   $0x8023a5
  800455:	e8 3e 02 00 00       	call   800698 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	6a 00                	push   $0x0
  80045f:	68 b5 23 80 00       	push   $0x8023b5
  800464:	e8 b0 16 00 00       	call   801b19 <open>
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	85 c0                	test   %eax,%eax
  80046e:	79 12                	jns    800482 <umain+0x404>
		panic("open /newmotd: %e", r);
  800470:	50                   	push   %eax
  800471:	68 c4 23 80 00       	push   $0x8023c4
  800476:	6a 5f                	push   $0x5f
  800478:	68 a5 23 80 00       	push   $0x8023a5
  80047d:	e8 16 02 00 00       	call   800698 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800482:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800485:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80048c:	75 12                	jne    8004a0 <umain+0x422>
  80048e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800495:	75 09                	jne    8004a0 <umain+0x422>
  800497:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80049e:	74 14                	je     8004b4 <umain+0x436>
		panic("open did not fill struct Fd correctly\n");
  8004a0:	83 ec 04             	sub    $0x4,%esp
  8004a3:	68 ac 26 80 00       	push   $0x8026ac
  8004a8:	6a 62                	push   $0x62
  8004aa:	68 a5 23 80 00       	push   $0x8023a5
  8004af:	e8 e4 01 00 00       	call   800698 <_panic>
	cprintf("open is good\n");
  8004b4:	83 ec 0c             	sub    $0xc,%esp
  8004b7:	68 dc 23 80 00       	push   $0x8023dc
  8004bc:	e8 b0 02 00 00       	call   800771 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004c1:	83 c4 08             	add    $0x8,%esp
  8004c4:	68 01 01 00 00       	push   $0x101
  8004c9:	68 c6 24 80 00       	push   $0x8024c6
  8004ce:	e8 46 16 00 00       	call   801b19 <open>
  8004d3:	89 c6                	mov    %eax,%esi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	79 12                	jns    8004ee <umain+0x470>
		panic("creat /big: %e", f);
  8004dc:	50                   	push   %eax
  8004dd:	68 cb 24 80 00       	push   $0x8024cb
  8004e2:	6a 67                	push   $0x67
  8004e4:	68 a5 23 80 00       	push   $0x8023a5
  8004e9:	e8 aa 01 00 00       	call   800698 <_panic>
	memset(buf, 0, sizeof(buf));
  8004ee:	83 ec 04             	sub    $0x4,%esp
  8004f1:	68 00 02 00 00       	push   $0x200
  8004f6:	6a 00                	push   $0x0
  8004f8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004fe:	50                   	push   %eax
  8004ff:	e8 37 09 00 00       	call   800e3b <memset>
  800504:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800507:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  80050c:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800512:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800518:	83 ec 04             	sub    $0x4,%esp
  80051b:	68 00 02 00 00       	push   $0x200
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	e8 6d 12 00 00       	call   801794 <write>
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	85 c0                	test   %eax,%eax
  80052c:	79 16                	jns    800544 <umain+0x4c6>
			panic("write /big@%d: %e", i, r);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	50                   	push   %eax
  800532:	53                   	push   %ebx
  800533:	68 da 24 80 00       	push   $0x8024da
  800538:	6a 6c                	push   $0x6c
  80053a:	68 a5 23 80 00       	push   $0x8023a5
  80053f:	e8 54 01 00 00       	call   800698 <_panic>
  800544:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80054a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80054c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800551:	75 bf                	jne    800512 <umain+0x494>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800553:	83 ec 0c             	sub    $0xc,%esp
  800556:	56                   	push   %esi
  800557:	e8 22 10 00 00       	call   80157e <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	6a 00                	push   $0x0
  800561:	68 c6 24 80 00       	push   $0x8024c6
  800566:	e8 ae 15 00 00       	call   801b19 <open>
  80056b:	89 c6                	mov    %eax,%esi
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	85 c0                	test   %eax,%eax
  800572:	79 12                	jns    800586 <umain+0x508>
		panic("open /big: %e", f);
  800574:	50                   	push   %eax
  800575:	68 ec 24 80 00       	push   $0x8024ec
  80057a:	6a 71                	push   $0x71
  80057c:	68 a5 23 80 00       	push   $0x8023a5
  800581:	e8 12 01 00 00       	call   800698 <_panic>
  800586:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80058b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800591:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800597:	83 ec 04             	sub    $0x4,%esp
  80059a:	68 00 02 00 00       	push   $0x200
  80059f:	57                   	push   %edi
  8005a0:	56                   	push   %esi
  8005a1:	e8 a5 11 00 00       	call   80174b <readn>
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	79 16                	jns    8005c3 <umain+0x545>
			panic("read /big@%d: %e", i, r);
  8005ad:	83 ec 0c             	sub    $0xc,%esp
  8005b0:	50                   	push   %eax
  8005b1:	53                   	push   %ebx
  8005b2:	68 fa 24 80 00       	push   $0x8024fa
  8005b7:	6a 75                	push   $0x75
  8005b9:	68 a5 23 80 00       	push   $0x8023a5
  8005be:	e8 d5 00 00 00       	call   800698 <_panic>
		if (r != sizeof(buf))
  8005c3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005c8:	74 1b                	je     8005e5 <umain+0x567>
			panic("read /big from %d returned %d < %d bytes",
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	68 00 02 00 00       	push   $0x200
  8005d2:	50                   	push   %eax
  8005d3:	53                   	push   %ebx
  8005d4:	68 d4 26 80 00       	push   $0x8026d4
  8005d9:	6a 78                	push   $0x78
  8005db:	68 a5 23 80 00       	push   $0x8023a5
  8005e0:	e8 b3 00 00 00       	call   800698 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005e5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005eb:	39 d8                	cmp    %ebx,%eax
  8005ed:	74 16                	je     800605 <umain+0x587>
			panic("read /big from %d returned bad data %d",
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	50                   	push   %eax
  8005f3:	53                   	push   %ebx
  8005f4:	68 00 27 80 00       	push   $0x802700
  8005f9:	6a 7b                	push   $0x7b
  8005fb:	68 a5 23 80 00       	push   $0x8023a5
  800600:	e8 93 00 00 00       	call   800698 <_panic>
  800605:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80060b:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80060d:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800612:	0f 85 79 ff ff ff    	jne    800591 <umain+0x513>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800618:	83 ec 0c             	sub    $0xc,%esp
  80061b:	56                   	push   %esi
  80061c:	e8 5d 0f 00 00       	call   80157e <close>
	cprintf("large file is good\n");
  800621:	c7 04 24 0b 25 80 00 	movl   $0x80250b,(%esp)
  800628:	e8 44 01 00 00       	call   800771 <cprintf>
}
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800633:	5b                   	pop    %ebx
  800634:	5e                   	pop    %esi
  800635:	5f                   	pop    %edi
  800636:	5d                   	pop    %ebp
  800637:	c3                   	ret    

00800638 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	56                   	push   %esi
  80063c:	53                   	push   %ebx
  80063d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800640:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800643:	e8 73 0a 00 00       	call   8010bb <sys_getenvid>
  800648:	25 ff 03 00 00       	and    $0x3ff,%eax
  80064d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800650:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800655:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80065a:	85 db                	test   %ebx,%ebx
  80065c:	7e 07                	jle    800665 <libmain+0x2d>
		binaryname = argv[0];
  80065e:	8b 06                	mov    (%esi),%eax
  800660:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	56                   	push   %esi
  800669:	53                   	push   %ebx
  80066a:	e8 0f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80066f:	e8 0a 00 00 00       	call   80067e <exit>
}
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80067a:	5b                   	pop    %ebx
  80067b:	5e                   	pop    %esi
  80067c:	5d                   	pop    %ebp
  80067d:	c3                   	ret    

0080067e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800684:	e8 20 0f 00 00       	call   8015a9 <close_all>
	sys_env_destroy(0);
  800689:	83 ec 0c             	sub    $0xc,%esp
  80068c:	6a 00                	push   $0x0
  80068e:	e8 e7 09 00 00       	call   80107a <sys_env_destroy>
}
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	c9                   	leave  
  800697:	c3                   	ret    

00800698 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	56                   	push   %esi
  80069c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80069d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006a0:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8006a6:	e8 10 0a 00 00       	call   8010bb <sys_getenvid>
  8006ab:	83 ec 0c             	sub    $0xc,%esp
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	ff 75 08             	pushl  0x8(%ebp)
  8006b4:	56                   	push   %esi
  8006b5:	50                   	push   %eax
  8006b6:	68 58 27 80 00       	push   $0x802758
  8006bb:	e8 b1 00 00 00       	call   800771 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006c0:	83 c4 18             	add    $0x18,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	ff 75 10             	pushl  0x10(%ebp)
  8006c7:	e8 54 00 00 00       	call   800720 <vcprintf>
	cprintf("\n");
  8006cc:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  8006d3:	e8 99 00 00 00       	call   800771 <cprintf>
  8006d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006db:	cc                   	int3   
  8006dc:	eb fd                	jmp    8006db <_panic+0x43>

008006de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	53                   	push   %ebx
  8006e2:	83 ec 04             	sub    $0x4,%esp
  8006e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006e8:	8b 13                	mov    (%ebx),%edx
  8006ea:	8d 42 01             	lea    0x1(%edx),%eax
  8006ed:	89 03                	mov    %eax,(%ebx)
  8006ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006fb:	75 1a                	jne    800717 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	68 ff 00 00 00       	push   $0xff
  800705:	8d 43 08             	lea    0x8(%ebx),%eax
  800708:	50                   	push   %eax
  800709:	e8 2f 09 00 00       	call   80103d <sys_cputs>
		b->idx = 0;
  80070e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800714:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800717:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80071b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800729:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800730:	00 00 00 
	b.cnt = 0;
  800733:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80073a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	ff 75 08             	pushl  0x8(%ebp)
  800743:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800749:	50                   	push   %eax
  80074a:	68 de 06 80 00       	push   $0x8006de
  80074f:	e8 54 01 00 00       	call   8008a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800754:	83 c4 08             	add    $0x8,%esp
  800757:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80075d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	e8 d4 08 00 00       	call   80103d <sys_cputs>

	return b.cnt;
}
  800769:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80076f:	c9                   	leave  
  800770:	c3                   	ret    

00800771 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800777:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80077a:	50                   	push   %eax
  80077b:	ff 75 08             	pushl  0x8(%ebp)
  80077e:	e8 9d ff ff ff       	call   800720 <vcprintf>
	va_end(ap);

	return cnt;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	57                   	push   %edi
  800789:	56                   	push   %esi
  80078a:	53                   	push   %ebx
  80078b:	83 ec 1c             	sub    $0x1c,%esp
  80078e:	89 c7                	mov    %eax,%edi
  800790:	89 d6                	mov    %edx,%esi
  800792:	8b 45 08             	mov    0x8(%ebp),%eax
  800795:	8b 55 0c             	mov    0xc(%ebp),%edx
  800798:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80079e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8007a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007ac:	39 d3                	cmp    %edx,%ebx
  8007ae:	72 05                	jb     8007b5 <printnum+0x30>
  8007b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007b3:	77 45                	ja     8007fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007b5:	83 ec 0c             	sub    $0xc,%esp
  8007b8:	ff 75 18             	pushl  0x18(%ebp)
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007c1:	53                   	push   %ebx
  8007c2:	ff 75 10             	pushl  0x10(%ebp)
  8007c5:	83 ec 08             	sub    $0x8,%esp
  8007c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8007d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007d4:	e8 07 19 00 00       	call   8020e0 <__udivdi3>
  8007d9:	83 c4 18             	add    $0x18,%esp
  8007dc:	52                   	push   %edx
  8007dd:	50                   	push   %eax
  8007de:	89 f2                	mov    %esi,%edx
  8007e0:	89 f8                	mov    %edi,%eax
  8007e2:	e8 9e ff ff ff       	call   800785 <printnum>
  8007e7:	83 c4 20             	add    $0x20,%esp
  8007ea:	eb 18                	jmp    800804 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	56                   	push   %esi
  8007f0:	ff 75 18             	pushl  0x18(%ebp)
  8007f3:	ff d7                	call   *%edi
  8007f5:	83 c4 10             	add    $0x10,%esp
  8007f8:	eb 03                	jmp    8007fd <printnum+0x78>
  8007fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007fd:	83 eb 01             	sub    $0x1,%ebx
  800800:	85 db                	test   %ebx,%ebx
  800802:	7f e8                	jg     8007ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800804:	83 ec 08             	sub    $0x8,%esp
  800807:	56                   	push   %esi
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80080e:	ff 75 e0             	pushl  -0x20(%ebp)
  800811:	ff 75 dc             	pushl  -0x24(%ebp)
  800814:	ff 75 d8             	pushl  -0x28(%ebp)
  800817:	e8 f4 19 00 00       	call   802210 <__umoddi3>
  80081c:	83 c4 14             	add    $0x14,%esp
  80081f:	0f be 80 7b 27 80 00 	movsbl 0x80277b(%eax),%eax
  800826:	50                   	push   %eax
  800827:	ff d7                	call   *%edi
}
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80082f:	5b                   	pop    %ebx
  800830:	5e                   	pop    %esi
  800831:	5f                   	pop    %edi
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800837:	83 fa 01             	cmp    $0x1,%edx
  80083a:	7e 0e                	jle    80084a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80083c:	8b 10                	mov    (%eax),%edx
  80083e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800841:	89 08                	mov    %ecx,(%eax)
  800843:	8b 02                	mov    (%edx),%eax
  800845:	8b 52 04             	mov    0x4(%edx),%edx
  800848:	eb 22                	jmp    80086c <getuint+0x38>
	else if (lflag)
  80084a:	85 d2                	test   %edx,%edx
  80084c:	74 10                	je     80085e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8d 4a 04             	lea    0x4(%edx),%ecx
  800853:	89 08                	mov    %ecx,(%eax)
  800855:	8b 02                	mov    (%edx),%eax
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
  80085c:	eb 0e                	jmp    80086c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80085e:	8b 10                	mov    (%eax),%edx
  800860:	8d 4a 04             	lea    0x4(%edx),%ecx
  800863:	89 08                	mov    %ecx,(%eax)
  800865:	8b 02                	mov    (%edx),%eax
  800867:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800874:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800878:	8b 10                	mov    (%eax),%edx
  80087a:	3b 50 04             	cmp    0x4(%eax),%edx
  80087d:	73 0a                	jae    800889 <sprintputch+0x1b>
		*b->buf++ = ch;
  80087f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800882:	89 08                	mov    %ecx,(%eax)
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	88 02                	mov    %al,(%edx)
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800891:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800894:	50                   	push   %eax
  800895:	ff 75 10             	pushl  0x10(%ebp)
  800898:	ff 75 0c             	pushl  0xc(%ebp)
  80089b:	ff 75 08             	pushl  0x8(%ebp)
  80089e:	e8 05 00 00 00       	call   8008a8 <vprintfmt>
	va_end(ap);
}
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	57                   	push   %edi
  8008ac:	56                   	push   %esi
  8008ad:	53                   	push   %ebx
  8008ae:	83 ec 2c             	sub    $0x2c,%esp
  8008b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008ba:	eb 12                	jmp    8008ce <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	0f 84 89 03 00 00    	je     800c4d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	53                   	push   %ebx
  8008c8:	50                   	push   %eax
  8008c9:	ff d6                	call   *%esi
  8008cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008ce:	83 c7 01             	add    $0x1,%edi
  8008d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008d5:	83 f8 25             	cmp    $0x25,%eax
  8008d8:	75 e2                	jne    8008bc <vprintfmt+0x14>
  8008da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f8:	eb 07                	jmp    800901 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800901:	8d 47 01             	lea    0x1(%edi),%eax
  800904:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800907:	0f b6 07             	movzbl (%edi),%eax
  80090a:	0f b6 c8             	movzbl %al,%ecx
  80090d:	83 e8 23             	sub    $0x23,%eax
  800910:	3c 55                	cmp    $0x55,%al
  800912:	0f 87 1a 03 00 00    	ja     800c32 <vprintfmt+0x38a>
  800918:	0f b6 c0             	movzbl %al,%eax
  80091b:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
  800922:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800925:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800929:	eb d6                	jmp    800901 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
  800933:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800936:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800939:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80093d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800940:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800943:	83 fa 09             	cmp    $0x9,%edx
  800946:	77 39                	ja     800981 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800948:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80094b:	eb e9                	jmp    800936 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80094d:	8b 45 14             	mov    0x14(%ebp),%eax
  800950:	8d 48 04             	lea    0x4(%eax),%ecx
  800953:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800956:	8b 00                	mov    (%eax),%eax
  800958:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80095e:	eb 27                	jmp    800987 <vprintfmt+0xdf>
  800960:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800963:	85 c0                	test   %eax,%eax
  800965:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096a:	0f 49 c8             	cmovns %eax,%ecx
  80096d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	eb 8c                	jmp    800901 <vprintfmt+0x59>
  800975:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800978:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80097f:	eb 80                	jmp    800901 <vprintfmt+0x59>
  800981:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800984:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800987:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098b:	0f 89 70 ff ff ff    	jns    800901 <vprintfmt+0x59>
				width = precision, precision = -1;
  800991:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800994:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800997:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80099e:	e9 5e ff ff ff       	jmp    800901 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009a9:	e9 53 ff ff ff       	jmp    800901 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b1:	8d 50 04             	lea    0x4(%eax),%edx
  8009b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b7:	83 ec 08             	sub    $0x8,%esp
  8009ba:	53                   	push   %ebx
  8009bb:	ff 30                	pushl  (%eax)
  8009bd:	ff d6                	call   *%esi
			break;
  8009bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009c5:	e9 04 ff ff ff       	jmp    8008ce <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8009cd:	8d 50 04             	lea    0x4(%eax),%edx
  8009d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d3:	8b 00                	mov    (%eax),%eax
  8009d5:	99                   	cltd   
  8009d6:	31 d0                	xor    %edx,%eax
  8009d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009da:	83 f8 0f             	cmp    $0xf,%eax
  8009dd:	7f 0b                	jg     8009ea <vprintfmt+0x142>
  8009df:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  8009e6:	85 d2                	test   %edx,%edx
  8009e8:	75 18                	jne    800a02 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009ea:	50                   	push   %eax
  8009eb:	68 93 27 80 00       	push   $0x802793
  8009f0:	53                   	push   %ebx
  8009f1:	56                   	push   %esi
  8009f2:	e8 94 fe ff ff       	call   80088b <printfmt>
  8009f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009fd:	e9 cc fe ff ff       	jmp    8008ce <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800a02:	52                   	push   %edx
  800a03:	68 96 2b 80 00       	push   $0x802b96
  800a08:	53                   	push   %ebx
  800a09:	56                   	push   %esi
  800a0a:	e8 7c fe ff ff       	call   80088b <printfmt>
  800a0f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a15:	e9 b4 fe ff ff       	jmp    8008ce <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1d:	8d 50 04             	lea    0x4(%eax),%edx
  800a20:	89 55 14             	mov    %edx,0x14(%ebp)
  800a23:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a25:	85 ff                	test   %edi,%edi
  800a27:	b8 8c 27 80 00       	mov    $0x80278c,%eax
  800a2c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a2f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a33:	0f 8e 94 00 00 00    	jle    800acd <vprintfmt+0x225>
  800a39:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a3d:	0f 84 98 00 00 00    	je     800adb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a43:	83 ec 08             	sub    $0x8,%esp
  800a46:	ff 75 d0             	pushl  -0x30(%ebp)
  800a49:	57                   	push   %edi
  800a4a:	e8 86 02 00 00       	call   800cd5 <strnlen>
  800a4f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a52:	29 c1                	sub    %eax,%ecx
  800a54:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a57:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a5a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a5e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a61:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a64:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a66:	eb 0f                	jmp    800a77 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a68:	83 ec 08             	sub    $0x8,%esp
  800a6b:	53                   	push   %ebx
  800a6c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a6f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a71:	83 ef 01             	sub    $0x1,%edi
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	85 ff                	test   %edi,%edi
  800a79:	7f ed                	jg     800a68 <vprintfmt+0x1c0>
  800a7b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a7e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a81:	85 c9                	test   %ecx,%ecx
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	0f 49 c1             	cmovns %ecx,%eax
  800a8b:	29 c1                	sub    %eax,%ecx
  800a8d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a90:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a93:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a96:	89 cb                	mov    %ecx,%ebx
  800a98:	eb 4d                	jmp    800ae7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a9a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a9e:	74 1b                	je     800abb <vprintfmt+0x213>
  800aa0:	0f be c0             	movsbl %al,%eax
  800aa3:	83 e8 20             	sub    $0x20,%eax
  800aa6:	83 f8 5e             	cmp    $0x5e,%eax
  800aa9:	76 10                	jbe    800abb <vprintfmt+0x213>
					putch('?', putdat);
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	6a 3f                	push   $0x3f
  800ab3:	ff 55 08             	call   *0x8(%ebp)
  800ab6:	83 c4 10             	add    $0x10,%esp
  800ab9:	eb 0d                	jmp    800ac8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800abb:	83 ec 08             	sub    $0x8,%esp
  800abe:	ff 75 0c             	pushl  0xc(%ebp)
  800ac1:	52                   	push   %edx
  800ac2:	ff 55 08             	call   *0x8(%ebp)
  800ac5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ac8:	83 eb 01             	sub    $0x1,%ebx
  800acb:	eb 1a                	jmp    800ae7 <vprintfmt+0x23f>
  800acd:	89 75 08             	mov    %esi,0x8(%ebp)
  800ad0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ad3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ad9:	eb 0c                	jmp    800ae7 <vprintfmt+0x23f>
  800adb:	89 75 08             	mov    %esi,0x8(%ebp)
  800ade:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ae1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ae4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ae7:	83 c7 01             	add    $0x1,%edi
  800aea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800aee:	0f be d0             	movsbl %al,%edx
  800af1:	85 d2                	test   %edx,%edx
  800af3:	74 23                	je     800b18 <vprintfmt+0x270>
  800af5:	85 f6                	test   %esi,%esi
  800af7:	78 a1                	js     800a9a <vprintfmt+0x1f2>
  800af9:	83 ee 01             	sub    $0x1,%esi
  800afc:	79 9c                	jns    800a9a <vprintfmt+0x1f2>
  800afe:	89 df                	mov    %ebx,%edi
  800b00:	8b 75 08             	mov    0x8(%ebp),%esi
  800b03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b06:	eb 18                	jmp    800b20 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	53                   	push   %ebx
  800b0c:	6a 20                	push   $0x20
  800b0e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b10:	83 ef 01             	sub    $0x1,%edi
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	eb 08                	jmp    800b20 <vprintfmt+0x278>
  800b18:	89 df                	mov    %ebx,%edi
  800b1a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b20:	85 ff                	test   %edi,%edi
  800b22:	7f e4                	jg     800b08 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b27:	e9 a2 fd ff ff       	jmp    8008ce <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b2c:	83 fa 01             	cmp    $0x1,%edx
  800b2f:	7e 16                	jle    800b47 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b31:	8b 45 14             	mov    0x14(%ebp),%eax
  800b34:	8d 50 08             	lea    0x8(%eax),%edx
  800b37:	89 55 14             	mov    %edx,0x14(%ebp)
  800b3a:	8b 50 04             	mov    0x4(%eax),%edx
  800b3d:	8b 00                	mov    (%eax),%eax
  800b3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b42:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b45:	eb 32                	jmp    800b79 <vprintfmt+0x2d1>
	else if (lflag)
  800b47:	85 d2                	test   %edx,%edx
  800b49:	74 18                	je     800b63 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4e:	8d 50 04             	lea    0x4(%eax),%edx
  800b51:	89 55 14             	mov    %edx,0x14(%ebp)
  800b54:	8b 00                	mov    (%eax),%eax
  800b56:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b59:	89 c1                	mov    %eax,%ecx
  800b5b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b5e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b61:	eb 16                	jmp    800b79 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b63:	8b 45 14             	mov    0x14(%ebp),%eax
  800b66:	8d 50 04             	lea    0x4(%eax),%edx
  800b69:	89 55 14             	mov    %edx,0x14(%ebp)
  800b6c:	8b 00                	mov    (%eax),%eax
  800b6e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b71:	89 c1                	mov    %eax,%ecx
  800b73:	c1 f9 1f             	sar    $0x1f,%ecx
  800b76:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b79:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b7f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b84:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b88:	79 74                	jns    800bfe <vprintfmt+0x356>
				putch('-', putdat);
  800b8a:	83 ec 08             	sub    $0x8,%esp
  800b8d:	53                   	push   %ebx
  800b8e:	6a 2d                	push   $0x2d
  800b90:	ff d6                	call   *%esi
				num = -(long long) num;
  800b92:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b95:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b98:	f7 d8                	neg    %eax
  800b9a:	83 d2 00             	adc    $0x0,%edx
  800b9d:	f7 da                	neg    %edx
  800b9f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ba2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ba7:	eb 55                	jmp    800bfe <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ba9:	8d 45 14             	lea    0x14(%ebp),%eax
  800bac:	e8 83 fc ff ff       	call   800834 <getuint>
			base = 10;
  800bb1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bb6:	eb 46                	jmp    800bfe <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800bb8:	8d 45 14             	lea    0x14(%ebp),%eax
  800bbb:	e8 74 fc ff ff       	call   800834 <getuint>
			base = 8;
  800bc0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bc5:	eb 37                	jmp    800bfe <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800bc7:	83 ec 08             	sub    $0x8,%esp
  800bca:	53                   	push   %ebx
  800bcb:	6a 30                	push   $0x30
  800bcd:	ff d6                	call   *%esi
			putch('x', putdat);
  800bcf:	83 c4 08             	add    $0x8,%esp
  800bd2:	53                   	push   %ebx
  800bd3:	6a 78                	push   $0x78
  800bd5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bd7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bda:	8d 50 04             	lea    0x4(%eax),%edx
  800bdd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800be0:	8b 00                	mov    (%eax),%eax
  800be2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800be7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bea:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bef:	eb 0d                	jmp    800bfe <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bf1:	8d 45 14             	lea    0x14(%ebp),%eax
  800bf4:	e8 3b fc ff ff       	call   800834 <getuint>
			base = 16;
  800bf9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c05:	57                   	push   %edi
  800c06:	ff 75 e0             	pushl  -0x20(%ebp)
  800c09:	51                   	push   %ecx
  800c0a:	52                   	push   %edx
  800c0b:	50                   	push   %eax
  800c0c:	89 da                	mov    %ebx,%edx
  800c0e:	89 f0                	mov    %esi,%eax
  800c10:	e8 70 fb ff ff       	call   800785 <printnum>
			break;
  800c15:	83 c4 20             	add    $0x20,%esp
  800c18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c1b:	e9 ae fc ff ff       	jmp    8008ce <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c20:	83 ec 08             	sub    $0x8,%esp
  800c23:	53                   	push   %ebx
  800c24:	51                   	push   %ecx
  800c25:	ff d6                	call   *%esi
			break;
  800c27:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c2a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c2d:	e9 9c fc ff ff       	jmp    8008ce <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c32:	83 ec 08             	sub    $0x8,%esp
  800c35:	53                   	push   %ebx
  800c36:	6a 25                	push   $0x25
  800c38:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	eb 03                	jmp    800c42 <vprintfmt+0x39a>
  800c3f:	83 ef 01             	sub    $0x1,%edi
  800c42:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c46:	75 f7                	jne    800c3f <vprintfmt+0x397>
  800c48:	e9 81 fc ff ff       	jmp    8008ce <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	83 ec 18             	sub    $0x18,%esp
  800c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c61:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c64:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c68:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c72:	85 c0                	test   %eax,%eax
  800c74:	74 26                	je     800c9c <vsnprintf+0x47>
  800c76:	85 d2                	test   %edx,%edx
  800c78:	7e 22                	jle    800c9c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c7a:	ff 75 14             	pushl  0x14(%ebp)
  800c7d:	ff 75 10             	pushl  0x10(%ebp)
  800c80:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c83:	50                   	push   %eax
  800c84:	68 6e 08 80 00       	push   $0x80086e
  800c89:	e8 1a fc ff ff       	call   8008a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c91:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c97:	83 c4 10             	add    $0x10,%esp
  800c9a:	eb 05                	jmp    800ca1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ca1:	c9                   	leave  
  800ca2:	c3                   	ret    

00800ca3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ca9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cac:	50                   	push   %eax
  800cad:	ff 75 10             	pushl  0x10(%ebp)
  800cb0:	ff 75 0c             	pushl  0xc(%ebp)
  800cb3:	ff 75 08             	pushl  0x8(%ebp)
  800cb6:	e8 9a ff ff ff       	call   800c55 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cbb:	c9                   	leave  
  800cbc:	c3                   	ret    

00800cbd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc8:	eb 03                	jmp    800ccd <strlen+0x10>
		n++;
  800cca:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ccd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cd1:	75 f7                	jne    800cca <strlen+0xd>
		n++;
	return n;
}
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cde:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce3:	eb 03                	jmp    800ce8 <strnlen+0x13>
		n++;
  800ce5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce8:	39 c2                	cmp    %eax,%edx
  800cea:	74 08                	je     800cf4 <strnlen+0x1f>
  800cec:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800cf0:	75 f3                	jne    800ce5 <strnlen+0x10>
  800cf2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	53                   	push   %ebx
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d00:	89 c2                	mov    %eax,%edx
  800d02:	83 c2 01             	add    $0x1,%edx
  800d05:	83 c1 01             	add    $0x1,%ecx
  800d08:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d0c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d0f:	84 db                	test   %bl,%bl
  800d11:	75 ef                	jne    800d02 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d13:	5b                   	pop    %ebx
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	53                   	push   %ebx
  800d1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d1d:	53                   	push   %ebx
  800d1e:	e8 9a ff ff ff       	call   800cbd <strlen>
  800d23:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d26:	ff 75 0c             	pushl  0xc(%ebp)
  800d29:	01 d8                	add    %ebx,%eax
  800d2b:	50                   	push   %eax
  800d2c:	e8 c5 ff ff ff       	call   800cf6 <strcpy>
	return dst;
}
  800d31:	89 d8                	mov    %ebx,%eax
  800d33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	89 f3                	mov    %esi,%ebx
  800d45:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d48:	89 f2                	mov    %esi,%edx
  800d4a:	eb 0f                	jmp    800d5b <strncpy+0x23>
		*dst++ = *src;
  800d4c:	83 c2 01             	add    $0x1,%edx
  800d4f:	0f b6 01             	movzbl (%ecx),%eax
  800d52:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d55:	80 39 01             	cmpb   $0x1,(%ecx)
  800d58:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d5b:	39 da                	cmp    %ebx,%edx
  800d5d:	75 ed                	jne    800d4c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d5f:	89 f0                	mov    %esi,%eax
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 10             	mov    0x10(%ebp),%edx
  800d73:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d75:	85 d2                	test   %edx,%edx
  800d77:	74 21                	je     800d9a <strlcpy+0x35>
  800d79:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d7d:	89 f2                	mov    %esi,%edx
  800d7f:	eb 09                	jmp    800d8a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d81:	83 c2 01             	add    $0x1,%edx
  800d84:	83 c1 01             	add    $0x1,%ecx
  800d87:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d8a:	39 c2                	cmp    %eax,%edx
  800d8c:	74 09                	je     800d97 <strlcpy+0x32>
  800d8e:	0f b6 19             	movzbl (%ecx),%ebx
  800d91:	84 db                	test   %bl,%bl
  800d93:	75 ec                	jne    800d81 <strlcpy+0x1c>
  800d95:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d97:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d9a:	29 f0                	sub    %esi,%eax
}
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800da9:	eb 06                	jmp    800db1 <strcmp+0x11>
		p++, q++;
  800dab:	83 c1 01             	add    $0x1,%ecx
  800dae:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800db1:	0f b6 01             	movzbl (%ecx),%eax
  800db4:	84 c0                	test   %al,%al
  800db6:	74 04                	je     800dbc <strcmp+0x1c>
  800db8:	3a 02                	cmp    (%edx),%al
  800dba:	74 ef                	je     800dab <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dbc:	0f b6 c0             	movzbl %al,%eax
  800dbf:	0f b6 12             	movzbl (%edx),%edx
  800dc2:	29 d0                	sub    %edx,%eax
}
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	53                   	push   %ebx
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd0:	89 c3                	mov    %eax,%ebx
  800dd2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dd5:	eb 06                	jmp    800ddd <strncmp+0x17>
		n--, p++, q++;
  800dd7:	83 c0 01             	add    $0x1,%eax
  800dda:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ddd:	39 d8                	cmp    %ebx,%eax
  800ddf:	74 15                	je     800df6 <strncmp+0x30>
  800de1:	0f b6 08             	movzbl (%eax),%ecx
  800de4:	84 c9                	test   %cl,%cl
  800de6:	74 04                	je     800dec <strncmp+0x26>
  800de8:	3a 0a                	cmp    (%edx),%cl
  800dea:	74 eb                	je     800dd7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dec:	0f b6 00             	movzbl (%eax),%eax
  800def:	0f b6 12             	movzbl (%edx),%edx
  800df2:	29 d0                	sub    %edx,%eax
  800df4:	eb 05                	jmp    800dfb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800df6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e08:	eb 07                	jmp    800e11 <strchr+0x13>
		if (*s == c)
  800e0a:	38 ca                	cmp    %cl,%dl
  800e0c:	74 0f                	je     800e1d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e0e:	83 c0 01             	add    $0x1,%eax
  800e11:	0f b6 10             	movzbl (%eax),%edx
  800e14:	84 d2                	test   %dl,%dl
  800e16:	75 f2                	jne    800e0a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e29:	eb 03                	jmp    800e2e <strfind+0xf>
  800e2b:	83 c0 01             	add    $0x1,%eax
  800e2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e31:	38 ca                	cmp    %cl,%dl
  800e33:	74 04                	je     800e39 <strfind+0x1a>
  800e35:	84 d2                	test   %dl,%dl
  800e37:	75 f2                	jne    800e2b <strfind+0xc>
			break;
	return (char *) s;
}
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	57                   	push   %edi
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
  800e41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e47:	85 c9                	test   %ecx,%ecx
  800e49:	74 36                	je     800e81 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e51:	75 28                	jne    800e7b <memset+0x40>
  800e53:	f6 c1 03             	test   $0x3,%cl
  800e56:	75 23                	jne    800e7b <memset+0x40>
		c &= 0xFF;
  800e58:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e5c:	89 d3                	mov    %edx,%ebx
  800e5e:	c1 e3 08             	shl    $0x8,%ebx
  800e61:	89 d6                	mov    %edx,%esi
  800e63:	c1 e6 18             	shl    $0x18,%esi
  800e66:	89 d0                	mov    %edx,%eax
  800e68:	c1 e0 10             	shl    $0x10,%eax
  800e6b:	09 f0                	or     %esi,%eax
  800e6d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e6f:	89 d8                	mov    %ebx,%eax
  800e71:	09 d0                	or     %edx,%eax
  800e73:	c1 e9 02             	shr    $0x2,%ecx
  800e76:	fc                   	cld    
  800e77:	f3 ab                	rep stos %eax,%es:(%edi)
  800e79:	eb 06                	jmp    800e81 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7e:	fc                   	cld    
  800e7f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e81:	89 f8                	mov    %edi,%eax
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e96:	39 c6                	cmp    %eax,%esi
  800e98:	73 35                	jae    800ecf <memmove+0x47>
  800e9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e9d:	39 d0                	cmp    %edx,%eax
  800e9f:	73 2e                	jae    800ecf <memmove+0x47>
		s += n;
		d += n;
  800ea1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea4:	89 d6                	mov    %edx,%esi
  800ea6:	09 fe                	or     %edi,%esi
  800ea8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eae:	75 13                	jne    800ec3 <memmove+0x3b>
  800eb0:	f6 c1 03             	test   $0x3,%cl
  800eb3:	75 0e                	jne    800ec3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800eb5:	83 ef 04             	sub    $0x4,%edi
  800eb8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ebb:	c1 e9 02             	shr    $0x2,%ecx
  800ebe:	fd                   	std    
  800ebf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec1:	eb 09                	jmp    800ecc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ec3:	83 ef 01             	sub    $0x1,%edi
  800ec6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ec9:	fd                   	std    
  800eca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ecc:	fc                   	cld    
  800ecd:	eb 1d                	jmp    800eec <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ecf:	89 f2                	mov    %esi,%edx
  800ed1:	09 c2                	or     %eax,%edx
  800ed3:	f6 c2 03             	test   $0x3,%dl
  800ed6:	75 0f                	jne    800ee7 <memmove+0x5f>
  800ed8:	f6 c1 03             	test   $0x3,%cl
  800edb:	75 0a                	jne    800ee7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800edd:	c1 e9 02             	shr    $0x2,%ecx
  800ee0:	89 c7                	mov    %eax,%edi
  800ee2:	fc                   	cld    
  800ee3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ee5:	eb 05                	jmp    800eec <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ee7:	89 c7                	mov    %eax,%edi
  800ee9:	fc                   	cld    
  800eea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ef3:	ff 75 10             	pushl  0x10(%ebp)
  800ef6:	ff 75 0c             	pushl  0xc(%ebp)
  800ef9:	ff 75 08             	pushl  0x8(%ebp)
  800efc:	e8 87 ff ff ff       	call   800e88 <memmove>
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0e:	89 c6                	mov    %eax,%esi
  800f10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f13:	eb 1a                	jmp    800f2f <memcmp+0x2c>
		if (*s1 != *s2)
  800f15:	0f b6 08             	movzbl (%eax),%ecx
  800f18:	0f b6 1a             	movzbl (%edx),%ebx
  800f1b:	38 d9                	cmp    %bl,%cl
  800f1d:	74 0a                	je     800f29 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f1f:	0f b6 c1             	movzbl %cl,%eax
  800f22:	0f b6 db             	movzbl %bl,%ebx
  800f25:	29 d8                	sub    %ebx,%eax
  800f27:	eb 0f                	jmp    800f38 <memcmp+0x35>
		s1++, s2++;
  800f29:	83 c0 01             	add    $0x1,%eax
  800f2c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f2f:	39 f0                	cmp    %esi,%eax
  800f31:	75 e2                	jne    800f15 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	53                   	push   %ebx
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f43:	89 c1                	mov    %eax,%ecx
  800f45:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f48:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f4c:	eb 0a                	jmp    800f58 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f4e:	0f b6 10             	movzbl (%eax),%edx
  800f51:	39 da                	cmp    %ebx,%edx
  800f53:	74 07                	je     800f5c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f55:	83 c0 01             	add    $0x1,%eax
  800f58:	39 c8                	cmp    %ecx,%eax
  800f5a:	72 f2                	jb     800f4e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f5c:	5b                   	pop    %ebx
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	57                   	push   %edi
  800f63:	56                   	push   %esi
  800f64:	53                   	push   %ebx
  800f65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f6b:	eb 03                	jmp    800f70 <strtol+0x11>
		s++;
  800f6d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f70:	0f b6 01             	movzbl (%ecx),%eax
  800f73:	3c 20                	cmp    $0x20,%al
  800f75:	74 f6                	je     800f6d <strtol+0xe>
  800f77:	3c 09                	cmp    $0x9,%al
  800f79:	74 f2                	je     800f6d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f7b:	3c 2b                	cmp    $0x2b,%al
  800f7d:	75 0a                	jne    800f89 <strtol+0x2a>
		s++;
  800f7f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f82:	bf 00 00 00 00       	mov    $0x0,%edi
  800f87:	eb 11                	jmp    800f9a <strtol+0x3b>
  800f89:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f8e:	3c 2d                	cmp    $0x2d,%al
  800f90:	75 08                	jne    800f9a <strtol+0x3b>
		s++, neg = 1;
  800f92:	83 c1 01             	add    $0x1,%ecx
  800f95:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f9a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fa0:	75 15                	jne    800fb7 <strtol+0x58>
  800fa2:	80 39 30             	cmpb   $0x30,(%ecx)
  800fa5:	75 10                	jne    800fb7 <strtol+0x58>
  800fa7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fab:	75 7c                	jne    801029 <strtol+0xca>
		s += 2, base = 16;
  800fad:	83 c1 02             	add    $0x2,%ecx
  800fb0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fb5:	eb 16                	jmp    800fcd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fb7:	85 db                	test   %ebx,%ebx
  800fb9:	75 12                	jne    800fcd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fbb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800fc3:	75 08                	jne    800fcd <strtol+0x6e>
		s++, base = 8;
  800fc5:	83 c1 01             	add    $0x1,%ecx
  800fc8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fd5:	0f b6 11             	movzbl (%ecx),%edx
  800fd8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fdb:	89 f3                	mov    %esi,%ebx
  800fdd:	80 fb 09             	cmp    $0x9,%bl
  800fe0:	77 08                	ja     800fea <strtol+0x8b>
			dig = *s - '0';
  800fe2:	0f be d2             	movsbl %dl,%edx
  800fe5:	83 ea 30             	sub    $0x30,%edx
  800fe8:	eb 22                	jmp    80100c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800fea:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fed:	89 f3                	mov    %esi,%ebx
  800fef:	80 fb 19             	cmp    $0x19,%bl
  800ff2:	77 08                	ja     800ffc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ff4:	0f be d2             	movsbl %dl,%edx
  800ff7:	83 ea 57             	sub    $0x57,%edx
  800ffa:	eb 10                	jmp    80100c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ffc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fff:	89 f3                	mov    %esi,%ebx
  801001:	80 fb 19             	cmp    $0x19,%bl
  801004:	77 16                	ja     80101c <strtol+0xbd>
			dig = *s - 'A' + 10;
  801006:	0f be d2             	movsbl %dl,%edx
  801009:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80100c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80100f:	7d 0b                	jge    80101c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801011:	83 c1 01             	add    $0x1,%ecx
  801014:	0f af 45 10          	imul   0x10(%ebp),%eax
  801018:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80101a:	eb b9                	jmp    800fd5 <strtol+0x76>

	if (endptr)
  80101c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801020:	74 0d                	je     80102f <strtol+0xd0>
		*endptr = (char *) s;
  801022:	8b 75 0c             	mov    0xc(%ebp),%esi
  801025:	89 0e                	mov    %ecx,(%esi)
  801027:	eb 06                	jmp    80102f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801029:	85 db                	test   %ebx,%ebx
  80102b:	74 98                	je     800fc5 <strtol+0x66>
  80102d:	eb 9e                	jmp    800fcd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80102f:	89 c2                	mov    %eax,%edx
  801031:	f7 da                	neg    %edx
  801033:	85 ff                	test   %edi,%edi
  801035:	0f 45 c2             	cmovne %edx,%eax
}
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	57                   	push   %edi
  801041:	56                   	push   %esi
  801042:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801043:	b8 00 00 00 00       	mov    $0x0,%eax
  801048:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104b:	8b 55 08             	mov    0x8(%ebp),%edx
  80104e:	89 c3                	mov    %eax,%ebx
  801050:	89 c7                	mov    %eax,%edi
  801052:	89 c6                	mov    %eax,%esi
  801054:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <sys_cgetc>:

int
sys_cgetc(void)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	ba 00 00 00 00       	mov    $0x0,%edx
  801066:	b8 01 00 00 00       	mov    $0x1,%eax
  80106b:	89 d1                	mov    %edx,%ecx
  80106d:	89 d3                	mov    %edx,%ebx
  80106f:	89 d7                	mov    %edx,%edi
  801071:	89 d6                	mov    %edx,%esi
  801073:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801075:	5b                   	pop    %ebx
  801076:	5e                   	pop    %esi
  801077:	5f                   	pop    %edi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	57                   	push   %edi
  80107e:	56                   	push   %esi
  80107f:	53                   	push   %ebx
  801080:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801083:	b9 00 00 00 00       	mov    $0x0,%ecx
  801088:	b8 03 00 00 00       	mov    $0x3,%eax
  80108d:	8b 55 08             	mov    0x8(%ebp),%edx
  801090:	89 cb                	mov    %ecx,%ebx
  801092:	89 cf                	mov    %ecx,%edi
  801094:	89 ce                	mov    %ecx,%esi
  801096:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801098:	85 c0                	test   %eax,%eax
  80109a:	7e 17                	jle    8010b3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	50                   	push   %eax
  8010a0:	6a 03                	push   $0x3
  8010a2:	68 7f 2a 80 00       	push   $0x802a7f
  8010a7:	6a 23                	push   $0x23
  8010a9:	68 9c 2a 80 00       	push   $0x802a9c
  8010ae:	e8 e5 f5 ff ff       	call   800698 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b6:	5b                   	pop    %ebx
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c6:	b8 02 00 00 00       	mov    $0x2,%eax
  8010cb:	89 d1                	mov    %edx,%ecx
  8010cd:	89 d3                	mov    %edx,%ebx
  8010cf:	89 d7                	mov    %edx,%edi
  8010d1:	89 d6                	mov    %edx,%esi
  8010d3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010d5:	5b                   	pop    %ebx
  8010d6:	5e                   	pop    %esi
  8010d7:	5f                   	pop    %edi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <sys_yield>:

void
sys_yield(void)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	57                   	push   %edi
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010ea:	89 d1                	mov    %edx,%ecx
  8010ec:	89 d3                	mov    %edx,%ebx
  8010ee:	89 d7                	mov    %edx,%edi
  8010f0:	89 d6                	mov    %edx,%esi
  8010f2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010f4:	5b                   	pop    %ebx
  8010f5:	5e                   	pop    %esi
  8010f6:	5f                   	pop    %edi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	57                   	push   %edi
  8010fd:	56                   	push   %esi
  8010fe:	53                   	push   %ebx
  8010ff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801102:	be 00 00 00 00       	mov    $0x0,%esi
  801107:	b8 04 00 00 00       	mov    $0x4,%eax
  80110c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110f:	8b 55 08             	mov    0x8(%ebp),%edx
  801112:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801115:	89 f7                	mov    %esi,%edi
  801117:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801119:	85 c0                	test   %eax,%eax
  80111b:	7e 17                	jle    801134 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111d:	83 ec 0c             	sub    $0xc,%esp
  801120:	50                   	push   %eax
  801121:	6a 04                	push   $0x4
  801123:	68 7f 2a 80 00       	push   $0x802a7f
  801128:	6a 23                	push   $0x23
  80112a:	68 9c 2a 80 00       	push   $0x802a9c
  80112f:	e8 64 f5 ff ff       	call   800698 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801134:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801137:	5b                   	pop    %ebx
  801138:	5e                   	pop    %esi
  801139:	5f                   	pop    %edi
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	57                   	push   %edi
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801145:	b8 05 00 00 00       	mov    $0x5,%eax
  80114a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114d:	8b 55 08             	mov    0x8(%ebp),%edx
  801150:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801153:	8b 7d 14             	mov    0x14(%ebp),%edi
  801156:	8b 75 18             	mov    0x18(%ebp),%esi
  801159:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80115b:	85 c0                	test   %eax,%eax
  80115d:	7e 17                	jle    801176 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	50                   	push   %eax
  801163:	6a 05                	push   $0x5
  801165:	68 7f 2a 80 00       	push   $0x802a7f
  80116a:	6a 23                	push   $0x23
  80116c:	68 9c 2a 80 00       	push   $0x802a9c
  801171:	e8 22 f5 ff ff       	call   800698 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801187:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118c:	b8 06 00 00 00       	mov    $0x6,%eax
  801191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801194:	8b 55 08             	mov    0x8(%ebp),%edx
  801197:	89 df                	mov    %ebx,%edi
  801199:	89 de                	mov    %ebx,%esi
  80119b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80119d:	85 c0                	test   %eax,%eax
  80119f:	7e 17                	jle    8011b8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	50                   	push   %eax
  8011a5:	6a 06                	push   $0x6
  8011a7:	68 7f 2a 80 00       	push   $0x802a7f
  8011ac:	6a 23                	push   $0x23
  8011ae:	68 9c 2a 80 00       	push   $0x802a9c
  8011b3:	e8 e0 f4 ff ff       	call   800698 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	57                   	push   %edi
  8011c4:	56                   	push   %esi
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8011d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d9:	89 df                	mov    %ebx,%edi
  8011db:	89 de                	mov    %ebx,%esi
  8011dd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	7e 17                	jle    8011fa <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	50                   	push   %eax
  8011e7:	6a 08                	push   $0x8
  8011e9:	68 7f 2a 80 00       	push   $0x802a7f
  8011ee:	6a 23                	push   $0x23
  8011f0:	68 9c 2a 80 00       	push   $0x802a9c
  8011f5:	e8 9e f4 ff ff       	call   800698 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5f                   	pop    %edi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	57                   	push   %edi
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801210:	b8 09 00 00 00       	mov    $0x9,%eax
  801215:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801218:	8b 55 08             	mov    0x8(%ebp),%edx
  80121b:	89 df                	mov    %ebx,%edi
  80121d:	89 de                	mov    %ebx,%esi
  80121f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801221:	85 c0                	test   %eax,%eax
  801223:	7e 17                	jle    80123c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801225:	83 ec 0c             	sub    $0xc,%esp
  801228:	50                   	push   %eax
  801229:	6a 09                	push   $0x9
  80122b:	68 7f 2a 80 00       	push   $0x802a7f
  801230:	6a 23                	push   $0x23
  801232:	68 9c 2a 80 00       	push   $0x802a9c
  801237:	e8 5c f4 ff ff       	call   800698 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80123c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5f                   	pop    %edi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	57                   	push   %edi
  801248:	56                   	push   %esi
  801249:	53                   	push   %ebx
  80124a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801252:	b8 0a 00 00 00       	mov    $0xa,%eax
  801257:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125a:	8b 55 08             	mov    0x8(%ebp),%edx
  80125d:	89 df                	mov    %ebx,%edi
  80125f:	89 de                	mov    %ebx,%esi
  801261:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801263:	85 c0                	test   %eax,%eax
  801265:	7e 17                	jle    80127e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	50                   	push   %eax
  80126b:	6a 0a                	push   $0xa
  80126d:	68 7f 2a 80 00       	push   $0x802a7f
  801272:	6a 23                	push   $0x23
  801274:	68 9c 2a 80 00       	push   $0x802a9c
  801279:	e8 1a f4 ff ff       	call   800698 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80127e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801281:	5b                   	pop    %ebx
  801282:	5e                   	pop    %esi
  801283:	5f                   	pop    %edi
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	57                   	push   %edi
  80128a:	56                   	push   %esi
  80128b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80128c:	be 00 00 00 00       	mov    $0x0,%esi
  801291:	b8 0c 00 00 00       	mov    $0xc,%eax
  801296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801299:	8b 55 08             	mov    0x8(%ebp),%edx
  80129c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80129f:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012a2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012a4:	5b                   	pop    %ebx
  8012a5:	5e                   	pop    %esi
  8012a6:	5f                   	pop    %edi
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    

008012a9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	57                   	push   %edi
  8012ad:	56                   	push   %esi
  8012ae:	53                   	push   %ebx
  8012af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8012bf:	89 cb                	mov    %ecx,%ebx
  8012c1:	89 cf                	mov    %ecx,%edi
  8012c3:	89 ce                	mov    %ecx,%esi
  8012c5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	7e 17                	jle    8012e2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	50                   	push   %eax
  8012cf:	6a 0d                	push   $0xd
  8012d1:	68 7f 2a 80 00       	push   $0x802a7f
  8012d6:	6a 23                	push   $0x23
  8012d8:	68 9c 2a 80 00       	push   $0x802a9c
  8012dd:	e8 b6 f3 ff ff       	call   800698 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5f                   	pop    %edi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	56                   	push   %esi
  8012ee:	53                   	push   %ebx
  8012ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8012f8:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8012fa:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012ff:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801302:	83 ec 0c             	sub    $0xc,%esp
  801305:	50                   	push   %eax
  801306:	e8 9e ff ff ff       	call   8012a9 <sys_ipc_recv>

	if (from_env_store != NULL)
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	85 f6                	test   %esi,%esi
  801310:	74 14                	je     801326 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801312:	ba 00 00 00 00       	mov    $0x0,%edx
  801317:	85 c0                	test   %eax,%eax
  801319:	78 09                	js     801324 <ipc_recv+0x3a>
  80131b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801321:	8b 52 74             	mov    0x74(%edx),%edx
  801324:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801326:	85 db                	test   %ebx,%ebx
  801328:	74 14                	je     80133e <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80132a:	ba 00 00 00 00       	mov    $0x0,%edx
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 09                	js     80133c <ipc_recv+0x52>
  801333:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801339:	8b 52 78             	mov    0x78(%edx),%edx
  80133c:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 08                	js     80134a <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801342:	a1 04 40 80 00       	mov    0x804004,%eax
  801347:	8b 40 70             	mov    0x70(%eax),%eax
}
  80134a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	57                   	push   %edi
  801355:	56                   	push   %esi
  801356:	53                   	push   %ebx
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80135d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801360:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801363:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801365:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80136a:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80136d:	ff 75 14             	pushl  0x14(%ebp)
  801370:	53                   	push   %ebx
  801371:	56                   	push   %esi
  801372:	57                   	push   %edi
  801373:	e8 0e ff ff ff       	call   801286 <sys_ipc_try_send>

		if (err < 0) {
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	79 1e                	jns    80139d <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80137f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801382:	75 07                	jne    80138b <ipc_send+0x3a>
				sys_yield();
  801384:	e8 51 fd ff ff       	call   8010da <sys_yield>
  801389:	eb e2                	jmp    80136d <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80138b:	50                   	push   %eax
  80138c:	68 aa 2a 80 00       	push   $0x802aaa
  801391:	6a 49                	push   $0x49
  801393:	68 b7 2a 80 00       	push   $0x802ab7
  801398:	e8 fb f2 ff ff       	call   800698 <_panic>
		}

	} while (err < 0);

}
  80139d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a0:	5b                   	pop    %ebx
  8013a1:	5e                   	pop    %esi
  8013a2:	5f                   	pop    %edi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013ab:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013b0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013b3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013b9:	8b 52 50             	mov    0x50(%edx),%edx
  8013bc:	39 ca                	cmp    %ecx,%edx
  8013be:	75 0d                	jne    8013cd <ipc_find_env+0x28>
			return envs[i].env_id;
  8013c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013c8:	8b 40 48             	mov    0x48(%eax),%eax
  8013cb:	eb 0f                	jmp    8013dc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013cd:	83 c0 01             	add    $0x1,%eax
  8013d0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013d5:	75 d9                	jne    8013b0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	05 00 00 00 30       	add    $0x30000000,%eax
  8013e9:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f4:	05 00 00 00 30       	add    $0x30000000,%eax
  8013f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013fe:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80140b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801410:	89 c2                	mov    %eax,%edx
  801412:	c1 ea 16             	shr    $0x16,%edx
  801415:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80141c:	f6 c2 01             	test   $0x1,%dl
  80141f:	74 11                	je     801432 <fd_alloc+0x2d>
  801421:	89 c2                	mov    %eax,%edx
  801423:	c1 ea 0c             	shr    $0xc,%edx
  801426:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142d:	f6 c2 01             	test   $0x1,%dl
  801430:	75 09                	jne    80143b <fd_alloc+0x36>
			*fd_store = fd;
  801432:	89 01                	mov    %eax,(%ecx)
			return 0;
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
  801439:	eb 17                	jmp    801452 <fd_alloc+0x4d>
  80143b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801440:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801445:	75 c9                	jne    801410 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801447:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80144d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801452:	5d                   	pop    %ebp
  801453:	c3                   	ret    

00801454 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80145a:	83 f8 1f             	cmp    $0x1f,%eax
  80145d:	77 36                	ja     801495 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80145f:	c1 e0 0c             	shl    $0xc,%eax
  801462:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801467:	89 c2                	mov    %eax,%edx
  801469:	c1 ea 16             	shr    $0x16,%edx
  80146c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801473:	f6 c2 01             	test   $0x1,%dl
  801476:	74 24                	je     80149c <fd_lookup+0x48>
  801478:	89 c2                	mov    %eax,%edx
  80147a:	c1 ea 0c             	shr    $0xc,%edx
  80147d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801484:	f6 c2 01             	test   $0x1,%dl
  801487:	74 1a                	je     8014a3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801489:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148c:	89 02                	mov    %eax,(%edx)
	return 0;
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
  801493:	eb 13                	jmp    8014a8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801495:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149a:	eb 0c                	jmp    8014a8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80149c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a1:	eb 05                	jmp    8014a8 <fd_lookup+0x54>
  8014a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    

008014aa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b3:	ba 44 2b 80 00       	mov    $0x802b44,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014b8:	eb 13                	jmp    8014cd <dev_lookup+0x23>
  8014ba:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014bd:	39 08                	cmp    %ecx,(%eax)
  8014bf:	75 0c                	jne    8014cd <dev_lookup+0x23>
			*dev = devtab[i];
  8014c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cb:	eb 2e                	jmp    8014fb <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014cd:	8b 02                	mov    (%edx),%eax
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	75 e7                	jne    8014ba <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014d3:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d8:	8b 40 48             	mov    0x48(%eax),%eax
  8014db:	83 ec 04             	sub    $0x4,%esp
  8014de:	51                   	push   %ecx
  8014df:	50                   	push   %eax
  8014e0:	68 c4 2a 80 00       	push   $0x802ac4
  8014e5:	e8 87 f2 ff ff       	call   800771 <cprintf>
	*dev = 0;
  8014ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014fb:	c9                   	leave  
  8014fc:	c3                   	ret    

008014fd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	56                   	push   %esi
  801501:	53                   	push   %ebx
  801502:	83 ec 10             	sub    $0x10,%esp
  801505:	8b 75 08             	mov    0x8(%ebp),%esi
  801508:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80150b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150e:	50                   	push   %eax
  80150f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801515:	c1 e8 0c             	shr    $0xc,%eax
  801518:	50                   	push   %eax
  801519:	e8 36 ff ff ff       	call   801454 <fd_lookup>
  80151e:	83 c4 08             	add    $0x8,%esp
  801521:	85 c0                	test   %eax,%eax
  801523:	78 05                	js     80152a <fd_close+0x2d>
	    || fd != fd2)
  801525:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801528:	74 0c                	je     801536 <fd_close+0x39>
		return (must_exist ? r : 0);
  80152a:	84 db                	test   %bl,%bl
  80152c:	ba 00 00 00 00       	mov    $0x0,%edx
  801531:	0f 44 c2             	cmove  %edx,%eax
  801534:	eb 41                	jmp    801577 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153c:	50                   	push   %eax
  80153d:	ff 36                	pushl  (%esi)
  80153f:	e8 66 ff ff ff       	call   8014aa <dev_lookup>
  801544:	89 c3                	mov    %eax,%ebx
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 1a                	js     801567 <fd_close+0x6a>
		if (dev->dev_close)
  80154d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801550:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801553:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801558:	85 c0                	test   %eax,%eax
  80155a:	74 0b                	je     801567 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80155c:	83 ec 0c             	sub    $0xc,%esp
  80155f:	56                   	push   %esi
  801560:	ff d0                	call   *%eax
  801562:	89 c3                	mov    %eax,%ebx
  801564:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	56                   	push   %esi
  80156b:	6a 00                	push   $0x0
  80156d:	e8 0c fc ff ff       	call   80117e <sys_page_unmap>
	return r;
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	89 d8                	mov    %ebx,%eax
}
  801577:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157a:	5b                   	pop    %ebx
  80157b:	5e                   	pop    %esi
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801584:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	ff 75 08             	pushl  0x8(%ebp)
  80158b:	e8 c4 fe ff ff       	call   801454 <fd_lookup>
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 10                	js     8015a7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	6a 01                	push   $0x1
  80159c:	ff 75 f4             	pushl  -0xc(%ebp)
  80159f:	e8 59 ff ff ff       	call   8014fd <fd_close>
  8015a4:	83 c4 10             	add    $0x10,%esp
}
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <close_all>:

void
close_all(void)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015b0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	53                   	push   %ebx
  8015b9:	e8 c0 ff ff ff       	call   80157e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015be:	83 c3 01             	add    $0x1,%ebx
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	83 fb 20             	cmp    $0x20,%ebx
  8015c7:	75 ec                	jne    8015b5 <close_all+0xc>
		close(i);
}
  8015c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	57                   	push   %edi
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 2c             	sub    $0x2c,%esp
  8015d7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	ff 75 08             	pushl  0x8(%ebp)
  8015e1:	e8 6e fe ff ff       	call   801454 <fd_lookup>
  8015e6:	83 c4 08             	add    $0x8,%esp
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	0f 88 c1 00 00 00    	js     8016b2 <dup+0xe4>
		return r;
	close(newfdnum);
  8015f1:	83 ec 0c             	sub    $0xc,%esp
  8015f4:	56                   	push   %esi
  8015f5:	e8 84 ff ff ff       	call   80157e <close>

	newfd = INDEX2FD(newfdnum);
  8015fa:	89 f3                	mov    %esi,%ebx
  8015fc:	c1 e3 0c             	shl    $0xc,%ebx
  8015ff:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801605:	83 c4 04             	add    $0x4,%esp
  801608:	ff 75 e4             	pushl  -0x1c(%ebp)
  80160b:	e8 de fd ff ff       	call   8013ee <fd2data>
  801610:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801612:	89 1c 24             	mov    %ebx,(%esp)
  801615:	e8 d4 fd ff ff       	call   8013ee <fd2data>
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801620:	89 f8                	mov    %edi,%eax
  801622:	c1 e8 16             	shr    $0x16,%eax
  801625:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80162c:	a8 01                	test   $0x1,%al
  80162e:	74 37                	je     801667 <dup+0x99>
  801630:	89 f8                	mov    %edi,%eax
  801632:	c1 e8 0c             	shr    $0xc,%eax
  801635:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80163c:	f6 c2 01             	test   $0x1,%dl
  80163f:	74 26                	je     801667 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801641:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	25 07 0e 00 00       	and    $0xe07,%eax
  801650:	50                   	push   %eax
  801651:	ff 75 d4             	pushl  -0x2c(%ebp)
  801654:	6a 00                	push   $0x0
  801656:	57                   	push   %edi
  801657:	6a 00                	push   $0x0
  801659:	e8 de fa ff ff       	call   80113c <sys_page_map>
  80165e:	89 c7                	mov    %eax,%edi
  801660:	83 c4 20             	add    $0x20,%esp
  801663:	85 c0                	test   %eax,%eax
  801665:	78 2e                	js     801695 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801667:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80166a:	89 d0                	mov    %edx,%eax
  80166c:	c1 e8 0c             	shr    $0xc,%eax
  80166f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801676:	83 ec 0c             	sub    $0xc,%esp
  801679:	25 07 0e 00 00       	and    $0xe07,%eax
  80167e:	50                   	push   %eax
  80167f:	53                   	push   %ebx
  801680:	6a 00                	push   $0x0
  801682:	52                   	push   %edx
  801683:	6a 00                	push   $0x0
  801685:	e8 b2 fa ff ff       	call   80113c <sys_page_map>
  80168a:	89 c7                	mov    %eax,%edi
  80168c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80168f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801691:	85 ff                	test   %edi,%edi
  801693:	79 1d                	jns    8016b2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801695:	83 ec 08             	sub    $0x8,%esp
  801698:	53                   	push   %ebx
  801699:	6a 00                	push   $0x0
  80169b:	e8 de fa ff ff       	call   80117e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016a0:	83 c4 08             	add    $0x8,%esp
  8016a3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016a6:	6a 00                	push   $0x0
  8016a8:	e8 d1 fa ff ff       	call   80117e <sys_page_unmap>
	return r;
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	89 f8                	mov    %edi,%eax
}
  8016b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5f                   	pop    %edi
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 14             	sub    $0x14,%esp
  8016c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c7:	50                   	push   %eax
  8016c8:	53                   	push   %ebx
  8016c9:	e8 86 fd ff ff       	call   801454 <fd_lookup>
  8016ce:	83 c4 08             	add    $0x8,%esp
  8016d1:	89 c2                	mov    %eax,%edx
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 6d                	js     801744 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e1:	ff 30                	pushl  (%eax)
  8016e3:	e8 c2 fd ff ff       	call   8014aa <dev_lookup>
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 4c                	js     80173b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016f2:	8b 42 08             	mov    0x8(%edx),%eax
  8016f5:	83 e0 03             	and    $0x3,%eax
  8016f8:	83 f8 01             	cmp    $0x1,%eax
  8016fb:	75 21                	jne    80171e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016fd:	a1 04 40 80 00       	mov    0x804004,%eax
  801702:	8b 40 48             	mov    0x48(%eax),%eax
  801705:	83 ec 04             	sub    $0x4,%esp
  801708:	53                   	push   %ebx
  801709:	50                   	push   %eax
  80170a:	68 08 2b 80 00       	push   $0x802b08
  80170f:	e8 5d f0 ff ff       	call   800771 <cprintf>
		return -E_INVAL;
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80171c:	eb 26                	jmp    801744 <read+0x8a>
	}
	if (!dev->dev_read)
  80171e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801721:	8b 40 08             	mov    0x8(%eax),%eax
  801724:	85 c0                	test   %eax,%eax
  801726:	74 17                	je     80173f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801728:	83 ec 04             	sub    $0x4,%esp
  80172b:	ff 75 10             	pushl  0x10(%ebp)
  80172e:	ff 75 0c             	pushl  0xc(%ebp)
  801731:	52                   	push   %edx
  801732:	ff d0                	call   *%eax
  801734:	89 c2                	mov    %eax,%edx
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	eb 09                	jmp    801744 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173b:	89 c2                	mov    %eax,%edx
  80173d:	eb 05                	jmp    801744 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80173f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801744:	89 d0                	mov    %edx,%eax
  801746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	57                   	push   %edi
  80174f:	56                   	push   %esi
  801750:	53                   	push   %ebx
  801751:	83 ec 0c             	sub    $0xc,%esp
  801754:	8b 7d 08             	mov    0x8(%ebp),%edi
  801757:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80175a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175f:	eb 21                	jmp    801782 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801761:	83 ec 04             	sub    $0x4,%esp
  801764:	89 f0                	mov    %esi,%eax
  801766:	29 d8                	sub    %ebx,%eax
  801768:	50                   	push   %eax
  801769:	89 d8                	mov    %ebx,%eax
  80176b:	03 45 0c             	add    0xc(%ebp),%eax
  80176e:	50                   	push   %eax
  80176f:	57                   	push   %edi
  801770:	e8 45 ff ff ff       	call   8016ba <read>
		if (m < 0)
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 10                	js     80178c <readn+0x41>
			return m;
		if (m == 0)
  80177c:	85 c0                	test   %eax,%eax
  80177e:	74 0a                	je     80178a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801780:	01 c3                	add    %eax,%ebx
  801782:	39 f3                	cmp    %esi,%ebx
  801784:	72 db                	jb     801761 <readn+0x16>
  801786:	89 d8                	mov    %ebx,%eax
  801788:	eb 02                	jmp    80178c <readn+0x41>
  80178a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80178c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5f                   	pop    %edi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	53                   	push   %ebx
  801798:	83 ec 14             	sub    $0x14,%esp
  80179b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a1:	50                   	push   %eax
  8017a2:	53                   	push   %ebx
  8017a3:	e8 ac fc ff ff       	call   801454 <fd_lookup>
  8017a8:	83 c4 08             	add    $0x8,%esp
  8017ab:	89 c2                	mov    %eax,%edx
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 68                	js     801819 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b7:	50                   	push   %eax
  8017b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bb:	ff 30                	pushl  (%eax)
  8017bd:	e8 e8 fc ff ff       	call   8014aa <dev_lookup>
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 47                	js     801810 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d0:	75 21                	jne    8017f3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8017d7:	8b 40 48             	mov    0x48(%eax),%eax
  8017da:	83 ec 04             	sub    $0x4,%esp
  8017dd:	53                   	push   %ebx
  8017de:	50                   	push   %eax
  8017df:	68 24 2b 80 00       	push   $0x802b24
  8017e4:	e8 88 ef ff ff       	call   800771 <cprintf>
		return -E_INVAL;
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017f1:	eb 26                	jmp    801819 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017f9:	85 d2                	test   %edx,%edx
  8017fb:	74 17                	je     801814 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017fd:	83 ec 04             	sub    $0x4,%esp
  801800:	ff 75 10             	pushl  0x10(%ebp)
  801803:	ff 75 0c             	pushl  0xc(%ebp)
  801806:	50                   	push   %eax
  801807:	ff d2                	call   *%edx
  801809:	89 c2                	mov    %eax,%edx
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	eb 09                	jmp    801819 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801810:	89 c2                	mov    %eax,%edx
  801812:	eb 05                	jmp    801819 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801814:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801819:	89 d0                	mov    %edx,%eax
  80181b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <seek>:

int
seek(int fdnum, off_t offset)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801826:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801829:	50                   	push   %eax
  80182a:	ff 75 08             	pushl  0x8(%ebp)
  80182d:	e8 22 fc ff ff       	call   801454 <fd_lookup>
  801832:	83 c4 08             	add    $0x8,%esp
  801835:	85 c0                	test   %eax,%eax
  801837:	78 0e                	js     801847 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801839:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80183c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80183f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801842:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	53                   	push   %ebx
  80184d:	83 ec 14             	sub    $0x14,%esp
  801850:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801853:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801856:	50                   	push   %eax
  801857:	53                   	push   %ebx
  801858:	e8 f7 fb ff ff       	call   801454 <fd_lookup>
  80185d:	83 c4 08             	add    $0x8,%esp
  801860:	89 c2                	mov    %eax,%edx
  801862:	85 c0                	test   %eax,%eax
  801864:	78 65                	js     8018cb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186c:	50                   	push   %eax
  80186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801870:	ff 30                	pushl  (%eax)
  801872:	e8 33 fc ff ff       	call   8014aa <dev_lookup>
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	85 c0                	test   %eax,%eax
  80187c:	78 44                	js     8018c2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80187e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801881:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801885:	75 21                	jne    8018a8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801887:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80188c:	8b 40 48             	mov    0x48(%eax),%eax
  80188f:	83 ec 04             	sub    $0x4,%esp
  801892:	53                   	push   %ebx
  801893:	50                   	push   %eax
  801894:	68 e4 2a 80 00       	push   $0x802ae4
  801899:	e8 d3 ee ff ff       	call   800771 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018a6:	eb 23                	jmp    8018cb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ab:	8b 52 18             	mov    0x18(%edx),%edx
  8018ae:	85 d2                	test   %edx,%edx
  8018b0:	74 14                	je     8018c6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018b2:	83 ec 08             	sub    $0x8,%esp
  8018b5:	ff 75 0c             	pushl  0xc(%ebp)
  8018b8:	50                   	push   %eax
  8018b9:	ff d2                	call   *%edx
  8018bb:	89 c2                	mov    %eax,%edx
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	eb 09                	jmp    8018cb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c2:	89 c2                	mov    %eax,%edx
  8018c4:	eb 05                	jmp    8018cb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018cb:	89 d0                	mov    %edx,%eax
  8018cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 14             	sub    $0x14,%esp
  8018d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018df:	50                   	push   %eax
  8018e0:	ff 75 08             	pushl  0x8(%ebp)
  8018e3:	e8 6c fb ff ff       	call   801454 <fd_lookup>
  8018e8:	83 c4 08             	add    $0x8,%esp
  8018eb:	89 c2                	mov    %eax,%edx
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 58                	js     801949 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f7:	50                   	push   %eax
  8018f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fb:	ff 30                	pushl  (%eax)
  8018fd:	e8 a8 fb ff ff       	call   8014aa <dev_lookup>
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	85 c0                	test   %eax,%eax
  801907:	78 37                	js     801940 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801909:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801910:	74 32                	je     801944 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801912:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801915:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80191c:	00 00 00 
	stat->st_isdir = 0;
  80191f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801926:	00 00 00 
	stat->st_dev = dev;
  801929:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80192f:	83 ec 08             	sub    $0x8,%esp
  801932:	53                   	push   %ebx
  801933:	ff 75 f0             	pushl  -0x10(%ebp)
  801936:	ff 50 14             	call   *0x14(%eax)
  801939:	89 c2                	mov    %eax,%edx
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	eb 09                	jmp    801949 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801940:	89 c2                	mov    %eax,%edx
  801942:	eb 05                	jmp    801949 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801944:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801949:	89 d0                	mov    %edx,%eax
  80194b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	56                   	push   %esi
  801954:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	6a 00                	push   $0x0
  80195a:	ff 75 08             	pushl  0x8(%ebp)
  80195d:	e8 b7 01 00 00       	call   801b19 <open>
  801962:	89 c3                	mov    %eax,%ebx
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	78 1b                	js     801986 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	ff 75 0c             	pushl  0xc(%ebp)
  801971:	50                   	push   %eax
  801972:	e8 5b ff ff ff       	call   8018d2 <fstat>
  801977:	89 c6                	mov    %eax,%esi
	close(fd);
  801979:	89 1c 24             	mov    %ebx,(%esp)
  80197c:	e8 fd fb ff ff       	call   80157e <close>
	return r;
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	89 f0                	mov    %esi,%eax
}
  801986:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801989:	5b                   	pop    %ebx
  80198a:	5e                   	pop    %esi
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    

0080198d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	56                   	push   %esi
  801991:	53                   	push   %ebx
  801992:	89 c6                	mov    %eax,%esi
  801994:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801996:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80199d:	75 12                	jne    8019b1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	6a 01                	push   $0x1
  8019a4:	e8 fc f9 ff ff       	call   8013a5 <ipc_find_env>
  8019a9:	a3 00 40 80 00       	mov    %eax,0x804000
  8019ae:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019b1:	6a 07                	push   $0x7
  8019b3:	68 00 50 80 00       	push   $0x805000
  8019b8:	56                   	push   %esi
  8019b9:	ff 35 00 40 80 00    	pushl  0x804000
  8019bf:	e8 8d f9 ff ff       	call   801351 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019c4:	83 c4 0c             	add    $0xc,%esp
  8019c7:	6a 00                	push   $0x0
  8019c9:	53                   	push   %ebx
  8019ca:	6a 00                	push   $0x0
  8019cc:	e8 19 f9 ff ff       	call   8012ea <ipc_recv>
}
  8019d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019de:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ec:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8019fb:	e8 8d ff ff ff       	call   80198d <fsipc>
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a08:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a13:	ba 00 00 00 00       	mov    $0x0,%edx
  801a18:	b8 06 00 00 00       	mov    $0x6,%eax
  801a1d:	e8 6b ff ff ff       	call   80198d <fsipc>
}
  801a22:	c9                   	leave  
  801a23:	c3                   	ret    

00801a24 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	53                   	push   %ebx
  801a28:	83 ec 04             	sub    $0x4,%esp
  801a2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a31:	8b 40 0c             	mov    0xc(%eax),%eax
  801a34:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a39:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3e:	b8 05 00 00 00       	mov    $0x5,%eax
  801a43:	e8 45 ff ff ff       	call   80198d <fsipc>
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	78 2c                	js     801a78 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a4c:	83 ec 08             	sub    $0x8,%esp
  801a4f:	68 00 50 80 00       	push   $0x805000
  801a54:	53                   	push   %ebx
  801a55:	e8 9c f2 ff ff       	call   800cf6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a5a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a5f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a65:	a1 84 50 80 00       	mov    0x805084,%eax
  801a6a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7b:	c9                   	leave  
  801a7c:	c3                   	ret    

00801a7d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a83:	68 54 2b 80 00       	push   $0x802b54
  801a88:	68 90 00 00 00       	push   $0x90
  801a8d:	68 72 2b 80 00       	push   $0x802b72
  801a92:	e8 01 ec ff ff       	call   800698 <_panic>

00801a97 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	56                   	push   %esi
  801a9b:	53                   	push   %ebx
  801a9c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa2:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aaa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab5:	b8 03 00 00 00       	mov    $0x3,%eax
  801aba:	e8 ce fe ff ff       	call   80198d <fsipc>
  801abf:	89 c3                	mov    %eax,%ebx
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	78 4b                	js     801b10 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ac5:	39 c6                	cmp    %eax,%esi
  801ac7:	73 16                	jae    801adf <devfile_read+0x48>
  801ac9:	68 7d 2b 80 00       	push   $0x802b7d
  801ace:	68 84 2b 80 00       	push   $0x802b84
  801ad3:	6a 7c                	push   $0x7c
  801ad5:	68 72 2b 80 00       	push   $0x802b72
  801ada:	e8 b9 eb ff ff       	call   800698 <_panic>
	assert(r <= PGSIZE);
  801adf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ae4:	7e 16                	jle    801afc <devfile_read+0x65>
  801ae6:	68 99 2b 80 00       	push   $0x802b99
  801aeb:	68 84 2b 80 00       	push   $0x802b84
  801af0:	6a 7d                	push   $0x7d
  801af2:	68 72 2b 80 00       	push   $0x802b72
  801af7:	e8 9c eb ff ff       	call   800698 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801afc:	83 ec 04             	sub    $0x4,%esp
  801aff:	50                   	push   %eax
  801b00:	68 00 50 80 00       	push   $0x805000
  801b05:	ff 75 0c             	pushl  0xc(%ebp)
  801b08:	e8 7b f3 ff ff       	call   800e88 <memmove>
	return r;
  801b0d:	83 c4 10             	add    $0x10,%esp
}
  801b10:	89 d8                	mov    %ebx,%eax
  801b12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 20             	sub    $0x20,%esp
  801b20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b23:	53                   	push   %ebx
  801b24:	e8 94 f1 ff ff       	call   800cbd <strlen>
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b31:	7f 67                	jg     801b9a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b33:	83 ec 0c             	sub    $0xc,%esp
  801b36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b39:	50                   	push   %eax
  801b3a:	e8 c6 f8 ff ff       	call   801405 <fd_alloc>
  801b3f:	83 c4 10             	add    $0x10,%esp
		return r;
  801b42:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 57                	js     801b9f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	53                   	push   %ebx
  801b4c:	68 00 50 80 00       	push   $0x805000
  801b51:	e8 a0 f1 ff ff       	call   800cf6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b59:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b61:	b8 01 00 00 00       	mov    $0x1,%eax
  801b66:	e8 22 fe ff ff       	call   80198d <fsipc>
  801b6b:	89 c3                	mov    %eax,%ebx
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	79 14                	jns    801b88 <open+0x6f>
		fd_close(fd, 0);
  801b74:	83 ec 08             	sub    $0x8,%esp
  801b77:	6a 00                	push   $0x0
  801b79:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7c:	e8 7c f9 ff ff       	call   8014fd <fd_close>
		return r;
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	89 da                	mov    %ebx,%edx
  801b86:	eb 17                	jmp    801b9f <open+0x86>
	}

	return fd2num(fd);
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8e:	e8 4b f8 ff ff       	call   8013de <fd2num>
  801b93:	89 c2                	mov    %eax,%edx
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	eb 05                	jmp    801b9f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b9a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b9f:	89 d0                	mov    %edx,%eax
  801ba1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bac:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb1:	b8 08 00 00 00       	mov    $0x8,%eax
  801bb6:	e8 d2 fd ff ff       	call   80198d <fsipc>
}
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	56                   	push   %esi
  801bc1:	53                   	push   %ebx
  801bc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	ff 75 08             	pushl  0x8(%ebp)
  801bcb:	e8 1e f8 ff ff       	call   8013ee <fd2data>
  801bd0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bd2:	83 c4 08             	add    $0x8,%esp
  801bd5:	68 a5 2b 80 00       	push   $0x802ba5
  801bda:	53                   	push   %ebx
  801bdb:	e8 16 f1 ff ff       	call   800cf6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801be0:	8b 46 04             	mov    0x4(%esi),%eax
  801be3:	2b 06                	sub    (%esi),%eax
  801be5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801beb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bf2:	00 00 00 
	stat->st_dev = &devpipe;
  801bf5:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801bfc:	30 80 00 
	return 0;
}
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
  801c04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c15:	53                   	push   %ebx
  801c16:	6a 00                	push   $0x0
  801c18:	e8 61 f5 ff ff       	call   80117e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c1d:	89 1c 24             	mov    %ebx,(%esp)
  801c20:	e8 c9 f7 ff ff       	call   8013ee <fd2data>
  801c25:	83 c4 08             	add    $0x8,%esp
  801c28:	50                   	push   %eax
  801c29:	6a 00                	push   $0x0
  801c2b:	e8 4e f5 ff ff       	call   80117e <sys_page_unmap>
}
  801c30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	57                   	push   %edi
  801c39:	56                   	push   %esi
  801c3a:	53                   	push   %ebx
  801c3b:	83 ec 1c             	sub    $0x1c,%esp
  801c3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c41:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c43:	a1 04 40 80 00       	mov    0x804004,%eax
  801c48:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c4b:	83 ec 0c             	sub    $0xc,%esp
  801c4e:	ff 75 e0             	pushl  -0x20(%ebp)
  801c51:	e8 46 04 00 00       	call   80209c <pageref>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	89 3c 24             	mov    %edi,(%esp)
  801c5b:	e8 3c 04 00 00       	call   80209c <pageref>
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	39 c3                	cmp    %eax,%ebx
  801c65:	0f 94 c1             	sete   %cl
  801c68:	0f b6 c9             	movzbl %cl,%ecx
  801c6b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c6e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c74:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c77:	39 ce                	cmp    %ecx,%esi
  801c79:	74 1b                	je     801c96 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c7b:	39 c3                	cmp    %eax,%ebx
  801c7d:	75 c4                	jne    801c43 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c7f:	8b 42 58             	mov    0x58(%edx),%eax
  801c82:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c85:	50                   	push   %eax
  801c86:	56                   	push   %esi
  801c87:	68 ac 2b 80 00       	push   $0x802bac
  801c8c:	e8 e0 ea ff ff       	call   800771 <cprintf>
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	eb ad                	jmp    801c43 <_pipeisclosed+0xe>
	}
}
  801c96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5f                   	pop    %edi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	57                   	push   %edi
  801ca5:	56                   	push   %esi
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 28             	sub    $0x28,%esp
  801caa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cad:	56                   	push   %esi
  801cae:	e8 3b f7 ff ff       	call   8013ee <fd2data>
  801cb3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	bf 00 00 00 00       	mov    $0x0,%edi
  801cbd:	eb 4b                	jmp    801d0a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cbf:	89 da                	mov    %ebx,%edx
  801cc1:	89 f0                	mov    %esi,%eax
  801cc3:	e8 6d ff ff ff       	call   801c35 <_pipeisclosed>
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	75 48                	jne    801d14 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ccc:	e8 09 f4 ff ff       	call   8010da <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cd1:	8b 43 04             	mov    0x4(%ebx),%eax
  801cd4:	8b 0b                	mov    (%ebx),%ecx
  801cd6:	8d 51 20             	lea    0x20(%ecx),%edx
  801cd9:	39 d0                	cmp    %edx,%eax
  801cdb:	73 e2                	jae    801cbf <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ce4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ce7:	89 c2                	mov    %eax,%edx
  801ce9:	c1 fa 1f             	sar    $0x1f,%edx
  801cec:	89 d1                	mov    %edx,%ecx
  801cee:	c1 e9 1b             	shr    $0x1b,%ecx
  801cf1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cf4:	83 e2 1f             	and    $0x1f,%edx
  801cf7:	29 ca                	sub    %ecx,%edx
  801cf9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cfd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d01:	83 c0 01             	add    $0x1,%eax
  801d04:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d07:	83 c7 01             	add    $0x1,%edi
  801d0a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d0d:	75 c2                	jne    801cd1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d0f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d12:	eb 05                	jmp    801d19 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d14:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1c:	5b                   	pop    %ebx
  801d1d:	5e                   	pop    %esi
  801d1e:	5f                   	pop    %edi
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	57                   	push   %edi
  801d25:	56                   	push   %esi
  801d26:	53                   	push   %ebx
  801d27:	83 ec 18             	sub    $0x18,%esp
  801d2a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d2d:	57                   	push   %edi
  801d2e:	e8 bb f6 ff ff       	call   8013ee <fd2data>
  801d33:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d3d:	eb 3d                	jmp    801d7c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d3f:	85 db                	test   %ebx,%ebx
  801d41:	74 04                	je     801d47 <devpipe_read+0x26>
				return i;
  801d43:	89 d8                	mov    %ebx,%eax
  801d45:	eb 44                	jmp    801d8b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d47:	89 f2                	mov    %esi,%edx
  801d49:	89 f8                	mov    %edi,%eax
  801d4b:	e8 e5 fe ff ff       	call   801c35 <_pipeisclosed>
  801d50:	85 c0                	test   %eax,%eax
  801d52:	75 32                	jne    801d86 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d54:	e8 81 f3 ff ff       	call   8010da <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d59:	8b 06                	mov    (%esi),%eax
  801d5b:	3b 46 04             	cmp    0x4(%esi),%eax
  801d5e:	74 df                	je     801d3f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d60:	99                   	cltd   
  801d61:	c1 ea 1b             	shr    $0x1b,%edx
  801d64:	01 d0                	add    %edx,%eax
  801d66:	83 e0 1f             	and    $0x1f,%eax
  801d69:	29 d0                	sub    %edx,%eax
  801d6b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d73:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d76:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d79:	83 c3 01             	add    $0x1,%ebx
  801d7c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d7f:	75 d8                	jne    801d59 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d81:	8b 45 10             	mov    0x10(%ebp),%eax
  801d84:	eb 05                	jmp    801d8b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d86:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9e:	50                   	push   %eax
  801d9f:	e8 61 f6 ff ff       	call   801405 <fd_alloc>
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	89 c2                	mov    %eax,%edx
  801da9:	85 c0                	test   %eax,%eax
  801dab:	0f 88 2c 01 00 00    	js     801edd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db1:	83 ec 04             	sub    $0x4,%esp
  801db4:	68 07 04 00 00       	push   $0x407
  801db9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbc:	6a 00                	push   $0x0
  801dbe:	e8 36 f3 ff ff       	call   8010f9 <sys_page_alloc>
  801dc3:	83 c4 10             	add    $0x10,%esp
  801dc6:	89 c2                	mov    %eax,%edx
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	0f 88 0d 01 00 00    	js     801edd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dd0:	83 ec 0c             	sub    $0xc,%esp
  801dd3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dd6:	50                   	push   %eax
  801dd7:	e8 29 f6 ff ff       	call   801405 <fd_alloc>
  801ddc:	89 c3                	mov    %eax,%ebx
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	0f 88 e2 00 00 00    	js     801ecb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de9:	83 ec 04             	sub    $0x4,%esp
  801dec:	68 07 04 00 00       	push   $0x407
  801df1:	ff 75 f0             	pushl  -0x10(%ebp)
  801df4:	6a 00                	push   $0x0
  801df6:	e8 fe f2 ff ff       	call   8010f9 <sys_page_alloc>
  801dfb:	89 c3                	mov    %eax,%ebx
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	0f 88 c3 00 00 00    	js     801ecb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e08:	83 ec 0c             	sub    $0xc,%esp
  801e0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0e:	e8 db f5 ff ff       	call   8013ee <fd2data>
  801e13:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e15:	83 c4 0c             	add    $0xc,%esp
  801e18:	68 07 04 00 00       	push   $0x407
  801e1d:	50                   	push   %eax
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 d4 f2 ff ff       	call   8010f9 <sys_page_alloc>
  801e25:	89 c3                	mov    %eax,%ebx
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	0f 88 89 00 00 00    	js     801ebb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e32:	83 ec 0c             	sub    $0xc,%esp
  801e35:	ff 75 f0             	pushl  -0x10(%ebp)
  801e38:	e8 b1 f5 ff ff       	call   8013ee <fd2data>
  801e3d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e44:	50                   	push   %eax
  801e45:	6a 00                	push   $0x0
  801e47:	56                   	push   %esi
  801e48:	6a 00                	push   $0x0
  801e4a:	e8 ed f2 ff ff       	call   80113c <sys_page_map>
  801e4f:	89 c3                	mov    %eax,%ebx
  801e51:	83 c4 20             	add    $0x20,%esp
  801e54:	85 c0                	test   %eax,%eax
  801e56:	78 55                	js     801ead <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e58:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e61:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e66:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e6d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e76:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e7b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	ff 75 f4             	pushl  -0xc(%ebp)
  801e88:	e8 51 f5 ff ff       	call   8013de <fd2num>
  801e8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e90:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e92:	83 c4 04             	add    $0x4,%esp
  801e95:	ff 75 f0             	pushl  -0x10(%ebp)
  801e98:	e8 41 f5 ff ff       	call   8013de <fd2num>
  801e9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	ba 00 00 00 00       	mov    $0x0,%edx
  801eab:	eb 30                	jmp    801edd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ead:	83 ec 08             	sub    $0x8,%esp
  801eb0:	56                   	push   %esi
  801eb1:	6a 00                	push   $0x0
  801eb3:	e8 c6 f2 ff ff       	call   80117e <sys_page_unmap>
  801eb8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ebb:	83 ec 08             	sub    $0x8,%esp
  801ebe:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec1:	6a 00                	push   $0x0
  801ec3:	e8 b6 f2 ff ff       	call   80117e <sys_page_unmap>
  801ec8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ecb:	83 ec 08             	sub    $0x8,%esp
  801ece:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed1:	6a 00                	push   $0x0
  801ed3:	e8 a6 f2 ff ff       	call   80117e <sys_page_unmap>
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801edd:	89 d0                	mov    %edx,%eax
  801edf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee2:	5b                   	pop    %ebx
  801ee3:	5e                   	pop    %esi
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    

00801ee6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eef:	50                   	push   %eax
  801ef0:	ff 75 08             	pushl  0x8(%ebp)
  801ef3:	e8 5c f5 ff ff       	call   801454 <fd_lookup>
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	85 c0                	test   %eax,%eax
  801efd:	78 18                	js     801f17 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	ff 75 f4             	pushl  -0xc(%ebp)
  801f05:	e8 e4 f4 ff ff       	call   8013ee <fd2data>
	return _pipeisclosed(fd, p);
  801f0a:	89 c2                	mov    %eax,%edx
  801f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0f:	e8 21 fd ff ff       	call   801c35 <_pipeisclosed>
  801f14:	83 c4 10             	add    $0x10,%esp
}
  801f17:	c9                   	leave  
  801f18:	c3                   	ret    

00801f19 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    

00801f23 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f29:	68 c4 2b 80 00       	push   $0x802bc4
  801f2e:	ff 75 0c             	pushl  0xc(%ebp)
  801f31:	e8 c0 ed ff ff       	call   800cf6 <strcpy>
	return 0;
}
  801f36:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3b:	c9                   	leave  
  801f3c:	c3                   	ret    

00801f3d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	57                   	push   %edi
  801f41:	56                   	push   %esi
  801f42:	53                   	push   %ebx
  801f43:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f49:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f4e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f54:	eb 2d                	jmp    801f83 <devcons_write+0x46>
		m = n - tot;
  801f56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f59:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f5b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f5e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f63:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f66:	83 ec 04             	sub    $0x4,%esp
  801f69:	53                   	push   %ebx
  801f6a:	03 45 0c             	add    0xc(%ebp),%eax
  801f6d:	50                   	push   %eax
  801f6e:	57                   	push   %edi
  801f6f:	e8 14 ef ff ff       	call   800e88 <memmove>
		sys_cputs(buf, m);
  801f74:	83 c4 08             	add    $0x8,%esp
  801f77:	53                   	push   %ebx
  801f78:	57                   	push   %edi
  801f79:	e8 bf f0 ff ff       	call   80103d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f7e:	01 de                	add    %ebx,%esi
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	89 f0                	mov    %esi,%eax
  801f85:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f88:	72 cc                	jb     801f56 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	83 ec 08             	sub    $0x8,%esp
  801f98:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f9d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fa1:	74 2a                	je     801fcd <devcons_read+0x3b>
  801fa3:	eb 05                	jmp    801faa <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fa5:	e8 30 f1 ff ff       	call   8010da <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801faa:	e8 ac f0 ff ff       	call   80105b <sys_cgetc>
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	74 f2                	je     801fa5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	78 16                	js     801fcd <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fb7:	83 f8 04             	cmp    $0x4,%eax
  801fba:	74 0c                	je     801fc8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fbf:	88 02                	mov    %al,(%edx)
	return 1;
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	eb 05                	jmp    801fcd <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fc8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    

00801fcf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fdb:	6a 01                	push   $0x1
  801fdd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fe0:	50                   	push   %eax
  801fe1:	e8 57 f0 ff ff       	call   80103d <sys_cputs>
}
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    

00801feb <getchar>:

int
getchar(void)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ff1:	6a 01                	push   $0x1
  801ff3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff6:	50                   	push   %eax
  801ff7:	6a 00                	push   $0x0
  801ff9:	e8 bc f6 ff ff       	call   8016ba <read>
	if (r < 0)
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	85 c0                	test   %eax,%eax
  802003:	78 0f                	js     802014 <getchar+0x29>
		return r;
	if (r < 1)
  802005:	85 c0                	test   %eax,%eax
  802007:	7e 06                	jle    80200f <getchar+0x24>
		return -E_EOF;
	return c;
  802009:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80200d:	eb 05                	jmp    802014 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80200f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80201c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201f:	50                   	push   %eax
  802020:	ff 75 08             	pushl  0x8(%ebp)
  802023:	e8 2c f4 ff ff       	call   801454 <fd_lookup>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	78 11                	js     802040 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802032:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802038:	39 10                	cmp    %edx,(%eax)
  80203a:	0f 94 c0             	sete   %al
  80203d:	0f b6 c0             	movzbl %al,%eax
}
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <opencons>:

int
opencons(void)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204b:	50                   	push   %eax
  80204c:	e8 b4 f3 ff ff       	call   801405 <fd_alloc>
  802051:	83 c4 10             	add    $0x10,%esp
		return r;
  802054:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802056:	85 c0                	test   %eax,%eax
  802058:	78 3e                	js     802098 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80205a:	83 ec 04             	sub    $0x4,%esp
  80205d:	68 07 04 00 00       	push   $0x407
  802062:	ff 75 f4             	pushl  -0xc(%ebp)
  802065:	6a 00                	push   $0x0
  802067:	e8 8d f0 ff ff       	call   8010f9 <sys_page_alloc>
  80206c:	83 c4 10             	add    $0x10,%esp
		return r;
  80206f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802071:	85 c0                	test   %eax,%eax
  802073:	78 23                	js     802098 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802075:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80207b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802080:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802083:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80208a:	83 ec 0c             	sub    $0xc,%esp
  80208d:	50                   	push   %eax
  80208e:	e8 4b f3 ff ff       	call   8013de <fd2num>
  802093:	89 c2                	mov    %eax,%edx
  802095:	83 c4 10             	add    $0x10,%esp
}
  802098:	89 d0                	mov    %edx,%eax
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    

0080209c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020a2:	89 d0                	mov    %edx,%eax
  8020a4:	c1 e8 16             	shr    $0x16,%eax
  8020a7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020ae:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b3:	f6 c1 01             	test   $0x1,%cl
  8020b6:	74 1d                	je     8020d5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020b8:	c1 ea 0c             	shr    $0xc,%edx
  8020bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020c2:	f6 c2 01             	test   $0x1,%dl
  8020c5:	74 0e                	je     8020d5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020c7:	c1 ea 0c             	shr    $0xc,%edx
  8020ca:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020d1:	ef 
  8020d2:	0f b7 c0             	movzwl %ax,%eax
}
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    
  8020d7:	66 90                	xchg   %ax,%ax
  8020d9:	66 90                	xchg   %ax,%ax
  8020db:	66 90                	xchg   %ax,%ax
  8020dd:	66 90                	xchg   %ax,%ax
  8020df:	90                   	nop

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 f6                	test   %esi,%esi
  8020f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020fd:	89 ca                	mov    %ecx,%edx
  8020ff:	89 f8                	mov    %edi,%eax
  802101:	75 3d                	jne    802140 <__udivdi3+0x60>
  802103:	39 cf                	cmp    %ecx,%edi
  802105:	0f 87 c5 00 00 00    	ja     8021d0 <__udivdi3+0xf0>
  80210b:	85 ff                	test   %edi,%edi
  80210d:	89 fd                	mov    %edi,%ebp
  80210f:	75 0b                	jne    80211c <__udivdi3+0x3c>
  802111:	b8 01 00 00 00       	mov    $0x1,%eax
  802116:	31 d2                	xor    %edx,%edx
  802118:	f7 f7                	div    %edi
  80211a:	89 c5                	mov    %eax,%ebp
  80211c:	89 c8                	mov    %ecx,%eax
  80211e:	31 d2                	xor    %edx,%edx
  802120:	f7 f5                	div    %ebp
  802122:	89 c1                	mov    %eax,%ecx
  802124:	89 d8                	mov    %ebx,%eax
  802126:	89 cf                	mov    %ecx,%edi
  802128:	f7 f5                	div    %ebp
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	39 ce                	cmp    %ecx,%esi
  802142:	77 74                	ja     8021b8 <__udivdi3+0xd8>
  802144:	0f bd fe             	bsr    %esi,%edi
  802147:	83 f7 1f             	xor    $0x1f,%edi
  80214a:	0f 84 98 00 00 00    	je     8021e8 <__udivdi3+0x108>
  802150:	bb 20 00 00 00       	mov    $0x20,%ebx
  802155:	89 f9                	mov    %edi,%ecx
  802157:	89 c5                	mov    %eax,%ebp
  802159:	29 fb                	sub    %edi,%ebx
  80215b:	d3 e6                	shl    %cl,%esi
  80215d:	89 d9                	mov    %ebx,%ecx
  80215f:	d3 ed                	shr    %cl,%ebp
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e0                	shl    %cl,%eax
  802165:	09 ee                	or     %ebp,%esi
  802167:	89 d9                	mov    %ebx,%ecx
  802169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216d:	89 d5                	mov    %edx,%ebp
  80216f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802173:	d3 ed                	shr    %cl,%ebp
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e2                	shl    %cl,%edx
  802179:	89 d9                	mov    %ebx,%ecx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	09 c2                	or     %eax,%edx
  80217f:	89 d0                	mov    %edx,%eax
  802181:	89 ea                	mov    %ebp,%edx
  802183:	f7 f6                	div    %esi
  802185:	89 d5                	mov    %edx,%ebp
  802187:	89 c3                	mov    %eax,%ebx
  802189:	f7 64 24 0c          	mull   0xc(%esp)
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	72 10                	jb     8021a1 <__udivdi3+0xc1>
  802191:	8b 74 24 08          	mov    0x8(%esp),%esi
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e6                	shl    %cl,%esi
  802199:	39 c6                	cmp    %eax,%esi
  80219b:	73 07                	jae    8021a4 <__udivdi3+0xc4>
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	75 03                	jne    8021a4 <__udivdi3+0xc4>
  8021a1:	83 eb 01             	sub    $0x1,%ebx
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 d8                	mov    %ebx,%eax
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	31 ff                	xor    %edi,%edi
  8021ba:	31 db                	xor    %ebx,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d8                	mov    %ebx,%eax
  8021d2:	f7 f7                	div    %edi
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 c3                	mov    %eax,%ebx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 1c             	add    $0x1c,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	39 ce                	cmp    %ecx,%esi
  8021ea:	72 0c                	jb     8021f8 <__udivdi3+0x118>
  8021ec:	31 db                	xor    %ebx,%ebx
  8021ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021f2:	0f 87 34 ff ff ff    	ja     80212c <__udivdi3+0x4c>
  8021f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021fd:	e9 2a ff ff ff       	jmp    80212c <__udivdi3+0x4c>
  802202:	66 90                	xchg   %ax,%ax
  802204:	66 90                	xchg   %ax,%ax
  802206:	66 90                	xchg   %ax,%ax
  802208:	66 90                	xchg   %ax,%ax
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80221b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80221f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 d2                	test   %edx,%edx
  802229:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f3                	mov    %esi,%ebx
  802233:	89 3c 24             	mov    %edi,(%esp)
  802236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223a:	75 1c                	jne    802258 <__umoddi3+0x48>
  80223c:	39 f7                	cmp    %esi,%edi
  80223e:	76 50                	jbe    802290 <__umoddi3+0x80>
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	f7 f7                	div    %edi
  802246:	89 d0                	mov    %edx,%eax
  802248:	31 d2                	xor    %edx,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	39 f2                	cmp    %esi,%edx
  80225a:	89 d0                	mov    %edx,%eax
  80225c:	77 52                	ja     8022b0 <__umoddi3+0xa0>
  80225e:	0f bd ea             	bsr    %edx,%ebp
  802261:	83 f5 1f             	xor    $0x1f,%ebp
  802264:	75 5a                	jne    8022c0 <__umoddi3+0xb0>
  802266:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80226a:	0f 82 e0 00 00 00    	jb     802350 <__umoddi3+0x140>
  802270:	39 0c 24             	cmp    %ecx,(%esp)
  802273:	0f 86 d7 00 00 00    	jbe    802350 <__umoddi3+0x140>
  802279:	8b 44 24 08          	mov    0x8(%esp),%eax
  80227d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802281:	83 c4 1c             	add    $0x1c,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	85 ff                	test   %edi,%edi
  802292:	89 fd                	mov    %edi,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x91>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f7                	div    %edi
  80229f:	89 c5                	mov    %eax,%ebp
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f5                	div    %ebp
  8022a7:	89 c8                	mov    %ecx,%eax
  8022a9:	f7 f5                	div    %ebp
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	eb 99                	jmp    802248 <__umoddi3+0x38>
  8022af:	90                   	nop
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	83 c4 1c             	add    $0x1c,%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5f                   	pop    %edi
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	8b 34 24             	mov    (%esp),%esi
  8022c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	29 ef                	sub    %ebp,%edi
  8022cc:	d3 e0                	shl    %cl,%eax
  8022ce:	89 f9                	mov    %edi,%ecx
  8022d0:	89 f2                	mov    %esi,%edx
  8022d2:	d3 ea                	shr    %cl,%edx
  8022d4:	89 e9                	mov    %ebp,%ecx
  8022d6:	09 c2                	or     %eax,%edx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 14 24             	mov    %edx,(%esp)
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	d3 e2                	shl    %cl,%edx
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	89 c6                	mov    %eax,%esi
  8022f1:	d3 e3                	shl    %cl,%ebx
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 d0                	mov    %edx,%eax
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	09 d8                	or     %ebx,%eax
  8022fd:	89 d3                	mov    %edx,%ebx
  8022ff:	89 f2                	mov    %esi,%edx
  802301:	f7 34 24             	divl   (%esp)
  802304:	89 d6                	mov    %edx,%esi
  802306:	d3 e3                	shl    %cl,%ebx
  802308:	f7 64 24 04          	mull   0x4(%esp)
  80230c:	39 d6                	cmp    %edx,%esi
  80230e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802312:	89 d1                	mov    %edx,%ecx
  802314:	89 c3                	mov    %eax,%ebx
  802316:	72 08                	jb     802320 <__umoddi3+0x110>
  802318:	75 11                	jne    80232b <__umoddi3+0x11b>
  80231a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80231e:	73 0b                	jae    80232b <__umoddi3+0x11b>
  802320:	2b 44 24 04          	sub    0x4(%esp),%eax
  802324:	1b 14 24             	sbb    (%esp),%edx
  802327:	89 d1                	mov    %edx,%ecx
  802329:	89 c3                	mov    %eax,%ebx
  80232b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80232f:	29 da                	sub    %ebx,%edx
  802331:	19 ce                	sbb    %ecx,%esi
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 f0                	mov    %esi,%eax
  802337:	d3 e0                	shl    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	d3 ea                	shr    %cl,%edx
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	d3 ee                	shr    %cl,%esi
  802341:	09 d0                	or     %edx,%eax
  802343:	89 f2                	mov    %esi,%edx
  802345:	83 c4 1c             	add    $0x1c,%esp
  802348:	5b                   	pop    %ebx
  802349:	5e                   	pop    %esi
  80234a:	5f                   	pop    %edi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    
  80234d:	8d 76 00             	lea    0x0(%esi),%esi
  802350:	29 f9                	sub    %edi,%ecx
  802352:	19 d6                	sbb    %edx,%esi
  802354:	89 74 24 04          	mov    %esi,0x4(%esp)
  802358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80235c:	e9 18 ff ff ff       	jmp    802279 <__umoddi3+0x69>
