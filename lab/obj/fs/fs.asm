
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 09 16 00 00       	call   80163a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 e0 33 80 00       	push   $0x8033e0
  8000b7:	e8 b7 16 00 00       	call   801773 <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 f7 33 80 00       	push   $0x8033f7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 07 34 80 00       	push   $0x803407
  8000e0:	e8 b5 15 00 00       	call   80169a <_panic>
	diskno = d;
  8000e5:	a3 00 40 80 00       	mov    %eax,0x804000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 10 34 80 00       	push   $0x803410
  80010b:	68 1d 34 80 00       	push   $0x80341d
  800110:	6a 44                	push   $0x44
  800112:	68 07 34 80 00       	push   $0x803407
  800117:	e8 7e 15 00 00       	call   80169a <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 40 80 00 	movzbl 0x804000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 10 34 80 00       	push   $0x803410
  8001cf:	68 1d 34 80 00       	push   $0x80341d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 07 34 80 00       	push   $0x803407
  8001db:	e8 ba 14 00 00       	call   80169a <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 40 80 00 	movzbl 0x804000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800280:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800282:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800288:	89 c6                	mov    %eax,%esi
  80028a:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028d:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800292:	76 1b                	jbe    8002af <bc_pgfault+0x3b>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	ff 72 04             	pushl  0x4(%edx)
  80029a:	53                   	push   %ebx
  80029b:	ff 72 28             	pushl  0x28(%edx)
  80029e:	68 34 34 80 00       	push   $0x803434
  8002a3:	6a 27                	push   $0x27
  8002a5:	68 10 35 80 00       	push   $0x803510
  8002aa:	e8 eb 13 00 00       	call   80169a <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002af:	a1 08 90 80 00       	mov    0x809008,%eax
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 70 04             	cmp    0x4(%eax),%esi
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	56                   	push   %esi
  8002be:	68 64 34 80 00       	push   $0x803464
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 10 35 80 00       	push   $0x803510
  8002ca:	e8 cb 13 00 00       	call   80169a <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:

	void* base_addr = ROUNDDOWN(addr, PGSIZE);
  8002cf:	89 df                	mov    %ebx,%edi
  8002d1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

	r = sys_page_alloc(0, base_addr, PTE_P|PTE_W|PTE_U);
  8002d7:	83 ec 04             	sub    $0x4,%esp
  8002da:	6a 07                	push   $0x7
  8002dc:	57                   	push   %edi
  8002dd:	6a 00                	push   $0x0
  8002df:	e8 17 1e 00 00       	call   8020fb <sys_page_alloc>
	if (r < 0)
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	79 12                	jns    8002fd <bc_pgfault+0x89>
		panic("bc_pgfault: sys_page_alloc: %e", r);
  8002eb:	50                   	push   %eax
  8002ec:	68 88 34 80 00       	push   $0x803488
  8002f1:	6a 38                	push   $0x38
  8002f3:	68 10 35 80 00       	push   $0x803510
  8002f8:	e8 9d 13 00 00       	call   80169a <_panic>

	r =	ide_read(blockno * 8, base_addr, 8);
  8002fd:	83 ec 04             	sub    $0x4,%esp
  800300:	6a 08                	push   $0x8
  800302:	57                   	push   %edi
  800303:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  80030a:	50                   	push   %eax
  80030b:	e8 dc fd ff ff       	call   8000ec <ide_read>
	if (r < 0)
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	85 c0                	test   %eax,%eax
  800315:	79 12                	jns    800329 <bc_pgfault+0xb5>
		panic("bc_pgfault: ide_read: %e", r);
  800317:	50                   	push   %eax
  800318:	68 18 35 80 00       	push   $0x803518
  80031d:	6a 3c                	push   $0x3c
  80031f:	68 10 35 80 00       	push   $0x803510
  800324:	e8 71 13 00 00       	call   80169a <_panic>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800329:	89 d8                	mov    %ebx,%eax
  80032b:	c1 e8 0c             	shr    $0xc,%eax
  80032e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	25 07 0e 00 00       	and    $0xe07,%eax
  80033d:	50                   	push   %eax
  80033e:	53                   	push   %ebx
  80033f:	6a 00                	push   $0x0
  800341:	53                   	push   %ebx
  800342:	6a 00                	push   $0x0
  800344:	e8 f5 1d 00 00       	call   80213e <sys_page_map>
  800349:	83 c4 20             	add    $0x20,%esp
  80034c:	85 c0                	test   %eax,%eax
  80034e:	79 12                	jns    800362 <bc_pgfault+0xee>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800350:	50                   	push   %eax
  800351:	68 a8 34 80 00       	push   $0x8034a8
  800356:	6a 41                	push   $0x41
  800358:	68 10 35 80 00       	push   $0x803510
  80035d:	e8 38 13 00 00       	call   80169a <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800362:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  800369:	74 22                	je     80038d <bc_pgfault+0x119>
  80036b:	83 ec 0c             	sub    $0xc,%esp
  80036e:	56                   	push   %esi
  80036f:	e8 36 06 00 00       	call   8009aa <block_is_free>
  800374:	83 c4 10             	add    $0x10,%esp
  800377:	84 c0                	test   %al,%al
  800379:	74 12                	je     80038d <bc_pgfault+0x119>
		panic("reading free block %08x\n", blockno);
  80037b:	56                   	push   %esi
  80037c:	68 31 35 80 00       	push   $0x803531
  800381:	6a 47                	push   $0x47
  800383:	68 10 35 80 00       	push   $0x803510
  800388:	e8 0d 13 00 00       	call   80169a <_panic>
}
  80038d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	74 0f                	je     8003b1 <diskaddr+0x1c>
  8003a2:	8b 15 08 90 80 00    	mov    0x809008,%edx
  8003a8:	85 d2                	test   %edx,%edx
  8003aa:	74 17                	je     8003c3 <diskaddr+0x2e>
  8003ac:	3b 42 04             	cmp    0x4(%edx),%eax
  8003af:	72 12                	jb     8003c3 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003b1:	50                   	push   %eax
  8003b2:	68 c8 34 80 00       	push   $0x8034c8
  8003b7:	6a 09                	push   $0x9
  8003b9:	68 10 35 80 00       	push   $0x803510
  8003be:	e8 d7 12 00 00       	call   80169a <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003c3:	05 00 00 01 00       	add    $0x10000,%eax
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
}
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003d3:	89 d0                	mov    %edx,%eax
  8003d5:	c1 e8 16             	shr    $0x16,%eax
  8003d8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003df:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e4:	f6 c1 01             	test   $0x1,%cl
  8003e7:	74 0d                	je     8003f6 <va_is_mapped+0x29>
  8003e9:	c1 ea 0c             	shr    $0xc,%edx
  8003ec:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003f3:	83 e0 01             	and    $0x1,%eax
  8003f6:	83 e0 01             	and    $0x1,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	c1 e8 0c             	shr    $0xc,%eax
  800404:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80040b:	c1 e8 06             	shr    $0x6,%eax
  80040e:	83 e0 01             	and    $0x1,%eax
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	56                   	push   %esi
  800417:	53                   	push   %ebx
  800418:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80041b:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800421:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800426:	76 12                	jbe    80043a <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800428:	53                   	push   %ebx
  800429:	68 4a 35 80 00       	push   $0x80354a
  80042e:	6a 57                	push   $0x57
  800430:	68 10 35 80 00       	push   $0x803510
  800435:	e8 60 12 00 00       	call   80169a <_panic>

	// LAB 5: Your code here.
	// panic("flush_block not implemented");

	if (!va_is_mapped(addr) || !va_is_dirty(addr))
  80043a:	83 ec 0c             	sub    $0xc,%esp
  80043d:	53                   	push   %ebx
  80043e:	e8 8a ff ff ff       	call   8003cd <va_is_mapped>
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	84 c0                	test   %al,%al
  800448:	0f 84 80 00 00 00    	je     8004ce <flush_block+0xbb>
  80044e:	83 ec 0c             	sub    $0xc,%esp
  800451:	53                   	push   %ebx
  800452:	e8 a4 ff ff ff       	call   8003fb <va_is_dirty>
  800457:	83 c4 10             	add    $0x10,%esp
  80045a:	84 c0                	test   %al,%al
  80045c:	74 70                	je     8004ce <flush_block+0xbb>
		return;
	
	void* base_addr = ROUNDDOWN(addr, PGSIZE);
  80045e:	89 de                	mov    %ebx,%esi
  800460:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	int r = ide_write(blockno * 8, base_addr, 8);
  800466:	83 ec 04             	sub    $0x4,%esp
  800469:	6a 08                	push   $0x8
  80046b:	56                   	push   %esi
  80046c:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800472:	c1 e8 0c             	shr    $0xc,%eax
  800475:	c1 e0 03             	shl    $0x3,%eax
  800478:	50                   	push   %eax
  800479:	e8 32 fd ff ff       	call   8001b0 <ide_write>
	if (r < 0)
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	85 c0                	test   %eax,%eax
  800483:	79 12                	jns    800497 <flush_block+0x84>
		panic("flush_block: ide_write: %e", r);
  800485:	50                   	push   %eax
  800486:	68 65 35 80 00       	push   $0x803565
  80048b:	6a 63                	push   $0x63
  80048d:	68 10 35 80 00       	push   $0x803510
  800492:	e8 03 12 00 00       	call   80169a <_panic>

	r = sys_page_map(0, base_addr, 0, base_addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  800497:	c1 eb 0c             	shr    $0xc,%ebx
  80049a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8004a1:	83 ec 0c             	sub    $0xc,%esp
  8004a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8004a9:	50                   	push   %eax
  8004aa:	56                   	push   %esi
  8004ab:	6a 00                	push   $0x0
  8004ad:	56                   	push   %esi
  8004ae:	6a 00                	push   $0x0
  8004b0:	e8 89 1c 00 00       	call   80213e <sys_page_map>
	if (r < 0)
  8004b5:	83 c4 20             	add    $0x20,%esp
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	79 12                	jns    8004ce <flush_block+0xbb>
		panic("flush_block: sys_page_map: %e", r);
  8004bc:	50                   	push   %eax
  8004bd:	68 80 35 80 00       	push   $0x803580
  8004c2:	6a 67                	push   $0x67
  8004c4:	68 10 35 80 00       	push   $0x803510
  8004c9:	e8 cc 11 00 00       	call   80169a <_panic>

}
  8004ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	53                   	push   %ebx
  8004d9:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004df:	68 74 02 80 00       	push   $0x800274
  8004e4:	e8 03 1e 00 00       	call   8022ec <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004f0:	e8 a0 fe ff ff       	call   800395 <diskaddr>
  8004f5:	83 c4 0c             	add    $0xc,%esp
  8004f8:	68 08 01 00 00       	push   $0x108
  8004fd:	50                   	push   %eax
  8004fe:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	e8 80 19 00 00       	call   801e8a <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80050a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800511:	e8 7f fe ff ff       	call   800395 <diskaddr>
  800516:	83 c4 08             	add    $0x8,%esp
  800519:	68 9e 35 80 00       	push   $0x80359e
  80051e:	50                   	push   %eax
  80051f:	e8 d4 17 00 00       	call   801cf8 <strcpy>
	flush_block(diskaddr(1));
  800524:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80052b:	e8 65 fe ff ff       	call   800395 <diskaddr>
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	e8 db fe ff ff       	call   800413 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800538:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80053f:	e8 51 fe ff ff       	call   800395 <diskaddr>
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	e8 81 fe ff ff       	call   8003cd <va_is_mapped>
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	84 c0                	test   %al,%al
  800551:	75 16                	jne    800569 <bc_init+0x94>
  800553:	68 c0 35 80 00       	push   $0x8035c0
  800558:	68 1d 34 80 00       	push   $0x80341d
  80055d:	6a 78                	push   $0x78
  80055f:	68 10 35 80 00       	push   $0x803510
  800564:	e8 31 11 00 00       	call   80169a <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	6a 01                	push   $0x1
  80056e:	e8 22 fe ff ff       	call   800395 <diskaddr>
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 80 fe ff ff       	call   8003fb <va_is_dirty>
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	84 c0                	test   %al,%al
  800580:	74 16                	je     800598 <bc_init+0xc3>
  800582:	68 a5 35 80 00       	push   $0x8035a5
  800587:	68 1d 34 80 00       	push   $0x80341d
  80058c:	6a 79                	push   $0x79
  80058e:	68 10 35 80 00       	push   $0x803510
  800593:	e8 02 11 00 00       	call   80169a <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	6a 01                	push   $0x1
  80059d:	e8 f3 fd ff ff       	call   800395 <diskaddr>
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	50                   	push   %eax
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 d3 1b 00 00       	call   802180 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b4:	e8 dc fd ff ff       	call   800395 <diskaddr>
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	e8 0c fe ff ff       	call   8003cd <va_is_mapped>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	84 c0                	test   %al,%al
  8005c6:	74 16                	je     8005de <bc_init+0x109>
  8005c8:	68 bf 35 80 00       	push   $0x8035bf
  8005cd:	68 1d 34 80 00       	push   $0x80341d
  8005d2:	6a 7d                	push   $0x7d
  8005d4:	68 10 35 80 00       	push   $0x803510
  8005d9:	e8 bc 10 00 00       	call   80169a <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	6a 01                	push   $0x1
  8005e3:	e8 ad fd ff ff       	call   800395 <diskaddr>
  8005e8:	83 c4 08             	add    $0x8,%esp
  8005eb:	68 9e 35 80 00       	push   $0x80359e
  8005f0:	50                   	push   %eax
  8005f1:	e8 ac 17 00 00       	call   801da2 <strcmp>
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	74 19                	je     800616 <bc_init+0x141>
  8005fd:	68 ec 34 80 00       	push   $0x8034ec
  800602:	68 1d 34 80 00       	push   $0x80341d
  800607:	68 80 00 00 00       	push   $0x80
  80060c:	68 10 35 80 00       	push   $0x803510
  800611:	e8 84 10 00 00       	call   80169a <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	6a 01                	push   $0x1
  80061b:	e8 75 fd ff ff       	call   800395 <diskaddr>
  800620:	83 c4 0c             	add    $0xc,%esp
  800623:	68 08 01 00 00       	push   $0x108
  800628:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	e8 55 18 00 00       	call   801e8a <memmove>
	flush_block(diskaddr(1));
  800635:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80063c:	e8 54 fd ff ff       	call   800395 <diskaddr>
  800641:	89 04 24             	mov    %eax,(%esp)
  800644:	e8 ca fd ff ff       	call   800413 <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800649:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800650:	e8 40 fd ff ff       	call   800395 <diskaddr>
  800655:	83 c4 0c             	add    $0xc,%esp
  800658:	68 08 01 00 00       	push   $0x108
  80065d:	50                   	push   %eax
  80065e:	53                   	push   %ebx
  80065f:	e8 26 18 00 00       	call   801e8a <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066b:	e8 25 fd ff ff       	call   800395 <diskaddr>
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	68 9e 35 80 00       	push   $0x80359e
  800678:	50                   	push   %eax
  800679:	e8 7a 16 00 00       	call   801cf8 <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  80067e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800685:	e8 0b fd ff ff       	call   800395 <diskaddr>
  80068a:	83 c0 14             	add    $0x14,%eax
  80068d:	89 04 24             	mov    %eax,(%esp)
  800690:	e8 7e fd ff ff       	call   800413 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800695:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80069c:	e8 f4 fc ff ff       	call   800395 <diskaddr>
  8006a1:	89 04 24             	mov    %eax,(%esp)
  8006a4:	e8 24 fd ff ff       	call   8003cd <va_is_mapped>
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	84 c0                	test   %al,%al
  8006ae:	75 19                	jne    8006c9 <bc_init+0x1f4>
  8006b0:	68 c0 35 80 00       	push   $0x8035c0
  8006b5:	68 1d 34 80 00       	push   $0x80341d
  8006ba:	68 91 00 00 00       	push   $0x91
  8006bf:	68 10 35 80 00       	push   $0x803510
  8006c4:	e8 d1 0f 00 00       	call   80169a <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	6a 01                	push   $0x1
  8006ce:	e8 c2 fc ff ff       	call   800395 <diskaddr>
  8006d3:	83 c4 08             	add    $0x8,%esp
  8006d6:	50                   	push   %eax
  8006d7:	6a 00                	push   $0x0
  8006d9:	e8 a2 1a 00 00       	call   802180 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e5:	e8 ab fc ff ff       	call   800395 <diskaddr>
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	e8 db fc ff ff       	call   8003cd <va_is_mapped>
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	84 c0                	test   %al,%al
  8006f7:	74 19                	je     800712 <bc_init+0x23d>
  8006f9:	68 bf 35 80 00       	push   $0x8035bf
  8006fe:	68 1d 34 80 00       	push   $0x80341d
  800703:	68 99 00 00 00       	push   $0x99
  800708:	68 10 35 80 00       	push   $0x803510
  80070d:	e8 88 0f 00 00       	call   80169a <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800712:	83 ec 0c             	sub    $0xc,%esp
  800715:	6a 01                	push   $0x1
  800717:	e8 79 fc ff ff       	call   800395 <diskaddr>
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	68 9e 35 80 00       	push   $0x80359e
  800724:	50                   	push   %eax
  800725:	e8 78 16 00 00       	call   801da2 <strcmp>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 19                	je     80074a <bc_init+0x275>
  800731:	68 ec 34 80 00       	push   $0x8034ec
  800736:	68 1d 34 80 00       	push   $0x80341d
  80073b:	68 9c 00 00 00       	push   $0x9c
  800740:	68 10 35 80 00       	push   $0x803510
  800745:	e8 50 0f 00 00       	call   80169a <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80074a:	83 ec 0c             	sub    $0xc,%esp
  80074d:	6a 01                	push   $0x1
  80074f:	e8 41 fc ff ff       	call   800395 <diskaddr>
  800754:	83 c4 0c             	add    $0xc,%esp
  800757:	68 08 01 00 00       	push   $0x108
  80075c:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800762:	52                   	push   %edx
  800763:	50                   	push   %eax
  800764:	e8 21 17 00 00       	call   801e8a <memmove>
	flush_block(diskaddr(1));
  800769:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800770:	e8 20 fc ff ff       	call   800395 <diskaddr>
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 96 fc ff ff       	call   800413 <flush_block>

	cprintf("block cache is good\n");
  80077d:	c7 04 24 da 35 80 00 	movl   $0x8035da,(%esp)
  800784:	e8 ea 0f 00 00       	call   801773 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800789:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800790:	e8 00 fc ff ff       	call   800395 <diskaddr>
  800795:	83 c4 0c             	add    $0xc,%esp
  800798:	68 08 01 00 00       	push   $0x108
  80079d:	50                   	push   %eax
  80079e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007a4:	50                   	push   %eax
  8007a5:	e8 e0 16 00 00       	call   801e8a <memmove>
}
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	57                   	push   %edi
  8007b6:	56                   	push   %esi
  8007b7:	53                   	push   %ebx
  8007b8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8007be:	89 95 64 ff ff ff    	mov    %edx,-0x9c(%ebp)
  8007c4:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  8007ca:	eb 03                	jmp    8007cf <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8007cc:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8007cf:	80 38 2f             	cmpb   $0x2f,(%eax)
  8007d2:	74 f8                	je     8007cc <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  8007d4:	8b 3d 08 90 80 00    	mov    0x809008,%edi
  8007da:	8d 4f 08             	lea    0x8(%edi),%ecx
  8007dd:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
	dir = 0;
	name[0] = 0;
  8007e3:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  8007ea:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
  8007f0:	85 c9                	test   %ecx,%ecx
  8007f2:	0f 84 3d 01 00 00    	je     800935 <walk_path+0x183>
		*pdir = 0;
  8007f8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  8007fe:	8b 8d 60 ff ff ff    	mov    -0xa0(%ebp),%ecx
  800804:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	while (*path != '\0') {
  80080a:	80 38 00             	cmpb   $0x0,(%eax)
  80080d:	0f 84 f3 00 00 00    	je     800906 <walk_path+0x154>
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800813:	89 c3                	mov    %eax,%ebx
  800815:	eb 03                	jmp    80081a <walk_path+0x68>
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800817:	83 c3 01             	add    $0x1,%ebx
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  80081a:	0f b6 13             	movzbl (%ebx),%edx
  80081d:	80 fa 2f             	cmp    $0x2f,%dl
  800820:	74 04                	je     800826 <walk_path+0x74>
  800822:	84 d2                	test   %dl,%dl
  800824:	75 f1                	jne    800817 <walk_path+0x65>
			path++;
		if (path - p >= MAXNAMELEN)
  800826:	89 de                	mov    %ebx,%esi
  800828:	29 c6                	sub    %eax,%esi
  80082a:	83 fe 7f             	cmp    $0x7f,%esi
  80082d:	0f 8f f4 00 00 00    	jg     800927 <walk_path+0x175>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800833:	83 ec 04             	sub    $0x4,%esp
  800836:	56                   	push   %esi
  800837:	50                   	push   %eax
  800838:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80083e:	50                   	push   %eax
  80083f:	e8 46 16 00 00       	call   801e8a <memmove>
		name[path - p] = '\0';
  800844:	c6 84 35 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%esi,1)
  80084b:	00 
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	eb 03                	jmp    800854 <walk_path+0xa2>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800851:	83 c3 01             	add    $0x1,%ebx

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800854:	0f b6 13             	movzbl (%ebx),%edx
  800857:	80 fa 2f             	cmp    $0x2f,%dl
  80085a:	74 f5                	je     800851 <walk_path+0x9f>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  80085c:	83 bf 8c 00 00 00 01 	cmpl   $0x1,0x8c(%edi)
  800863:	0f 85 c5 00 00 00    	jne    80092e <walk_path+0x17c>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800869:	8b 8f 88 00 00 00    	mov    0x88(%edi),%ecx
  80086f:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
  800875:	74 19                	je     800890 <walk_path+0xde>
  800877:	68 ef 35 80 00       	push   $0x8035ef
  80087c:	68 1d 34 80 00       	push   $0x80341d
  800881:	68 ab 00 00 00       	push   $0xab
  800886:	68 0c 36 80 00       	push   $0x80360c
  80088b:	e8 0a 0e 00 00       	call   80169a <_panic>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800890:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
  800896:	85 c9                	test   %ecx,%ecx
  800898:	0f 49 c1             	cmovns %ecx,%eax
  80089b:	c1 f8 0c             	sar    $0xc,%eax
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	74 17                	je     8008b9 <walk_path+0x107>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8008a2:	83 ec 04             	sub    $0x4,%esp
  8008a5:	68 e0 36 80 00       	push   $0x8036e0
  8008aa:	68 99 00 00 00       	push   $0x99
  8008af:	68 0c 36 80 00       	push   $0x80360c
  8008b4:	e8 e1 0d 00 00       	call   80169a <_panic>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  8008b9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  8008be:	84 d2                	test   %dl,%dl
  8008c0:	0f 85 86 00 00 00    	jne    80094c <walk_path+0x19a>
				if (pdir)
  8008c6:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	74 08                	je     8008d8 <walk_path+0x126>
					*pdir = dir;
  8008d0:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  8008d6:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  8008d8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008dc:	74 15                	je     8008f3 <walk_path+0x141>
					strcpy(lastelem, name);
  8008de:	83 ec 08             	sub    $0x8,%esp
  8008e1:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8008e7:	50                   	push   %eax
  8008e8:	ff 75 08             	pushl  0x8(%ebp)
  8008eb:	e8 08 14 00 00       	call   801cf8 <strcpy>
  8008f0:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  8008f3:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8008f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  8008ff:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800904:	eb 46                	jmp    80094c <walk_path+0x19a>
		}
	}

	if (pdir)
		*pdir = dir;
  800906:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  80090c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pf = f;
  800912:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  800918:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  80091e:	89 08                	mov    %ecx,(%eax)
	return 0;
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
  800925:	eb 25                	jmp    80094c <walk_path+0x19a>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800927:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80092c:	eb 1e                	jmp    80094c <walk_path+0x19a>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  80092e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800933:	eb 17                	jmp    80094c <walk_path+0x19a>
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  800935:	8b 8d 60 ff ff ff    	mov    -0xa0(%ebp),%ecx
  80093b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	while (*path != '\0') {
  800941:	80 38 00             	cmpb   $0x0,(%eax)
  800944:	0f 85 c9 fe ff ff    	jne    800813 <walk_path+0x61>
  80094a:	eb c6                	jmp    800912 <walk_path+0x160>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  80094c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5f                   	pop    %edi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80095a:	a1 08 90 80 00       	mov    0x809008,%eax
  80095f:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800965:	74 14                	je     80097b <check_super+0x27>
		panic("bad file system magic number");
  800967:	83 ec 04             	sub    $0x4,%esp
  80096a:	68 14 36 80 00       	push   $0x803614
  80096f:	6a 0f                	push   $0xf
  800971:	68 0c 36 80 00       	push   $0x80360c
  800976:	e8 1f 0d 00 00       	call   80169a <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80097b:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800982:	76 14                	jbe    800998 <check_super+0x44>
		panic("file system is too large");
  800984:	83 ec 04             	sub    $0x4,%esp
  800987:	68 31 36 80 00       	push   $0x803631
  80098c:	6a 12                	push   $0x12
  80098e:	68 0c 36 80 00       	push   $0x80360c
  800993:	e8 02 0d 00 00       	call   80169a <_panic>

	cprintf("superblock is good\n");
  800998:	83 ec 0c             	sub    $0xc,%esp
  80099b:	68 4a 36 80 00       	push   $0x80364a
  8009a0:	e8 ce 0d 00 00       	call   801773 <cprintf>
}
  8009a5:	83 c4 10             	add    $0x10,%esp
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	53                   	push   %ebx
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8009b1:	8b 15 08 90 80 00    	mov    0x809008,%edx
  8009b7:	85 d2                	test   %edx,%edx
  8009b9:	74 24                	je     8009df <block_is_free+0x35>
		return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8009c0:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8009c3:	76 1f                	jbe    8009e4 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8009c5:	89 cb                	mov    %ecx,%ebx
  8009c7:	c1 eb 05             	shr    $0x5,%ebx
  8009ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8009cf:	d3 e0                	shl    %cl,%eax
  8009d1:	8b 15 04 90 80 00    	mov    0x809004,%edx
  8009d7:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8009da:	0f 95 c0             	setne  %al
  8009dd:	eb 05                	jmp    8009e4 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	53                   	push   %ebx
  8009eb:	83 ec 04             	sub    $0x4,%esp
  8009ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  8009f1:	85 c9                	test   %ecx,%ecx
  8009f3:	75 14                	jne    800a09 <free_block+0x22>
		panic("attempt to free zero block");
  8009f5:	83 ec 04             	sub    $0x4,%esp
  8009f8:	68 5e 36 80 00       	push   $0x80365e
  8009fd:	6a 2d                	push   $0x2d
  8009ff:	68 0c 36 80 00       	push   $0x80360c
  800a04:	e8 91 0c 00 00       	call   80169a <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800a09:	89 cb                	mov    %ecx,%ebx
  800a0b:	c1 eb 05             	shr    $0x5,%ebx
  800a0e:	8b 15 04 90 80 00    	mov    0x809004,%edx
  800a14:	b8 01 00 00 00       	mov    $0x1,%eax
  800a19:	d3 e0                	shl    %cl,%eax
  800a1b:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800a1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	83 ec 0c             	sub    $0xc,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	panic("alloc_block not implemented");
  800a29:	68 79 36 80 00       	push   $0x803679
  800a2e:	6a 41                	push   $0x41
  800a30:	68 0c 36 80 00       	push   $0x80360c
  800a35:	e8 60 0c 00 00       	call   80169a <_panic>

00800a3a <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a3f:	a1 08 90 80 00       	mov    0x809008,%eax
  800a44:	8b 70 04             	mov    0x4(%eax),%esi
  800a47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a4c:	eb 29                	jmp    800a77 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800a4e:	8d 43 02             	lea    0x2(%ebx),%eax
  800a51:	50                   	push   %eax
  800a52:	e8 53 ff ff ff       	call   8009aa <block_is_free>
  800a57:	83 c4 04             	add    $0x4,%esp
  800a5a:	84 c0                	test   %al,%al
  800a5c:	74 16                	je     800a74 <check_bitmap+0x3a>
  800a5e:	68 95 36 80 00       	push   $0x803695
  800a63:	68 1d 34 80 00       	push   $0x80341d
  800a68:	6a 50                	push   $0x50
  800a6a:	68 0c 36 80 00       	push   $0x80360c
  800a6f:	e8 26 0c 00 00       	call   80169a <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a74:	83 c3 01             	add    $0x1,%ebx
  800a77:	89 d8                	mov    %ebx,%eax
  800a79:	c1 e0 0f             	shl    $0xf,%eax
  800a7c:	39 f0                	cmp    %esi,%eax
  800a7e:	72 ce                	jb     800a4e <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800a80:	83 ec 0c             	sub    $0xc,%esp
  800a83:	6a 00                	push   $0x0
  800a85:	e8 20 ff ff ff       	call   8009aa <block_is_free>
  800a8a:	83 c4 10             	add    $0x10,%esp
  800a8d:	84 c0                	test   %al,%al
  800a8f:	74 16                	je     800aa7 <check_bitmap+0x6d>
  800a91:	68 a9 36 80 00       	push   $0x8036a9
  800a96:	68 1d 34 80 00       	push   $0x80341d
  800a9b:	6a 53                	push   $0x53
  800a9d:	68 0c 36 80 00       	push   $0x80360c
  800aa2:	e8 f3 0b 00 00       	call   80169a <_panic>
	assert(!block_is_free(1));
  800aa7:	83 ec 0c             	sub    $0xc,%esp
  800aaa:	6a 01                	push   $0x1
  800aac:	e8 f9 fe ff ff       	call   8009aa <block_is_free>
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	84 c0                	test   %al,%al
  800ab6:	74 16                	je     800ace <check_bitmap+0x94>
  800ab8:	68 bb 36 80 00       	push   $0x8036bb
  800abd:	68 1d 34 80 00       	push   $0x80341d
  800ac2:	6a 54                	push   $0x54
  800ac4:	68 0c 36 80 00       	push   $0x80360c
  800ac9:	e8 cc 0b 00 00       	call   80169a <_panic>

	cprintf("bitmap is good\n");
  800ace:	83 ec 0c             	sub    $0xc,%esp
  800ad1:	68 cd 36 80 00       	push   $0x8036cd
  800ad6:	e8 98 0c 00 00       	call   801773 <cprintf>
}
  800adb:	83 c4 10             	add    $0x10,%esp
  800ade:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800aeb:	e8 6f f5 ff ff       	call   80005f <ide_probe_disk1>
  800af0:	84 c0                	test   %al,%al
  800af2:	74 0f                	je     800b03 <fs_init+0x1e>
		ide_set_disk(1);
  800af4:	83 ec 0c             	sub    $0xc,%esp
  800af7:	6a 01                	push   $0x1
  800af9:	e8 c5 f5 ff ff       	call   8000c3 <ide_set_disk>
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	eb 0d                	jmp    800b10 <fs_init+0x2b>
	else
		ide_set_disk(0);
  800b03:	83 ec 0c             	sub    $0xc,%esp
  800b06:	6a 00                	push   $0x0
  800b08:	e8 b6 f5 ff ff       	call   8000c3 <ide_set_disk>
  800b0d:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800b10:	e8 c0 f9 ff ff       	call   8004d5 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800b15:	83 ec 0c             	sub    $0xc,%esp
  800b18:	6a 01                	push   $0x1
  800b1a:	e8 76 f8 ff ff       	call   800395 <diskaddr>
  800b1f:	a3 08 90 80 00       	mov    %eax,0x809008
	check_super();
  800b24:	e8 2b fe ff ff       	call   800954 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800b29:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b30:	e8 60 f8 ff ff       	call   800395 <diskaddr>
  800b35:	a3 04 90 80 00       	mov    %eax,0x809004
	check_bitmap();
  800b3a:	e8 fb fe ff ff       	call   800a3a <check_bitmap>
	
}
  800b3f:	83 c4 10             	add    $0x10,%esp
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	83 ec 0c             	sub    $0xc,%esp
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800b4a:	68 e0 36 80 00       	push   $0x8036e0
  800b4f:	68 99 00 00 00       	push   $0x99
  800b54:	68 0c 36 80 00       	push   $0x80360c
  800b59:	e8 3c 0b 00 00       	call   80169a <_panic>

00800b5e <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800b69:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  800b6f:	50                   	push   %eax
  800b70:	8d 8d 70 ff ff ff    	lea    -0x90(%ebp),%ecx
  800b76:	8d 95 74 ff ff ff    	lea    -0x8c(%ebp),%edx
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	e8 2e fc ff ff       	call   8007b2 <walk_path>
  800b84:	83 c4 10             	add    $0x10,%esp
  800b87:	85 c0                	test   %eax,%eax
  800b89:	0f 84 82 00 00 00    	je     800c11 <file_create+0xb3>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800b8f:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800b92:	0f 85 85 00 00 00    	jne    800c1d <file_create+0xbf>
  800b98:	8b 8d 74 ff ff ff    	mov    -0x8c(%ebp),%ecx
  800b9e:	85 c9                	test   %ecx,%ecx
  800ba0:	74 76                	je     800c18 <file_create+0xba>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800ba2:	8b 99 80 00 00 00    	mov    0x80(%ecx),%ebx
  800ba8:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  800bae:	74 19                	je     800bc9 <file_create+0x6b>
  800bb0:	68 ef 35 80 00       	push   $0x8035ef
  800bb5:	68 1d 34 80 00       	push   $0x80341d
  800bba:	68 c4 00 00 00       	push   $0xc4
  800bbf:	68 0c 36 80 00       	push   $0x80360c
  800bc4:	e8 d1 0a 00 00       	call   80169a <_panic>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800bc9:	be 00 10 00 00       	mov    $0x1000,%esi
  800bce:	89 d8                	mov    %ebx,%eax
  800bd0:	99                   	cltd   
  800bd1:	f7 fe                	idiv   %esi
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	74 17                	je     800bee <file_create+0x90>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800bd7:	83 ec 04             	sub    $0x4,%esp
  800bda:	68 e0 36 80 00       	push   $0x8036e0
  800bdf:	68 99 00 00 00       	push   $0x99
  800be4:	68 0c 36 80 00       	push   $0x80360c
  800be9:	e8 ac 0a 00 00       	call   80169a <_panic>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800bee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800bf4:	89 99 80 00 00 00    	mov    %ebx,0x80(%ecx)
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800bfa:	83 ec 04             	sub    $0x4,%esp
  800bfd:	68 e0 36 80 00       	push   $0x8036e0
  800c02:	68 99 00 00 00       	push   $0x99
  800c07:	68 0c 36 80 00       	push   $0x80360c
  800c0c:	e8 89 0a 00 00       	call   80169a <_panic>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800c11:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800c16:	eb 05                	jmp    800c1d <file_create+0xbf>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  800c18:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  800c1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800c2a:	6a 00                	push   $0x0
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c34:	8b 45 08             	mov    0x8(%ebp),%eax
  800c37:	e8 76 fb ff ff       	call   8007b2 <walk_path>
}
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c47:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800c50:	39 d0                	cmp    %edx,%eax
  800c52:	7e 27                	jle    800c7b <file_read+0x3d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c54:	29 d0                	sub    %edx,%eax
  800c56:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c59:	0f 47 45 10          	cmova  0x10(%ebp),%eax

	for (pos = offset; pos < offset + count; ) {
  800c5d:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800c60:	39 ca                	cmp    %ecx,%edx
  800c62:	73 1c                	jae    800c80 <file_read+0x42>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800c64:	83 ec 04             	sub    $0x4,%esp
  800c67:	68 e0 36 80 00       	push   $0x8036e0
  800c6c:	68 99 00 00 00       	push   $0x99
  800c71:	68 0c 36 80 00       	push   $0x80360c
  800c76:	e8 1f 0a 00 00       	call   80169a <_panic>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800c7b:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    

00800c82 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c8a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800c8d:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800c93:	39 f0                	cmp    %esi,%eax
  800c95:	7e 65                	jle    800cfc <file_set_size+0x7a>
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800c97:	8d 96 fe 1f 00 00    	lea    0x1ffe(%esi),%edx
  800c9d:	89 f1                	mov    %esi,%ecx
  800c9f:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
  800ca5:	0f 49 d1             	cmovns %ecx,%edx
  800ca8:	c1 fa 0c             	sar    $0xc,%edx
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800cab:	8d 88 fe 1f 00 00    	lea    0x1ffe(%eax),%ecx
  800cb1:	05 ff 0f 00 00       	add    $0xfff,%eax
  800cb6:	0f 48 c1             	cmovs  %ecx,%eax
  800cb9:	c1 f8 0c             	sar    $0xc,%eax
  800cbc:	39 d0                	cmp    %edx,%eax
  800cbe:	76 17                	jbe    800cd7 <file_set_size+0x55>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  800cc0:	83 ec 04             	sub    $0x4,%esp
  800cc3:	68 00 37 80 00       	push   $0x803700
  800cc8:	68 8a 00 00 00       	push   $0x8a
  800ccd:	68 0c 36 80 00       	push   $0x80360c
  800cd2:	e8 c3 09 00 00       	call   80169a <_panic>
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800cd7:	83 fa 0a             	cmp    $0xa,%edx
  800cda:	77 20                	ja     800cfc <file_set_size+0x7a>
  800cdc:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	74 16                	je     800cfc <file_set_size+0x7a>
		free_block(f->f_indirect);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	e8 f8 fc ff ff       	call   8009e7 <free_block>
		f->f_indirect = 0;
  800cef:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
  800cf6:	00 00 00 
  800cf9:	83 c4 10             	add    $0x10,%esp
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800cfc:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	53                   	push   %ebx
  800d06:	e8 08 f7 ff ff       	call   800413 <flush_block>
	return 0;
}
  800d0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800d29:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
  800d2c:	3b b0 80 00 00 00    	cmp    0x80(%eax),%esi
  800d32:	76 11                	jbe    800d45 <file_write+0x2e>
		if ((r = file_set_size(f, offset + count)) < 0)
  800d34:	83 ec 08             	sub    $0x8,%esp
  800d37:	56                   	push   %esi
  800d38:	50                   	push   %eax
  800d39:	e8 44 ff ff ff       	call   800c82 <file_set_size>
  800d3e:	83 c4 10             	add    $0x10,%esp
  800d41:	85 c0                	test   %eax,%eax
  800d43:	78 1d                	js     800d62 <file_write+0x4b>
			return r;

	for (pos = offset; pos < offset + count; ) {
  800d45:	39 f7                	cmp    %esi,%edi
  800d47:	73 17                	jae    800d60 <file_write+0x49>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800d49:	83 ec 04             	sub    $0x4,%esp
  800d4c:	68 e0 36 80 00       	push   $0x8036e0
  800d51:	68 99 00 00 00       	push   $0x99
  800d56:	68 0c 36 80 00       	push   $0x80360c
  800d5b:	e8 3a 09 00 00       	call   80169a <_panic>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800d60:	89 d8                	mov    %ebx,%eax
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 04             	sub    $0x4,%esp
  800d71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800d74:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800d7a:	05 ff 0f 00 00       	add    $0xfff,%eax
  800d7f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800d84:	7e 17                	jle    800d9d <file_flush+0x33>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	68 00 37 80 00       	push   $0x803700
  800d8e:	68 8a 00 00 00       	push   $0x8a
  800d93:	68 0c 36 80 00       	push   $0x80360c
  800d98:	e8 fd 08 00 00       	call   80169a <_panic>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	53                   	push   %ebx
  800da1:	e8 6d f6 ff ff       	call   800413 <flush_block>
	if (f->f_indirect)
  800da6:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	85 c0                	test   %eax,%eax
  800db1:	74 14                	je     800dc7 <file_flush+0x5d>
		flush_block(diskaddr(f->f_indirect));
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	50                   	push   %eax
  800db7:	e8 d9 f5 ff ff       	call   800395 <diskaddr>
  800dbc:	89 04 24             	mov    %eax,(%esp)
  800dbf:	e8 4f f6 ff ff       	call   800413 <flush_block>
  800dc4:	83 c4 10             	add    $0x10,%esp
}
  800dc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dca:	c9                   	leave  
  800dcb:	c3                   	ret    

00800dcc <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800dd3:	bb 01 00 00 00       	mov    $0x1,%ebx
  800dd8:	eb 17                	jmp    800df1 <fs_sync+0x25>
		flush_block(diskaddr(i));
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	53                   	push   %ebx
  800dde:	e8 b2 f5 ff ff       	call   800395 <diskaddr>
  800de3:	89 04 24             	mov    %eax,(%esp)
  800de6:	e8 28 f6 ff ff       	call   800413 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800deb:	83 c3 01             	add    $0x1,%ebx
  800dee:	83 c4 10             	add    $0x10,%esp
  800df1:	a1 08 90 80 00       	mov    0x809008,%eax
  800df6:	39 58 04             	cmp    %ebx,0x4(%eax)
  800df9:	77 df                	ja     800dda <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  800dfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    

00800e00 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	return 0;
}
  800e03:	b8 00 00 00 00       	mov    $0x0,%eax
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	83 ec 0c             	sub    $0xc,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  800e10:	68 20 37 80 00       	push   $0x803720
  800e15:	68 e8 00 00 00       	push   $0xe8
  800e1a:	68 3c 37 80 00       	push   $0x80373c
  800e1f:	e8 76 08 00 00       	call   80169a <_panic>

00800e24 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  800e2a:	e8 9d ff ff ff       	call   800dcc <fs_sync>
	return 0;
}
  800e2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e34:	c9                   	leave  
  800e35:	c3                   	ret    

00800e36 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	ba 60 40 80 00       	mov    $0x804060,%edx
	int i;
	uintptr_t va = FILEVA;
  800e3e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  800e48:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800e4a:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800e4d:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800e53:	83 c0 01             	add    $0x1,%eax
  800e56:	83 c2 10             	add    $0x10,%edx
  800e59:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e5e:	75 e8                	jne    800e48 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	89 d8                	mov    %ebx,%eax
  800e74:	c1 e0 04             	shl    $0x4,%eax
  800e77:	ff b0 6c 40 80 00    	pushl  0x80406c(%eax)
  800e7d:	e8 a8 1d 00 00       	call   802c2a <pageref>
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	74 07                	je     800e90 <openfile_alloc+0x2e>
  800e89:	83 f8 01             	cmp    $0x1,%eax
  800e8c:	74 20                	je     800eae <openfile_alloc+0x4c>
  800e8e:	eb 51                	jmp    800ee1 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800e90:	83 ec 04             	sub    $0x4,%esp
  800e93:	6a 07                	push   $0x7
  800e95:	89 d8                	mov    %ebx,%eax
  800e97:	c1 e0 04             	shl    $0x4,%eax
  800e9a:	ff b0 6c 40 80 00    	pushl  0x80406c(%eax)
  800ea0:	6a 00                	push   $0x0
  800ea2:	e8 54 12 00 00       	call   8020fb <sys_page_alloc>
  800ea7:	83 c4 10             	add    $0x10,%esp
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	78 43                	js     800ef1 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  800eae:	c1 e3 04             	shl    $0x4,%ebx
  800eb1:	8d 83 60 40 80 00    	lea    0x804060(%ebx),%eax
  800eb7:	81 83 60 40 80 00 00 	addl   $0x400,0x804060(%ebx)
  800ebe:	04 00 00 
			*o = &opentab[i];
  800ec1:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  800ec3:	83 ec 04             	sub    $0x4,%esp
  800ec6:	68 00 10 00 00       	push   $0x1000
  800ecb:	6a 00                	push   $0x0
  800ecd:	ff b3 6c 40 80 00    	pushl  0x80406c(%ebx)
  800ed3:	e8 65 0f 00 00       	call   801e3d <memset>
			return (*o)->o_fileid;
  800ed8:	8b 06                	mov    (%esi),%eax
  800eda:	8b 00                	mov    (%eax),%eax
  800edc:	83 c4 10             	add    $0x10,%esp
  800edf:	eb 10                	jmp    800ef1 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800ee1:	83 c3 01             	add    $0x1,%ebx
  800ee4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800eea:	75 83                	jne    800e6f <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  800eec:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ef1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	53                   	push   %ebx
  800efe:	83 ec 18             	sub    $0x18,%esp
  800f01:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800f04:	89 fb                	mov    %edi,%ebx
  800f06:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800f0c:	89 de                	mov    %ebx,%esi
  800f0e:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800f11:	ff b6 6c 40 80 00    	pushl  0x80406c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800f17:	81 c6 60 40 80 00    	add    $0x804060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800f1d:	e8 08 1d 00 00       	call   802c2a <pageref>
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	83 f8 01             	cmp    $0x1,%eax
  800f28:	7e 17                	jle    800f41 <openfile_lookup+0x49>
  800f2a:	c1 e3 04             	shl    $0x4,%ebx
  800f2d:	3b bb 60 40 80 00    	cmp    0x804060(%ebx),%edi
  800f33:	75 13                	jne    800f48 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  800f35:	8b 45 10             	mov    0x10(%ebp),%eax
  800f38:	89 30                	mov    %esi,(%eax)
	return 0;
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3f:	eb 0c                	jmp    800f4d <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  800f41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f46:	eb 05                	jmp    800f4d <openfile_lookup+0x55>
  800f48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  800f4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	53                   	push   %ebx
  800f59:	83 ec 18             	sub    $0x18,%esp
  800f5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800f5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f62:	50                   	push   %eax
  800f63:	ff 33                	pushl  (%ebx)
  800f65:	ff 75 08             	pushl  0x8(%ebp)
  800f68:	e8 8b ff ff ff       	call   800ef8 <openfile_lookup>
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	78 14                	js     800f88 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  800f74:	83 ec 08             	sub    $0x8,%esp
  800f77:	ff 73 04             	pushl  0x4(%ebx)
  800f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7d:	ff 70 04             	pushl  0x4(%eax)
  800f80:	e8 fd fc ff ff       	call   800c82 <file_set_size>
  800f85:	83 c4 10             	add    $0x10,%esp
}
  800f88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	53                   	push   %ebx
  800f91:	83 ec 18             	sub    $0x18,%esp
  800f94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800f97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9a:	50                   	push   %eax
  800f9b:	ff 33                	pushl  (%ebx)
  800f9d:	ff 75 08             	pushl  0x8(%ebp)
  800fa0:	e8 53 ff ff ff       	call   800ef8 <openfile_lookup>
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 3f                	js     800feb <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  800fac:	83 ec 08             	sub    $0x8,%esp
  800faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb2:	ff 70 04             	pushl  0x4(%eax)
  800fb5:	53                   	push   %ebx
  800fb6:	e8 3d 0d 00 00       	call   801cf8 <strcpy>
	ret->ret_size = o->o_file->f_size;
  800fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbe:	8b 50 04             	mov    0x4(%eax),%edx
  800fc1:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800fc7:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  800fcd:	8b 40 04             	mov    0x4(%eax),%eax
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800fda:	0f 94 c0             	sete   %al
  800fdd:	0f b6 c0             	movzbl %al,%eax
  800fe0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800fe6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800feb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff9:	50                   	push   %eax
  800ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffd:	ff 30                	pushl  (%eax)
  800fff:	ff 75 08             	pushl  0x8(%ebp)
  801002:	e8 f1 fe ff ff       	call   800ef8 <openfile_lookup>
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 16                	js     801024 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801014:	ff 70 04             	pushl  0x4(%eax)
  801017:	e8 4e fd ff ff       	call   800d6a <file_flush>
	return 0;
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801024:	c9                   	leave  
  801025:	c3                   	ret    

00801026 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	53                   	push   %ebx
  80102a:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801030:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801033:	68 00 04 00 00       	push   $0x400
  801038:	53                   	push   %ebx
  801039:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80103f:	50                   	push   %eax
  801040:	e8 45 0e 00 00       	call   801e8a <memmove>
	path[MAXPATHLEN-1] = 0;
  801045:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801049:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  80104f:	89 04 24             	mov    %eax,(%esp)
  801052:	e8 0b fe ff ff       	call   800e62 <openfile_alloc>
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	0f 88 f0 00 00 00    	js     801152 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801062:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801069:	74 33                	je     80109e <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  80106b:	83 ec 08             	sub    $0x8,%esp
  80106e:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801074:	50                   	push   %eax
  801075:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80107b:	50                   	push   %eax
  80107c:	e8 dd fa ff ff       	call   800b5e <file_create>
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	79 37                	jns    8010bf <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801088:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  80108f:	0f 85 bd 00 00 00    	jne    801152 <serve_open+0x12c>
  801095:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801098:	0f 85 b4 00 00 00    	jne    801152 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80109e:	83 ec 08             	sub    $0x8,%esp
  8010a1:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8010a7:	50                   	push   %eax
  8010a8:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8010ae:	50                   	push   %eax
  8010af:	e8 70 fb ff ff       	call   800c24 <file_open>
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	0f 88 93 00 00 00    	js     801152 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8010bf:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8010c6:	74 17                	je     8010df <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8010c8:	83 ec 08             	sub    $0x8,%esp
  8010cb:	6a 00                	push   $0x0
  8010cd:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8010d3:	e8 aa fb ff ff       	call   800c82 <file_set_size>
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	78 73                	js     801152 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8010df:	83 ec 08             	sub    $0x8,%esp
  8010e2:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	e8 2f fb ff ff       	call   800c24 <file_open>
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	78 56                	js     801152 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8010fc:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801102:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801108:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  80110b:	8b 50 0c             	mov    0xc(%eax),%edx
  80110e:	8b 08                	mov    (%eax),%ecx
  801110:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801113:	8b 48 0c             	mov    0xc(%eax),%ecx
  801116:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80111c:	83 e2 03             	and    $0x3,%edx
  80111f:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801122:	8b 40 0c             	mov    0xc(%eax),%eax
  801125:	8b 15 64 80 80 00    	mov    0x808064,%edx
  80112b:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80112d:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801133:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801139:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80113c:	8b 50 0c             	mov    0xc(%eax),%edx
  80113f:	8b 45 10             	mov    0x10(%ebp),%eax
  801142:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801144:	8b 45 14             	mov    0x14(%ebp),%eax
  801147:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80114d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	56                   	push   %esi
  80115b:	53                   	push   %ebx
  80115c:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80115f:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801162:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801165:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80116c:	83 ec 04             	sub    $0x4,%esp
  80116f:	53                   	push   %ebx
  801170:	ff 35 44 40 80 00    	pushl  0x804044
  801176:	56                   	push   %esi
  801177:	e8 db 11 00 00       	call   802357 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801183:	75 15                	jne    80119a <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	ff 75 f4             	pushl  -0xc(%ebp)
  80118b:	68 68 37 80 00       	push   $0x803768
  801190:	e8 de 05 00 00       	call   801773 <cprintf>
				whom);
			continue; // just leave it hanging...
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	eb cb                	jmp    801165 <serve+0xe>
		}

		pg = NULL;
  80119a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8011a1:	83 f8 01             	cmp    $0x1,%eax
  8011a4:	75 18                	jne    8011be <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8011a6:	53                   	push   %ebx
  8011a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8011aa:	50                   	push   %eax
  8011ab:	ff 35 44 40 80 00    	pushl  0x804044
  8011b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8011b4:	e8 6d fe ff ff       	call   801026 <serve_open>
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	eb 3c                	jmp    8011fa <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8011be:	83 f8 08             	cmp    $0x8,%eax
  8011c1:	77 1e                	ja     8011e1 <serve+0x8a>
  8011c3:	8b 14 85 20 40 80 00 	mov    0x804020(,%eax,4),%edx
  8011ca:	85 d2                	test   %edx,%edx
  8011cc:	74 13                	je     8011e1 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	ff 35 44 40 80 00    	pushl  0x804044
  8011d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8011da:	ff d2                	call   *%edx
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	eb 19                	jmp    8011fa <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e7:	50                   	push   %eax
  8011e8:	68 98 37 80 00       	push   $0x803798
  8011ed:	e8 81 05 00 00       	call   801773 <cprintf>
  8011f2:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8011f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8011fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8011fd:	ff 75 ec             	pushl  -0x14(%ebp)
  801200:	50                   	push   %eax
  801201:	ff 75 f4             	pushl  -0xc(%ebp)
  801204:	e8 b5 11 00 00       	call   8023be <ipc_send>
		sys_page_unmap(0, fsreq);
  801209:	83 c4 08             	add    $0x8,%esp
  80120c:	ff 35 44 40 80 00    	pushl  0x804044
  801212:	6a 00                	push   $0x0
  801214:	e8 67 0f 00 00       	call   802180 <sys_page_unmap>
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	e9 44 ff ff ff       	jmp    801165 <serve+0xe>

00801221 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801227:	c7 05 60 80 80 00 46 	movl   $0x803746,0x808060
  80122e:	37 80 00 
	cprintf("FS is running\n");
  801231:	68 49 37 80 00       	push   $0x803749
  801236:	e8 38 05 00 00       	call   801773 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80123b:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801240:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801245:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801247:	c7 04 24 58 37 80 00 	movl   $0x803758,(%esp)
  80124e:	e8 20 05 00 00       	call   801773 <cprintf>

	serve_init();
  801253:	e8 de fb ff ff       	call   800e36 <serve_init>
	fs_init();
  801258:	e8 88 f8 ff ff       	call   800ae5 <fs_init>
        fs_test();
  80125d:	e8 05 00 00 00       	call   801267 <fs_test>
	serve();
  801262:	e8 f0 fe ff ff       	call   801157 <serve>

00801267 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	53                   	push   %ebx
  80126b:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80126e:	6a 07                	push   $0x7
  801270:	68 00 10 00 00       	push   $0x1000
  801275:	6a 00                	push   $0x0
  801277:	e8 7f 0e 00 00       	call   8020fb <sys_page_alloc>
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	79 12                	jns    801295 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801283:	50                   	push   %eax
  801284:	68 bb 37 80 00       	push   $0x8037bb
  801289:	6a 12                	push   $0x12
  80128b:	68 ce 37 80 00       	push   $0x8037ce
  801290:	e8 05 04 00 00       	call   80169a <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	68 00 10 00 00       	push   $0x1000
  80129d:	ff 35 04 90 80 00    	pushl  0x809004
  8012a3:	68 00 10 00 00       	push   $0x1000
  8012a8:	e8 dd 0b 00 00       	call   801e8a <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8012ad:	e8 71 f7 ff ff       	call   800a23 <alloc_block>
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	79 12                	jns    8012cb <fs_test+0x64>
		panic("alloc_block: %e", r);
  8012b9:	50                   	push   %eax
  8012ba:	68 d8 37 80 00       	push   $0x8037d8
  8012bf:	6a 17                	push   $0x17
  8012c1:	68 ce 37 80 00       	push   $0x8037ce
  8012c6:	e8 cf 03 00 00       	call   80169a <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8012cb:	8d 50 1f             	lea    0x1f(%eax),%edx
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	0f 49 d0             	cmovns %eax,%edx
  8012d3:	c1 fa 05             	sar    $0x5,%edx
  8012d6:	89 c3                	mov    %eax,%ebx
  8012d8:	c1 fb 1f             	sar    $0x1f,%ebx
  8012db:	c1 eb 1b             	shr    $0x1b,%ebx
  8012de:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8012e1:	83 e1 1f             	and    $0x1f,%ecx
  8012e4:	29 d9                	sub    %ebx,%ecx
  8012e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012eb:	d3 e0                	shl    %cl,%eax
  8012ed:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8012f4:	75 16                	jne    80130c <fs_test+0xa5>
  8012f6:	68 e8 37 80 00       	push   $0x8037e8
  8012fb:	68 1d 34 80 00       	push   $0x80341d
  801300:	6a 19                	push   $0x19
  801302:	68 ce 37 80 00       	push   $0x8037ce
  801307:	e8 8e 03 00 00       	call   80169a <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80130c:	8b 0d 04 90 80 00    	mov    0x809004,%ecx
  801312:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801315:	74 16                	je     80132d <fs_test+0xc6>
  801317:	68 60 39 80 00       	push   $0x803960
  80131c:	68 1d 34 80 00       	push   $0x80341d
  801321:	6a 1b                	push   $0x1b
  801323:	68 ce 37 80 00       	push   $0x8037ce
  801328:	e8 6d 03 00 00       	call   80169a <_panic>
	cprintf("alloc_block is good\n");
  80132d:	83 ec 0c             	sub    $0xc,%esp
  801330:	68 03 38 80 00       	push   $0x803803
  801335:	e8 39 04 00 00       	call   801773 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80133a:	83 c4 08             	add    $0x8,%esp
  80133d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	68 18 38 80 00       	push   $0x803818
  801346:	e8 d9 f8 ff ff       	call   800c24 <file_open>
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801351:	74 1b                	je     80136e <fs_test+0x107>
  801353:	89 c2                	mov    %eax,%edx
  801355:	c1 ea 1f             	shr    $0x1f,%edx
  801358:	84 d2                	test   %dl,%dl
  80135a:	74 12                	je     80136e <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80135c:	50                   	push   %eax
  80135d:	68 23 38 80 00       	push   $0x803823
  801362:	6a 1f                	push   $0x1f
  801364:	68 ce 37 80 00       	push   $0x8037ce
  801369:	e8 2c 03 00 00       	call   80169a <_panic>
	else if (r == 0)
  80136e:	85 c0                	test   %eax,%eax
  801370:	75 14                	jne    801386 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801372:	83 ec 04             	sub    $0x4,%esp
  801375:	68 80 39 80 00       	push   $0x803980
  80137a:	6a 21                	push   $0x21
  80137c:	68 ce 37 80 00       	push   $0x8037ce
  801381:	e8 14 03 00 00       	call   80169a <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	68 3c 38 80 00       	push   $0x80383c
  801392:	e8 8d f8 ff ff       	call   800c24 <file_open>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	79 12                	jns    8013b0 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  80139e:	50                   	push   %eax
  80139f:	68 45 38 80 00       	push   $0x803845
  8013a4:	6a 23                	push   $0x23
  8013a6:	68 ce 37 80 00       	push   $0x8037ce
  8013ab:	e8 ea 02 00 00       	call   80169a <_panic>
	cprintf("file_open is good\n");
  8013b0:	83 ec 0c             	sub    $0xc,%esp
  8013b3:	68 5c 38 80 00       	push   $0x80385c
  8013b8:	e8 b6 03 00 00       	call   801773 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8013bd:	83 c4 0c             	add    $0xc,%esp
  8013c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c3:	50                   	push   %eax
  8013c4:	6a 00                	push   $0x0
  8013c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c9:	e8 76 f7 ff ff       	call   800b44 <file_get_block>
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	79 12                	jns    8013e7 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8013d5:	50                   	push   %eax
  8013d6:	68 6f 38 80 00       	push   $0x80386f
  8013db:	6a 27                	push   $0x27
  8013dd:	68 ce 37 80 00       	push   $0x8037ce
  8013e2:	e8 b3 02 00 00       	call   80169a <_panic>
	if (strcmp(blk, msg) != 0)
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	68 a0 39 80 00       	push   $0x8039a0
  8013ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f2:	e8 ab 09 00 00       	call   801da2 <strcmp>
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	74 14                	je     801412 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8013fe:	83 ec 04             	sub    $0x4,%esp
  801401:	68 c8 39 80 00       	push   $0x8039c8
  801406:	6a 29                	push   $0x29
  801408:	68 ce 37 80 00       	push   $0x8037ce
  80140d:	e8 88 02 00 00       	call   80169a <_panic>
	cprintf("file_get_block is good\n");
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	68 82 38 80 00       	push   $0x803882
  80141a:	e8 54 03 00 00       	call   801773 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80141f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801422:	0f b6 10             	movzbl (%eax),%edx
  801425:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801427:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142a:	c1 e8 0c             	shr    $0xc,%eax
  80142d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	a8 40                	test   $0x40,%al
  801439:	75 16                	jne    801451 <fs_test+0x1ea>
  80143b:	68 9b 38 80 00       	push   $0x80389b
  801440:	68 1d 34 80 00       	push   $0x80341d
  801445:	6a 2d                	push   $0x2d
  801447:	68 ce 37 80 00       	push   $0x8037ce
  80144c:	e8 49 02 00 00       	call   80169a <_panic>
	file_flush(f);
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	ff 75 f4             	pushl  -0xc(%ebp)
  801457:	e8 0e f9 ff ff       	call   800d6a <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80145c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145f:	c1 e8 0c             	shr    $0xc,%eax
  801462:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	a8 40                	test   $0x40,%al
  80146e:	74 16                	je     801486 <fs_test+0x21f>
  801470:	68 9a 38 80 00       	push   $0x80389a
  801475:	68 1d 34 80 00       	push   $0x80341d
  80147a:	6a 2f                	push   $0x2f
  80147c:	68 ce 37 80 00       	push   $0x8037ce
  801481:	e8 14 02 00 00       	call   80169a <_panic>
	cprintf("file_flush is good\n");
  801486:	83 ec 0c             	sub    $0xc,%esp
  801489:	68 b6 38 80 00       	push   $0x8038b6
  80148e:	e8 e0 02 00 00       	call   801773 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801493:	83 c4 08             	add    $0x8,%esp
  801496:	6a 00                	push   $0x0
  801498:	ff 75 f4             	pushl  -0xc(%ebp)
  80149b:	e8 e2 f7 ff ff       	call   800c82 <file_set_size>
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	79 12                	jns    8014b9 <fs_test+0x252>
		panic("file_set_size: %e", r);
  8014a7:	50                   	push   %eax
  8014a8:	68 ca 38 80 00       	push   $0x8038ca
  8014ad:	6a 33                	push   $0x33
  8014af:	68 ce 37 80 00       	push   $0x8037ce
  8014b4:	e8 e1 01 00 00       	call   80169a <_panic>
	assert(f->f_direct[0] == 0);
  8014b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bc:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8014c3:	74 16                	je     8014db <fs_test+0x274>
  8014c5:	68 dc 38 80 00       	push   $0x8038dc
  8014ca:	68 1d 34 80 00       	push   $0x80341d
  8014cf:	6a 34                	push   $0x34
  8014d1:	68 ce 37 80 00       	push   $0x8037ce
  8014d6:	e8 bf 01 00 00       	call   80169a <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8014db:	c1 e8 0c             	shr    $0xc,%eax
  8014de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e5:	a8 40                	test   $0x40,%al
  8014e7:	74 16                	je     8014ff <fs_test+0x298>
  8014e9:	68 f0 38 80 00       	push   $0x8038f0
  8014ee:	68 1d 34 80 00       	push   $0x80341d
  8014f3:	6a 35                	push   $0x35
  8014f5:	68 ce 37 80 00       	push   $0x8037ce
  8014fa:	e8 9b 01 00 00       	call   80169a <_panic>
	cprintf("file_truncate is good\n");
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	68 0a 39 80 00       	push   $0x80390a
  801507:	e8 67 02 00 00       	call   801773 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80150c:	c7 04 24 a0 39 80 00 	movl   $0x8039a0,(%esp)
  801513:	e8 a7 07 00 00       	call   801cbf <strlen>
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	50                   	push   %eax
  80151c:	ff 75 f4             	pushl  -0xc(%ebp)
  80151f:	e8 5e f7 ff ff       	call   800c82 <file_set_size>
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	79 12                	jns    80153d <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  80152b:	50                   	push   %eax
  80152c:	68 21 39 80 00       	push   $0x803921
  801531:	6a 39                	push   $0x39
  801533:	68 ce 37 80 00       	push   $0x8037ce
  801538:	e8 5d 01 00 00       	call   80169a <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80153d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801540:	89 c2                	mov    %eax,%edx
  801542:	c1 ea 0c             	shr    $0xc,%edx
  801545:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80154c:	f6 c2 40             	test   $0x40,%dl
  80154f:	74 16                	je     801567 <fs_test+0x300>
  801551:	68 f0 38 80 00       	push   $0x8038f0
  801556:	68 1d 34 80 00       	push   $0x80341d
  80155b:	6a 3a                	push   $0x3a
  80155d:	68 ce 37 80 00       	push   $0x8037ce
  801562:	e8 33 01 00 00       	call   80169a <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80156d:	52                   	push   %edx
  80156e:	6a 00                	push   $0x0
  801570:	50                   	push   %eax
  801571:	e8 ce f5 ff ff       	call   800b44 <file_get_block>
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	85 c0                	test   %eax,%eax
  80157b:	79 12                	jns    80158f <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  80157d:	50                   	push   %eax
  80157e:	68 35 39 80 00       	push   $0x803935
  801583:	6a 3c                	push   $0x3c
  801585:	68 ce 37 80 00       	push   $0x8037ce
  80158a:	e8 0b 01 00 00       	call   80169a <_panic>
	strcpy(blk, msg);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	68 a0 39 80 00       	push   $0x8039a0
  801597:	ff 75 f0             	pushl  -0x10(%ebp)
  80159a:	e8 59 07 00 00       	call   801cf8 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80159f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a2:	c1 e8 0c             	shr    $0xc,%eax
  8015a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	a8 40                	test   $0x40,%al
  8015b1:	75 16                	jne    8015c9 <fs_test+0x362>
  8015b3:	68 9b 38 80 00       	push   $0x80389b
  8015b8:	68 1d 34 80 00       	push   $0x80341d
  8015bd:	6a 3e                	push   $0x3e
  8015bf:	68 ce 37 80 00       	push   $0x8037ce
  8015c4:	e8 d1 00 00 00       	call   80169a <_panic>
	file_flush(f);
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8015cf:	e8 96 f7 ff ff       	call   800d6a <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8015d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d7:	c1 e8 0c             	shr    $0xc,%eax
  8015da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	a8 40                	test   $0x40,%al
  8015e6:	74 16                	je     8015fe <fs_test+0x397>
  8015e8:	68 9a 38 80 00       	push   $0x80389a
  8015ed:	68 1d 34 80 00       	push   $0x80341d
  8015f2:	6a 40                	push   $0x40
  8015f4:	68 ce 37 80 00       	push   $0x8037ce
  8015f9:	e8 9c 00 00 00       	call   80169a <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8015fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801601:	c1 e8 0c             	shr    $0xc,%eax
  801604:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80160b:	a8 40                	test   $0x40,%al
  80160d:	74 16                	je     801625 <fs_test+0x3be>
  80160f:	68 f0 38 80 00       	push   $0x8038f0
  801614:	68 1d 34 80 00       	push   $0x80341d
  801619:	6a 41                	push   $0x41
  80161b:	68 ce 37 80 00       	push   $0x8037ce
  801620:	e8 75 00 00 00       	call   80169a <_panic>
	cprintf("file rewrite is good\n");
  801625:	83 ec 0c             	sub    $0xc,%esp
  801628:	68 4a 39 80 00       	push   $0x80394a
  80162d:	e8 41 01 00 00       	call   801773 <cprintf>
}
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801638:	c9                   	leave  
  801639:	c3                   	ret    

0080163a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801642:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801645:	e8 73 0a 00 00       	call   8020bd <sys_getenvid>
  80164a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80164f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801652:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801657:	a3 0c 90 80 00       	mov    %eax,0x80900c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80165c:	85 db                	test   %ebx,%ebx
  80165e:	7e 07                	jle    801667 <libmain+0x2d>
		binaryname = argv[0];
  801660:	8b 06                	mov    (%esi),%eax
  801662:	a3 60 80 80 00       	mov    %eax,0x808060

	// call user main routine
	umain(argc, argv);
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	56                   	push   %esi
  80166b:	53                   	push   %ebx
  80166c:	e8 b0 fb ff ff       	call   801221 <umain>

	// exit gracefully
	exit();
  801671:	e8 0a 00 00 00       	call   801680 <exit>
}
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801686:	e8 8b 0f 00 00       	call   802616 <close_all>
	sys_env_destroy(0);
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	6a 00                	push   $0x0
  801690:	e8 e7 09 00 00       	call   80207c <sys_env_destroy>
}
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	56                   	push   %esi
  80169e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80169f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8016a2:	8b 35 60 80 80 00    	mov    0x808060,%esi
  8016a8:	e8 10 0a 00 00       	call   8020bd <sys_getenvid>
  8016ad:	83 ec 0c             	sub    $0xc,%esp
  8016b0:	ff 75 0c             	pushl  0xc(%ebp)
  8016b3:	ff 75 08             	pushl  0x8(%ebp)
  8016b6:	56                   	push   %esi
  8016b7:	50                   	push   %eax
  8016b8:	68 f8 39 80 00       	push   $0x8039f8
  8016bd:	e8 b1 00 00 00       	call   801773 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8016c2:	83 c4 18             	add    $0x18,%esp
  8016c5:	53                   	push   %ebx
  8016c6:	ff 75 10             	pushl  0x10(%ebp)
  8016c9:	e8 54 00 00 00       	call   801722 <vcprintf>
	cprintf("\n");
  8016ce:	c7 04 24 a3 35 80 00 	movl   $0x8035a3,(%esp)
  8016d5:	e8 99 00 00 00       	call   801773 <cprintf>
  8016da:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8016dd:	cc                   	int3   
  8016de:	eb fd                	jmp    8016dd <_panic+0x43>

008016e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 04             	sub    $0x4,%esp
  8016e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8016ea:	8b 13                	mov    (%ebx),%edx
  8016ec:	8d 42 01             	lea    0x1(%edx),%eax
  8016ef:	89 03                	mov    %eax,(%ebx)
  8016f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8016f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8016fd:	75 1a                	jne    801719 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	68 ff 00 00 00       	push   $0xff
  801707:	8d 43 08             	lea    0x8(%ebx),%eax
  80170a:	50                   	push   %eax
  80170b:	e8 2f 09 00 00       	call   80203f <sys_cputs>
		b->idx = 0;
  801710:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801716:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801719:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80171d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80172b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801732:	00 00 00 
	b.cnt = 0;
  801735:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80173c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80173f:	ff 75 0c             	pushl  0xc(%ebp)
  801742:	ff 75 08             	pushl  0x8(%ebp)
  801745:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80174b:	50                   	push   %eax
  80174c:	68 e0 16 80 00       	push   $0x8016e0
  801751:	e8 54 01 00 00       	call   8018aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801756:	83 c4 08             	add    $0x8,%esp
  801759:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80175f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801765:	50                   	push   %eax
  801766:	e8 d4 08 00 00       	call   80203f <sys_cputs>

	return b.cnt;
}
  80176b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801779:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80177c:	50                   	push   %eax
  80177d:	ff 75 08             	pushl  0x8(%ebp)
  801780:	e8 9d ff ff ff       	call   801722 <vcprintf>
	va_end(ap);

	return cnt;
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	57                   	push   %edi
  80178b:	56                   	push   %esi
  80178c:	53                   	push   %ebx
  80178d:	83 ec 1c             	sub    $0x1c,%esp
  801790:	89 c7                	mov    %eax,%edi
  801792:	89 d6                	mov    %edx,%esi
  801794:	8b 45 08             	mov    0x8(%ebp),%eax
  801797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80179d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8017a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8017ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8017ae:	39 d3                	cmp    %edx,%ebx
  8017b0:	72 05                	jb     8017b7 <printnum+0x30>
  8017b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8017b5:	77 45                	ja     8017fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8017b7:	83 ec 0c             	sub    $0xc,%esp
  8017ba:	ff 75 18             	pushl  0x18(%ebp)
  8017bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8017c3:	53                   	push   %ebx
  8017c4:	ff 75 10             	pushl  0x10(%ebp)
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8017d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8017d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8017d6:	e8 75 19 00 00       	call   803150 <__udivdi3>
  8017db:	83 c4 18             	add    $0x18,%esp
  8017de:	52                   	push   %edx
  8017df:	50                   	push   %eax
  8017e0:	89 f2                	mov    %esi,%edx
  8017e2:	89 f8                	mov    %edi,%eax
  8017e4:	e8 9e ff ff ff       	call   801787 <printnum>
  8017e9:	83 c4 20             	add    $0x20,%esp
  8017ec:	eb 18                	jmp    801806 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	56                   	push   %esi
  8017f2:	ff 75 18             	pushl  0x18(%ebp)
  8017f5:	ff d7                	call   *%edi
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	eb 03                	jmp    8017ff <printnum+0x78>
  8017fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017ff:	83 eb 01             	sub    $0x1,%ebx
  801802:	85 db                	test   %ebx,%ebx
  801804:	7f e8                	jg     8017ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801806:	83 ec 08             	sub    $0x8,%esp
  801809:	56                   	push   %esi
  80180a:	83 ec 04             	sub    $0x4,%esp
  80180d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801810:	ff 75 e0             	pushl  -0x20(%ebp)
  801813:	ff 75 dc             	pushl  -0x24(%ebp)
  801816:	ff 75 d8             	pushl  -0x28(%ebp)
  801819:	e8 62 1a 00 00       	call   803280 <__umoddi3>
  80181e:	83 c4 14             	add    $0x14,%esp
  801821:	0f be 80 1b 3a 80 00 	movsbl 0x803a1b(%eax),%eax
  801828:	50                   	push   %eax
  801829:	ff d7                	call   *%edi
}
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801831:	5b                   	pop    %ebx
  801832:	5e                   	pop    %esi
  801833:	5f                   	pop    %edi
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    

00801836 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801839:	83 fa 01             	cmp    $0x1,%edx
  80183c:	7e 0e                	jle    80184c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80183e:	8b 10                	mov    (%eax),%edx
  801840:	8d 4a 08             	lea    0x8(%edx),%ecx
  801843:	89 08                	mov    %ecx,(%eax)
  801845:	8b 02                	mov    (%edx),%eax
  801847:	8b 52 04             	mov    0x4(%edx),%edx
  80184a:	eb 22                	jmp    80186e <getuint+0x38>
	else if (lflag)
  80184c:	85 d2                	test   %edx,%edx
  80184e:	74 10                	je     801860 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801850:	8b 10                	mov    (%eax),%edx
  801852:	8d 4a 04             	lea    0x4(%edx),%ecx
  801855:	89 08                	mov    %ecx,(%eax)
  801857:	8b 02                	mov    (%edx),%eax
  801859:	ba 00 00 00 00       	mov    $0x0,%edx
  80185e:	eb 0e                	jmp    80186e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801860:	8b 10                	mov    (%eax),%edx
  801862:	8d 4a 04             	lea    0x4(%edx),%ecx
  801865:	89 08                	mov    %ecx,(%eax)
  801867:	8b 02                	mov    (%edx),%eax
  801869:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80186e:	5d                   	pop    %ebp
  80186f:	c3                   	ret    

00801870 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801876:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80187a:	8b 10                	mov    (%eax),%edx
  80187c:	3b 50 04             	cmp    0x4(%eax),%edx
  80187f:	73 0a                	jae    80188b <sprintputch+0x1b>
		*b->buf++ = ch;
  801881:	8d 4a 01             	lea    0x1(%edx),%ecx
  801884:	89 08                	mov    %ecx,(%eax)
  801886:	8b 45 08             	mov    0x8(%ebp),%eax
  801889:	88 02                	mov    %al,(%edx)
}
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801893:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801896:	50                   	push   %eax
  801897:	ff 75 10             	pushl  0x10(%ebp)
  80189a:	ff 75 0c             	pushl  0xc(%ebp)
  80189d:	ff 75 08             	pushl  0x8(%ebp)
  8018a0:	e8 05 00 00 00       	call   8018aa <vprintfmt>
	va_end(ap);
}
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	57                   	push   %edi
  8018ae:	56                   	push   %esi
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 2c             	sub    $0x2c,%esp
  8018b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8018b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8018bc:	eb 12                	jmp    8018d0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	0f 84 89 03 00 00    	je     801c4f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	53                   	push   %ebx
  8018ca:	50                   	push   %eax
  8018cb:	ff d6                	call   *%esi
  8018cd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8018d0:	83 c7 01             	add    $0x1,%edi
  8018d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018d7:	83 f8 25             	cmp    $0x25,%eax
  8018da:	75 e2                	jne    8018be <vprintfmt+0x14>
  8018dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8018e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8018e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8018f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fa:	eb 07                	jmp    801903 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801903:	8d 47 01             	lea    0x1(%edi),%eax
  801906:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801909:	0f b6 07             	movzbl (%edi),%eax
  80190c:	0f b6 c8             	movzbl %al,%ecx
  80190f:	83 e8 23             	sub    $0x23,%eax
  801912:	3c 55                	cmp    $0x55,%al
  801914:	0f 87 1a 03 00 00    	ja     801c34 <vprintfmt+0x38a>
  80191a:	0f b6 c0             	movzbl %al,%eax
  80191d:	ff 24 85 60 3b 80 00 	jmp    *0x803b60(,%eax,4)
  801924:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801927:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80192b:	eb d6                	jmp    801903 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801930:	b8 00 00 00 00       	mov    $0x0,%eax
  801935:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801938:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80193b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80193f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801942:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801945:	83 fa 09             	cmp    $0x9,%edx
  801948:	77 39                	ja     801983 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80194a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80194d:	eb e9                	jmp    801938 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80194f:	8b 45 14             	mov    0x14(%ebp),%eax
  801952:	8d 48 04             	lea    0x4(%eax),%ecx
  801955:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801958:	8b 00                	mov    (%eax),%eax
  80195a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80195d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801960:	eb 27                	jmp    801989 <vprintfmt+0xdf>
  801962:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801965:	85 c0                	test   %eax,%eax
  801967:	b9 00 00 00 00       	mov    $0x0,%ecx
  80196c:	0f 49 c8             	cmovns %eax,%ecx
  80196f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801972:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801975:	eb 8c                	jmp    801903 <vprintfmt+0x59>
  801977:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80197a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801981:	eb 80                	jmp    801903 <vprintfmt+0x59>
  801983:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801986:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801989:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80198d:	0f 89 70 ff ff ff    	jns    801903 <vprintfmt+0x59>
				width = precision, precision = -1;
  801993:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801996:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801999:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8019a0:	e9 5e ff ff ff       	jmp    801903 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8019a5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8019ab:	e9 53 ff ff ff       	jmp    801903 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8019b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b3:	8d 50 04             	lea    0x4(%eax),%edx
  8019b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	53                   	push   %ebx
  8019bd:	ff 30                	pushl  (%eax)
  8019bf:	ff d6                	call   *%esi
			break;
  8019c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8019c7:	e9 04 ff ff ff       	jmp    8018d0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8019cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cf:	8d 50 04             	lea    0x4(%eax),%edx
  8019d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d5:	8b 00                	mov    (%eax),%eax
  8019d7:	99                   	cltd   
  8019d8:	31 d0                	xor    %edx,%eax
  8019da:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8019dc:	83 f8 0f             	cmp    $0xf,%eax
  8019df:	7f 0b                	jg     8019ec <vprintfmt+0x142>
  8019e1:	8b 14 85 c0 3c 80 00 	mov    0x803cc0(,%eax,4),%edx
  8019e8:	85 d2                	test   %edx,%edx
  8019ea:	75 18                	jne    801a04 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8019ec:	50                   	push   %eax
  8019ed:	68 33 3a 80 00       	push   $0x803a33
  8019f2:	53                   	push   %ebx
  8019f3:	56                   	push   %esi
  8019f4:	e8 94 fe ff ff       	call   80188d <printfmt>
  8019f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019ff:	e9 cc fe ff ff       	jmp    8018d0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801a04:	52                   	push   %edx
  801a05:	68 2f 34 80 00       	push   $0x80342f
  801a0a:	53                   	push   %ebx
  801a0b:	56                   	push   %esi
  801a0c:	e8 7c fe ff ff       	call   80188d <printfmt>
  801a11:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a17:	e9 b4 fe ff ff       	jmp    8018d0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801a1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1f:	8d 50 04             	lea    0x4(%eax),%edx
  801a22:	89 55 14             	mov    %edx,0x14(%ebp)
  801a25:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801a27:	85 ff                	test   %edi,%edi
  801a29:	b8 2c 3a 80 00       	mov    $0x803a2c,%eax
  801a2e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801a31:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801a35:	0f 8e 94 00 00 00    	jle    801acf <vprintfmt+0x225>
  801a3b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801a3f:	0f 84 98 00 00 00    	je     801add <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801a45:	83 ec 08             	sub    $0x8,%esp
  801a48:	ff 75 d0             	pushl  -0x30(%ebp)
  801a4b:	57                   	push   %edi
  801a4c:	e8 86 02 00 00       	call   801cd7 <strnlen>
  801a51:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801a54:	29 c1                	sub    %eax,%ecx
  801a56:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801a59:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801a5c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801a60:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a63:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801a66:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a68:	eb 0f                	jmp    801a79 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801a6a:	83 ec 08             	sub    $0x8,%esp
  801a6d:	53                   	push   %ebx
  801a6e:	ff 75 e0             	pushl  -0x20(%ebp)
  801a71:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a73:	83 ef 01             	sub    $0x1,%edi
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	85 ff                	test   %edi,%edi
  801a7b:	7f ed                	jg     801a6a <vprintfmt+0x1c0>
  801a7d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801a80:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801a83:	85 c9                	test   %ecx,%ecx
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8a:	0f 49 c1             	cmovns %ecx,%eax
  801a8d:	29 c1                	sub    %eax,%ecx
  801a8f:	89 75 08             	mov    %esi,0x8(%ebp)
  801a92:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a95:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a98:	89 cb                	mov    %ecx,%ebx
  801a9a:	eb 4d                	jmp    801ae9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a9c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801aa0:	74 1b                	je     801abd <vprintfmt+0x213>
  801aa2:	0f be c0             	movsbl %al,%eax
  801aa5:	83 e8 20             	sub    $0x20,%eax
  801aa8:	83 f8 5e             	cmp    $0x5e,%eax
  801aab:	76 10                	jbe    801abd <vprintfmt+0x213>
					putch('?', putdat);
  801aad:	83 ec 08             	sub    $0x8,%esp
  801ab0:	ff 75 0c             	pushl  0xc(%ebp)
  801ab3:	6a 3f                	push   $0x3f
  801ab5:	ff 55 08             	call   *0x8(%ebp)
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	eb 0d                	jmp    801aca <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801abd:	83 ec 08             	sub    $0x8,%esp
  801ac0:	ff 75 0c             	pushl  0xc(%ebp)
  801ac3:	52                   	push   %edx
  801ac4:	ff 55 08             	call   *0x8(%ebp)
  801ac7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801aca:	83 eb 01             	sub    $0x1,%ebx
  801acd:	eb 1a                	jmp    801ae9 <vprintfmt+0x23f>
  801acf:	89 75 08             	mov    %esi,0x8(%ebp)
  801ad2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ad5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ad8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801adb:	eb 0c                	jmp    801ae9 <vprintfmt+0x23f>
  801add:	89 75 08             	mov    %esi,0x8(%ebp)
  801ae0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ae3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ae6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ae9:	83 c7 01             	add    $0x1,%edi
  801aec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801af0:	0f be d0             	movsbl %al,%edx
  801af3:	85 d2                	test   %edx,%edx
  801af5:	74 23                	je     801b1a <vprintfmt+0x270>
  801af7:	85 f6                	test   %esi,%esi
  801af9:	78 a1                	js     801a9c <vprintfmt+0x1f2>
  801afb:	83 ee 01             	sub    $0x1,%esi
  801afe:	79 9c                	jns    801a9c <vprintfmt+0x1f2>
  801b00:	89 df                	mov    %ebx,%edi
  801b02:	8b 75 08             	mov    0x8(%ebp),%esi
  801b05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b08:	eb 18                	jmp    801b22 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801b0a:	83 ec 08             	sub    $0x8,%esp
  801b0d:	53                   	push   %ebx
  801b0e:	6a 20                	push   $0x20
  801b10:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b12:	83 ef 01             	sub    $0x1,%edi
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	eb 08                	jmp    801b22 <vprintfmt+0x278>
  801b1a:	89 df                	mov    %ebx,%edi
  801b1c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b22:	85 ff                	test   %edi,%edi
  801b24:	7f e4                	jg     801b0a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b29:	e9 a2 fd ff ff       	jmp    8018d0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801b2e:	83 fa 01             	cmp    $0x1,%edx
  801b31:	7e 16                	jle    801b49 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801b33:	8b 45 14             	mov    0x14(%ebp),%eax
  801b36:	8d 50 08             	lea    0x8(%eax),%edx
  801b39:	89 55 14             	mov    %edx,0x14(%ebp)
  801b3c:	8b 50 04             	mov    0x4(%eax),%edx
  801b3f:	8b 00                	mov    (%eax),%eax
  801b41:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b44:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801b47:	eb 32                	jmp    801b7b <vprintfmt+0x2d1>
	else if (lflag)
  801b49:	85 d2                	test   %edx,%edx
  801b4b:	74 18                	je     801b65 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801b4d:	8b 45 14             	mov    0x14(%ebp),%eax
  801b50:	8d 50 04             	lea    0x4(%eax),%edx
  801b53:	89 55 14             	mov    %edx,0x14(%ebp)
  801b56:	8b 00                	mov    (%eax),%eax
  801b58:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b5b:	89 c1                	mov    %eax,%ecx
  801b5d:	c1 f9 1f             	sar    $0x1f,%ecx
  801b60:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801b63:	eb 16                	jmp    801b7b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801b65:	8b 45 14             	mov    0x14(%ebp),%eax
  801b68:	8d 50 04             	lea    0x4(%eax),%edx
  801b6b:	89 55 14             	mov    %edx,0x14(%ebp)
  801b6e:	8b 00                	mov    (%eax),%eax
  801b70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b73:	89 c1                	mov    %eax,%ecx
  801b75:	c1 f9 1f             	sar    $0x1f,%ecx
  801b78:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b7e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801b81:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b86:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b8a:	79 74                	jns    801c00 <vprintfmt+0x356>
				putch('-', putdat);
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	53                   	push   %ebx
  801b90:	6a 2d                	push   $0x2d
  801b92:	ff d6                	call   *%esi
				num = -(long long) num;
  801b94:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b97:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b9a:	f7 d8                	neg    %eax
  801b9c:	83 d2 00             	adc    $0x0,%edx
  801b9f:	f7 da                	neg    %edx
  801ba1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ba4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ba9:	eb 55                	jmp    801c00 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801bab:	8d 45 14             	lea    0x14(%ebp),%eax
  801bae:	e8 83 fc ff ff       	call   801836 <getuint>
			base = 10;
  801bb3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801bb8:	eb 46                	jmp    801c00 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801bba:	8d 45 14             	lea    0x14(%ebp),%eax
  801bbd:	e8 74 fc ff ff       	call   801836 <getuint>
			base = 8;
  801bc2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801bc7:	eb 37                	jmp    801c00 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801bc9:	83 ec 08             	sub    $0x8,%esp
  801bcc:	53                   	push   %ebx
  801bcd:	6a 30                	push   $0x30
  801bcf:	ff d6                	call   *%esi
			putch('x', putdat);
  801bd1:	83 c4 08             	add    $0x8,%esp
  801bd4:	53                   	push   %ebx
  801bd5:	6a 78                	push   $0x78
  801bd7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801bd9:	8b 45 14             	mov    0x14(%ebp),%eax
  801bdc:	8d 50 04             	lea    0x4(%eax),%edx
  801bdf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801be2:	8b 00                	mov    (%eax),%eax
  801be4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801be9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801bec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801bf1:	eb 0d                	jmp    801c00 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801bf3:	8d 45 14             	lea    0x14(%ebp),%eax
  801bf6:	e8 3b fc ff ff       	call   801836 <getuint>
			base = 16;
  801bfb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801c00:	83 ec 0c             	sub    $0xc,%esp
  801c03:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801c07:	57                   	push   %edi
  801c08:	ff 75 e0             	pushl  -0x20(%ebp)
  801c0b:	51                   	push   %ecx
  801c0c:	52                   	push   %edx
  801c0d:	50                   	push   %eax
  801c0e:	89 da                	mov    %ebx,%edx
  801c10:	89 f0                	mov    %esi,%eax
  801c12:	e8 70 fb ff ff       	call   801787 <printnum>
			break;
  801c17:	83 c4 20             	add    $0x20,%esp
  801c1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c1d:	e9 ae fc ff ff       	jmp    8018d0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801c22:	83 ec 08             	sub    $0x8,%esp
  801c25:	53                   	push   %ebx
  801c26:	51                   	push   %ecx
  801c27:	ff d6                	call   *%esi
			break;
  801c29:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801c2f:	e9 9c fc ff ff       	jmp    8018d0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801c34:	83 ec 08             	sub    $0x8,%esp
  801c37:	53                   	push   %ebx
  801c38:	6a 25                	push   $0x25
  801c3a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	eb 03                	jmp    801c44 <vprintfmt+0x39a>
  801c41:	83 ef 01             	sub    $0x1,%edi
  801c44:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801c48:	75 f7                	jne    801c41 <vprintfmt+0x397>
  801c4a:	e9 81 fc ff ff       	jmp    8018d0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5f                   	pop    %edi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	83 ec 18             	sub    $0x18,%esp
  801c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c60:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c66:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c6a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c74:	85 c0                	test   %eax,%eax
  801c76:	74 26                	je     801c9e <vsnprintf+0x47>
  801c78:	85 d2                	test   %edx,%edx
  801c7a:	7e 22                	jle    801c9e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c7c:	ff 75 14             	pushl  0x14(%ebp)
  801c7f:	ff 75 10             	pushl  0x10(%ebp)
  801c82:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c85:	50                   	push   %eax
  801c86:	68 70 18 80 00       	push   $0x801870
  801c8b:	e8 1a fc ff ff       	call   8018aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c93:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	eb 05                	jmp    801ca3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801cab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801cae:	50                   	push   %eax
  801caf:	ff 75 10             	pushl  0x10(%ebp)
  801cb2:	ff 75 0c             	pushl  0xc(%ebp)
  801cb5:	ff 75 08             	pushl  0x8(%ebp)
  801cb8:	e8 9a ff ff ff       	call   801c57 <vsnprintf>
	va_end(ap);

	return rc;
}
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cca:	eb 03                	jmp    801ccf <strlen+0x10>
		n++;
  801ccc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ccf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801cd3:	75 f7                	jne    801ccc <strlen+0xd>
		n++;
	return n;
}
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce5:	eb 03                	jmp    801cea <strnlen+0x13>
		n++;
  801ce7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801cea:	39 c2                	cmp    %eax,%edx
  801cec:	74 08                	je     801cf6 <strnlen+0x1f>
  801cee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801cf2:	75 f3                	jne    801ce7 <strnlen+0x10>
  801cf4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	53                   	push   %ebx
  801cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801d02:	89 c2                	mov    %eax,%edx
  801d04:	83 c2 01             	add    $0x1,%edx
  801d07:	83 c1 01             	add    $0x1,%ecx
  801d0a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801d0e:	88 5a ff             	mov    %bl,-0x1(%edx)
  801d11:	84 db                	test   %bl,%bl
  801d13:	75 ef                	jne    801d04 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801d15:	5b                   	pop    %ebx
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    

00801d18 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	53                   	push   %ebx
  801d1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801d1f:	53                   	push   %ebx
  801d20:	e8 9a ff ff ff       	call   801cbf <strlen>
  801d25:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801d28:	ff 75 0c             	pushl  0xc(%ebp)
  801d2b:	01 d8                	add    %ebx,%eax
  801d2d:	50                   	push   %eax
  801d2e:	e8 c5 ff ff ff       	call   801cf8 <strcpy>
	return dst;
}
  801d33:	89 d8                	mov    %ebx,%eax
  801d35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	56                   	push   %esi
  801d3e:	53                   	push   %ebx
  801d3f:	8b 75 08             	mov    0x8(%ebp),%esi
  801d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d45:	89 f3                	mov    %esi,%ebx
  801d47:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d4a:	89 f2                	mov    %esi,%edx
  801d4c:	eb 0f                	jmp    801d5d <strncpy+0x23>
		*dst++ = *src;
  801d4e:	83 c2 01             	add    $0x1,%edx
  801d51:	0f b6 01             	movzbl (%ecx),%eax
  801d54:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d57:	80 39 01             	cmpb   $0x1,(%ecx)
  801d5a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d5d:	39 da                	cmp    %ebx,%edx
  801d5f:	75 ed                	jne    801d4e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	56                   	push   %esi
  801d6b:	53                   	push   %ebx
  801d6c:	8b 75 08             	mov    0x8(%ebp),%esi
  801d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d72:	8b 55 10             	mov    0x10(%ebp),%edx
  801d75:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d77:	85 d2                	test   %edx,%edx
  801d79:	74 21                	je     801d9c <strlcpy+0x35>
  801d7b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801d7f:	89 f2                	mov    %esi,%edx
  801d81:	eb 09                	jmp    801d8c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d83:	83 c2 01             	add    $0x1,%edx
  801d86:	83 c1 01             	add    $0x1,%ecx
  801d89:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801d8c:	39 c2                	cmp    %eax,%edx
  801d8e:	74 09                	je     801d99 <strlcpy+0x32>
  801d90:	0f b6 19             	movzbl (%ecx),%ebx
  801d93:	84 db                	test   %bl,%bl
  801d95:	75 ec                	jne    801d83 <strlcpy+0x1c>
  801d97:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d99:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d9c:	29 f0                	sub    %esi,%eax
}
  801d9e:	5b                   	pop    %ebx
  801d9f:	5e                   	pop    %esi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    

00801da2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801dab:	eb 06                	jmp    801db3 <strcmp+0x11>
		p++, q++;
  801dad:	83 c1 01             	add    $0x1,%ecx
  801db0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801db3:	0f b6 01             	movzbl (%ecx),%eax
  801db6:	84 c0                	test   %al,%al
  801db8:	74 04                	je     801dbe <strcmp+0x1c>
  801dba:	3a 02                	cmp    (%edx),%al
  801dbc:	74 ef                	je     801dad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801dbe:	0f b6 c0             	movzbl %al,%eax
  801dc1:	0f b6 12             	movzbl (%edx),%edx
  801dc4:	29 d0                	sub    %edx,%eax
}
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    

00801dc8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	53                   	push   %ebx
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd2:	89 c3                	mov    %eax,%ebx
  801dd4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801dd7:	eb 06                	jmp    801ddf <strncmp+0x17>
		n--, p++, q++;
  801dd9:	83 c0 01             	add    $0x1,%eax
  801ddc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ddf:	39 d8                	cmp    %ebx,%eax
  801de1:	74 15                	je     801df8 <strncmp+0x30>
  801de3:	0f b6 08             	movzbl (%eax),%ecx
  801de6:	84 c9                	test   %cl,%cl
  801de8:	74 04                	je     801dee <strncmp+0x26>
  801dea:	3a 0a                	cmp    (%edx),%cl
  801dec:	74 eb                	je     801dd9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801dee:	0f b6 00             	movzbl (%eax),%eax
  801df1:	0f b6 12             	movzbl (%edx),%edx
  801df4:	29 d0                	sub    %edx,%eax
  801df6:	eb 05                	jmp    801dfd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801df8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801dfd:	5b                   	pop    %ebx
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	8b 45 08             	mov    0x8(%ebp),%eax
  801e06:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801e0a:	eb 07                	jmp    801e13 <strchr+0x13>
		if (*s == c)
  801e0c:	38 ca                	cmp    %cl,%dl
  801e0e:	74 0f                	je     801e1f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801e10:	83 c0 01             	add    $0x1,%eax
  801e13:	0f b6 10             	movzbl (%eax),%edx
  801e16:	84 d2                	test   %dl,%dl
  801e18:	75 f2                	jne    801e0c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	8b 45 08             	mov    0x8(%ebp),%eax
  801e27:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801e2b:	eb 03                	jmp    801e30 <strfind+0xf>
  801e2d:	83 c0 01             	add    $0x1,%eax
  801e30:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801e33:	38 ca                	cmp    %cl,%dl
  801e35:	74 04                	je     801e3b <strfind+0x1a>
  801e37:	84 d2                	test   %dl,%dl
  801e39:	75 f2                	jne    801e2d <strfind+0xc>
			break;
	return (char *) s;
}
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    

00801e3d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	57                   	push   %edi
  801e41:	56                   	push   %esi
  801e42:	53                   	push   %ebx
  801e43:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801e49:	85 c9                	test   %ecx,%ecx
  801e4b:	74 36                	je     801e83 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801e4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801e53:	75 28                	jne    801e7d <memset+0x40>
  801e55:	f6 c1 03             	test   $0x3,%cl
  801e58:	75 23                	jne    801e7d <memset+0x40>
		c &= 0xFF;
  801e5a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e5e:	89 d3                	mov    %edx,%ebx
  801e60:	c1 e3 08             	shl    $0x8,%ebx
  801e63:	89 d6                	mov    %edx,%esi
  801e65:	c1 e6 18             	shl    $0x18,%esi
  801e68:	89 d0                	mov    %edx,%eax
  801e6a:	c1 e0 10             	shl    $0x10,%eax
  801e6d:	09 f0                	or     %esi,%eax
  801e6f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801e71:	89 d8                	mov    %ebx,%eax
  801e73:	09 d0                	or     %edx,%eax
  801e75:	c1 e9 02             	shr    $0x2,%ecx
  801e78:	fc                   	cld    
  801e79:	f3 ab                	rep stos %eax,%es:(%edi)
  801e7b:	eb 06                	jmp    801e83 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e80:	fc                   	cld    
  801e81:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e83:	89 f8                	mov    %edi,%eax
  801e85:	5b                   	pop    %ebx
  801e86:	5e                   	pop    %esi
  801e87:	5f                   	pop    %edi
  801e88:	5d                   	pop    %ebp
  801e89:	c3                   	ret    

00801e8a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	57                   	push   %edi
  801e8e:	56                   	push   %esi
  801e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e92:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e98:	39 c6                	cmp    %eax,%esi
  801e9a:	73 35                	jae    801ed1 <memmove+0x47>
  801e9c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e9f:	39 d0                	cmp    %edx,%eax
  801ea1:	73 2e                	jae    801ed1 <memmove+0x47>
		s += n;
		d += n;
  801ea3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ea6:	89 d6                	mov    %edx,%esi
  801ea8:	09 fe                	or     %edi,%esi
  801eaa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801eb0:	75 13                	jne    801ec5 <memmove+0x3b>
  801eb2:	f6 c1 03             	test   $0x3,%cl
  801eb5:	75 0e                	jne    801ec5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801eb7:	83 ef 04             	sub    $0x4,%edi
  801eba:	8d 72 fc             	lea    -0x4(%edx),%esi
  801ebd:	c1 e9 02             	shr    $0x2,%ecx
  801ec0:	fd                   	std    
  801ec1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801ec3:	eb 09                	jmp    801ece <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801ec5:	83 ef 01             	sub    $0x1,%edi
  801ec8:	8d 72 ff             	lea    -0x1(%edx),%esi
  801ecb:	fd                   	std    
  801ecc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ece:	fc                   	cld    
  801ecf:	eb 1d                	jmp    801eee <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ed1:	89 f2                	mov    %esi,%edx
  801ed3:	09 c2                	or     %eax,%edx
  801ed5:	f6 c2 03             	test   $0x3,%dl
  801ed8:	75 0f                	jne    801ee9 <memmove+0x5f>
  801eda:	f6 c1 03             	test   $0x3,%cl
  801edd:	75 0a                	jne    801ee9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801edf:	c1 e9 02             	shr    $0x2,%ecx
  801ee2:	89 c7                	mov    %eax,%edi
  801ee4:	fc                   	cld    
  801ee5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801ee7:	eb 05                	jmp    801eee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801ee9:	89 c7                	mov    %eax,%edi
  801eeb:	fc                   	cld    
  801eec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801eee:	5e                   	pop    %esi
  801eef:	5f                   	pop    %edi
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801ef5:	ff 75 10             	pushl  0x10(%ebp)
  801ef8:	ff 75 0c             	pushl  0xc(%ebp)
  801efb:	ff 75 08             	pushl  0x8(%ebp)
  801efe:	e8 87 ff ff ff       	call   801e8a <memmove>
}
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	56                   	push   %esi
  801f09:	53                   	push   %ebx
  801f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f10:	89 c6                	mov    %eax,%esi
  801f12:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801f15:	eb 1a                	jmp    801f31 <memcmp+0x2c>
		if (*s1 != *s2)
  801f17:	0f b6 08             	movzbl (%eax),%ecx
  801f1a:	0f b6 1a             	movzbl (%edx),%ebx
  801f1d:	38 d9                	cmp    %bl,%cl
  801f1f:	74 0a                	je     801f2b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801f21:	0f b6 c1             	movzbl %cl,%eax
  801f24:	0f b6 db             	movzbl %bl,%ebx
  801f27:	29 d8                	sub    %ebx,%eax
  801f29:	eb 0f                	jmp    801f3a <memcmp+0x35>
		s1++, s2++;
  801f2b:	83 c0 01             	add    $0x1,%eax
  801f2e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801f31:	39 f0                	cmp    %esi,%eax
  801f33:	75 e2                	jne    801f17 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801f35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f3a:	5b                   	pop    %ebx
  801f3b:	5e                   	pop    %esi
  801f3c:	5d                   	pop    %ebp
  801f3d:	c3                   	ret    

00801f3e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	53                   	push   %ebx
  801f42:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801f45:	89 c1                	mov    %eax,%ecx
  801f47:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801f4a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f4e:	eb 0a                	jmp    801f5a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801f50:	0f b6 10             	movzbl (%eax),%edx
  801f53:	39 da                	cmp    %ebx,%edx
  801f55:	74 07                	je     801f5e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f57:	83 c0 01             	add    $0x1,%eax
  801f5a:	39 c8                	cmp    %ecx,%eax
  801f5c:	72 f2                	jb     801f50 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801f5e:	5b                   	pop    %ebx
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	57                   	push   %edi
  801f65:	56                   	push   %esi
  801f66:	53                   	push   %ebx
  801f67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f6d:	eb 03                	jmp    801f72 <strtol+0x11>
		s++;
  801f6f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f72:	0f b6 01             	movzbl (%ecx),%eax
  801f75:	3c 20                	cmp    $0x20,%al
  801f77:	74 f6                	je     801f6f <strtol+0xe>
  801f79:	3c 09                	cmp    $0x9,%al
  801f7b:	74 f2                	je     801f6f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801f7d:	3c 2b                	cmp    $0x2b,%al
  801f7f:	75 0a                	jne    801f8b <strtol+0x2a>
		s++;
  801f81:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f84:	bf 00 00 00 00       	mov    $0x0,%edi
  801f89:	eb 11                	jmp    801f9c <strtol+0x3b>
  801f8b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801f90:	3c 2d                	cmp    $0x2d,%al
  801f92:	75 08                	jne    801f9c <strtol+0x3b>
		s++, neg = 1;
  801f94:	83 c1 01             	add    $0x1,%ecx
  801f97:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f9c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801fa2:	75 15                	jne    801fb9 <strtol+0x58>
  801fa4:	80 39 30             	cmpb   $0x30,(%ecx)
  801fa7:	75 10                	jne    801fb9 <strtol+0x58>
  801fa9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801fad:	75 7c                	jne    80202b <strtol+0xca>
		s += 2, base = 16;
  801faf:	83 c1 02             	add    $0x2,%ecx
  801fb2:	bb 10 00 00 00       	mov    $0x10,%ebx
  801fb7:	eb 16                	jmp    801fcf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801fb9:	85 db                	test   %ebx,%ebx
  801fbb:	75 12                	jne    801fcf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801fbd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801fc2:	80 39 30             	cmpb   $0x30,(%ecx)
  801fc5:	75 08                	jne    801fcf <strtol+0x6e>
		s++, base = 8;
  801fc7:	83 c1 01             	add    $0x1,%ecx
  801fca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801fcf:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801fd7:	0f b6 11             	movzbl (%ecx),%edx
  801fda:	8d 72 d0             	lea    -0x30(%edx),%esi
  801fdd:	89 f3                	mov    %esi,%ebx
  801fdf:	80 fb 09             	cmp    $0x9,%bl
  801fe2:	77 08                	ja     801fec <strtol+0x8b>
			dig = *s - '0';
  801fe4:	0f be d2             	movsbl %dl,%edx
  801fe7:	83 ea 30             	sub    $0x30,%edx
  801fea:	eb 22                	jmp    80200e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801fec:	8d 72 9f             	lea    -0x61(%edx),%esi
  801fef:	89 f3                	mov    %esi,%ebx
  801ff1:	80 fb 19             	cmp    $0x19,%bl
  801ff4:	77 08                	ja     801ffe <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ff6:	0f be d2             	movsbl %dl,%edx
  801ff9:	83 ea 57             	sub    $0x57,%edx
  801ffc:	eb 10                	jmp    80200e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ffe:	8d 72 bf             	lea    -0x41(%edx),%esi
  802001:	89 f3                	mov    %esi,%ebx
  802003:	80 fb 19             	cmp    $0x19,%bl
  802006:	77 16                	ja     80201e <strtol+0xbd>
			dig = *s - 'A' + 10;
  802008:	0f be d2             	movsbl %dl,%edx
  80200b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80200e:	3b 55 10             	cmp    0x10(%ebp),%edx
  802011:	7d 0b                	jge    80201e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802013:	83 c1 01             	add    $0x1,%ecx
  802016:	0f af 45 10          	imul   0x10(%ebp),%eax
  80201a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80201c:	eb b9                	jmp    801fd7 <strtol+0x76>

	if (endptr)
  80201e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802022:	74 0d                	je     802031 <strtol+0xd0>
		*endptr = (char *) s;
  802024:	8b 75 0c             	mov    0xc(%ebp),%esi
  802027:	89 0e                	mov    %ecx,(%esi)
  802029:	eb 06                	jmp    802031 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80202b:	85 db                	test   %ebx,%ebx
  80202d:	74 98                	je     801fc7 <strtol+0x66>
  80202f:	eb 9e                	jmp    801fcf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802031:	89 c2                	mov    %eax,%edx
  802033:	f7 da                	neg    %edx
  802035:	85 ff                	test   %edi,%edi
  802037:	0f 45 c2             	cmovne %edx,%eax
}
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5f                   	pop    %edi
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    

0080203f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	57                   	push   %edi
  802043:	56                   	push   %esi
  802044:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802045:	b8 00 00 00 00       	mov    $0x0,%eax
  80204a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80204d:	8b 55 08             	mov    0x8(%ebp),%edx
  802050:	89 c3                	mov    %eax,%ebx
  802052:	89 c7                	mov    %eax,%edi
  802054:	89 c6                	mov    %eax,%esi
  802056:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802058:	5b                   	pop    %ebx
  802059:	5e                   	pop    %esi
  80205a:	5f                   	pop    %edi
  80205b:	5d                   	pop    %ebp
  80205c:	c3                   	ret    

0080205d <sys_cgetc>:

int
sys_cgetc(void)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	57                   	push   %edi
  802061:	56                   	push   %esi
  802062:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802063:	ba 00 00 00 00       	mov    $0x0,%edx
  802068:	b8 01 00 00 00       	mov    $0x1,%eax
  80206d:	89 d1                	mov    %edx,%ecx
  80206f:	89 d3                	mov    %edx,%ebx
  802071:	89 d7                	mov    %edx,%edi
  802073:	89 d6                	mov    %edx,%esi
  802075:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802077:	5b                   	pop    %ebx
  802078:	5e                   	pop    %esi
  802079:	5f                   	pop    %edi
  80207a:	5d                   	pop    %ebp
  80207b:	c3                   	ret    

0080207c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	57                   	push   %edi
  802080:	56                   	push   %esi
  802081:	53                   	push   %ebx
  802082:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802085:	b9 00 00 00 00       	mov    $0x0,%ecx
  80208a:	b8 03 00 00 00       	mov    $0x3,%eax
  80208f:	8b 55 08             	mov    0x8(%ebp),%edx
  802092:	89 cb                	mov    %ecx,%ebx
  802094:	89 cf                	mov    %ecx,%edi
  802096:	89 ce                	mov    %ecx,%esi
  802098:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80209a:	85 c0                	test   %eax,%eax
  80209c:	7e 17                	jle    8020b5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80209e:	83 ec 0c             	sub    $0xc,%esp
  8020a1:	50                   	push   %eax
  8020a2:	6a 03                	push   $0x3
  8020a4:	68 1f 3d 80 00       	push   $0x803d1f
  8020a9:	6a 23                	push   $0x23
  8020ab:	68 3c 3d 80 00       	push   $0x803d3c
  8020b0:	e8 e5 f5 ff ff       	call   80169a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8020b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b8:	5b                   	pop    %ebx
  8020b9:	5e                   	pop    %esi
  8020ba:	5f                   	pop    %edi
  8020bb:	5d                   	pop    %ebp
  8020bc:	c3                   	ret    

008020bd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8020bd:	55                   	push   %ebp
  8020be:	89 e5                	mov    %esp,%ebp
  8020c0:	57                   	push   %edi
  8020c1:	56                   	push   %esi
  8020c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8020c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8020c8:	b8 02 00 00 00       	mov    $0x2,%eax
  8020cd:	89 d1                	mov    %edx,%ecx
  8020cf:	89 d3                	mov    %edx,%ebx
  8020d1:	89 d7                	mov    %edx,%edi
  8020d3:	89 d6                	mov    %edx,%esi
  8020d5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5f                   	pop    %edi
  8020da:	5d                   	pop    %ebp
  8020db:	c3                   	ret    

008020dc <sys_yield>:

void
sys_yield(void)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	57                   	push   %edi
  8020e0:	56                   	push   %esi
  8020e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8020e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8020ec:	89 d1                	mov    %edx,%ecx
  8020ee:	89 d3                	mov    %edx,%ebx
  8020f0:	89 d7                	mov    %edx,%edi
  8020f2:	89 d6                	mov    %edx,%esi
  8020f4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8020f6:	5b                   	pop    %ebx
  8020f7:	5e                   	pop    %esi
  8020f8:	5f                   	pop    %edi
  8020f9:	5d                   	pop    %ebp
  8020fa:	c3                   	ret    

008020fb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8020fb:	55                   	push   %ebp
  8020fc:	89 e5                	mov    %esp,%ebp
  8020fe:	57                   	push   %edi
  8020ff:	56                   	push   %esi
  802100:	53                   	push   %ebx
  802101:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802104:	be 00 00 00 00       	mov    $0x0,%esi
  802109:	b8 04 00 00 00       	mov    $0x4,%eax
  80210e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802111:	8b 55 08             	mov    0x8(%ebp),%edx
  802114:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802117:	89 f7                	mov    %esi,%edi
  802119:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80211b:	85 c0                	test   %eax,%eax
  80211d:	7e 17                	jle    802136 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80211f:	83 ec 0c             	sub    $0xc,%esp
  802122:	50                   	push   %eax
  802123:	6a 04                	push   $0x4
  802125:	68 1f 3d 80 00       	push   $0x803d1f
  80212a:	6a 23                	push   $0x23
  80212c:	68 3c 3d 80 00       	push   $0x803d3c
  802131:	e8 64 f5 ff ff       	call   80169a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802139:	5b                   	pop    %ebx
  80213a:	5e                   	pop    %esi
  80213b:	5f                   	pop    %edi
  80213c:	5d                   	pop    %ebp
  80213d:	c3                   	ret    

0080213e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802147:	b8 05 00 00 00       	mov    $0x5,%eax
  80214c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80214f:	8b 55 08             	mov    0x8(%ebp),%edx
  802152:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802155:	8b 7d 14             	mov    0x14(%ebp),%edi
  802158:	8b 75 18             	mov    0x18(%ebp),%esi
  80215b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80215d:	85 c0                	test   %eax,%eax
  80215f:	7e 17                	jle    802178 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802161:	83 ec 0c             	sub    $0xc,%esp
  802164:	50                   	push   %eax
  802165:	6a 05                	push   $0x5
  802167:	68 1f 3d 80 00       	push   $0x803d1f
  80216c:	6a 23                	push   $0x23
  80216e:	68 3c 3d 80 00       	push   $0x803d3c
  802173:	e8 22 f5 ff ff       	call   80169a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80217b:	5b                   	pop    %ebx
  80217c:	5e                   	pop    %esi
  80217d:	5f                   	pop    %edi
  80217e:	5d                   	pop    %ebp
  80217f:	c3                   	ret    

00802180 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	57                   	push   %edi
  802184:	56                   	push   %esi
  802185:	53                   	push   %ebx
  802186:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802189:	bb 00 00 00 00       	mov    $0x0,%ebx
  80218e:	b8 06 00 00 00       	mov    $0x6,%eax
  802193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802196:	8b 55 08             	mov    0x8(%ebp),%edx
  802199:	89 df                	mov    %ebx,%edi
  80219b:	89 de                	mov    %ebx,%esi
  80219d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80219f:	85 c0                	test   %eax,%eax
  8021a1:	7e 17                	jle    8021ba <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8021a3:	83 ec 0c             	sub    $0xc,%esp
  8021a6:	50                   	push   %eax
  8021a7:	6a 06                	push   $0x6
  8021a9:	68 1f 3d 80 00       	push   $0x803d1f
  8021ae:	6a 23                	push   $0x23
  8021b0:	68 3c 3d 80 00       	push   $0x803d3c
  8021b5:	e8 e0 f4 ff ff       	call   80169a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8021ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    

008021c2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	57                   	push   %edi
  8021c6:	56                   	push   %esi
  8021c7:	53                   	push   %ebx
  8021c8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8021cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8021d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8021db:	89 df                	mov    %ebx,%edi
  8021dd:	89 de                	mov    %ebx,%esi
  8021df:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	7e 17                	jle    8021fc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8021e5:	83 ec 0c             	sub    $0xc,%esp
  8021e8:	50                   	push   %eax
  8021e9:	6a 08                	push   $0x8
  8021eb:	68 1f 3d 80 00       	push   $0x803d1f
  8021f0:	6a 23                	push   $0x23
  8021f2:	68 3c 3d 80 00       	push   $0x803d3c
  8021f7:	e8 9e f4 ff ff       	call   80169a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8021fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ff:	5b                   	pop    %ebx
  802200:	5e                   	pop    %esi
  802201:	5f                   	pop    %edi
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    

00802204 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	57                   	push   %edi
  802208:	56                   	push   %esi
  802209:	53                   	push   %ebx
  80220a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80220d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802212:	b8 09 00 00 00       	mov    $0x9,%eax
  802217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80221a:	8b 55 08             	mov    0x8(%ebp),%edx
  80221d:	89 df                	mov    %ebx,%edi
  80221f:	89 de                	mov    %ebx,%esi
  802221:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802223:	85 c0                	test   %eax,%eax
  802225:	7e 17                	jle    80223e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802227:	83 ec 0c             	sub    $0xc,%esp
  80222a:	50                   	push   %eax
  80222b:	6a 09                	push   $0x9
  80222d:	68 1f 3d 80 00       	push   $0x803d1f
  802232:	6a 23                	push   $0x23
  802234:	68 3c 3d 80 00       	push   $0x803d3c
  802239:	e8 5c f4 ff ff       	call   80169a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80223e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802241:	5b                   	pop    %ebx
  802242:	5e                   	pop    %esi
  802243:	5f                   	pop    %edi
  802244:	5d                   	pop    %ebp
  802245:	c3                   	ret    

00802246 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802246:	55                   	push   %ebp
  802247:	89 e5                	mov    %esp,%ebp
  802249:	57                   	push   %edi
  80224a:	56                   	push   %esi
  80224b:	53                   	push   %ebx
  80224c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80224f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802254:	b8 0a 00 00 00       	mov    $0xa,%eax
  802259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80225c:	8b 55 08             	mov    0x8(%ebp),%edx
  80225f:	89 df                	mov    %ebx,%edi
  802261:	89 de                	mov    %ebx,%esi
  802263:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802265:	85 c0                	test   %eax,%eax
  802267:	7e 17                	jle    802280 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802269:	83 ec 0c             	sub    $0xc,%esp
  80226c:	50                   	push   %eax
  80226d:	6a 0a                	push   $0xa
  80226f:	68 1f 3d 80 00       	push   $0x803d1f
  802274:	6a 23                	push   $0x23
  802276:	68 3c 3d 80 00       	push   $0x803d3c
  80227b:	e8 1a f4 ff ff       	call   80169a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802280:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    

00802288 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	57                   	push   %edi
  80228c:	56                   	push   %esi
  80228d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80228e:	be 00 00 00 00       	mov    $0x0,%esi
  802293:	b8 0c 00 00 00       	mov    $0xc,%eax
  802298:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80229b:	8b 55 08             	mov    0x8(%ebp),%edx
  80229e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022a1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8022a4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8022a6:	5b                   	pop    %ebx
  8022a7:	5e                   	pop    %esi
  8022a8:	5f                   	pop    %edi
  8022a9:	5d                   	pop    %ebp
  8022aa:	c3                   	ret    

008022ab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	57                   	push   %edi
  8022af:	56                   	push   %esi
  8022b0:	53                   	push   %ebx
  8022b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8022b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8022b9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8022be:	8b 55 08             	mov    0x8(%ebp),%edx
  8022c1:	89 cb                	mov    %ecx,%ebx
  8022c3:	89 cf                	mov    %ecx,%edi
  8022c5:	89 ce                	mov    %ecx,%esi
  8022c7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8022c9:	85 c0                	test   %eax,%eax
  8022cb:	7e 17                	jle    8022e4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8022cd:	83 ec 0c             	sub    $0xc,%esp
  8022d0:	50                   	push   %eax
  8022d1:	6a 0d                	push   $0xd
  8022d3:	68 1f 3d 80 00       	push   $0x803d1f
  8022d8:	6a 23                	push   $0x23
  8022da:	68 3c 3d 80 00       	push   $0x803d3c
  8022df:	e8 b6 f3 ff ff       	call   80169a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8022e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5f                   	pop    %edi
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    

008022ec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022f2:	83 3d 10 90 80 00 00 	cmpl   $0x0,0x809010
  8022f9:	75 2e                	jne    802329 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8022fb:	e8 bd fd ff ff       	call   8020bd <sys_getenvid>
  802300:	83 ec 04             	sub    $0x4,%esp
  802303:	68 07 0e 00 00       	push   $0xe07
  802308:	68 00 f0 bf ee       	push   $0xeebff000
  80230d:	50                   	push   %eax
  80230e:	e8 e8 fd ff ff       	call   8020fb <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802313:	e8 a5 fd ff ff       	call   8020bd <sys_getenvid>
  802318:	83 c4 08             	add    $0x8,%esp
  80231b:	68 33 23 80 00       	push   $0x802333
  802320:	50                   	push   %eax
  802321:	e8 20 ff ff ff       	call   802246 <sys_env_set_pgfault_upcall>
  802326:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802329:	8b 45 08             	mov    0x8(%ebp),%eax
  80232c:	a3 10 90 80 00       	mov    %eax,0x809010
}
  802331:	c9                   	leave  
  802332:	c3                   	ret    

00802333 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802333:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802334:	a1 10 90 80 00       	mov    0x809010,%eax
	call *%eax
  802339:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80233b:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80233e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802342:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802346:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802349:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80234c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80234d:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802350:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802351:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802352:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802356:	c3                   	ret    

00802357 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802357:	55                   	push   %ebp
  802358:	89 e5                	mov    %esp,%ebp
  80235a:	56                   	push   %esi
  80235b:	53                   	push   %ebx
  80235c:	8b 75 08             	mov    0x8(%ebp),%esi
  80235f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802362:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802365:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802367:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80236c:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80236f:	83 ec 0c             	sub    $0xc,%esp
  802372:	50                   	push   %eax
  802373:	e8 33 ff ff ff       	call   8022ab <sys_ipc_recv>

	if (from_env_store != NULL)
  802378:	83 c4 10             	add    $0x10,%esp
  80237b:	85 f6                	test   %esi,%esi
  80237d:	74 14                	je     802393 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80237f:	ba 00 00 00 00       	mov    $0x0,%edx
  802384:	85 c0                	test   %eax,%eax
  802386:	78 09                	js     802391 <ipc_recv+0x3a>
  802388:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  80238e:	8b 52 74             	mov    0x74(%edx),%edx
  802391:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802393:	85 db                	test   %ebx,%ebx
  802395:	74 14                	je     8023ab <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802397:	ba 00 00 00 00       	mov    $0x0,%edx
  80239c:	85 c0                	test   %eax,%eax
  80239e:	78 09                	js     8023a9 <ipc_recv+0x52>
  8023a0:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  8023a6:	8b 52 78             	mov    0x78(%edx),%edx
  8023a9:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	78 08                	js     8023b7 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8023af:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8023b4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ba:	5b                   	pop    %ebx
  8023bb:	5e                   	pop    %esi
  8023bc:	5d                   	pop    %ebp
  8023bd:	c3                   	ret    

008023be <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 0c             	sub    $0xc,%esp
  8023c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8023d0:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8023d2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023d7:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8023da:	ff 75 14             	pushl  0x14(%ebp)
  8023dd:	53                   	push   %ebx
  8023de:	56                   	push   %esi
  8023df:	57                   	push   %edi
  8023e0:	e8 a3 fe ff ff       	call   802288 <sys_ipc_try_send>

		if (err < 0) {
  8023e5:	83 c4 10             	add    $0x10,%esp
  8023e8:	85 c0                	test   %eax,%eax
  8023ea:	79 1e                	jns    80240a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8023ec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023ef:	75 07                	jne    8023f8 <ipc_send+0x3a>
				sys_yield();
  8023f1:	e8 e6 fc ff ff       	call   8020dc <sys_yield>
  8023f6:	eb e2                	jmp    8023da <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8023f8:	50                   	push   %eax
  8023f9:	68 4a 3d 80 00       	push   $0x803d4a
  8023fe:	6a 49                	push   $0x49
  802400:	68 57 3d 80 00       	push   $0x803d57
  802405:	e8 90 f2 ff ff       	call   80169a <_panic>
		}

	} while (err < 0);

}
  80240a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80240d:	5b                   	pop    %ebx
  80240e:	5e                   	pop    %esi
  80240f:	5f                   	pop    %edi
  802410:	5d                   	pop    %ebp
  802411:	c3                   	ret    

00802412 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802412:	55                   	push   %ebp
  802413:	89 e5                	mov    %esp,%ebp
  802415:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802418:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80241d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802420:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802426:	8b 52 50             	mov    0x50(%edx),%edx
  802429:	39 ca                	cmp    %ecx,%edx
  80242b:	75 0d                	jne    80243a <ipc_find_env+0x28>
			return envs[i].env_id;
  80242d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802430:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802435:	8b 40 48             	mov    0x48(%eax),%eax
  802438:	eb 0f                	jmp    802449 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80243a:	83 c0 01             	add    $0x1,%eax
  80243d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802442:	75 d9                	jne    80241d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802444:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802449:	5d                   	pop    %ebp
  80244a:	c3                   	ret    

0080244b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80244b:	55                   	push   %ebp
  80244c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80244e:	8b 45 08             	mov    0x8(%ebp),%eax
  802451:	05 00 00 00 30       	add    $0x30000000,%eax
  802456:	c1 e8 0c             	shr    $0xc,%eax
}
  802459:	5d                   	pop    %ebp
  80245a:	c3                   	ret    

0080245b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80245b:	55                   	push   %ebp
  80245c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80245e:	8b 45 08             	mov    0x8(%ebp),%eax
  802461:	05 00 00 00 30       	add    $0x30000000,%eax
  802466:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80246b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    

00802472 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802472:	55                   	push   %ebp
  802473:	89 e5                	mov    %esp,%ebp
  802475:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802478:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80247d:	89 c2                	mov    %eax,%edx
  80247f:	c1 ea 16             	shr    $0x16,%edx
  802482:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802489:	f6 c2 01             	test   $0x1,%dl
  80248c:	74 11                	je     80249f <fd_alloc+0x2d>
  80248e:	89 c2                	mov    %eax,%edx
  802490:	c1 ea 0c             	shr    $0xc,%edx
  802493:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80249a:	f6 c2 01             	test   $0x1,%dl
  80249d:	75 09                	jne    8024a8 <fd_alloc+0x36>
			*fd_store = fd;
  80249f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8024a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8024a6:	eb 17                	jmp    8024bf <fd_alloc+0x4d>
  8024a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8024ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8024b2:	75 c9                	jne    80247d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8024b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8024ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8024bf:	5d                   	pop    %ebp
  8024c0:	c3                   	ret    

008024c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8024c1:	55                   	push   %ebp
  8024c2:	89 e5                	mov    %esp,%ebp
  8024c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8024c7:	83 f8 1f             	cmp    $0x1f,%eax
  8024ca:	77 36                	ja     802502 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8024cc:	c1 e0 0c             	shl    $0xc,%eax
  8024cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8024d4:	89 c2                	mov    %eax,%edx
  8024d6:	c1 ea 16             	shr    $0x16,%edx
  8024d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024e0:	f6 c2 01             	test   $0x1,%dl
  8024e3:	74 24                	je     802509 <fd_lookup+0x48>
  8024e5:	89 c2                	mov    %eax,%edx
  8024e7:	c1 ea 0c             	shr    $0xc,%edx
  8024ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8024f1:	f6 c2 01             	test   $0x1,%dl
  8024f4:	74 1a                	je     802510 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8024f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8024fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802500:	eb 13                	jmp    802515 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802502:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802507:	eb 0c                	jmp    802515 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802509:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80250e:	eb 05                	jmp    802515 <fd_lookup+0x54>
  802510:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802515:	5d                   	pop    %ebp
  802516:	c3                   	ret    

00802517 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	83 ec 08             	sub    $0x8,%esp
  80251d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802520:	ba e4 3d 80 00       	mov    $0x803de4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802525:	eb 13                	jmp    80253a <dev_lookup+0x23>
  802527:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80252a:	39 08                	cmp    %ecx,(%eax)
  80252c:	75 0c                	jne    80253a <dev_lookup+0x23>
			*dev = devtab[i];
  80252e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802531:	89 01                	mov    %eax,(%ecx)
			return 0;
  802533:	b8 00 00 00 00       	mov    $0x0,%eax
  802538:	eb 2e                	jmp    802568 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80253a:	8b 02                	mov    (%edx),%eax
  80253c:	85 c0                	test   %eax,%eax
  80253e:	75 e7                	jne    802527 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802540:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802545:	8b 40 48             	mov    0x48(%eax),%eax
  802548:	83 ec 04             	sub    $0x4,%esp
  80254b:	51                   	push   %ecx
  80254c:	50                   	push   %eax
  80254d:	68 64 3d 80 00       	push   $0x803d64
  802552:	e8 1c f2 ff ff       	call   801773 <cprintf>
	*dev = 0;
  802557:	8b 45 0c             	mov    0xc(%ebp),%eax
  80255a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802560:	83 c4 10             	add    $0x10,%esp
  802563:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802568:	c9                   	leave  
  802569:	c3                   	ret    

0080256a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80256a:	55                   	push   %ebp
  80256b:	89 e5                	mov    %esp,%ebp
  80256d:	56                   	push   %esi
  80256e:	53                   	push   %ebx
  80256f:	83 ec 10             	sub    $0x10,%esp
  802572:	8b 75 08             	mov    0x8(%ebp),%esi
  802575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802578:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80257b:	50                   	push   %eax
  80257c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802582:	c1 e8 0c             	shr    $0xc,%eax
  802585:	50                   	push   %eax
  802586:	e8 36 ff ff ff       	call   8024c1 <fd_lookup>
  80258b:	83 c4 08             	add    $0x8,%esp
  80258e:	85 c0                	test   %eax,%eax
  802590:	78 05                	js     802597 <fd_close+0x2d>
	    || fd != fd2)
  802592:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802595:	74 0c                	je     8025a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  802597:	84 db                	test   %bl,%bl
  802599:	ba 00 00 00 00       	mov    $0x0,%edx
  80259e:	0f 44 c2             	cmove  %edx,%eax
  8025a1:	eb 41                	jmp    8025e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8025a3:	83 ec 08             	sub    $0x8,%esp
  8025a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8025a9:	50                   	push   %eax
  8025aa:	ff 36                	pushl  (%esi)
  8025ac:	e8 66 ff ff ff       	call   802517 <dev_lookup>
  8025b1:	89 c3                	mov    %eax,%ebx
  8025b3:	83 c4 10             	add    $0x10,%esp
  8025b6:	85 c0                	test   %eax,%eax
  8025b8:	78 1a                	js     8025d4 <fd_close+0x6a>
		if (dev->dev_close)
  8025ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8025c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8025c5:	85 c0                	test   %eax,%eax
  8025c7:	74 0b                	je     8025d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8025c9:	83 ec 0c             	sub    $0xc,%esp
  8025cc:	56                   	push   %esi
  8025cd:	ff d0                	call   *%eax
  8025cf:	89 c3                	mov    %eax,%ebx
  8025d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8025d4:	83 ec 08             	sub    $0x8,%esp
  8025d7:	56                   	push   %esi
  8025d8:	6a 00                	push   $0x0
  8025da:	e8 a1 fb ff ff       	call   802180 <sys_page_unmap>
	return r;
  8025df:	83 c4 10             	add    $0x10,%esp
  8025e2:	89 d8                	mov    %ebx,%eax
}
  8025e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025e7:	5b                   	pop    %ebx
  8025e8:	5e                   	pop    %esi
  8025e9:	5d                   	pop    %ebp
  8025ea:	c3                   	ret    

008025eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8025eb:	55                   	push   %ebp
  8025ec:	89 e5                	mov    %esp,%ebp
  8025ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025f4:	50                   	push   %eax
  8025f5:	ff 75 08             	pushl  0x8(%ebp)
  8025f8:	e8 c4 fe ff ff       	call   8024c1 <fd_lookup>
  8025fd:	83 c4 08             	add    $0x8,%esp
  802600:	85 c0                	test   %eax,%eax
  802602:	78 10                	js     802614 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802604:	83 ec 08             	sub    $0x8,%esp
  802607:	6a 01                	push   $0x1
  802609:	ff 75 f4             	pushl  -0xc(%ebp)
  80260c:	e8 59 ff ff ff       	call   80256a <fd_close>
  802611:	83 c4 10             	add    $0x10,%esp
}
  802614:	c9                   	leave  
  802615:	c3                   	ret    

00802616 <close_all>:

void
close_all(void)
{
  802616:	55                   	push   %ebp
  802617:	89 e5                	mov    %esp,%ebp
  802619:	53                   	push   %ebx
  80261a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80261d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802622:	83 ec 0c             	sub    $0xc,%esp
  802625:	53                   	push   %ebx
  802626:	e8 c0 ff ff ff       	call   8025eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80262b:	83 c3 01             	add    $0x1,%ebx
  80262e:	83 c4 10             	add    $0x10,%esp
  802631:	83 fb 20             	cmp    $0x20,%ebx
  802634:	75 ec                	jne    802622 <close_all+0xc>
		close(i);
}
  802636:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802639:	c9                   	leave  
  80263a:	c3                   	ret    

0080263b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80263b:	55                   	push   %ebp
  80263c:	89 e5                	mov    %esp,%ebp
  80263e:	57                   	push   %edi
  80263f:	56                   	push   %esi
  802640:	53                   	push   %ebx
  802641:	83 ec 2c             	sub    $0x2c,%esp
  802644:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802647:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80264a:	50                   	push   %eax
  80264b:	ff 75 08             	pushl  0x8(%ebp)
  80264e:	e8 6e fe ff ff       	call   8024c1 <fd_lookup>
  802653:	83 c4 08             	add    $0x8,%esp
  802656:	85 c0                	test   %eax,%eax
  802658:	0f 88 c1 00 00 00    	js     80271f <dup+0xe4>
		return r;
	close(newfdnum);
  80265e:	83 ec 0c             	sub    $0xc,%esp
  802661:	56                   	push   %esi
  802662:	e8 84 ff ff ff       	call   8025eb <close>

	newfd = INDEX2FD(newfdnum);
  802667:	89 f3                	mov    %esi,%ebx
  802669:	c1 e3 0c             	shl    $0xc,%ebx
  80266c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802672:	83 c4 04             	add    $0x4,%esp
  802675:	ff 75 e4             	pushl  -0x1c(%ebp)
  802678:	e8 de fd ff ff       	call   80245b <fd2data>
  80267d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80267f:	89 1c 24             	mov    %ebx,(%esp)
  802682:	e8 d4 fd ff ff       	call   80245b <fd2data>
  802687:	83 c4 10             	add    $0x10,%esp
  80268a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80268d:	89 f8                	mov    %edi,%eax
  80268f:	c1 e8 16             	shr    $0x16,%eax
  802692:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802699:	a8 01                	test   $0x1,%al
  80269b:	74 37                	je     8026d4 <dup+0x99>
  80269d:	89 f8                	mov    %edi,%eax
  80269f:	c1 e8 0c             	shr    $0xc,%eax
  8026a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8026a9:	f6 c2 01             	test   $0x1,%dl
  8026ac:	74 26                	je     8026d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8026ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8026b5:	83 ec 0c             	sub    $0xc,%esp
  8026b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8026bd:	50                   	push   %eax
  8026be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8026c1:	6a 00                	push   $0x0
  8026c3:	57                   	push   %edi
  8026c4:	6a 00                	push   $0x0
  8026c6:	e8 73 fa ff ff       	call   80213e <sys_page_map>
  8026cb:	89 c7                	mov    %eax,%edi
  8026cd:	83 c4 20             	add    $0x20,%esp
  8026d0:	85 c0                	test   %eax,%eax
  8026d2:	78 2e                	js     802702 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8026d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8026d7:	89 d0                	mov    %edx,%eax
  8026d9:	c1 e8 0c             	shr    $0xc,%eax
  8026dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8026e3:	83 ec 0c             	sub    $0xc,%esp
  8026e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8026eb:	50                   	push   %eax
  8026ec:	53                   	push   %ebx
  8026ed:	6a 00                	push   $0x0
  8026ef:	52                   	push   %edx
  8026f0:	6a 00                	push   $0x0
  8026f2:	e8 47 fa ff ff       	call   80213e <sys_page_map>
  8026f7:	89 c7                	mov    %eax,%edi
  8026f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8026fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8026fe:	85 ff                	test   %edi,%edi
  802700:	79 1d                	jns    80271f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802702:	83 ec 08             	sub    $0x8,%esp
  802705:	53                   	push   %ebx
  802706:	6a 00                	push   $0x0
  802708:	e8 73 fa ff ff       	call   802180 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80270d:	83 c4 08             	add    $0x8,%esp
  802710:	ff 75 d4             	pushl  -0x2c(%ebp)
  802713:	6a 00                	push   $0x0
  802715:	e8 66 fa ff ff       	call   802180 <sys_page_unmap>
	return r;
  80271a:	83 c4 10             	add    $0x10,%esp
  80271d:	89 f8                	mov    %edi,%eax
}
  80271f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802722:	5b                   	pop    %ebx
  802723:	5e                   	pop    %esi
  802724:	5f                   	pop    %edi
  802725:	5d                   	pop    %ebp
  802726:	c3                   	ret    

00802727 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802727:	55                   	push   %ebp
  802728:	89 e5                	mov    %esp,%ebp
  80272a:	53                   	push   %ebx
  80272b:	83 ec 14             	sub    $0x14,%esp
  80272e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802731:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802734:	50                   	push   %eax
  802735:	53                   	push   %ebx
  802736:	e8 86 fd ff ff       	call   8024c1 <fd_lookup>
  80273b:	83 c4 08             	add    $0x8,%esp
  80273e:	89 c2                	mov    %eax,%edx
  802740:	85 c0                	test   %eax,%eax
  802742:	78 6d                	js     8027b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802744:	83 ec 08             	sub    $0x8,%esp
  802747:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80274a:	50                   	push   %eax
  80274b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80274e:	ff 30                	pushl  (%eax)
  802750:	e8 c2 fd ff ff       	call   802517 <dev_lookup>
  802755:	83 c4 10             	add    $0x10,%esp
  802758:	85 c0                	test   %eax,%eax
  80275a:	78 4c                	js     8027a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80275c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80275f:	8b 42 08             	mov    0x8(%edx),%eax
  802762:	83 e0 03             	and    $0x3,%eax
  802765:	83 f8 01             	cmp    $0x1,%eax
  802768:	75 21                	jne    80278b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80276a:	a1 0c 90 80 00       	mov    0x80900c,%eax
  80276f:	8b 40 48             	mov    0x48(%eax),%eax
  802772:	83 ec 04             	sub    $0x4,%esp
  802775:	53                   	push   %ebx
  802776:	50                   	push   %eax
  802777:	68 a8 3d 80 00       	push   $0x803da8
  80277c:	e8 f2 ef ff ff       	call   801773 <cprintf>
		return -E_INVAL;
  802781:	83 c4 10             	add    $0x10,%esp
  802784:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802789:	eb 26                	jmp    8027b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80278b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80278e:	8b 40 08             	mov    0x8(%eax),%eax
  802791:	85 c0                	test   %eax,%eax
  802793:	74 17                	je     8027ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802795:	83 ec 04             	sub    $0x4,%esp
  802798:	ff 75 10             	pushl  0x10(%ebp)
  80279b:	ff 75 0c             	pushl  0xc(%ebp)
  80279e:	52                   	push   %edx
  80279f:	ff d0                	call   *%eax
  8027a1:	89 c2                	mov    %eax,%edx
  8027a3:	83 c4 10             	add    $0x10,%esp
  8027a6:	eb 09                	jmp    8027b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8027a8:	89 c2                	mov    %eax,%edx
  8027aa:	eb 05                	jmp    8027b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8027ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8027b1:	89 d0                	mov    %edx,%eax
  8027b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8027b6:	c9                   	leave  
  8027b7:	c3                   	ret    

008027b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8027b8:	55                   	push   %ebp
  8027b9:	89 e5                	mov    %esp,%ebp
  8027bb:	57                   	push   %edi
  8027bc:	56                   	push   %esi
  8027bd:	53                   	push   %ebx
  8027be:	83 ec 0c             	sub    $0xc,%esp
  8027c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8027c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8027c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027cc:	eb 21                	jmp    8027ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8027ce:	83 ec 04             	sub    $0x4,%esp
  8027d1:	89 f0                	mov    %esi,%eax
  8027d3:	29 d8                	sub    %ebx,%eax
  8027d5:	50                   	push   %eax
  8027d6:	89 d8                	mov    %ebx,%eax
  8027d8:	03 45 0c             	add    0xc(%ebp),%eax
  8027db:	50                   	push   %eax
  8027dc:	57                   	push   %edi
  8027dd:	e8 45 ff ff ff       	call   802727 <read>
		if (m < 0)
  8027e2:	83 c4 10             	add    $0x10,%esp
  8027e5:	85 c0                	test   %eax,%eax
  8027e7:	78 10                	js     8027f9 <readn+0x41>
			return m;
		if (m == 0)
  8027e9:	85 c0                	test   %eax,%eax
  8027eb:	74 0a                	je     8027f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8027ed:	01 c3                	add    %eax,%ebx
  8027ef:	39 f3                	cmp    %esi,%ebx
  8027f1:	72 db                	jb     8027ce <readn+0x16>
  8027f3:	89 d8                	mov    %ebx,%eax
  8027f5:	eb 02                	jmp    8027f9 <readn+0x41>
  8027f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8027f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027fc:	5b                   	pop    %ebx
  8027fd:	5e                   	pop    %esi
  8027fe:	5f                   	pop    %edi
  8027ff:	5d                   	pop    %ebp
  802800:	c3                   	ret    

00802801 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802801:	55                   	push   %ebp
  802802:	89 e5                	mov    %esp,%ebp
  802804:	53                   	push   %ebx
  802805:	83 ec 14             	sub    $0x14,%esp
  802808:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80280b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80280e:	50                   	push   %eax
  80280f:	53                   	push   %ebx
  802810:	e8 ac fc ff ff       	call   8024c1 <fd_lookup>
  802815:	83 c4 08             	add    $0x8,%esp
  802818:	89 c2                	mov    %eax,%edx
  80281a:	85 c0                	test   %eax,%eax
  80281c:	78 68                	js     802886 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80281e:	83 ec 08             	sub    $0x8,%esp
  802821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802824:	50                   	push   %eax
  802825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802828:	ff 30                	pushl  (%eax)
  80282a:	e8 e8 fc ff ff       	call   802517 <dev_lookup>
  80282f:	83 c4 10             	add    $0x10,%esp
  802832:	85 c0                	test   %eax,%eax
  802834:	78 47                	js     80287d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802839:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80283d:	75 21                	jne    802860 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80283f:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802844:	8b 40 48             	mov    0x48(%eax),%eax
  802847:	83 ec 04             	sub    $0x4,%esp
  80284a:	53                   	push   %ebx
  80284b:	50                   	push   %eax
  80284c:	68 c4 3d 80 00       	push   $0x803dc4
  802851:	e8 1d ef ff ff       	call   801773 <cprintf>
		return -E_INVAL;
  802856:	83 c4 10             	add    $0x10,%esp
  802859:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80285e:	eb 26                	jmp    802886 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802860:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802863:	8b 52 0c             	mov    0xc(%edx),%edx
  802866:	85 d2                	test   %edx,%edx
  802868:	74 17                	je     802881 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80286a:	83 ec 04             	sub    $0x4,%esp
  80286d:	ff 75 10             	pushl  0x10(%ebp)
  802870:	ff 75 0c             	pushl  0xc(%ebp)
  802873:	50                   	push   %eax
  802874:	ff d2                	call   *%edx
  802876:	89 c2                	mov    %eax,%edx
  802878:	83 c4 10             	add    $0x10,%esp
  80287b:	eb 09                	jmp    802886 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80287d:	89 c2                	mov    %eax,%edx
  80287f:	eb 05                	jmp    802886 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802881:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802886:	89 d0                	mov    %edx,%eax
  802888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80288b:	c9                   	leave  
  80288c:	c3                   	ret    

0080288d <seek>:

int
seek(int fdnum, off_t offset)
{
  80288d:	55                   	push   %ebp
  80288e:	89 e5                	mov    %esp,%ebp
  802890:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802893:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802896:	50                   	push   %eax
  802897:	ff 75 08             	pushl  0x8(%ebp)
  80289a:	e8 22 fc ff ff       	call   8024c1 <fd_lookup>
  80289f:	83 c4 08             	add    $0x8,%esp
  8028a2:	85 c0                	test   %eax,%eax
  8028a4:	78 0e                	js     8028b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8028a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8028a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8028af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8028b4:	c9                   	leave  
  8028b5:	c3                   	ret    

008028b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8028b6:	55                   	push   %ebp
  8028b7:	89 e5                	mov    %esp,%ebp
  8028b9:	53                   	push   %ebx
  8028ba:	83 ec 14             	sub    $0x14,%esp
  8028bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8028c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028c3:	50                   	push   %eax
  8028c4:	53                   	push   %ebx
  8028c5:	e8 f7 fb ff ff       	call   8024c1 <fd_lookup>
  8028ca:	83 c4 08             	add    $0x8,%esp
  8028cd:	89 c2                	mov    %eax,%edx
  8028cf:	85 c0                	test   %eax,%eax
  8028d1:	78 65                	js     802938 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8028d3:	83 ec 08             	sub    $0x8,%esp
  8028d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028d9:	50                   	push   %eax
  8028da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028dd:	ff 30                	pushl  (%eax)
  8028df:	e8 33 fc ff ff       	call   802517 <dev_lookup>
  8028e4:	83 c4 10             	add    $0x10,%esp
  8028e7:	85 c0                	test   %eax,%eax
  8028e9:	78 44                	js     80292f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8028eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8028f2:	75 21                	jne    802915 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8028f4:	a1 0c 90 80 00       	mov    0x80900c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8028f9:	8b 40 48             	mov    0x48(%eax),%eax
  8028fc:	83 ec 04             	sub    $0x4,%esp
  8028ff:	53                   	push   %ebx
  802900:	50                   	push   %eax
  802901:	68 84 3d 80 00       	push   $0x803d84
  802906:	e8 68 ee ff ff       	call   801773 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80290b:	83 c4 10             	add    $0x10,%esp
  80290e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802913:	eb 23                	jmp    802938 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802915:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802918:	8b 52 18             	mov    0x18(%edx),%edx
  80291b:	85 d2                	test   %edx,%edx
  80291d:	74 14                	je     802933 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80291f:	83 ec 08             	sub    $0x8,%esp
  802922:	ff 75 0c             	pushl  0xc(%ebp)
  802925:	50                   	push   %eax
  802926:	ff d2                	call   *%edx
  802928:	89 c2                	mov    %eax,%edx
  80292a:	83 c4 10             	add    $0x10,%esp
  80292d:	eb 09                	jmp    802938 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80292f:	89 c2                	mov    %eax,%edx
  802931:	eb 05                	jmp    802938 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802933:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802938:	89 d0                	mov    %edx,%eax
  80293a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80293d:	c9                   	leave  
  80293e:	c3                   	ret    

0080293f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80293f:	55                   	push   %ebp
  802940:	89 e5                	mov    %esp,%ebp
  802942:	53                   	push   %ebx
  802943:	83 ec 14             	sub    $0x14,%esp
  802946:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802949:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80294c:	50                   	push   %eax
  80294d:	ff 75 08             	pushl  0x8(%ebp)
  802950:	e8 6c fb ff ff       	call   8024c1 <fd_lookup>
  802955:	83 c4 08             	add    $0x8,%esp
  802958:	89 c2                	mov    %eax,%edx
  80295a:	85 c0                	test   %eax,%eax
  80295c:	78 58                	js     8029b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80295e:	83 ec 08             	sub    $0x8,%esp
  802961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802964:	50                   	push   %eax
  802965:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802968:	ff 30                	pushl  (%eax)
  80296a:	e8 a8 fb ff ff       	call   802517 <dev_lookup>
  80296f:	83 c4 10             	add    $0x10,%esp
  802972:	85 c0                	test   %eax,%eax
  802974:	78 37                	js     8029ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802976:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802979:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80297d:	74 32                	je     8029b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80297f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802982:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802989:	00 00 00 
	stat->st_isdir = 0;
  80298c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802993:	00 00 00 
	stat->st_dev = dev;
  802996:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80299c:	83 ec 08             	sub    $0x8,%esp
  80299f:	53                   	push   %ebx
  8029a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8029a3:	ff 50 14             	call   *0x14(%eax)
  8029a6:	89 c2                	mov    %eax,%edx
  8029a8:	83 c4 10             	add    $0x10,%esp
  8029ab:	eb 09                	jmp    8029b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8029ad:	89 c2                	mov    %eax,%edx
  8029af:	eb 05                	jmp    8029b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8029b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8029b6:	89 d0                	mov    %edx,%eax
  8029b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8029bb:	c9                   	leave  
  8029bc:	c3                   	ret    

008029bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8029bd:	55                   	push   %ebp
  8029be:	89 e5                	mov    %esp,%ebp
  8029c0:	56                   	push   %esi
  8029c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8029c2:	83 ec 08             	sub    $0x8,%esp
  8029c5:	6a 00                	push   $0x0
  8029c7:	ff 75 08             	pushl  0x8(%ebp)
  8029ca:	e8 b7 01 00 00       	call   802b86 <open>
  8029cf:	89 c3                	mov    %eax,%ebx
  8029d1:	83 c4 10             	add    $0x10,%esp
  8029d4:	85 c0                	test   %eax,%eax
  8029d6:	78 1b                	js     8029f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8029d8:	83 ec 08             	sub    $0x8,%esp
  8029db:	ff 75 0c             	pushl  0xc(%ebp)
  8029de:	50                   	push   %eax
  8029df:	e8 5b ff ff ff       	call   80293f <fstat>
  8029e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8029e6:	89 1c 24             	mov    %ebx,(%esp)
  8029e9:	e8 fd fb ff ff       	call   8025eb <close>
	return r;
  8029ee:	83 c4 10             	add    $0x10,%esp
  8029f1:	89 f0                	mov    %esi,%eax
}
  8029f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029f6:	5b                   	pop    %ebx
  8029f7:	5e                   	pop    %esi
  8029f8:	5d                   	pop    %ebp
  8029f9:	c3                   	ret    

008029fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8029fa:	55                   	push   %ebp
  8029fb:	89 e5                	mov    %esp,%ebp
  8029fd:	56                   	push   %esi
  8029fe:	53                   	push   %ebx
  8029ff:	89 c6                	mov    %eax,%esi
  802a01:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802a03:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802a0a:	75 12                	jne    802a1e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802a0c:	83 ec 0c             	sub    $0xc,%esp
  802a0f:	6a 01                	push   $0x1
  802a11:	e8 fc f9 ff ff       	call   802412 <ipc_find_env>
  802a16:	a3 00 90 80 00       	mov    %eax,0x809000
  802a1b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802a1e:	6a 07                	push   $0x7
  802a20:	68 00 a0 80 00       	push   $0x80a000
  802a25:	56                   	push   %esi
  802a26:	ff 35 00 90 80 00    	pushl  0x809000
  802a2c:	e8 8d f9 ff ff       	call   8023be <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802a31:	83 c4 0c             	add    $0xc,%esp
  802a34:	6a 00                	push   $0x0
  802a36:	53                   	push   %ebx
  802a37:	6a 00                	push   $0x0
  802a39:	e8 19 f9 ff ff       	call   802357 <ipc_recv>
}
  802a3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a41:	5b                   	pop    %ebx
  802a42:	5e                   	pop    %esi
  802a43:	5d                   	pop    %ebp
  802a44:	c3                   	ret    

00802a45 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802a45:	55                   	push   %ebp
  802a46:	89 e5                	mov    %esp,%ebp
  802a48:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  802a4e:	8b 40 0c             	mov    0xc(%eax),%eax
  802a51:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.set_size.req_size = newsize;
  802a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a59:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802a5e:	ba 00 00 00 00       	mov    $0x0,%edx
  802a63:	b8 02 00 00 00       	mov    $0x2,%eax
  802a68:	e8 8d ff ff ff       	call   8029fa <fsipc>
}
  802a6d:	c9                   	leave  
  802a6e:	c3                   	ret    

00802a6f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802a6f:	55                   	push   %ebp
  802a70:	89 e5                	mov    %esp,%ebp
  802a72:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802a75:	8b 45 08             	mov    0x8(%ebp),%eax
  802a78:	8b 40 0c             	mov    0xc(%eax),%eax
  802a7b:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return fsipc(FSREQ_FLUSH, NULL);
  802a80:	ba 00 00 00 00       	mov    $0x0,%edx
  802a85:	b8 06 00 00 00       	mov    $0x6,%eax
  802a8a:	e8 6b ff ff ff       	call   8029fa <fsipc>
}
  802a8f:	c9                   	leave  
  802a90:	c3                   	ret    

00802a91 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802a91:	55                   	push   %ebp
  802a92:	89 e5                	mov    %esp,%ebp
  802a94:	53                   	push   %ebx
  802a95:	83 ec 04             	sub    $0x4,%esp
  802a98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  802a9e:	8b 40 0c             	mov    0xc(%eax),%eax
  802aa1:	a3 00 a0 80 00       	mov    %eax,0x80a000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  802aab:	b8 05 00 00 00       	mov    $0x5,%eax
  802ab0:	e8 45 ff ff ff       	call   8029fa <fsipc>
  802ab5:	85 c0                	test   %eax,%eax
  802ab7:	78 2c                	js     802ae5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802ab9:	83 ec 08             	sub    $0x8,%esp
  802abc:	68 00 a0 80 00       	push   $0x80a000
  802ac1:	53                   	push   %ebx
  802ac2:	e8 31 f2 ff ff       	call   801cf8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802ac7:	a1 80 a0 80 00       	mov    0x80a080,%eax
  802acc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802ad2:	a1 84 a0 80 00       	mov    0x80a084,%eax
  802ad7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802add:	83 c4 10             	add    $0x10,%esp
  802ae0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ae5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ae8:	c9                   	leave  
  802ae9:	c3                   	ret    

00802aea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802aea:	55                   	push   %ebp
  802aeb:	89 e5                	mov    %esp,%ebp
  802aed:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802af0:	68 f4 3d 80 00       	push   $0x803df4
  802af5:	68 90 00 00 00       	push   $0x90
  802afa:	68 12 3e 80 00       	push   $0x803e12
  802aff:	e8 96 eb ff ff       	call   80169a <_panic>

00802b04 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802b04:	55                   	push   %ebp
  802b05:	89 e5                	mov    %esp,%ebp
  802b07:	56                   	push   %esi
  802b08:	53                   	push   %ebx
  802b09:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  802b0f:	8b 40 0c             	mov    0xc(%eax),%eax
  802b12:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.read.req_n = n;
  802b17:	89 35 04 a0 80 00    	mov    %esi,0x80a004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  802b22:	b8 03 00 00 00       	mov    $0x3,%eax
  802b27:	e8 ce fe ff ff       	call   8029fa <fsipc>
  802b2c:	89 c3                	mov    %eax,%ebx
  802b2e:	85 c0                	test   %eax,%eax
  802b30:	78 4b                	js     802b7d <devfile_read+0x79>
		return r;
	assert(r <= n);
  802b32:	39 c6                	cmp    %eax,%esi
  802b34:	73 16                	jae    802b4c <devfile_read+0x48>
  802b36:	68 1d 3e 80 00       	push   $0x803e1d
  802b3b:	68 1d 34 80 00       	push   $0x80341d
  802b40:	6a 7c                	push   $0x7c
  802b42:	68 12 3e 80 00       	push   $0x803e12
  802b47:	e8 4e eb ff ff       	call   80169a <_panic>
	assert(r <= PGSIZE);
  802b4c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802b51:	7e 16                	jle    802b69 <devfile_read+0x65>
  802b53:	68 24 3e 80 00       	push   $0x803e24
  802b58:	68 1d 34 80 00       	push   $0x80341d
  802b5d:	6a 7d                	push   $0x7d
  802b5f:	68 12 3e 80 00       	push   $0x803e12
  802b64:	e8 31 eb ff ff       	call   80169a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802b69:	83 ec 04             	sub    $0x4,%esp
  802b6c:	50                   	push   %eax
  802b6d:	68 00 a0 80 00       	push   $0x80a000
  802b72:	ff 75 0c             	pushl  0xc(%ebp)
  802b75:	e8 10 f3 ff ff       	call   801e8a <memmove>
	return r;
  802b7a:	83 c4 10             	add    $0x10,%esp
}
  802b7d:	89 d8                	mov    %ebx,%eax
  802b7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b82:	5b                   	pop    %ebx
  802b83:	5e                   	pop    %esi
  802b84:	5d                   	pop    %ebp
  802b85:	c3                   	ret    

00802b86 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802b86:	55                   	push   %ebp
  802b87:	89 e5                	mov    %esp,%ebp
  802b89:	53                   	push   %ebx
  802b8a:	83 ec 20             	sub    $0x20,%esp
  802b8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802b90:	53                   	push   %ebx
  802b91:	e8 29 f1 ff ff       	call   801cbf <strlen>
  802b96:	83 c4 10             	add    $0x10,%esp
  802b99:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802b9e:	7f 67                	jg     802c07 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802ba0:	83 ec 0c             	sub    $0xc,%esp
  802ba3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ba6:	50                   	push   %eax
  802ba7:	e8 c6 f8 ff ff       	call   802472 <fd_alloc>
  802bac:	83 c4 10             	add    $0x10,%esp
		return r;
  802baf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802bb1:	85 c0                	test   %eax,%eax
  802bb3:	78 57                	js     802c0c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802bb5:	83 ec 08             	sub    $0x8,%esp
  802bb8:	53                   	push   %ebx
  802bb9:	68 00 a0 80 00       	push   $0x80a000
  802bbe:	e8 35 f1 ff ff       	call   801cf8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  802bc6:	a3 00 a4 80 00       	mov    %eax,0x80a400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802bcb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802bce:	b8 01 00 00 00       	mov    $0x1,%eax
  802bd3:	e8 22 fe ff ff       	call   8029fa <fsipc>
  802bd8:	89 c3                	mov    %eax,%ebx
  802bda:	83 c4 10             	add    $0x10,%esp
  802bdd:	85 c0                	test   %eax,%eax
  802bdf:	79 14                	jns    802bf5 <open+0x6f>
		fd_close(fd, 0);
  802be1:	83 ec 08             	sub    $0x8,%esp
  802be4:	6a 00                	push   $0x0
  802be6:	ff 75 f4             	pushl  -0xc(%ebp)
  802be9:	e8 7c f9 ff ff       	call   80256a <fd_close>
		return r;
  802bee:	83 c4 10             	add    $0x10,%esp
  802bf1:	89 da                	mov    %ebx,%edx
  802bf3:	eb 17                	jmp    802c0c <open+0x86>
	}

	return fd2num(fd);
  802bf5:	83 ec 0c             	sub    $0xc,%esp
  802bf8:	ff 75 f4             	pushl  -0xc(%ebp)
  802bfb:	e8 4b f8 ff ff       	call   80244b <fd2num>
  802c00:	89 c2                	mov    %eax,%edx
  802c02:	83 c4 10             	add    $0x10,%esp
  802c05:	eb 05                	jmp    802c0c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802c07:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802c0c:	89 d0                	mov    %edx,%eax
  802c0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c11:	c9                   	leave  
  802c12:	c3                   	ret    

00802c13 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802c13:	55                   	push   %ebp
  802c14:	89 e5                	mov    %esp,%ebp
  802c16:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802c19:	ba 00 00 00 00       	mov    $0x0,%edx
  802c1e:	b8 08 00 00 00       	mov    $0x8,%eax
  802c23:	e8 d2 fd ff ff       	call   8029fa <fsipc>
}
  802c28:	c9                   	leave  
  802c29:	c3                   	ret    

00802c2a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802c2a:	55                   	push   %ebp
  802c2b:	89 e5                	mov    %esp,%ebp
  802c2d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802c30:	89 d0                	mov    %edx,%eax
  802c32:	c1 e8 16             	shr    $0x16,%eax
  802c35:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802c3c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802c41:	f6 c1 01             	test   $0x1,%cl
  802c44:	74 1d                	je     802c63 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802c46:	c1 ea 0c             	shr    $0xc,%edx
  802c49:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802c50:	f6 c2 01             	test   $0x1,%dl
  802c53:	74 0e                	je     802c63 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802c55:	c1 ea 0c             	shr    $0xc,%edx
  802c58:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802c5f:	ef 
  802c60:	0f b7 c0             	movzwl %ax,%eax
}
  802c63:	5d                   	pop    %ebp
  802c64:	c3                   	ret    

00802c65 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802c65:	55                   	push   %ebp
  802c66:	89 e5                	mov    %esp,%ebp
  802c68:	56                   	push   %esi
  802c69:	53                   	push   %ebx
  802c6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802c6d:	83 ec 0c             	sub    $0xc,%esp
  802c70:	ff 75 08             	pushl  0x8(%ebp)
  802c73:	e8 e3 f7 ff ff       	call   80245b <fd2data>
  802c78:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802c7a:	83 c4 08             	add    $0x8,%esp
  802c7d:	68 30 3e 80 00       	push   $0x803e30
  802c82:	53                   	push   %ebx
  802c83:	e8 70 f0 ff ff       	call   801cf8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802c88:	8b 46 04             	mov    0x4(%esi),%eax
  802c8b:	2b 06                	sub    (%esi),%eax
  802c8d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802c93:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802c9a:	00 00 00 
	stat->st_dev = &devpipe;
  802c9d:	c7 83 88 00 00 00 80 	movl   $0x808080,0x88(%ebx)
  802ca4:	80 80 00 
	return 0;
}
  802ca7:	b8 00 00 00 00       	mov    $0x0,%eax
  802cac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802caf:	5b                   	pop    %ebx
  802cb0:	5e                   	pop    %esi
  802cb1:	5d                   	pop    %ebp
  802cb2:	c3                   	ret    

00802cb3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802cb3:	55                   	push   %ebp
  802cb4:	89 e5                	mov    %esp,%ebp
  802cb6:	53                   	push   %ebx
  802cb7:	83 ec 0c             	sub    $0xc,%esp
  802cba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802cbd:	53                   	push   %ebx
  802cbe:	6a 00                	push   $0x0
  802cc0:	e8 bb f4 ff ff       	call   802180 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802cc5:	89 1c 24             	mov    %ebx,(%esp)
  802cc8:	e8 8e f7 ff ff       	call   80245b <fd2data>
  802ccd:	83 c4 08             	add    $0x8,%esp
  802cd0:	50                   	push   %eax
  802cd1:	6a 00                	push   $0x0
  802cd3:	e8 a8 f4 ff ff       	call   802180 <sys_page_unmap>
}
  802cd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cdb:	c9                   	leave  
  802cdc:	c3                   	ret    

00802cdd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802cdd:	55                   	push   %ebp
  802cde:	89 e5                	mov    %esp,%ebp
  802ce0:	57                   	push   %edi
  802ce1:	56                   	push   %esi
  802ce2:	53                   	push   %ebx
  802ce3:	83 ec 1c             	sub    $0x1c,%esp
  802ce6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802ce9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802ceb:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802cf0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802cf3:	83 ec 0c             	sub    $0xc,%esp
  802cf6:	ff 75 e0             	pushl  -0x20(%ebp)
  802cf9:	e8 2c ff ff ff       	call   802c2a <pageref>
  802cfe:	89 c3                	mov    %eax,%ebx
  802d00:	89 3c 24             	mov    %edi,(%esp)
  802d03:	e8 22 ff ff ff       	call   802c2a <pageref>
  802d08:	83 c4 10             	add    $0x10,%esp
  802d0b:	39 c3                	cmp    %eax,%ebx
  802d0d:	0f 94 c1             	sete   %cl
  802d10:	0f b6 c9             	movzbl %cl,%ecx
  802d13:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802d16:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  802d1c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802d1f:	39 ce                	cmp    %ecx,%esi
  802d21:	74 1b                	je     802d3e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802d23:	39 c3                	cmp    %eax,%ebx
  802d25:	75 c4                	jne    802ceb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802d27:	8b 42 58             	mov    0x58(%edx),%eax
  802d2a:	ff 75 e4             	pushl  -0x1c(%ebp)
  802d2d:	50                   	push   %eax
  802d2e:	56                   	push   %esi
  802d2f:	68 37 3e 80 00       	push   $0x803e37
  802d34:	e8 3a ea ff ff       	call   801773 <cprintf>
  802d39:	83 c4 10             	add    $0x10,%esp
  802d3c:	eb ad                	jmp    802ceb <_pipeisclosed+0xe>
	}
}
  802d3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d44:	5b                   	pop    %ebx
  802d45:	5e                   	pop    %esi
  802d46:	5f                   	pop    %edi
  802d47:	5d                   	pop    %ebp
  802d48:	c3                   	ret    

00802d49 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802d49:	55                   	push   %ebp
  802d4a:	89 e5                	mov    %esp,%ebp
  802d4c:	57                   	push   %edi
  802d4d:	56                   	push   %esi
  802d4e:	53                   	push   %ebx
  802d4f:	83 ec 28             	sub    $0x28,%esp
  802d52:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802d55:	56                   	push   %esi
  802d56:	e8 00 f7 ff ff       	call   80245b <fd2data>
  802d5b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802d5d:	83 c4 10             	add    $0x10,%esp
  802d60:	bf 00 00 00 00       	mov    $0x0,%edi
  802d65:	eb 4b                	jmp    802db2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802d67:	89 da                	mov    %ebx,%edx
  802d69:	89 f0                	mov    %esi,%eax
  802d6b:	e8 6d ff ff ff       	call   802cdd <_pipeisclosed>
  802d70:	85 c0                	test   %eax,%eax
  802d72:	75 48                	jne    802dbc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802d74:	e8 63 f3 ff ff       	call   8020dc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802d79:	8b 43 04             	mov    0x4(%ebx),%eax
  802d7c:	8b 0b                	mov    (%ebx),%ecx
  802d7e:	8d 51 20             	lea    0x20(%ecx),%edx
  802d81:	39 d0                	cmp    %edx,%eax
  802d83:	73 e2                	jae    802d67 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d88:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802d8c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802d8f:	89 c2                	mov    %eax,%edx
  802d91:	c1 fa 1f             	sar    $0x1f,%edx
  802d94:	89 d1                	mov    %edx,%ecx
  802d96:	c1 e9 1b             	shr    $0x1b,%ecx
  802d99:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802d9c:	83 e2 1f             	and    $0x1f,%edx
  802d9f:	29 ca                	sub    %ecx,%edx
  802da1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802da5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802da9:	83 c0 01             	add    $0x1,%eax
  802dac:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802daf:	83 c7 01             	add    $0x1,%edi
  802db2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802db5:	75 c2                	jne    802d79 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802db7:	8b 45 10             	mov    0x10(%ebp),%eax
  802dba:	eb 05                	jmp    802dc1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802dbc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802dc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802dc4:	5b                   	pop    %ebx
  802dc5:	5e                   	pop    %esi
  802dc6:	5f                   	pop    %edi
  802dc7:	5d                   	pop    %ebp
  802dc8:	c3                   	ret    

00802dc9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802dc9:	55                   	push   %ebp
  802dca:	89 e5                	mov    %esp,%ebp
  802dcc:	57                   	push   %edi
  802dcd:	56                   	push   %esi
  802dce:	53                   	push   %ebx
  802dcf:	83 ec 18             	sub    $0x18,%esp
  802dd2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802dd5:	57                   	push   %edi
  802dd6:	e8 80 f6 ff ff       	call   80245b <fd2data>
  802ddb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ddd:	83 c4 10             	add    $0x10,%esp
  802de0:	bb 00 00 00 00       	mov    $0x0,%ebx
  802de5:	eb 3d                	jmp    802e24 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802de7:	85 db                	test   %ebx,%ebx
  802de9:	74 04                	je     802def <devpipe_read+0x26>
				return i;
  802deb:	89 d8                	mov    %ebx,%eax
  802ded:	eb 44                	jmp    802e33 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802def:	89 f2                	mov    %esi,%edx
  802df1:	89 f8                	mov    %edi,%eax
  802df3:	e8 e5 fe ff ff       	call   802cdd <_pipeisclosed>
  802df8:	85 c0                	test   %eax,%eax
  802dfa:	75 32                	jne    802e2e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802dfc:	e8 db f2 ff ff       	call   8020dc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802e01:	8b 06                	mov    (%esi),%eax
  802e03:	3b 46 04             	cmp    0x4(%esi),%eax
  802e06:	74 df                	je     802de7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802e08:	99                   	cltd   
  802e09:	c1 ea 1b             	shr    $0x1b,%edx
  802e0c:	01 d0                	add    %edx,%eax
  802e0e:	83 e0 1f             	and    $0x1f,%eax
  802e11:	29 d0                	sub    %edx,%eax
  802e13:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e1b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802e1e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e21:	83 c3 01             	add    $0x1,%ebx
  802e24:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802e27:	75 d8                	jne    802e01 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802e29:	8b 45 10             	mov    0x10(%ebp),%eax
  802e2c:	eb 05                	jmp    802e33 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802e2e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802e33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e36:	5b                   	pop    %ebx
  802e37:	5e                   	pop    %esi
  802e38:	5f                   	pop    %edi
  802e39:	5d                   	pop    %ebp
  802e3a:	c3                   	ret    

00802e3b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802e3b:	55                   	push   %ebp
  802e3c:	89 e5                	mov    %esp,%ebp
  802e3e:	56                   	push   %esi
  802e3f:	53                   	push   %ebx
  802e40:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802e43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e46:	50                   	push   %eax
  802e47:	e8 26 f6 ff ff       	call   802472 <fd_alloc>
  802e4c:	83 c4 10             	add    $0x10,%esp
  802e4f:	89 c2                	mov    %eax,%edx
  802e51:	85 c0                	test   %eax,%eax
  802e53:	0f 88 2c 01 00 00    	js     802f85 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802e59:	83 ec 04             	sub    $0x4,%esp
  802e5c:	68 07 04 00 00       	push   $0x407
  802e61:	ff 75 f4             	pushl  -0xc(%ebp)
  802e64:	6a 00                	push   $0x0
  802e66:	e8 90 f2 ff ff       	call   8020fb <sys_page_alloc>
  802e6b:	83 c4 10             	add    $0x10,%esp
  802e6e:	89 c2                	mov    %eax,%edx
  802e70:	85 c0                	test   %eax,%eax
  802e72:	0f 88 0d 01 00 00    	js     802f85 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802e78:	83 ec 0c             	sub    $0xc,%esp
  802e7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e7e:	50                   	push   %eax
  802e7f:	e8 ee f5 ff ff       	call   802472 <fd_alloc>
  802e84:	89 c3                	mov    %eax,%ebx
  802e86:	83 c4 10             	add    $0x10,%esp
  802e89:	85 c0                	test   %eax,%eax
  802e8b:	0f 88 e2 00 00 00    	js     802f73 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802e91:	83 ec 04             	sub    $0x4,%esp
  802e94:	68 07 04 00 00       	push   $0x407
  802e99:	ff 75 f0             	pushl  -0x10(%ebp)
  802e9c:	6a 00                	push   $0x0
  802e9e:	e8 58 f2 ff ff       	call   8020fb <sys_page_alloc>
  802ea3:	89 c3                	mov    %eax,%ebx
  802ea5:	83 c4 10             	add    $0x10,%esp
  802ea8:	85 c0                	test   %eax,%eax
  802eaa:	0f 88 c3 00 00 00    	js     802f73 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802eb0:	83 ec 0c             	sub    $0xc,%esp
  802eb3:	ff 75 f4             	pushl  -0xc(%ebp)
  802eb6:	e8 a0 f5 ff ff       	call   80245b <fd2data>
  802ebb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ebd:	83 c4 0c             	add    $0xc,%esp
  802ec0:	68 07 04 00 00       	push   $0x407
  802ec5:	50                   	push   %eax
  802ec6:	6a 00                	push   $0x0
  802ec8:	e8 2e f2 ff ff       	call   8020fb <sys_page_alloc>
  802ecd:	89 c3                	mov    %eax,%ebx
  802ecf:	83 c4 10             	add    $0x10,%esp
  802ed2:	85 c0                	test   %eax,%eax
  802ed4:	0f 88 89 00 00 00    	js     802f63 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802eda:	83 ec 0c             	sub    $0xc,%esp
  802edd:	ff 75 f0             	pushl  -0x10(%ebp)
  802ee0:	e8 76 f5 ff ff       	call   80245b <fd2data>
  802ee5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802eec:	50                   	push   %eax
  802eed:	6a 00                	push   $0x0
  802eef:	56                   	push   %esi
  802ef0:	6a 00                	push   $0x0
  802ef2:	e8 47 f2 ff ff       	call   80213e <sys_page_map>
  802ef7:	89 c3                	mov    %eax,%ebx
  802ef9:	83 c4 20             	add    $0x20,%esp
  802efc:	85 c0                	test   %eax,%eax
  802efe:	78 55                	js     802f55 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802f00:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f09:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f0e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802f15:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f1e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f23:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802f2a:	83 ec 0c             	sub    $0xc,%esp
  802f2d:	ff 75 f4             	pushl  -0xc(%ebp)
  802f30:	e8 16 f5 ff ff       	call   80244b <fd2num>
  802f35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802f38:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802f3a:	83 c4 04             	add    $0x4,%esp
  802f3d:	ff 75 f0             	pushl  -0x10(%ebp)
  802f40:	e8 06 f5 ff ff       	call   80244b <fd2num>
  802f45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802f48:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802f4b:	83 c4 10             	add    $0x10,%esp
  802f4e:	ba 00 00 00 00       	mov    $0x0,%edx
  802f53:	eb 30                	jmp    802f85 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802f55:	83 ec 08             	sub    $0x8,%esp
  802f58:	56                   	push   %esi
  802f59:	6a 00                	push   $0x0
  802f5b:	e8 20 f2 ff ff       	call   802180 <sys_page_unmap>
  802f60:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802f63:	83 ec 08             	sub    $0x8,%esp
  802f66:	ff 75 f0             	pushl  -0x10(%ebp)
  802f69:	6a 00                	push   $0x0
  802f6b:	e8 10 f2 ff ff       	call   802180 <sys_page_unmap>
  802f70:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802f73:	83 ec 08             	sub    $0x8,%esp
  802f76:	ff 75 f4             	pushl  -0xc(%ebp)
  802f79:	6a 00                	push   $0x0
  802f7b:	e8 00 f2 ff ff       	call   802180 <sys_page_unmap>
  802f80:	83 c4 10             	add    $0x10,%esp
  802f83:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802f85:	89 d0                	mov    %edx,%eax
  802f87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f8a:	5b                   	pop    %ebx
  802f8b:	5e                   	pop    %esi
  802f8c:	5d                   	pop    %ebp
  802f8d:	c3                   	ret    

00802f8e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802f8e:	55                   	push   %ebp
  802f8f:	89 e5                	mov    %esp,%ebp
  802f91:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802f94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f97:	50                   	push   %eax
  802f98:	ff 75 08             	pushl  0x8(%ebp)
  802f9b:	e8 21 f5 ff ff       	call   8024c1 <fd_lookup>
  802fa0:	83 c4 10             	add    $0x10,%esp
  802fa3:	85 c0                	test   %eax,%eax
  802fa5:	78 18                	js     802fbf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802fa7:	83 ec 0c             	sub    $0xc,%esp
  802faa:	ff 75 f4             	pushl  -0xc(%ebp)
  802fad:	e8 a9 f4 ff ff       	call   80245b <fd2data>
	return _pipeisclosed(fd, p);
  802fb2:	89 c2                	mov    %eax,%edx
  802fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fb7:	e8 21 fd ff ff       	call   802cdd <_pipeisclosed>
  802fbc:	83 c4 10             	add    $0x10,%esp
}
  802fbf:	c9                   	leave  
  802fc0:	c3                   	ret    

00802fc1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802fc1:	55                   	push   %ebp
  802fc2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802fc4:	b8 00 00 00 00       	mov    $0x0,%eax
  802fc9:	5d                   	pop    %ebp
  802fca:	c3                   	ret    

00802fcb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802fcb:	55                   	push   %ebp
  802fcc:	89 e5                	mov    %esp,%ebp
  802fce:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802fd1:	68 4f 3e 80 00       	push   $0x803e4f
  802fd6:	ff 75 0c             	pushl  0xc(%ebp)
  802fd9:	e8 1a ed ff ff       	call   801cf8 <strcpy>
	return 0;
}
  802fde:	b8 00 00 00 00       	mov    $0x0,%eax
  802fe3:	c9                   	leave  
  802fe4:	c3                   	ret    

00802fe5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802fe5:	55                   	push   %ebp
  802fe6:	89 e5                	mov    %esp,%ebp
  802fe8:	57                   	push   %edi
  802fe9:	56                   	push   %esi
  802fea:	53                   	push   %ebx
  802feb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802ff1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802ff6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802ffc:	eb 2d                	jmp    80302b <devcons_write+0x46>
		m = n - tot;
  802ffe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803001:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803003:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803006:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80300b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80300e:	83 ec 04             	sub    $0x4,%esp
  803011:	53                   	push   %ebx
  803012:	03 45 0c             	add    0xc(%ebp),%eax
  803015:	50                   	push   %eax
  803016:	57                   	push   %edi
  803017:	e8 6e ee ff ff       	call   801e8a <memmove>
		sys_cputs(buf, m);
  80301c:	83 c4 08             	add    $0x8,%esp
  80301f:	53                   	push   %ebx
  803020:	57                   	push   %edi
  803021:	e8 19 f0 ff ff       	call   80203f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803026:	01 de                	add    %ebx,%esi
  803028:	83 c4 10             	add    $0x10,%esp
  80302b:	89 f0                	mov    %esi,%eax
  80302d:	3b 75 10             	cmp    0x10(%ebp),%esi
  803030:	72 cc                	jb     802ffe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803032:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803035:	5b                   	pop    %ebx
  803036:	5e                   	pop    %esi
  803037:	5f                   	pop    %edi
  803038:	5d                   	pop    %ebp
  803039:	c3                   	ret    

0080303a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80303a:	55                   	push   %ebp
  80303b:	89 e5                	mov    %esp,%ebp
  80303d:	83 ec 08             	sub    $0x8,%esp
  803040:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803045:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803049:	74 2a                	je     803075 <devcons_read+0x3b>
  80304b:	eb 05                	jmp    803052 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80304d:	e8 8a f0 ff ff       	call   8020dc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803052:	e8 06 f0 ff ff       	call   80205d <sys_cgetc>
  803057:	85 c0                	test   %eax,%eax
  803059:	74 f2                	je     80304d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80305b:	85 c0                	test   %eax,%eax
  80305d:	78 16                	js     803075 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80305f:	83 f8 04             	cmp    $0x4,%eax
  803062:	74 0c                	je     803070 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803064:	8b 55 0c             	mov    0xc(%ebp),%edx
  803067:	88 02                	mov    %al,(%edx)
	return 1;
  803069:	b8 01 00 00 00       	mov    $0x1,%eax
  80306e:	eb 05                	jmp    803075 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803070:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803075:	c9                   	leave  
  803076:	c3                   	ret    

00803077 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803077:	55                   	push   %ebp
  803078:	89 e5                	mov    %esp,%ebp
  80307a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80307d:	8b 45 08             	mov    0x8(%ebp),%eax
  803080:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803083:	6a 01                	push   $0x1
  803085:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803088:	50                   	push   %eax
  803089:	e8 b1 ef ff ff       	call   80203f <sys_cputs>
}
  80308e:	83 c4 10             	add    $0x10,%esp
  803091:	c9                   	leave  
  803092:	c3                   	ret    

00803093 <getchar>:

int
getchar(void)
{
  803093:	55                   	push   %ebp
  803094:	89 e5                	mov    %esp,%ebp
  803096:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803099:	6a 01                	push   $0x1
  80309b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80309e:	50                   	push   %eax
  80309f:	6a 00                	push   $0x0
  8030a1:	e8 81 f6 ff ff       	call   802727 <read>
	if (r < 0)
  8030a6:	83 c4 10             	add    $0x10,%esp
  8030a9:	85 c0                	test   %eax,%eax
  8030ab:	78 0f                	js     8030bc <getchar+0x29>
		return r;
	if (r < 1)
  8030ad:	85 c0                	test   %eax,%eax
  8030af:	7e 06                	jle    8030b7 <getchar+0x24>
		return -E_EOF;
	return c;
  8030b1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8030b5:	eb 05                	jmp    8030bc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8030b7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8030bc:	c9                   	leave  
  8030bd:	c3                   	ret    

008030be <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8030be:	55                   	push   %ebp
  8030bf:	89 e5                	mov    %esp,%ebp
  8030c1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8030c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030c7:	50                   	push   %eax
  8030c8:	ff 75 08             	pushl  0x8(%ebp)
  8030cb:	e8 f1 f3 ff ff       	call   8024c1 <fd_lookup>
  8030d0:	83 c4 10             	add    $0x10,%esp
  8030d3:	85 c0                	test   %eax,%eax
  8030d5:	78 11                	js     8030e8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8030d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030da:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  8030e0:	39 10                	cmp    %edx,(%eax)
  8030e2:	0f 94 c0             	sete   %al
  8030e5:	0f b6 c0             	movzbl %al,%eax
}
  8030e8:	c9                   	leave  
  8030e9:	c3                   	ret    

008030ea <opencons>:

int
opencons(void)
{
  8030ea:	55                   	push   %ebp
  8030eb:	89 e5                	mov    %esp,%ebp
  8030ed:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8030f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030f3:	50                   	push   %eax
  8030f4:	e8 79 f3 ff ff       	call   802472 <fd_alloc>
  8030f9:	83 c4 10             	add    $0x10,%esp
		return r;
  8030fc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8030fe:	85 c0                	test   %eax,%eax
  803100:	78 3e                	js     803140 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803102:	83 ec 04             	sub    $0x4,%esp
  803105:	68 07 04 00 00       	push   $0x407
  80310a:	ff 75 f4             	pushl  -0xc(%ebp)
  80310d:	6a 00                	push   $0x0
  80310f:	e8 e7 ef ff ff       	call   8020fb <sys_page_alloc>
  803114:	83 c4 10             	add    $0x10,%esp
		return r;
  803117:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803119:	85 c0                	test   %eax,%eax
  80311b:	78 23                	js     803140 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80311d:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  803123:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803126:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80312b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803132:	83 ec 0c             	sub    $0xc,%esp
  803135:	50                   	push   %eax
  803136:	e8 10 f3 ff ff       	call   80244b <fd2num>
  80313b:	89 c2                	mov    %eax,%edx
  80313d:	83 c4 10             	add    $0x10,%esp
}
  803140:	89 d0                	mov    %edx,%eax
  803142:	c9                   	leave  
  803143:	c3                   	ret    
  803144:	66 90                	xchg   %ax,%ax
  803146:	66 90                	xchg   %ax,%ax
  803148:	66 90                	xchg   %ax,%ax
  80314a:	66 90                	xchg   %ax,%ax
  80314c:	66 90                	xchg   %ax,%ax
  80314e:	66 90                	xchg   %ax,%ax

00803150 <__udivdi3>:
  803150:	55                   	push   %ebp
  803151:	57                   	push   %edi
  803152:	56                   	push   %esi
  803153:	53                   	push   %ebx
  803154:	83 ec 1c             	sub    $0x1c,%esp
  803157:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80315b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80315f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803167:	85 f6                	test   %esi,%esi
  803169:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80316d:	89 ca                	mov    %ecx,%edx
  80316f:	89 f8                	mov    %edi,%eax
  803171:	75 3d                	jne    8031b0 <__udivdi3+0x60>
  803173:	39 cf                	cmp    %ecx,%edi
  803175:	0f 87 c5 00 00 00    	ja     803240 <__udivdi3+0xf0>
  80317b:	85 ff                	test   %edi,%edi
  80317d:	89 fd                	mov    %edi,%ebp
  80317f:	75 0b                	jne    80318c <__udivdi3+0x3c>
  803181:	b8 01 00 00 00       	mov    $0x1,%eax
  803186:	31 d2                	xor    %edx,%edx
  803188:	f7 f7                	div    %edi
  80318a:	89 c5                	mov    %eax,%ebp
  80318c:	89 c8                	mov    %ecx,%eax
  80318e:	31 d2                	xor    %edx,%edx
  803190:	f7 f5                	div    %ebp
  803192:	89 c1                	mov    %eax,%ecx
  803194:	89 d8                	mov    %ebx,%eax
  803196:	89 cf                	mov    %ecx,%edi
  803198:	f7 f5                	div    %ebp
  80319a:	89 c3                	mov    %eax,%ebx
  80319c:	89 d8                	mov    %ebx,%eax
  80319e:	89 fa                	mov    %edi,%edx
  8031a0:	83 c4 1c             	add    $0x1c,%esp
  8031a3:	5b                   	pop    %ebx
  8031a4:	5e                   	pop    %esi
  8031a5:	5f                   	pop    %edi
  8031a6:	5d                   	pop    %ebp
  8031a7:	c3                   	ret    
  8031a8:	90                   	nop
  8031a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8031b0:	39 ce                	cmp    %ecx,%esi
  8031b2:	77 74                	ja     803228 <__udivdi3+0xd8>
  8031b4:	0f bd fe             	bsr    %esi,%edi
  8031b7:	83 f7 1f             	xor    $0x1f,%edi
  8031ba:	0f 84 98 00 00 00    	je     803258 <__udivdi3+0x108>
  8031c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8031c5:	89 f9                	mov    %edi,%ecx
  8031c7:	89 c5                	mov    %eax,%ebp
  8031c9:	29 fb                	sub    %edi,%ebx
  8031cb:	d3 e6                	shl    %cl,%esi
  8031cd:	89 d9                	mov    %ebx,%ecx
  8031cf:	d3 ed                	shr    %cl,%ebp
  8031d1:	89 f9                	mov    %edi,%ecx
  8031d3:	d3 e0                	shl    %cl,%eax
  8031d5:	09 ee                	or     %ebp,%esi
  8031d7:	89 d9                	mov    %ebx,%ecx
  8031d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8031dd:	89 d5                	mov    %edx,%ebp
  8031df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8031e3:	d3 ed                	shr    %cl,%ebp
  8031e5:	89 f9                	mov    %edi,%ecx
  8031e7:	d3 e2                	shl    %cl,%edx
  8031e9:	89 d9                	mov    %ebx,%ecx
  8031eb:	d3 e8                	shr    %cl,%eax
  8031ed:	09 c2                	or     %eax,%edx
  8031ef:	89 d0                	mov    %edx,%eax
  8031f1:	89 ea                	mov    %ebp,%edx
  8031f3:	f7 f6                	div    %esi
  8031f5:	89 d5                	mov    %edx,%ebp
  8031f7:	89 c3                	mov    %eax,%ebx
  8031f9:	f7 64 24 0c          	mull   0xc(%esp)
  8031fd:	39 d5                	cmp    %edx,%ebp
  8031ff:	72 10                	jb     803211 <__udivdi3+0xc1>
  803201:	8b 74 24 08          	mov    0x8(%esp),%esi
  803205:	89 f9                	mov    %edi,%ecx
  803207:	d3 e6                	shl    %cl,%esi
  803209:	39 c6                	cmp    %eax,%esi
  80320b:	73 07                	jae    803214 <__udivdi3+0xc4>
  80320d:	39 d5                	cmp    %edx,%ebp
  80320f:	75 03                	jne    803214 <__udivdi3+0xc4>
  803211:	83 eb 01             	sub    $0x1,%ebx
  803214:	31 ff                	xor    %edi,%edi
  803216:	89 d8                	mov    %ebx,%eax
  803218:	89 fa                	mov    %edi,%edx
  80321a:	83 c4 1c             	add    $0x1c,%esp
  80321d:	5b                   	pop    %ebx
  80321e:	5e                   	pop    %esi
  80321f:	5f                   	pop    %edi
  803220:	5d                   	pop    %ebp
  803221:	c3                   	ret    
  803222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803228:	31 ff                	xor    %edi,%edi
  80322a:	31 db                	xor    %ebx,%ebx
  80322c:	89 d8                	mov    %ebx,%eax
  80322e:	89 fa                	mov    %edi,%edx
  803230:	83 c4 1c             	add    $0x1c,%esp
  803233:	5b                   	pop    %ebx
  803234:	5e                   	pop    %esi
  803235:	5f                   	pop    %edi
  803236:	5d                   	pop    %ebp
  803237:	c3                   	ret    
  803238:	90                   	nop
  803239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803240:	89 d8                	mov    %ebx,%eax
  803242:	f7 f7                	div    %edi
  803244:	31 ff                	xor    %edi,%edi
  803246:	89 c3                	mov    %eax,%ebx
  803248:	89 d8                	mov    %ebx,%eax
  80324a:	89 fa                	mov    %edi,%edx
  80324c:	83 c4 1c             	add    $0x1c,%esp
  80324f:	5b                   	pop    %ebx
  803250:	5e                   	pop    %esi
  803251:	5f                   	pop    %edi
  803252:	5d                   	pop    %ebp
  803253:	c3                   	ret    
  803254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803258:	39 ce                	cmp    %ecx,%esi
  80325a:	72 0c                	jb     803268 <__udivdi3+0x118>
  80325c:	31 db                	xor    %ebx,%ebx
  80325e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803262:	0f 87 34 ff ff ff    	ja     80319c <__udivdi3+0x4c>
  803268:	bb 01 00 00 00       	mov    $0x1,%ebx
  80326d:	e9 2a ff ff ff       	jmp    80319c <__udivdi3+0x4c>
  803272:	66 90                	xchg   %ax,%ax
  803274:	66 90                	xchg   %ax,%ax
  803276:	66 90                	xchg   %ax,%ax
  803278:	66 90                	xchg   %ax,%ax
  80327a:	66 90                	xchg   %ax,%ax
  80327c:	66 90                	xchg   %ax,%ax
  80327e:	66 90                	xchg   %ax,%ax

00803280 <__umoddi3>:
  803280:	55                   	push   %ebp
  803281:	57                   	push   %edi
  803282:	56                   	push   %esi
  803283:	53                   	push   %ebx
  803284:	83 ec 1c             	sub    $0x1c,%esp
  803287:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80328b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80328f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803297:	85 d2                	test   %edx,%edx
  803299:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80329d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8032a1:	89 f3                	mov    %esi,%ebx
  8032a3:	89 3c 24             	mov    %edi,(%esp)
  8032a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032aa:	75 1c                	jne    8032c8 <__umoddi3+0x48>
  8032ac:	39 f7                	cmp    %esi,%edi
  8032ae:	76 50                	jbe    803300 <__umoddi3+0x80>
  8032b0:	89 c8                	mov    %ecx,%eax
  8032b2:	89 f2                	mov    %esi,%edx
  8032b4:	f7 f7                	div    %edi
  8032b6:	89 d0                	mov    %edx,%eax
  8032b8:	31 d2                	xor    %edx,%edx
  8032ba:	83 c4 1c             	add    $0x1c,%esp
  8032bd:	5b                   	pop    %ebx
  8032be:	5e                   	pop    %esi
  8032bf:	5f                   	pop    %edi
  8032c0:	5d                   	pop    %ebp
  8032c1:	c3                   	ret    
  8032c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8032c8:	39 f2                	cmp    %esi,%edx
  8032ca:	89 d0                	mov    %edx,%eax
  8032cc:	77 52                	ja     803320 <__umoddi3+0xa0>
  8032ce:	0f bd ea             	bsr    %edx,%ebp
  8032d1:	83 f5 1f             	xor    $0x1f,%ebp
  8032d4:	75 5a                	jne    803330 <__umoddi3+0xb0>
  8032d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8032da:	0f 82 e0 00 00 00    	jb     8033c0 <__umoddi3+0x140>
  8032e0:	39 0c 24             	cmp    %ecx,(%esp)
  8032e3:	0f 86 d7 00 00 00    	jbe    8033c0 <__umoddi3+0x140>
  8032e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8032ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8032f1:	83 c4 1c             	add    $0x1c,%esp
  8032f4:	5b                   	pop    %ebx
  8032f5:	5e                   	pop    %esi
  8032f6:	5f                   	pop    %edi
  8032f7:	5d                   	pop    %ebp
  8032f8:	c3                   	ret    
  8032f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803300:	85 ff                	test   %edi,%edi
  803302:	89 fd                	mov    %edi,%ebp
  803304:	75 0b                	jne    803311 <__umoddi3+0x91>
  803306:	b8 01 00 00 00       	mov    $0x1,%eax
  80330b:	31 d2                	xor    %edx,%edx
  80330d:	f7 f7                	div    %edi
  80330f:	89 c5                	mov    %eax,%ebp
  803311:	89 f0                	mov    %esi,%eax
  803313:	31 d2                	xor    %edx,%edx
  803315:	f7 f5                	div    %ebp
  803317:	89 c8                	mov    %ecx,%eax
  803319:	f7 f5                	div    %ebp
  80331b:	89 d0                	mov    %edx,%eax
  80331d:	eb 99                	jmp    8032b8 <__umoddi3+0x38>
  80331f:	90                   	nop
  803320:	89 c8                	mov    %ecx,%eax
  803322:	89 f2                	mov    %esi,%edx
  803324:	83 c4 1c             	add    $0x1c,%esp
  803327:	5b                   	pop    %ebx
  803328:	5e                   	pop    %esi
  803329:	5f                   	pop    %edi
  80332a:	5d                   	pop    %ebp
  80332b:	c3                   	ret    
  80332c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803330:	8b 34 24             	mov    (%esp),%esi
  803333:	bf 20 00 00 00       	mov    $0x20,%edi
  803338:	89 e9                	mov    %ebp,%ecx
  80333a:	29 ef                	sub    %ebp,%edi
  80333c:	d3 e0                	shl    %cl,%eax
  80333e:	89 f9                	mov    %edi,%ecx
  803340:	89 f2                	mov    %esi,%edx
  803342:	d3 ea                	shr    %cl,%edx
  803344:	89 e9                	mov    %ebp,%ecx
  803346:	09 c2                	or     %eax,%edx
  803348:	89 d8                	mov    %ebx,%eax
  80334a:	89 14 24             	mov    %edx,(%esp)
  80334d:	89 f2                	mov    %esi,%edx
  80334f:	d3 e2                	shl    %cl,%edx
  803351:	89 f9                	mov    %edi,%ecx
  803353:	89 54 24 04          	mov    %edx,0x4(%esp)
  803357:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80335b:	d3 e8                	shr    %cl,%eax
  80335d:	89 e9                	mov    %ebp,%ecx
  80335f:	89 c6                	mov    %eax,%esi
  803361:	d3 e3                	shl    %cl,%ebx
  803363:	89 f9                	mov    %edi,%ecx
  803365:	89 d0                	mov    %edx,%eax
  803367:	d3 e8                	shr    %cl,%eax
  803369:	89 e9                	mov    %ebp,%ecx
  80336b:	09 d8                	or     %ebx,%eax
  80336d:	89 d3                	mov    %edx,%ebx
  80336f:	89 f2                	mov    %esi,%edx
  803371:	f7 34 24             	divl   (%esp)
  803374:	89 d6                	mov    %edx,%esi
  803376:	d3 e3                	shl    %cl,%ebx
  803378:	f7 64 24 04          	mull   0x4(%esp)
  80337c:	39 d6                	cmp    %edx,%esi
  80337e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803382:	89 d1                	mov    %edx,%ecx
  803384:	89 c3                	mov    %eax,%ebx
  803386:	72 08                	jb     803390 <__umoddi3+0x110>
  803388:	75 11                	jne    80339b <__umoddi3+0x11b>
  80338a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80338e:	73 0b                	jae    80339b <__umoddi3+0x11b>
  803390:	2b 44 24 04          	sub    0x4(%esp),%eax
  803394:	1b 14 24             	sbb    (%esp),%edx
  803397:	89 d1                	mov    %edx,%ecx
  803399:	89 c3                	mov    %eax,%ebx
  80339b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80339f:	29 da                	sub    %ebx,%edx
  8033a1:	19 ce                	sbb    %ecx,%esi
  8033a3:	89 f9                	mov    %edi,%ecx
  8033a5:	89 f0                	mov    %esi,%eax
  8033a7:	d3 e0                	shl    %cl,%eax
  8033a9:	89 e9                	mov    %ebp,%ecx
  8033ab:	d3 ea                	shr    %cl,%edx
  8033ad:	89 e9                	mov    %ebp,%ecx
  8033af:	d3 ee                	shr    %cl,%esi
  8033b1:	09 d0                	or     %edx,%eax
  8033b3:	89 f2                	mov    %esi,%edx
  8033b5:	83 c4 1c             	add    $0x1c,%esp
  8033b8:	5b                   	pop    %ebx
  8033b9:	5e                   	pop    %esi
  8033ba:	5f                   	pop    %edi
  8033bb:	5d                   	pop    %ebp
  8033bc:	c3                   	ret    
  8033bd:	8d 76 00             	lea    0x0(%esi),%esi
  8033c0:	29 f9                	sub    %edi,%ecx
  8033c2:	19 d6                	sbb    %edx,%esi
  8033c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8033c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8033cc:	e9 18 ff ff ff       	jmp    8032e9 <__umoddi3+0x69>
