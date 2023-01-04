
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
  80002c:	e8 29 1c 00 00       	call   801c5a <libmain>
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
  8000b2:	68 20 3a 80 00       	push   $0x803a20
  8000b7:	e8 d7 1c 00 00       	call   801d93 <cprintf>
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
  8000d4:	68 37 3a 80 00       	push   $0x803a37
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 47 3a 80 00       	push   $0x803a47
  8000e0:	e8 d5 1b 00 00       	call   801cba <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
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
  800106:	68 50 3a 80 00       	push   $0x803a50
  80010b:	68 5d 3a 80 00       	push   $0x803a5d
  800110:	6a 44                	push   $0x44
  800112:	68 47 3a 80 00       	push   $0x803a47
  800117:	e8 9e 1b 00 00       	call   801cba <_panic>

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
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
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
  8001ca:	68 50 3a 80 00       	push   $0x803a50
  8001cf:	68 5d 3a 80 00       	push   $0x803a5d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 47 3a 80 00       	push   $0x803a47
  8001db:	e8 da 1a 00 00       	call   801cba <_panic>

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
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
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
  80029e:	68 74 3a 80 00       	push   $0x803a74
  8002a3:	6a 27                	push   $0x27
  8002a5:	68 50 3b 80 00       	push   $0x803b50
  8002aa:	e8 0b 1a 00 00       	call   801cba <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002af:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 70 04             	cmp    0x4(%eax),%esi
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	56                   	push   %esi
  8002be:	68 a4 3a 80 00       	push   $0x803aa4
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 50 3b 80 00       	push   $0x803b50
  8002ca:	e8 eb 19 00 00       	call   801cba <_panic>
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
  8002df:	e8 37 24 00 00       	call   80271b <sys_page_alloc>
	if (r < 0)
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	79 12                	jns    8002fd <bc_pgfault+0x89>
		panic("bc_pgfault: sys_page_alloc: %e", r);
  8002eb:	50                   	push   %eax
  8002ec:	68 c8 3a 80 00       	push   $0x803ac8
  8002f1:	6a 38                	push   $0x38
  8002f3:	68 50 3b 80 00       	push   $0x803b50
  8002f8:	e8 bd 19 00 00       	call   801cba <_panic>

	r =	ide_read(blockno * (BLKSIZE / SECTSIZE), base_addr, (BLKSIZE / SECTSIZE));
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
  800318:	68 58 3b 80 00       	push   $0x803b58
  80031d:	6a 3c                	push   $0x3c
  80031f:	68 50 3b 80 00       	push   $0x803b50
  800324:	e8 91 19 00 00       	call   801cba <_panic>

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
  800344:	e8 15 24 00 00       	call   80275e <sys_page_map>
  800349:	83 c4 20             	add    $0x20,%esp
  80034c:	85 c0                	test   %eax,%eax
  80034e:	79 12                	jns    800362 <bc_pgfault+0xee>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800350:	50                   	push   %eax
  800351:	68 e8 3a 80 00       	push   $0x803ae8
  800356:	6a 41                	push   $0x41
  800358:	68 50 3b 80 00       	push   $0x803b50
  80035d:	e8 58 19 00 00       	call   801cba <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800362:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800369:	74 22                	je     80038d <bc_pgfault+0x119>
  80036b:	83 ec 0c             	sub    $0xc,%esp
  80036e:	56                   	push   %esi
  80036f:	e8 94 04 00 00       	call   800808 <block_is_free>
  800374:	83 c4 10             	add    $0x10,%esp
  800377:	84 c0                	test   %al,%al
  800379:	74 12                	je     80038d <bc_pgfault+0x119>
		panic("reading free block %08x\n", blockno);
  80037b:	56                   	push   %esi
  80037c:	68 71 3b 80 00       	push   $0x803b71
  800381:	6a 47                	push   $0x47
  800383:	68 50 3b 80 00       	push   $0x803b50
  800388:	e8 2d 19 00 00       	call   801cba <_panic>
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
  8003a2:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003a8:	85 d2                	test   %edx,%edx
  8003aa:	74 17                	je     8003c3 <diskaddr+0x2e>
  8003ac:	3b 42 04             	cmp    0x4(%edx),%eax
  8003af:	72 12                	jb     8003c3 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003b1:	50                   	push   %eax
  8003b2:	68 08 3b 80 00       	push   $0x803b08
  8003b7:	6a 09                	push   $0x9
  8003b9:	68 50 3b 80 00       	push   $0x803b50
  8003be:	e8 f7 18 00 00       	call   801cba <_panic>
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
  800429:	68 8a 3b 80 00       	push   $0x803b8a
  80042e:	6a 57                	push   $0x57
  800430:	68 50 3b 80 00       	push   $0x803b50
  800435:	e8 80 18 00 00       	call   801cba <_panic>

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
  800486:	68 a5 3b 80 00       	push   $0x803ba5
  80048b:	6a 63                	push   $0x63
  80048d:	68 50 3b 80 00       	push   $0x803b50
  800492:	e8 23 18 00 00       	call   801cba <_panic>

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
  8004b0:	e8 a9 22 00 00       	call   80275e <sys_page_map>
	if (r < 0)
  8004b5:	83 c4 20             	add    $0x20,%esp
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	79 12                	jns    8004ce <flush_block+0xbb>
		panic("flush_block: sys_page_map: %e", r);
  8004bc:	50                   	push   %eax
  8004bd:	68 c0 3b 80 00       	push   $0x803bc0
  8004c2:	6a 67                	push   $0x67
  8004c4:	68 50 3b 80 00       	push   $0x803b50
  8004c9:	e8 ec 17 00 00       	call   801cba <_panic>

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
  8004e4:	e8 23 24 00 00       	call   80290c <set_pgfault_handler>
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
  800505:	e8 a0 1f 00 00       	call   8024aa <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80050a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800511:	e8 7f fe ff ff       	call   800395 <diskaddr>
  800516:	83 c4 08             	add    $0x8,%esp
  800519:	68 de 3b 80 00       	push   $0x803bde
  80051e:	50                   	push   %eax
  80051f:	e8 f4 1d 00 00       	call   802318 <strcpy>
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
  800553:	68 00 3c 80 00       	push   $0x803c00
  800558:	68 5d 3a 80 00       	push   $0x803a5d
  80055d:	6a 78                	push   $0x78
  80055f:	68 50 3b 80 00       	push   $0x803b50
  800564:	e8 51 17 00 00       	call   801cba <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	6a 01                	push   $0x1
  80056e:	e8 22 fe ff ff       	call   800395 <diskaddr>
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 80 fe ff ff       	call   8003fb <va_is_dirty>
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	84 c0                	test   %al,%al
  800580:	74 16                	je     800598 <bc_init+0xc3>
  800582:	68 e5 3b 80 00       	push   $0x803be5
  800587:	68 5d 3a 80 00       	push   $0x803a5d
  80058c:	6a 79                	push   $0x79
  80058e:	68 50 3b 80 00       	push   $0x803b50
  800593:	e8 22 17 00 00       	call   801cba <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	6a 01                	push   $0x1
  80059d:	e8 f3 fd ff ff       	call   800395 <diskaddr>
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	50                   	push   %eax
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 f3 21 00 00       	call   8027a0 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b4:	e8 dc fd ff ff       	call   800395 <diskaddr>
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	e8 0c fe ff ff       	call   8003cd <va_is_mapped>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	84 c0                	test   %al,%al
  8005c6:	74 16                	je     8005de <bc_init+0x109>
  8005c8:	68 ff 3b 80 00       	push   $0x803bff
  8005cd:	68 5d 3a 80 00       	push   $0x803a5d
  8005d2:	6a 7d                	push   $0x7d
  8005d4:	68 50 3b 80 00       	push   $0x803b50
  8005d9:	e8 dc 16 00 00       	call   801cba <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	6a 01                	push   $0x1
  8005e3:	e8 ad fd ff ff       	call   800395 <diskaddr>
  8005e8:	83 c4 08             	add    $0x8,%esp
  8005eb:	68 de 3b 80 00       	push   $0x803bde
  8005f0:	50                   	push   %eax
  8005f1:	e8 cc 1d 00 00       	call   8023c2 <strcmp>
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	74 19                	je     800616 <bc_init+0x141>
  8005fd:	68 2c 3b 80 00       	push   $0x803b2c
  800602:	68 5d 3a 80 00       	push   $0x803a5d
  800607:	68 80 00 00 00       	push   $0x80
  80060c:	68 50 3b 80 00       	push   $0x803b50
  800611:	e8 a4 16 00 00       	call   801cba <_panic>

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
  800630:	e8 75 1e 00 00       	call   8024aa <memmove>
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
  80065f:	e8 46 1e 00 00       	call   8024aa <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066b:	e8 25 fd ff ff       	call   800395 <diskaddr>
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	68 de 3b 80 00       	push   $0x803bde
  800678:	50                   	push   %eax
  800679:	e8 9a 1c 00 00       	call   802318 <strcpy>

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
  8006b0:	68 00 3c 80 00       	push   $0x803c00
  8006b5:	68 5d 3a 80 00       	push   $0x803a5d
  8006ba:	68 91 00 00 00       	push   $0x91
  8006bf:	68 50 3b 80 00       	push   $0x803b50
  8006c4:	e8 f1 15 00 00       	call   801cba <_panic>
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
  8006d9:	e8 c2 20 00 00       	call   8027a0 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e5:	e8 ab fc ff ff       	call   800395 <diskaddr>
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	e8 db fc ff ff       	call   8003cd <va_is_mapped>
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	84 c0                	test   %al,%al
  8006f7:	74 19                	je     800712 <bc_init+0x23d>
  8006f9:	68 ff 3b 80 00       	push   $0x803bff
  8006fe:	68 5d 3a 80 00       	push   $0x803a5d
  800703:	68 99 00 00 00       	push   $0x99
  800708:	68 50 3b 80 00       	push   $0x803b50
  80070d:	e8 a8 15 00 00       	call   801cba <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800712:	83 ec 0c             	sub    $0xc,%esp
  800715:	6a 01                	push   $0x1
  800717:	e8 79 fc ff ff       	call   800395 <diskaddr>
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	68 de 3b 80 00       	push   $0x803bde
  800724:	50                   	push   %eax
  800725:	e8 98 1c 00 00       	call   8023c2 <strcmp>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 19                	je     80074a <bc_init+0x275>
  800731:	68 2c 3b 80 00       	push   $0x803b2c
  800736:	68 5d 3a 80 00       	push   $0x803a5d
  80073b:	68 9c 00 00 00       	push   $0x9c
  800740:	68 50 3b 80 00       	push   $0x803b50
  800745:	e8 70 15 00 00       	call   801cba <_panic>

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
  800764:	e8 41 1d 00 00       	call   8024aa <memmove>
	flush_block(diskaddr(1));
  800769:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800770:	e8 20 fc ff ff       	call   800395 <diskaddr>
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 96 fc ff ff       	call   800413 <flush_block>

	cprintf("block cache is good\n");
  80077d:	c7 04 24 1a 3c 80 00 	movl   $0x803c1a,(%esp)
  800784:	e8 0a 16 00 00       	call   801d93 <cprintf>
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
  8007a5:	e8 00 1d 00 00       	call   8024aa <memmove>
}
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8007b8:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007bd:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007c3:	74 14                	je     8007d9 <check_super+0x27>
		panic("bad file system magic number");
  8007c5:	83 ec 04             	sub    $0x4,%esp
  8007c8:	68 2f 3c 80 00       	push   $0x803c2f
  8007cd:	6a 0f                	push   $0xf
  8007cf:	68 4c 3c 80 00       	push   $0x803c4c
  8007d4:	e8 e1 14 00 00       	call   801cba <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007d9:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007e0:	76 14                	jbe    8007f6 <check_super+0x44>
		panic("file system is too large");
  8007e2:	83 ec 04             	sub    $0x4,%esp
  8007e5:	68 54 3c 80 00       	push   $0x803c54
  8007ea:	6a 12                	push   $0x12
  8007ec:	68 4c 3c 80 00       	push   $0x803c4c
  8007f1:	e8 c4 14 00 00       	call   801cba <_panic>

	cprintf("superblock is good\n");
  8007f6:	83 ec 0c             	sub    $0xc,%esp
  8007f9:	68 6d 3c 80 00       	push   $0x803c6d
  8007fe:	e8 90 15 00 00       	call   801d93 <cprintf>
}
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80080f:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800815:	85 d2                	test   %edx,%edx
  800817:	74 24                	je     80083d <block_is_free+0x35>
		return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  80081e:	39 4a 04             	cmp    %ecx,0x4(%edx)
  800821:	76 1f                	jbe    800842 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  800823:	89 cb                	mov    %ecx,%ebx
  800825:	c1 eb 05             	shr    $0x5,%ebx
  800828:	b8 01 00 00 00       	mov    $0x1,%eax
  80082d:	d3 e0                	shl    %cl,%eax
  80082f:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800835:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800838:	0f 95 c0             	setne  %al
  80083b:	eb 05                	jmp    800842 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	83 ec 04             	sub    $0x4,%esp
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80084f:	85 c9                	test   %ecx,%ecx
  800851:	75 14                	jne    800867 <free_block+0x22>
		panic("attempt to free zero block");
  800853:	83 ec 04             	sub    $0x4,%esp
  800856:	68 81 3c 80 00       	push   $0x803c81
  80085b:	6a 2d                	push   $0x2d
  80085d:	68 4c 3c 80 00       	push   $0x803c4c
  800862:	e8 53 14 00 00       	call   801cba <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800867:	89 cb                	mov    %ecx,%ebx
  800869:	c1 eb 05             	shr    $0x5,%ebx
  80086c:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800872:	b8 01 00 00 00       	mov    $0x1,%eax
  800877:	d3 e0                	shl    %cl,%eax
  800879:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  80087c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087f:	c9                   	leave  
  800880:	c3                   	ret    

00800881 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	56                   	push   %esi
  800885:	53                   	push   %ebx
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	// panic("alloc_block not implemented");

	for (int i=1; i<super->s_nblocks; i++) {
  800886:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80088b:	8b 70 04             	mov    0x4(%eax),%esi
  80088e:	bb 01 00 00 00       	mov    $0x1,%ebx
  800893:	eb 55                	jmp    8008ea <alloc_block+0x69>
		
		// find a free block
		if (block_is_free(i)) {
  800895:	53                   	push   %ebx
  800896:	e8 6d ff ff ff       	call   800808 <block_is_free>
  80089b:	83 c4 04             	add    $0x4,%esp
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 45                	je     8008e7 <alloc_block+0x66>

			// mark as used in bitmap
			bitmap[i/32] ^= (1<<(i%32));
  8008a2:	8d 43 1f             	lea    0x1f(%ebx),%eax
  8008a5:	85 db                	test   %ebx,%ebx
  8008a7:	0f 49 c3             	cmovns %ebx,%eax
  8008aa:	c1 f8 05             	sar    $0x5,%eax
  8008ad:	c1 e0 02             	shl    $0x2,%eax
  8008b0:	89 c2                	mov    %eax,%edx
  8008b2:	03 15 04 a0 80 00    	add    0x80a004,%edx
  8008b8:	89 de                	mov    %ebx,%esi
  8008ba:	c1 fe 1f             	sar    $0x1f,%esi
  8008bd:	c1 ee 1b             	shr    $0x1b,%esi
  8008c0:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
  8008c3:	83 e1 1f             	and    $0x1f,%ecx
  8008c6:	29 f1                	sub    %esi,%ecx
  8008c8:	be 01 00 00 00       	mov    $0x1,%esi
  8008cd:	d3 e6                	shl    %cl,%esi
  8008cf:	31 32                	xor    %esi,(%edx)
	
			// flush to disk
			flush_block(&bitmap[i/32]);
  8008d1:	83 ec 0c             	sub    $0xc,%esp
  8008d4:	03 05 04 a0 80 00    	add    0x80a004,%eax
  8008da:	50                   	push   %eax
  8008db:	e8 33 fb ff ff       	call   800413 <flush_block>

			return i;
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	89 d8                	mov    %ebx,%eax
  8008e5:	eb 0c                	jmp    8008f3 <alloc_block+0x72>
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	// panic("alloc_block not implemented");

	for (int i=1; i<super->s_nblocks; i++) {
  8008e7:	83 c3 01             	add    $0x1,%ebx
  8008ea:	39 de                	cmp    %ebx,%esi
  8008ec:	77 a7                	ja     800895 <alloc_block+0x14>

			return i;
		}
	}

	return -E_NO_DISK;
  8008ee:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	83 ec 1c             	sub    $0x1c,%esp
  800903:	8b 7d 08             	mov    0x8(%ebp),%edi
  800906:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	// LAB 5: Your code here.
    //    panic("file_block_walk not implemented");

	if (filebno >= NDIRECT + NINDIRECT)
  800909:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80090f:	0f 87 ec 00 00 00    	ja     800a01 <file_block_walk+0x107>
  800915:	89 ce                	mov    %ecx,%esi
  800917:	89 d3                	mov    %edx,%ebx
  800919:	89 c7                	mov    %eax,%edi
		return -E_INVAL;

	// direct block
	if (filebno < NDIRECT) {
  80091b:	83 fa 09             	cmp    $0x9,%edx
  80091e:	77 2c                	ja     80094c <file_block_walk+0x52>
		if (ppdiskbno != 0)
  800920:	85 c9                	test   %ecx,%ecx
  800922:	74 09                	je     80092d <file_block_walk+0x33>
			*ppdiskbno = &f->f_direct[filebno];
  800924:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  80092b:	89 01                	mov    %eax,(%ecx)
		
		cprintf("[?] 0x%x, 0x%x -->\n", *ppdiskbno, **ppdiskbno);
  80092d:	8b 06                	mov    (%esi),%eax
  80092f:	83 ec 04             	sub    $0x4,%esp
  800932:	ff 30                	pushl  (%eax)
  800934:	50                   	push   %eax
  800935:	68 9c 3c 80 00       	push   $0x803c9c
  80093a:	e8 54 14 00 00       	call   801d93 <cprintf>
		return 0;
  80093f:	83 c4 10             	add    $0x10,%esp
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
  800947:	e9 c1 00 00 00       	jmp    800a0d <file_block_walk+0x113>
	}

	// indirect block, allocated
	if (f->f_indirect != 0) {
  80094c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  800952:	85 c0                	test   %eax,%eax
  800954:	74 3c                	je     800992 <file_block_walk+0x98>
		if (ppdiskbno != 0)
  800956:	85 c9                	test   %ecx,%ecx
  800958:	74 12                	je     80096c <file_block_walk+0x72>
			*ppdiskbno = (uint32_t *)(diskaddr(f->f_indirect + filebno - NDIRECT));
  80095a:	83 ec 0c             	sub    $0xc,%esp
  80095d:	8d 44 10 f6          	lea    -0xa(%eax,%edx,1),%eax
  800961:	50                   	push   %eax
  800962:	e8 2e fa ff ff       	call   800395 <diskaddr>
  800967:	89 06                	mov    %eax,(%esi)
  800969:	83 c4 10             	add    $0x10,%esp
		cprintf("[?] 0x%x, 0x%x, 0x%x, 0x%x -->\n", f->f_indirect, filebno - NDIRECT, *ppdiskbno, **ppdiskbno);
  80096c:	8b 06                	mov    (%esi),%eax
  80096e:	83 ec 0c             	sub    $0xc,%esp
  800971:	ff 30                	pushl  (%eax)
  800973:	50                   	push   %eax
  800974:	83 eb 0a             	sub    $0xa,%ebx
  800977:	53                   	push   %ebx
  800978:	ff b7 b0 00 00 00    	pushl  0xb0(%edi)
  80097e:	68 4c 3d 80 00       	push   $0x803d4c
  800983:	e8 0b 14 00 00       	call   801d93 <cprintf>
		return 0;
  800988:	83 c4 20             	add    $0x20,%esp
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
  800990:	eb 7b                	jmp    800a0d <file_block_walk+0x113>
	}
	else {

		// not allocated
		if (alloc == 0)
  800992:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
  800996:	74 70                	je     800a08 <file_block_walk+0x10e>
			return -E_NOT_FOUND;
		
		int blockno = alloc_block();
  800998:	e8 e4 fe ff ff       	call   800881 <alloc_block>

		if (blockno < 0)
  80099d:	85 c0                	test   %eax,%eax
  80099f:	78 6c                	js     800a0d <file_block_walk+0x113>
			return blockno; // E_NO_DISK

		// cprintf("[?] %d\n", blockno);
		
		f->f_indirect = blockno;
  8009a1:	89 87 b0 00 00 00    	mov    %eax,0xb0(%edi)

		// flush to disk
		memset(diskaddr(blockno), 0, BLKSIZE);
  8009a7:	83 ec 0c             	sub    $0xc,%esp
  8009aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009ad:	50                   	push   %eax
  8009ae:	e8 e2 f9 ff ff       	call   800395 <diskaddr>
  8009b3:	83 c4 0c             	add    $0xc,%esp
  8009b6:	68 00 10 00 00       	push   $0x1000
  8009bb:	6a 00                	push   $0x0
  8009bd:	50                   	push   %eax
  8009be:	e8 9a 1a 00 00       	call   80245d <memset>
		flush_block(diskaddr(blockno));
  8009c3:	83 c4 04             	add    $0x4,%esp
  8009c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009c9:	e8 c7 f9 ff ff       	call   800395 <diskaddr>
  8009ce:	89 04 24             	mov    %eax,(%esp)
  8009d1:	e8 3d fa ff ff       	call   800413 <flush_block>

		if (ppdiskbno != 0)
  8009d6:	83 c4 10             	add    $0x10,%esp
			*ppdiskbno = (uint32_t *)(diskaddr(f->f_indirect + filebno - NDIRECT));
		return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax

		// flush to disk
		memset(diskaddr(blockno), 0, BLKSIZE);
		flush_block(diskaddr(blockno));

		if (ppdiskbno != 0)
  8009de:	85 f6                	test   %esi,%esi
  8009e0:	74 2b                	je     800a0d <file_block_walk+0x113>
			*ppdiskbno = (uint32_t *)(diskaddr(f->f_indirect + filebno - NDIRECT));
  8009e2:	83 ec 0c             	sub    $0xc,%esp
  8009e5:	8b 87 b0 00 00 00    	mov    0xb0(%edi),%eax
  8009eb:	8d 44 03 f6          	lea    -0xa(%ebx,%eax,1),%eax
  8009ef:	50                   	push   %eax
  8009f0:	e8 a0 f9 ff ff       	call   800395 <diskaddr>
  8009f5:	89 06                	mov    %eax,(%esi)
  8009f7:	83 c4 10             	add    $0x10,%esp
		return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	eb 0c                	jmp    800a0d <file_block_walk+0x113>
{
	// LAB 5: Your code here.
    //    panic("file_block_walk not implemented");

	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800a01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a06:	eb 05                	jmp    800a0d <file_block_walk+0x113>
	}
	else {

		// not allocated
		if (alloc == 0)
			return -E_NOT_FOUND;
  800a08:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
		if (ppdiskbno != 0)
			*ppdiskbno = (uint32_t *)(diskaddr(f->f_indirect + filebno - NDIRECT));
		return 0;
	}

}
  800a0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5f                   	pop    %edi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a1a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800a1f:	8b 70 04             	mov    0x4(%eax),%esi
  800a22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a27:	eb 29                	jmp    800a52 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800a29:	8d 43 02             	lea    0x2(%ebx),%eax
  800a2c:	50                   	push   %eax
  800a2d:	e8 d6 fd ff ff       	call   800808 <block_is_free>
  800a32:	83 c4 04             	add    $0x4,%esp
  800a35:	84 c0                	test   %al,%al
  800a37:	74 16                	je     800a4f <check_bitmap+0x3a>
  800a39:	68 b0 3c 80 00       	push   $0x803cb0
  800a3e:	68 5d 3a 80 00       	push   $0x803a5d
  800a43:	6a 60                	push   $0x60
  800a45:	68 4c 3c 80 00       	push   $0x803c4c
  800a4a:	e8 6b 12 00 00       	call   801cba <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a4f:	83 c3 01             	add    $0x1,%ebx
  800a52:	89 d8                	mov    %ebx,%eax
  800a54:	c1 e0 0f             	shl    $0xf,%eax
  800a57:	39 f0                	cmp    %esi,%eax
  800a59:	72 ce                	jb     800a29 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800a5b:	83 ec 0c             	sub    $0xc,%esp
  800a5e:	6a 00                	push   $0x0
  800a60:	e8 a3 fd ff ff       	call   800808 <block_is_free>
  800a65:	83 c4 10             	add    $0x10,%esp
  800a68:	84 c0                	test   %al,%al
  800a6a:	74 16                	je     800a82 <check_bitmap+0x6d>
  800a6c:	68 c4 3c 80 00       	push   $0x803cc4
  800a71:	68 5d 3a 80 00       	push   $0x803a5d
  800a76:	6a 63                	push   $0x63
  800a78:	68 4c 3c 80 00       	push   $0x803c4c
  800a7d:	e8 38 12 00 00       	call   801cba <_panic>
	assert(!block_is_free(1));
  800a82:	83 ec 0c             	sub    $0xc,%esp
  800a85:	6a 01                	push   $0x1
  800a87:	e8 7c fd ff ff       	call   800808 <block_is_free>
  800a8c:	83 c4 10             	add    $0x10,%esp
  800a8f:	84 c0                	test   %al,%al
  800a91:	74 16                	je     800aa9 <check_bitmap+0x94>
  800a93:	68 d6 3c 80 00       	push   $0x803cd6
  800a98:	68 5d 3a 80 00       	push   $0x803a5d
  800a9d:	6a 64                	push   $0x64
  800a9f:	68 4c 3c 80 00       	push   $0x803c4c
  800aa4:	e8 11 12 00 00       	call   801cba <_panic>

	cprintf("bitmap is good\n");
  800aa9:	83 ec 0c             	sub    $0xc,%esp
  800aac:	68 e8 3c 80 00       	push   $0x803ce8
  800ab1:	e8 dd 12 00 00       	call   801d93 <cprintf>
}
  800ab6:	83 c4 10             	add    $0x10,%esp
  800ab9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800ac6:	e8 94 f5 ff ff       	call   80005f <ide_probe_disk1>
  800acb:	84 c0                	test   %al,%al
  800acd:	74 0f                	je     800ade <fs_init+0x1e>
		ide_set_disk(1);
  800acf:	83 ec 0c             	sub    $0xc,%esp
  800ad2:	6a 01                	push   $0x1
  800ad4:	e8 ea f5 ff ff       	call   8000c3 <ide_set_disk>
  800ad9:	83 c4 10             	add    $0x10,%esp
  800adc:	eb 0d                	jmp    800aeb <fs_init+0x2b>
	else
		ide_set_disk(0);
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	6a 00                	push   $0x0
  800ae3:	e8 db f5 ff ff       	call   8000c3 <ide_set_disk>
  800ae8:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800aeb:	e8 e5 f9 ff ff       	call   8004d5 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	6a 01                	push   $0x1
  800af5:	e8 9b f8 ff ff       	call   800395 <diskaddr>
  800afa:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800aff:	e8 ae fc ff ff       	call   8007b2 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800b04:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b0b:	e8 85 f8 ff ff       	call   800395 <diskaddr>
  800b10:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800b15:	e8 fb fe ff ff       	call   800a15 <check_bitmap>
	
}
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	53                   	push   %ebx
  800b23:	83 ec 20             	sub    $0x20,%esp
    //    panic("file_get_block not implemented");

	uint32_t *ptr;
	int blockno = 0;

	int r = file_block_walk(f, filebno, &ptr, 1);
  800b26:	6a 01                	push   $0x1
  800b28:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	e8 c4 fd ff ff       	call   8008fa <file_block_walk>
	if (r < 0)
  800b36:	83 c4 10             	add    $0x10,%esp
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	0f 88 85 00 00 00    	js     800bc6 <file_get_block+0xa7>
		return r;
	cprintf("[?] 0x%x -> \n", *ptr);
  800b41:	83 ec 08             	sub    $0x8,%esp
  800b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b47:	ff 30                	pushl  (%eax)
  800b49:	68 f8 3c 80 00       	push   $0x803cf8
  800b4e:	e8 40 12 00 00       	call   801d93 <cprintf>
	// not allocated yet
	if (*ptr == 0) {
  800b53:	83 c4 10             	add    $0x10,%esp
  800b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b59:	83 38 00             	cmpl   $0x0,(%eax)
  800b5c:	75 3c                	jne    800b9a <file_get_block+0x7b>
		
		blockno = alloc_block();
  800b5e:	e8 1e fd ff ff       	call   800881 <alloc_block>
  800b63:	89 c3                	mov    %eax,%ebx

		// cprintf("[?] %d\n", blockno);

		if (blockno < 0)
  800b65:	85 c0                	test   %eax,%eax
  800b67:	78 5d                	js     800bc6 <file_get_block+0xa7>
			return blockno;
		
		*ptr = blockno;
  800b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b6c:	89 18                	mov    %ebx,(%eax)

		// flush to disk
		memset(diskaddr(blockno), 0, BLKSIZE);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	53                   	push   %ebx
  800b72:	e8 1e f8 ff ff       	call   800395 <diskaddr>
  800b77:	83 c4 0c             	add    $0xc,%esp
  800b7a:	68 00 10 00 00       	push   $0x1000
  800b7f:	6a 00                	push   $0x0
  800b81:	50                   	push   %eax
  800b82:	e8 d6 18 00 00       	call   80245d <memset>
		flush_block(diskaddr(blockno));
  800b87:	89 1c 24             	mov    %ebx,(%esp)
  800b8a:	e8 06 f8 ff ff       	call   800395 <diskaddr>
  800b8f:	89 04 24             	mov    %eax,(%esp)
  800b92:	e8 7c f8 ff ff       	call   800413 <flush_block>
  800b97:	83 c4 10             	add    $0x10,%esp
	}

	cprintf("[?] 0x%x\n", *ptr);
  800b9a:	83 ec 08             	sub    $0x8,%esp
  800b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ba0:	ff 30                	pushl  (%eax)
  800ba2:	68 06 3d 80 00       	push   $0x803d06
  800ba7:	e8 e7 11 00 00       	call   801d93 <cprintf>

	*blk = diskaddr(*ptr);
  800bac:	83 c4 04             	add    $0x4,%esp
  800baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bb2:	ff 30                	pushl  (%eax)
  800bb4:	e8 dc f7 ff ff       	call   800395 <diskaddr>
  800bb9:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbc:	89 02                	mov    %eax,(%edx)
	return 0;
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax

}
  800bc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800bd7:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800bdd:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800be3:	eb 03                	jmp    800be8 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800be5:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800be8:	80 38 2f             	cmpb   $0x2f,(%eax)
  800beb:	74 f8                	je     800be5 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800bed:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800bf3:	83 c1 08             	add    $0x8,%ecx
  800bf6:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800bfc:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800c03:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800c09:	85 c9                	test   %ecx,%ecx
  800c0b:	74 06                	je     800c13 <walk_path+0x48>
		*pdir = 0;
  800c0d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800c13:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800c19:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800c24:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800c2a:	e9 5f 01 00 00       	jmp    800d8e <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800c2f:	83 c7 01             	add    $0x1,%edi
  800c32:	eb 02                	jmp    800c36 <walk_path+0x6b>
  800c34:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800c36:	0f b6 17             	movzbl (%edi),%edx
  800c39:	80 fa 2f             	cmp    $0x2f,%dl
  800c3c:	74 04                	je     800c42 <walk_path+0x77>
  800c3e:	84 d2                	test   %dl,%dl
  800c40:	75 ed                	jne    800c2f <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800c42:	89 fb                	mov    %edi,%ebx
  800c44:	29 c3                	sub    %eax,%ebx
  800c46:	83 fb 7f             	cmp    $0x7f,%ebx
  800c49:	0f 8f 69 01 00 00    	jg     800db8 <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800c4f:	83 ec 04             	sub    $0x4,%esp
  800c52:	53                   	push   %ebx
  800c53:	50                   	push   %eax
  800c54:	56                   	push   %esi
  800c55:	e8 50 18 00 00       	call   8024aa <memmove>
		name[path - p] = '\0';
  800c5a:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800c61:	00 
  800c62:	83 c4 10             	add    $0x10,%esp
  800c65:	eb 03                	jmp    800c6a <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800c67:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800c6a:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800c6d:	74 f8                	je     800c67 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800c6f:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800c75:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c7c:	0f 85 3d 01 00 00    	jne    800dbf <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800c82:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800c88:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800c8d:	74 19                	je     800ca8 <walk_path+0xdd>
  800c8f:	68 10 3d 80 00       	push   $0x803d10
  800c94:	68 5d 3a 80 00       	push   $0x803a5d
  800c99:	68 05 01 00 00       	push   $0x105
  800c9e:	68 4c 3c 80 00       	push   $0x803c4c
  800ca3:	e8 12 10 00 00       	call   801cba <_panic>
	nblock = dir->f_size / BLKSIZE;
  800ca8:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	0f 48 c2             	cmovs  %edx,%eax
  800cb3:	c1 f8 0c             	sar    $0xc,%eax
  800cb6:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800cbc:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800cc3:	00 00 00 
  800cc6:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800ccc:	eb 5e                	jmp    800d2c <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800cce:	83 ec 04             	sub    $0x4,%esp
  800cd1:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800cd7:	50                   	push   %eax
  800cd8:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800cde:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800ce4:	e8 36 fe ff ff       	call   800b1f <file_get_block>
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	85 c0                	test   %eax,%eax
  800cee:	0f 88 ee 00 00 00    	js     800de2 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800cf4:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800cfa:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800d00:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800d06:	83 ec 08             	sub    $0x8,%esp
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	e8 b2 16 00 00       	call   8023c2 <strcmp>
  800d10:	83 c4 10             	add    $0x10,%esp
  800d13:	85 c0                	test   %eax,%eax
  800d15:	0f 84 ab 00 00 00    	je     800dc6 <walk_path+0x1fb>
  800d1b:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800d21:	39 fb                	cmp    %edi,%ebx
  800d23:	75 db                	jne    800d00 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800d25:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800d2c:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800d32:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800d38:	75 94                	jne    800cce <walk_path+0x103>
  800d3a:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800d40:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d45:	80 3f 00             	cmpb   $0x0,(%edi)
  800d48:	0f 85 a3 00 00 00    	jne    800df1 <walk_path+0x226>
				if (pdir)
  800d4e:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d54:	85 c0                	test   %eax,%eax
  800d56:	74 08                	je     800d60 <walk_path+0x195>
					*pdir = dir;
  800d58:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d5e:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800d60:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800d64:	74 15                	je     800d7b <walk_path+0x1b0>
					strcpy(lastelem, name);
  800d66:	83 ec 08             	sub    $0x8,%esp
  800d69:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800d6f:	50                   	push   %eax
  800d70:	ff 75 08             	pushl  0x8(%ebp)
  800d73:	e8 a0 15 00 00       	call   802318 <strcpy>
  800d78:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800d7b:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d81:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800d87:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d8c:	eb 63                	jmp    800df1 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800d8e:	80 38 00             	cmpb   $0x0,(%eax)
  800d91:	0f 85 9d fe ff ff    	jne    800c34 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800d97:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	74 02                	je     800da3 <walk_path+0x1d8>
		*pdir = dir;
  800da1:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800da3:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800da9:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800daf:	89 08                	mov    %ecx,(%eax)
	return 0;
  800db1:	b8 00 00 00 00       	mov    $0x0,%eax
  800db6:	eb 39                	jmp    800df1 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800db8:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800dbd:	eb 32                	jmp    800df1 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800dbf:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800dc4:	eb 2b                	jmp    800df1 <walk_path+0x226>
  800dc6:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800dcc:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800dd2:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800dd8:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800dde:	89 f8                	mov    %edi,%eax
  800de0:	eb ac                	jmp    800d8e <walk_path+0x1c3>
  800de2:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800de8:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800deb:	0f 84 4f ff ff ff    	je     800d40 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800df1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800dff:	6a 00                	push   $0x0
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	ba 00 00 00 00       	mov    $0x0,%edx
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0c:	e8 ba fd ff ff       	call   800bcb <walk_path>
}
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 2c             	sub    $0x2c,%esp
  800e1c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e1f:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800e30:	39 ca                	cmp    %ecx,%edx
  800e32:	7e 7c                	jle    800eb0 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800e34:	29 ca                	sub    %ecx,%edx
  800e36:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e39:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800e3d:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800e40:	89 ce                	mov    %ecx,%esi
  800e42:	01 d1                	add    %edx,%ecx
  800e44:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800e47:	eb 5d                	jmp    800ea6 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800e49:	83 ec 04             	sub    $0x4,%esp
  800e4c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e4f:	50                   	push   %eax
  800e50:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800e56:	85 f6                	test   %esi,%esi
  800e58:	0f 49 c6             	cmovns %esi,%eax
  800e5b:	c1 f8 0c             	sar    $0xc,%eax
  800e5e:	50                   	push   %eax
  800e5f:	ff 75 08             	pushl  0x8(%ebp)
  800e62:	e8 b8 fc ff ff       	call   800b1f <file_get_block>
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	78 42                	js     800eb0 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e6e:	89 f2                	mov    %esi,%edx
  800e70:	c1 fa 1f             	sar    $0x1f,%edx
  800e73:	c1 ea 14             	shr    $0x14,%edx
  800e76:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e79:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e7e:	29 d0                	sub    %edx,%eax
  800e80:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e83:	29 da                	sub    %ebx,%edx
  800e85:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800e8a:	29 c3                	sub    %eax,%ebx
  800e8c:	39 da                	cmp    %ebx,%edx
  800e8e:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	53                   	push   %ebx
  800e95:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e98:	50                   	push   %eax
  800e99:	57                   	push   %edi
  800e9a:	e8 0b 16 00 00       	call   8024aa <memmove>
		pos += bn;
  800e9f:	01 de                	add    %ebx,%esi
		buf += bn;
  800ea1:	01 df                	add    %ebx,%edi
  800ea3:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800ea6:	89 f3                	mov    %esi,%ebx
  800ea8:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800eab:	77 9c                	ja     800e49 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800ead:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800eb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
  800ebe:	83 ec 2c             	sub    $0x2c,%esp
  800ec1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800ec4:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800eca:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800ecd:	0f 8e a7 00 00 00    	jle    800f7a <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800ed3:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800ed9:	05 ff 0f 00 00       	add    $0xfff,%eax
  800ede:	0f 49 f8             	cmovns %eax,%edi
  800ee1:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee7:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800eec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eef:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800ef5:	0f 49 c2             	cmovns %edx,%eax
  800ef8:	c1 f8 0c             	sar    $0xc,%eax
  800efb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800efe:	89 c3                	mov    %eax,%ebx
  800f00:	eb 39                	jmp    800f3b <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800f02:	83 ec 0c             	sub    $0xc,%esp
  800f05:	6a 00                	push   $0x0
  800f07:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800f0a:	89 da                	mov    %ebx,%edx
  800f0c:	89 f0                	mov    %esi,%eax
  800f0e:	e8 e7 f9 ff ff       	call   8008fa <file_block_walk>
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	78 4d                	js     800f67 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800f1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1d:	8b 00                	mov    (%eax),%eax
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	74 15                	je     800f38 <file_set_size+0x80>
		free_block(*ptr);
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	50                   	push   %eax
  800f27:	e8 19 f9 ff ff       	call   800845 <free_block>
		*ptr = 0;
  800f2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f2f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800f35:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800f38:	83 c3 01             	add    $0x1,%ebx
  800f3b:	39 df                	cmp    %ebx,%edi
  800f3d:	77 c3                	ja     800f02 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800f3f:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800f43:	77 35                	ja     800f7a <file_set_size+0xc2>
  800f45:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	74 2b                	je     800f7a <file_set_size+0xc2>
		free_block(f->f_indirect);
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	50                   	push   %eax
  800f53:	e8 ed f8 ff ff       	call   800845 <free_block>
		f->f_indirect = 0;
  800f58:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800f5f:	00 00 00 
  800f62:	83 c4 10             	add    $0x10,%esp
  800f65:	eb 13                	jmp    800f7a <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800f67:	83 ec 08             	sub    $0x8,%esp
  800f6a:	50                   	push   %eax
  800f6b:	68 2d 3d 80 00       	push   $0x803d2d
  800f70:	e8 1e 0e 00 00       	call   801d93 <cprintf>
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	eb be                	jmp    800f38 <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	56                   	push   %esi
  800f87:	e8 87 f4 ff ff       	call   800413 <flush_block>
	return 0;
}
  800f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 2c             	sub    $0x2c,%esp
  800fa2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fa5:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800fa8:	89 f0                	mov    %esi,%eax
  800faa:	03 45 10             	add    0x10(%ebp),%eax
  800fad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800fb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb3:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800fb9:	76 72                	jbe    80102d <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	50                   	push   %eax
  800fbf:	51                   	push   %ecx
  800fc0:	e8 f3 fe ff ff       	call   800eb8 <file_set_size>
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	79 61                	jns    80102d <file_write+0x94>
  800fcc:	eb 69                	jmp    801037 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800fce:	83 ec 04             	sub    $0x4,%esp
  800fd1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd4:	50                   	push   %eax
  800fd5:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800fdb:	85 f6                	test   %esi,%esi
  800fdd:	0f 49 c6             	cmovns %esi,%eax
  800fe0:	c1 f8 0c             	sar    $0xc,%eax
  800fe3:	50                   	push   %eax
  800fe4:	ff 75 08             	pushl  0x8(%ebp)
  800fe7:	e8 33 fb ff ff       	call   800b1f <file_get_block>
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 44                	js     801037 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	c1 fa 1f             	sar    $0x1f,%edx
  800ff8:	c1 ea 14             	shr    $0x14,%edx
  800ffb:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800ffe:	25 ff 0f 00 00       	and    $0xfff,%eax
  801003:	29 d0                	sub    %edx,%eax
  801005:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801008:	29 d9                	sub    %ebx,%ecx
  80100a:	89 cb                	mov    %ecx,%ebx
  80100c:	ba 00 10 00 00       	mov    $0x1000,%edx
  801011:	29 c2                	sub    %eax,%edx
  801013:	39 d1                	cmp    %edx,%ecx
  801015:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	53                   	push   %ebx
  80101c:	57                   	push   %edi
  80101d:	03 45 e4             	add    -0x1c(%ebp),%eax
  801020:	50                   	push   %eax
  801021:	e8 84 14 00 00       	call   8024aa <memmove>
		pos += bn;
  801026:	01 de                	add    %ebx,%esi
		buf += bn;
  801028:	01 df                	add    %ebx,%edi
  80102a:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  80102d:	89 f3                	mov    %esi,%ebx
  80102f:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  801032:	77 9a                	ja     800fce <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  801034:	8b 45 10             	mov    0x10(%ebp),%eax
}
  801037:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103a:	5b                   	pop    %ebx
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
  801044:	83 ec 10             	sub    $0x10,%esp
  801047:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  80104a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104f:	eb 3c                	jmp    80108d <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	6a 00                	push   $0x0
  801056:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  801059:	89 da                	mov    %ebx,%edx
  80105b:	89 f0                	mov    %esi,%eax
  80105d:	e8 98 f8 ff ff       	call   8008fa <file_block_walk>
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	78 21                	js     80108a <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  801069:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80106c:	85 c0                	test   %eax,%eax
  80106e:	74 1a                	je     80108a <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  801070:	8b 00                	mov    (%eax),%eax
  801072:	85 c0                	test   %eax,%eax
  801074:	74 14                	je     80108a <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	50                   	push   %eax
  80107a:	e8 16 f3 ff ff       	call   800395 <diskaddr>
  80107f:	89 04 24             	mov    %eax,(%esp)
  801082:	e8 8c f3 ff ff       	call   800413 <flush_block>
  801087:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  80108a:	83 c3 01             	add    $0x1,%ebx
  80108d:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  801093:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  801099:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  80109f:	85 c9                	test   %ecx,%ecx
  8010a1:	0f 49 c1             	cmovns %ecx,%eax
  8010a4:	c1 f8 0c             	sar    $0xc,%eax
  8010a7:	39 c3                	cmp    %eax,%ebx
  8010a9:	7c a6                	jl     801051 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	56                   	push   %esi
  8010af:	e8 5f f3 ff ff       	call   800413 <flush_block>
	if (f->f_indirect)
  8010b4:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	74 14                	je     8010d5 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	50                   	push   %eax
  8010c5:	e8 cb f2 ff ff       	call   800395 <diskaddr>
  8010ca:	89 04 24             	mov    %eax,(%esp)
  8010cd:	e8 41 f3 ff ff       	call   800413 <flush_block>
  8010d2:	83 c4 10             	add    $0x10,%esp
}
  8010d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  8010e8:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8010ee:	50                   	push   %eax
  8010ef:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  8010f5:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	e8 c8 fa ff ff       	call   800bcb <walk_path>
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	85 c0                	test   %eax,%eax
  801108:	0f 84 d1 00 00 00    	je     8011df <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  80110e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801111:	0f 85 0c 01 00 00    	jne    801223 <file_create+0x147>
  801117:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  80111d:	85 f6                	test   %esi,%esi
  80111f:	0f 84 c1 00 00 00    	je     8011e6 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  801125:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  80112b:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801130:	74 19                	je     80114b <file_create+0x6f>
  801132:	68 10 3d 80 00       	push   $0x803d10
  801137:	68 5d 3a 80 00       	push   $0x803a5d
  80113c:	68 1e 01 00 00       	push   $0x11e
  801141:	68 4c 3c 80 00       	push   $0x803c4c
  801146:	e8 6f 0b 00 00       	call   801cba <_panic>
	nblock = dir->f_size / BLKSIZE;
  80114b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801151:	85 c0                	test   %eax,%eax
  801153:	0f 48 c2             	cmovs  %edx,%eax
  801156:	c1 f8 0c             	sar    $0xc,%eax
  801159:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  80115f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  801164:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  80116a:	eb 3b                	jmp    8011a7 <file_create+0xcb>
  80116c:	83 ec 04             	sub    $0x4,%esp
  80116f:	57                   	push   %edi
  801170:	53                   	push   %ebx
  801171:	56                   	push   %esi
  801172:	e8 a8 f9 ff ff       	call   800b1f <file_get_block>
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	0f 88 a1 00 00 00    	js     801223 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  801182:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801188:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  80118e:	80 38 00             	cmpb   $0x0,(%eax)
  801191:	75 08                	jne    80119b <file_create+0xbf>
				*file = &f[j];
  801193:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801199:	eb 52                	jmp    8011ed <file_create+0x111>
  80119b:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8011a0:	39 d0                	cmp    %edx,%eax
  8011a2:	75 ea                	jne    80118e <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8011a4:	83 c3 01             	add    $0x1,%ebx
  8011a7:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  8011ad:	75 bd                	jne    80116c <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8011af:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  8011b6:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8011b9:	83 ec 04             	sub    $0x4,%esp
  8011bc:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8011c2:	50                   	push   %eax
  8011c3:	53                   	push   %ebx
  8011c4:	56                   	push   %esi
  8011c5:	e8 55 f9 ff ff       	call   800b1f <file_get_block>
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 52                	js     801223 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  8011d1:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8011d7:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8011dd:	eb 0e                	jmp    8011ed <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  8011df:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8011e4:	eb 3d                	jmp    801223 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  8011e6:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8011eb:	eb 36                	jmp    801223 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  8011ed:	83 ec 08             	sub    $0x8,%esp
  8011f0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  8011fd:	e8 16 11 00 00       	call   802318 <strcpy>
	*pf = f;
  801202:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120b:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80120d:	83 c4 04             	add    $0x4,%esp
  801210:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801216:	e8 24 fe ff ff       	call   80103f <file_flush>
	return 0;
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801226:	5b                   	pop    %ebx
  801227:	5e                   	pop    %esi
  801228:	5f                   	pop    %edi
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	53                   	push   %ebx
  80122f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801232:	bb 01 00 00 00       	mov    $0x1,%ebx
  801237:	eb 17                	jmp    801250 <fs_sync+0x25>
		flush_block(diskaddr(i));
  801239:	83 ec 0c             	sub    $0xc,%esp
  80123c:	53                   	push   %ebx
  80123d:	e8 53 f1 ff ff       	call   800395 <diskaddr>
  801242:	89 04 24             	mov    %eax,(%esp)
  801245:	e8 c9 f1 ff ff       	call   800413 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80124a:	83 c3 01             	add    $0x1,%ebx
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801255:	39 58 04             	cmp    %ebx,0x4(%eax)
  801258:	77 df                	ja     801239 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80125a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801265:	e8 c1 ff ff ff       	call   80122b <fs_sync>
	return 0;
}
  80126a:	b8 00 00 00 00       	mov    $0x0,%eax
  80126f:	c9                   	leave  
  801270:	c3                   	ret    

00801271 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  801279:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  80127e:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801283:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  801285:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  801288:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  80128e:	83 c0 01             	add    $0x1,%eax
  801291:	83 c2 10             	add    $0x10,%edx
  801294:	3d 00 04 00 00       	cmp    $0x400,%eax
  801299:	75 e8                	jne    801283 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    

0080129d <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
  8012a2:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8012a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	89 d8                	mov    %ebx,%eax
  8012af:	c1 e0 04             	shl    $0x4,%eax
  8012b2:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8012b8:	e8 ac 1f 00 00       	call   803269 <pageref>
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	74 07                	je     8012cb <openfile_alloc+0x2e>
  8012c4:	83 f8 01             	cmp    $0x1,%eax
  8012c7:	74 20                	je     8012e9 <openfile_alloc+0x4c>
  8012c9:	eb 51                	jmp    80131c <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8012cb:	83 ec 04             	sub    $0x4,%esp
  8012ce:	6a 07                	push   $0x7
  8012d0:	89 d8                	mov    %ebx,%eax
  8012d2:	c1 e0 04             	shl    $0x4,%eax
  8012d5:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8012db:	6a 00                	push   $0x0
  8012dd:	e8 39 14 00 00       	call   80271b <sys_page_alloc>
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	78 43                	js     80132c <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8012e9:	c1 e3 04             	shl    $0x4,%ebx
  8012ec:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8012f2:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8012f9:	04 00 00 
			*o = &opentab[i];
  8012fc:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8012fe:	83 ec 04             	sub    $0x4,%esp
  801301:	68 00 10 00 00       	push   $0x1000
  801306:	6a 00                	push   $0x0
  801308:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  80130e:	e8 4a 11 00 00       	call   80245d <memset>
			return (*o)->o_fileid;
  801313:	8b 06                	mov    (%esi),%eax
  801315:	8b 00                	mov    (%eax),%eax
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	eb 10                	jmp    80132c <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80131c:	83 c3 01             	add    $0x1,%ebx
  80131f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801325:	75 83                	jne    8012aa <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801327:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80132c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	57                   	push   %edi
  801337:	56                   	push   %esi
  801338:	53                   	push   %ebx
  801339:	83 ec 18             	sub    $0x18,%esp
  80133c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80133f:	89 fb                	mov    %edi,%ebx
  801341:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801347:	89 de                	mov    %ebx,%esi
  801349:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80134c:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801352:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801358:	e8 0c 1f 00 00       	call   803269 <pageref>
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	83 f8 01             	cmp    $0x1,%eax
  801363:	7e 17                	jle    80137c <openfile_lookup+0x49>
  801365:	c1 e3 04             	shl    $0x4,%ebx
  801368:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  80136e:	75 13                	jne    801383 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801370:	8b 45 10             	mov    0x10(%ebp),%eax
  801373:	89 30                	mov    %esi,(%eax)
	return 0;
  801375:	b8 00 00 00 00       	mov    $0x0,%eax
  80137a:	eb 0c                	jmp    801388 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  80137c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801381:	eb 05                	jmp    801388 <openfile_lookup+0x55>
  801383:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  801388:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5f                   	pop    %edi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	56                   	push   %esi
  801394:	53                   	push   %ebx
  801395:	83 ec 10             	sub    $0x10,%esp
  801398:	8b 75 08             	mov    0x8(%ebp),%esi
  80139b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_set_size %08x %08x %08x\n", envid, req->req_fileid, req->req_size);
  80139e:	ff 73 04             	pushl  0x4(%ebx)
  8013a1:	ff 33                	pushl  (%ebx)
  8013a3:	56                   	push   %esi
  8013a4:	68 6c 3d 80 00       	push   $0x803d6c
  8013a9:	e8 e5 09 00 00       	call   801d93 <cprintf>
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013ae:	83 c4 0c             	add    $0xc,%esp
  8013b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b4:	50                   	push   %eax
  8013b5:	ff 33                	pushl  (%ebx)
  8013b7:	56                   	push   %esi
  8013b8:	e8 76 ff ff ff       	call   801333 <openfile_lookup>
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 14                	js     8013d8 <serve_set_size+0x48>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	ff 73 04             	pushl  0x4(%ebx)
  8013ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cd:	ff 70 04             	pushl  0x4(%eax)
  8013d0:	e8 e3 fa ff ff       	call   800eb8 <file_set_size>
  8013d5:	83 c4 10             	add    $0x10,%esp
}
  8013d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013db:	5b                   	pop    %ebx
  8013dc:	5e                   	pop    %esi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	83 ec 10             	sub    $0x10,%esp
  8013e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fsreq_read *req = &ipc->read;
	struct Fsret_read *ret = &ipc->readRet;

	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
  8013ed:	ff 73 04             	pushl  0x4(%ebx)
  8013f0:	ff 33                	pushl  (%ebx)
  8013f2:	56                   	push   %esi
  8013f3:	68 07 3e 80 00       	push   $0x803e07
  8013f8:	e8 96 09 00 00       	call   801d93 <cprintf>
	// Lab 5: Your code here:

	struct OpenFile *o;
	int r;

    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013fd:	83 c4 0c             	add    $0xc,%esp
  801400:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801403:	50                   	push   %eax
  801404:	ff 33                	pushl  (%ebx)
  801406:	56                   	push   %esi
  801407:	e8 27 ff ff ff       	call   801333 <openfile_lookup>
  80140c:	83 c4 10             	add    $0x10,%esp
		return r;
  80140f:	89 c2                	mov    %eax,%edx
	// Lab 5: Your code here:

	struct OpenFile *o;
	int r;

    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801411:	85 c0                	test   %eax,%eax
  801413:	78 2b                	js     801440 <serve_read+0x61>
		return r;

	r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
  801415:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801418:	8b 50 0c             	mov    0xc(%eax),%edx
  80141b:	ff 72 04             	pushl  0x4(%edx)
  80141e:	ff 73 04             	pushl  0x4(%ebx)
  801421:	53                   	push   %ebx
  801422:	ff 70 04             	pushl  0x4(%eax)
  801425:	e8 e9 f9 ff ff       	call   800e13 <file_read>
	if (r < 0)
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 0d                	js     80143e <serve_read+0x5f>
		return r;

	// req->req_fileid += r; 
	o->o_fd->fd_offset += r;
  801431:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801434:	8b 52 0c             	mov    0xc(%edx),%edx
  801437:	01 42 04             	add    %eax,0x4(%edx)

	return r;
  80143a:	89 c2                	mov    %eax,%edx
  80143c:	eb 02                	jmp    801440 <serve_read+0x61>
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
	if (r < 0)
		return r;
  80143e:	89 c2                	mov    %eax,%edx

	// req->req_fileid += r; 
	o->o_fd->fd_offset += r;

	return r;
}
  801440:	89 d0                	mov    %edx,%eax
  801442:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801445:	5b                   	pop    %ebx
  801446:	5e                   	pop    %esi
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    

00801449 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	56                   	push   %esi
  80144d:	53                   	push   %ebx
  80144e:	83 ec 10             	sub    $0x10,%esp
  801451:	8b 75 08             	mov    0x8(%ebp),%esi
  801454:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
  801457:	ff 73 04             	pushl  0x4(%ebx)
  80145a:	ff 33                	pushl  (%ebx)
  80145c:	56                   	push   %esi
  80145d:	68 22 3e 80 00       	push   $0x803e22
  801462:	e8 2c 09 00 00       	call   801d93 <cprintf>
	// LAB 5: Your code here.
	// panic("serve_write not implemented");

	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801467:	83 c4 0c             	add    $0xc,%esp
  80146a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	ff 33                	pushl  (%ebx)
  801470:	56                   	push   %esi
  801471:	e8 bd fe ff ff       	call   801333 <openfile_lookup>
  801476:	83 c4 10             	add    $0x10,%esp
		return r;
  801479:	89 c2                	mov    %eax,%edx
	// LAB 5: Your code here.
	// panic("serve_write not implemented");

	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80147b:	85 c0                	test   %eax,%eax
  80147d:	78 31                	js     8014b0 <serve_write+0x67>
		return r;
	if ((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  80147f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801482:	8b 50 0c             	mov    0xc(%eax),%edx
  801485:	ff 72 04             	pushl  0x4(%edx)
  801488:	ff 73 04             	pushl  0x4(%ebx)
  80148b:	8d 53 08             	lea    0x8(%ebx),%edx
  80148e:	52                   	push   %edx
  80148f:	ff 70 04             	pushl  0x4(%eax)
  801492:	e8 02 fb ff ff       	call   800f99 <file_write>
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 10                	js     8014ae <serve_write+0x65>
		return r;
	o->o_fd->fd_offset += req->req_n;
  80149e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a1:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a4:	8b 4b 04             	mov    0x4(%ebx),%ecx
  8014a7:	01 4a 04             	add    %ecx,0x4(%edx)
	return r;
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	eb 02                	jmp    8014b0 <serve_write+0x67>
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;
	if ((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
		return r;
  8014ae:	89 c2                	mov    %eax,%edx
	o->o_fd->fd_offset += req->req_n;
	return r;

}
  8014b0:	89 d0                	mov    %edx,%eax
  8014b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b5:	5b                   	pop    %ebx
  8014b6:	5e                   	pop    %esi
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    

008014b9 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	56                   	push   %esi
  8014bd:	53                   	push   %ebx
  8014be:	83 ec 14             	sub    $0x14,%esp
  8014c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fsret_stat *ret = &ipc->statRet;
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);
  8014c7:	ff 33                	pushl  (%ebx)
  8014c9:	56                   	push   %esi
  8014ca:	68 3e 3e 80 00       	push   $0x803e3e
  8014cf:	e8 bf 08 00 00       	call   801d93 <cprintf>

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014d4:	83 c4 0c             	add    $0xc,%esp
  8014d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	ff 33                	pushl  (%ebx)
  8014dd:	56                   	push   %esi
  8014de:	e8 50 fe ff ff       	call   801333 <openfile_lookup>
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 3f                	js     801529 <serve_stat+0x70>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8014ea:	83 ec 08             	sub    $0x8,%esp
  8014ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f0:	ff 70 04             	pushl  0x4(%eax)
  8014f3:	53                   	push   %ebx
  8014f4:	e8 1f 0e 00 00       	call   802318 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8014f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fc:	8b 50 04             	mov    0x4(%eax),%edx
  8014ff:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801505:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80150b:	8b 40 04             	mov    0x4(%eax),%eax
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801518:	0f 94 c0             	sete   %al
  80151b:	0f b6 c0             	movzbl %al,%eax
  80151e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801524:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801529:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5e                   	pop    %esi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	56                   	push   %esi
  801534:	53                   	push   %ebx
  801535:	83 ec 14             	sub    $0x14,%esp
  801538:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80153b:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);
  80153e:	ff 36                	pushl  (%esi)
  801540:	53                   	push   %ebx
  801541:	68 54 3e 80 00       	push   $0x803e54
  801546:	e8 48 08 00 00       	call   801d93 <cprintf>

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80154b:	83 c4 0c             	add    $0xc,%esp
  80154e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	ff 36                	pushl  (%esi)
  801554:	53                   	push   %ebx
  801555:	e8 d9 fd ff ff       	call   801333 <openfile_lookup>
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 16                	js     801577 <serve_flush+0x47>
		return r;
	file_flush(o->o_file);
  801561:	83 ec 0c             	sub    $0xc,%esp
  801564:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801567:	ff 70 04             	pushl  0x4(%eax)
  80156a:	e8 d0 fa ff ff       	call   80103f <file_flush>
	return 0;
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801577:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157a:	5b                   	pop    %ebx
  80157b:	5e                   	pop    %esi
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	56                   	push   %esi
  801582:	53                   	push   %ebx
  801583:	81 ec 10 04 00 00    	sub    $0x410,%esp
  801589:	8b 75 0c             	mov    0xc(%ebp),%esi
	int fileid;
	int r;
	struct OpenFile *o;

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);
  80158c:	ff b6 00 04 00 00    	pushl  0x400(%esi)
  801592:	56                   	push   %esi
  801593:	ff 75 08             	pushl  0x8(%ebp)
  801596:	68 6b 3e 80 00       	push   $0x803e6b
  80159b:	e8 f3 07 00 00       	call   801d93 <cprintf>

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  8015a0:	83 c4 0c             	add    $0xc,%esp
  8015a3:	68 00 04 00 00       	push   $0x400
  8015a8:	56                   	push   %esi
  8015a9:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	e8 f5 0e 00 00       	call   8024aa <memmove>
	path[MAXPATHLEN-1] = 0;
  8015b5:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  8015b9:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8015bf:	89 04 24             	mov    %eax,(%esp)
  8015c2:	e8 d6 fc ff ff       	call   80129d <openfile_alloc>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	79 1a                	jns    8015e8 <serve_open+0x6a>
  8015ce:	89 c3                	mov    %eax,%ebx
		if (debug)
			cprintf("openfile_alloc failed: %e", r);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	50                   	push   %eax
  8015d4:	68 84 3e 80 00       	push   $0x803e84
  8015d9:	e8 b5 07 00 00       	call   801d93 <cprintf>
		return r;
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	89 d8                	mov    %ebx,%eax
  8015e3:	e9 62 01 00 00       	jmp    80174a <serve_open+0x1cc>
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  8015e8:	f6 86 01 04 00 00 01 	testb  $0x1,0x401(%esi)
  8015ef:	74 45                	je     801636 <serve_open+0xb8>
		if ((r = file_create(path, &f)) < 0) {
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8015fa:	50                   	push   %eax
  8015fb:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	e8 d5 fa ff ff       	call   8010dc <file_create>
  801607:	89 c3                	mov    %eax,%ebx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	79 5d                	jns    80166d <serve_open+0xef>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801610:	f6 86 01 04 00 00 04 	testb  $0x4,0x401(%esi)
  801617:	75 05                	jne    80161e <serve_open+0xa0>
  801619:	83 f8 f3             	cmp    $0xfffffff3,%eax
  80161c:	74 18                	je     801636 <serve_open+0xb8>
				goto try_open;
			if (debug)
				cprintf("file_create failed: %e", r);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	53                   	push   %ebx
  801622:	68 9e 3e 80 00       	push   $0x803e9e
  801627:	e8 67 07 00 00       	call   801d93 <cprintf>
			return r;
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	89 d8                	mov    %ebx,%eax
  801631:	e9 14 01 00 00       	jmp    80174a <serve_open+0x1cc>
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80163f:	50                   	push   %eax
  801640:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801646:	50                   	push   %eax
  801647:	e8 ad f7 ff ff       	call   800df9 <file_open>
  80164c:	89 c3                	mov    %eax,%ebx
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	85 c0                	test   %eax,%eax
  801653:	79 18                	jns    80166d <serve_open+0xef>
			if (debug)
				cprintf("file_open failed: %e", r);
  801655:	83 ec 08             	sub    $0x8,%esp
  801658:	50                   	push   %eax
  801659:	68 b5 3e 80 00       	push   $0x803eb5
  80165e:	e8 30 07 00 00       	call   801d93 <cprintf>
			return r;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	89 d8                	mov    %ebx,%eax
  801668:	e9 dd 00 00 00       	jmp    80174a <serve_open+0x1cc>
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  80166d:	f6 86 01 04 00 00 02 	testb  $0x2,0x401(%esi)
  801674:	74 31                	je     8016a7 <serve_open+0x129>
		if ((r = file_set_size(f, 0)) < 0) {
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	6a 00                	push   $0x0
  80167b:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  801681:	e8 32 f8 ff ff       	call   800eb8 <file_set_size>
  801686:	89 c3                	mov    %eax,%ebx
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	79 18                	jns    8016a7 <serve_open+0x129>
			if (debug)
				cprintf("file_set_size failed: %e", r);
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	50                   	push   %eax
  801693:	68 ca 3e 80 00       	push   $0x803eca
  801698:	e8 f6 06 00 00       	call   801d93 <cprintf>
			return r;
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	89 d8                	mov    %ebx,%eax
  8016a2:	e9 a3 00 00 00       	jmp    80174a <serve_open+0x1cc>
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	e8 3c f7 ff ff       	call   800df9 <file_open>
  8016bd:	89 c3                	mov    %eax,%ebx
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	79 15                	jns    8016db <serve_open+0x15d>
		if (debug)
			cprintf("file_open failed: %e", r);
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	50                   	push   %eax
  8016ca:	68 b5 3e 80 00       	push   $0x803eb5
  8016cf:	e8 bf 06 00 00       	call   801d93 <cprintf>
		return r;
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	89 d8                	mov    %ebx,%eax
  8016d9:	eb 6f                	jmp    80174a <serve_open+0x1cc>
	}

	// Save the file pointer
	o->o_file = f;
  8016db:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016e1:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8016e7:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8016ea:	8b 50 0c             	mov    0xc(%eax),%edx
  8016ed:	8b 08                	mov    (%eax),%ecx
  8016ef:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8016f2:	8b 48 0c             	mov    0xc(%eax),%ecx
  8016f5:	8b 96 00 04 00 00    	mov    0x400(%esi),%edx
  8016fb:	83 e2 03             	and    $0x3,%edx
  8016fe:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801701:	8b 40 0c             	mov    0xc(%eax),%eax
  801704:	8b 15 64 90 80 00    	mov    0x809064,%edx
  80170a:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80170c:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801712:	8b 96 00 04 00 00    	mov    0x400(%esi),%edx
  801718:	89 50 08             	mov    %edx,0x8(%eax)

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	ff 70 0c             	pushl  0xc(%eax)
  801721:	68 e3 3e 80 00       	push   $0x803ee3
  801726:	e8 68 06 00 00       	call   801d93 <cprintf>

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80172b:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801731:	8b 50 0c             	mov    0xc(%eax),%edx
  801734:	8b 45 10             	mov    0x10(%ebp),%eax
  801737:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801739:	8b 45 14             	mov    0x14(%ebp),%eax
  80173c:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174d:	5b                   	pop    %ebx
  80174e:	5e                   	pop    %esi
  80174f:	5d                   	pop    %ebp
  801750:	c3                   	ret    

00801751 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	57                   	push   %edi
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
  801757:	83 ec 1c             	sub    $0x1c,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80175a:	8d 75 e0             	lea    -0x20(%ebp),%esi
  80175d:	8d 7d e4             	lea    -0x1c(%ebp),%edi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801760:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801767:	83 ec 04             	sub    $0x4,%esp
  80176a:	56                   	push   %esi
  80176b:	ff 35 44 50 80 00    	pushl  0x805044
  801771:	57                   	push   %edi
  801772:	e8 00 12 00 00       	call   802977 <ipc_recv>
  801777:	89 c3                	mov    %eax,%ebx
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);
  801779:	a1 44 50 80 00       	mov    0x805044,%eax
  80177e:	89 c2                	mov    %eax,%edx
  801780:	c1 ea 0c             	shr    $0xc,%edx

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
  801783:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80178a:	89 04 24             	mov    %eax,(%esp)
  80178d:	52                   	push   %edx
  80178e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801791:	53                   	push   %ebx
  801792:	68 8c 3d 80 00       	push   $0x803d8c
  801797:	e8 f7 05 00 00       	call   801d93 <cprintf>
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80179c:	83 c4 20             	add    $0x20,%esp
  80179f:	f6 45 e0 01          	testb  $0x1,-0x20(%ebp)
  8017a3:	75 15                	jne    8017ba <serve+0x69>
			cprintf("Invalid request from %08x: no argument page\n",
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017ab:	68 b4 3d 80 00       	push   $0x803db4
  8017b0:	e8 de 05 00 00       	call   801d93 <cprintf>
				whom);
			continue; // just leave it hanging...
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	eb a6                	jmp    801760 <serve+0xf>
		}

		pg = NULL;
  8017ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		if (req == FSREQ_OPEN) {
  8017c1:	83 fb 01             	cmp    $0x1,%ebx
  8017c4:	75 18                	jne    8017de <serve+0x8d>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8017c6:	56                   	push   %esi
  8017c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8017ca:	50                   	push   %eax
  8017cb:	ff 35 44 50 80 00    	pushl  0x805044
  8017d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017d4:	e8 a5 fd ff ff       	call   80157e <serve_open>
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	eb 3c                	jmp    80181a <serve+0xc9>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8017de:	83 fb 08             	cmp    $0x8,%ebx
  8017e1:	77 1e                	ja     801801 <serve+0xb0>
  8017e3:	8b 04 9d 20 50 80 00 	mov    0x805020(,%ebx,4),%eax
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	74 13                	je     801801 <serve+0xb0>
			r = handlers[req](whom, fsreq);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	ff 35 44 50 80 00    	pushl  0x805044
  8017f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017fa:	ff d0                	call   *%eax
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	eb 19                	jmp    80181a <serve+0xc9>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  801801:	83 ec 04             	sub    $0x4,%esp
  801804:	ff 75 e4             	pushl  -0x1c(%ebp)
  801807:	53                   	push   %ebx
  801808:	68 e4 3d 80 00       	push   $0x803de4
  80180d:	e8 81 05 00 00       	call   801d93 <cprintf>
  801812:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801815:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  80181a:	ff 75 e0             	pushl  -0x20(%ebp)
  80181d:	ff 75 dc             	pushl  -0x24(%ebp)
  801820:	50                   	push   %eax
  801821:	ff 75 e4             	pushl  -0x1c(%ebp)
  801824:	e8 b5 11 00 00       	call   8029de <ipc_send>
		sys_page_unmap(0, fsreq);
  801829:	83 c4 08             	add    $0x8,%esp
  80182c:	ff 35 44 50 80 00    	pushl  0x805044
  801832:	6a 00                	push   $0x0
  801834:	e8 67 0f 00 00       	call   8027a0 <sys_page_unmap>
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	e9 1f ff ff ff       	jmp    801760 <serve+0xf>

00801841 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801847:	c7 05 60 90 80 00 ff 	movl   $0x803eff,0x809060
  80184e:	3e 80 00 
	cprintf("FS is running\n");
  801851:	68 02 3f 80 00       	push   $0x803f02
  801856:	e8 38 05 00 00       	call   801d93 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80185b:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801860:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801865:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801867:	c7 04 24 11 3f 80 00 	movl   $0x803f11,(%esp)
  80186e:	e8 20 05 00 00       	call   801d93 <cprintf>

	serve_init();
  801873:	e8 f9 f9 ff ff       	call   801271 <serve_init>
	fs_init();
  801878:	e8 43 f2 ff ff       	call   800ac0 <fs_init>
        fs_test();
  80187d:	e8 05 00 00 00       	call   801887 <fs_test>
	serve();
  801882:	e8 ca fe ff ff       	call   801751 <serve>

00801887 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80188e:	6a 07                	push   $0x7
  801890:	68 00 10 00 00       	push   $0x1000
  801895:	6a 00                	push   $0x0
  801897:	e8 7f 0e 00 00       	call   80271b <sys_page_alloc>
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	79 12                	jns    8018b5 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  8018a3:	50                   	push   %eax
  8018a4:	68 20 3f 80 00       	push   $0x803f20
  8018a9:	6a 12                	push   $0x12
  8018ab:	68 33 3f 80 00       	push   $0x803f33
  8018b0:	e8 05 04 00 00       	call   801cba <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8018b5:	83 ec 04             	sub    $0x4,%esp
  8018b8:	68 00 10 00 00       	push   $0x1000
  8018bd:	ff 35 04 a0 80 00    	pushl  0x80a004
  8018c3:	68 00 10 00 00       	push   $0x1000
  8018c8:	e8 dd 0b 00 00       	call   8024aa <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8018cd:	e8 af ef ff ff       	call   800881 <alloc_block>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	79 12                	jns    8018eb <fs_test+0x64>
		panic("alloc_block: %e", r);
  8018d9:	50                   	push   %eax
  8018da:	68 3d 3f 80 00       	push   $0x803f3d
  8018df:	6a 17                	push   $0x17
  8018e1:	68 33 3f 80 00       	push   $0x803f33
  8018e6:	e8 cf 03 00 00       	call   801cba <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8018eb:	8d 50 1f             	lea    0x1f(%eax),%edx
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	0f 49 d0             	cmovns %eax,%edx
  8018f3:	c1 fa 05             	sar    $0x5,%edx
  8018f6:	89 c3                	mov    %eax,%ebx
  8018f8:	c1 fb 1f             	sar    $0x1f,%ebx
  8018fb:	c1 eb 1b             	shr    $0x1b,%ebx
  8018fe:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  801901:	83 e1 1f             	and    $0x1f,%ecx
  801904:	29 d9                	sub    %ebx,%ecx
  801906:	b8 01 00 00 00       	mov    $0x1,%eax
  80190b:	d3 e0                	shl    %cl,%eax
  80190d:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801914:	75 16                	jne    80192c <fs_test+0xa5>
  801916:	68 4d 3f 80 00       	push   $0x803f4d
  80191b:	68 5d 3a 80 00       	push   $0x803a5d
  801920:	6a 19                	push   $0x19
  801922:	68 33 3f 80 00       	push   $0x803f33
  801927:	e8 8e 03 00 00       	call   801cba <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80192c:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  801932:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801935:	74 16                	je     80194d <fs_test+0xc6>
  801937:	68 c8 40 80 00       	push   $0x8040c8
  80193c:	68 5d 3a 80 00       	push   $0x803a5d
  801941:	6a 1b                	push   $0x1b
  801943:	68 33 3f 80 00       	push   $0x803f33
  801948:	e8 6d 03 00 00       	call   801cba <_panic>
	cprintf("alloc_block is good\n");
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	68 68 3f 80 00       	push   $0x803f68
  801955:	e8 39 04 00 00       	call   801d93 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80195a:	83 c4 08             	add    $0x8,%esp
  80195d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801960:	50                   	push   %eax
  801961:	68 7d 3f 80 00       	push   $0x803f7d
  801966:	e8 8e f4 ff ff       	call   800df9 <file_open>
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801971:	74 1b                	je     80198e <fs_test+0x107>
  801973:	89 c2                	mov    %eax,%edx
  801975:	c1 ea 1f             	shr    $0x1f,%edx
  801978:	84 d2                	test   %dl,%dl
  80197a:	74 12                	je     80198e <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80197c:	50                   	push   %eax
  80197d:	68 88 3f 80 00       	push   $0x803f88
  801982:	6a 1f                	push   $0x1f
  801984:	68 33 3f 80 00       	push   $0x803f33
  801989:	e8 2c 03 00 00       	call   801cba <_panic>
	else if (r == 0)
  80198e:	85 c0                	test   %eax,%eax
  801990:	75 14                	jne    8019a6 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801992:	83 ec 04             	sub    $0x4,%esp
  801995:	68 e8 40 80 00       	push   $0x8040e8
  80199a:	6a 21                	push   $0x21
  80199c:	68 33 3f 80 00       	push   $0x803f33
  8019a1:	e8 14 03 00 00       	call   801cba <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ac:	50                   	push   %eax
  8019ad:	68 a1 3f 80 00       	push   $0x803fa1
  8019b2:	e8 42 f4 ff ff       	call   800df9 <file_open>
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	79 12                	jns    8019d0 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  8019be:	50                   	push   %eax
  8019bf:	68 aa 3f 80 00       	push   $0x803faa
  8019c4:	6a 23                	push   $0x23
  8019c6:	68 33 3f 80 00       	push   $0x803f33
  8019cb:	e8 ea 02 00 00       	call   801cba <_panic>
	cprintf("file_open is good\n");
  8019d0:	83 ec 0c             	sub    $0xc,%esp
  8019d3:	68 c1 3f 80 00       	push   $0x803fc1
  8019d8:	e8 b6 03 00 00       	call   801d93 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8019dd:	83 c4 0c             	add    $0xc,%esp
  8019e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	6a 00                	push   $0x0
  8019e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e9:	e8 31 f1 ff ff       	call   800b1f <file_get_block>
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	79 12                	jns    801a07 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8019f5:	50                   	push   %eax
  8019f6:	68 d4 3f 80 00       	push   $0x803fd4
  8019fb:	6a 27                	push   $0x27
  8019fd:	68 33 3f 80 00       	push   $0x803f33
  801a02:	e8 b3 02 00 00       	call   801cba <_panic>
	if (strcmp(blk, msg) != 0)
  801a07:	83 ec 08             	sub    $0x8,%esp
  801a0a:	68 08 41 80 00       	push   $0x804108
  801a0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a12:	e8 ab 09 00 00       	call   8023c2 <strcmp>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	74 14                	je     801a32 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  801a1e:	83 ec 04             	sub    $0x4,%esp
  801a21:	68 30 41 80 00       	push   $0x804130
  801a26:	6a 29                	push   $0x29
  801a28:	68 33 3f 80 00       	push   $0x803f33
  801a2d:	e8 88 02 00 00       	call   801cba <_panic>
	cprintf("file_get_block is good\n");
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	68 e7 3f 80 00       	push   $0x803fe7
  801a3a:	e8 54 03 00 00       	call   801d93 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a42:	0f b6 10             	movzbl (%eax),%edx
  801a45:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a4a:	c1 e8 0c             	shr    $0xc,%eax
  801a4d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	a8 40                	test   $0x40,%al
  801a59:	75 16                	jne    801a71 <fs_test+0x1ea>
  801a5b:	68 00 40 80 00       	push   $0x804000
  801a60:	68 5d 3a 80 00       	push   $0x803a5d
  801a65:	6a 2d                	push   $0x2d
  801a67:	68 33 3f 80 00       	push   $0x803f33
  801a6c:	e8 49 02 00 00       	call   801cba <_panic>
	file_flush(f);
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	ff 75 f4             	pushl  -0xc(%ebp)
  801a77:	e8 c3 f5 ff ff       	call   80103f <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a7f:	c1 e8 0c             	shr    $0xc,%eax
  801a82:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	a8 40                	test   $0x40,%al
  801a8e:	74 16                	je     801aa6 <fs_test+0x21f>
  801a90:	68 ff 3f 80 00       	push   $0x803fff
  801a95:	68 5d 3a 80 00       	push   $0x803a5d
  801a9a:	6a 2f                	push   $0x2f
  801a9c:	68 33 3f 80 00       	push   $0x803f33
  801aa1:	e8 14 02 00 00       	call   801cba <_panic>
	cprintf("file_flush is good\n");
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	68 1b 40 80 00       	push   $0x80401b
  801aae:	e8 e0 02 00 00       	call   801d93 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801ab3:	83 c4 08             	add    $0x8,%esp
  801ab6:	6a 00                	push   $0x0
  801ab8:	ff 75 f4             	pushl  -0xc(%ebp)
  801abb:	e8 f8 f3 ff ff       	call   800eb8 <file_set_size>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	79 12                	jns    801ad9 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801ac7:	50                   	push   %eax
  801ac8:	68 2f 40 80 00       	push   $0x80402f
  801acd:	6a 33                	push   $0x33
  801acf:	68 33 3f 80 00       	push   $0x803f33
  801ad4:	e8 e1 01 00 00       	call   801cba <_panic>
	assert(f->f_direct[0] == 0);
  801ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adc:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801ae3:	74 16                	je     801afb <fs_test+0x274>
  801ae5:	68 41 40 80 00       	push   $0x804041
  801aea:	68 5d 3a 80 00       	push   $0x803a5d
  801aef:	6a 34                	push   $0x34
  801af1:	68 33 3f 80 00       	push   $0x803f33
  801af6:	e8 bf 01 00 00       	call   801cba <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801afb:	c1 e8 0c             	shr    $0xc,%eax
  801afe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b05:	a8 40                	test   $0x40,%al
  801b07:	74 16                	je     801b1f <fs_test+0x298>
  801b09:	68 55 40 80 00       	push   $0x804055
  801b0e:	68 5d 3a 80 00       	push   $0x803a5d
  801b13:	6a 35                	push   $0x35
  801b15:	68 33 3f 80 00       	push   $0x803f33
  801b1a:	e8 9b 01 00 00       	call   801cba <_panic>
	cprintf("file_truncate is good\n");
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	68 6f 40 80 00       	push   $0x80406f
  801b27:	e8 67 02 00 00       	call   801d93 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801b2c:	c7 04 24 08 41 80 00 	movl   $0x804108,(%esp)
  801b33:	e8 a7 07 00 00       	call   8022df <strlen>
  801b38:	83 c4 08             	add    $0x8,%esp
  801b3b:	50                   	push   %eax
  801b3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3f:	e8 74 f3 ff ff       	call   800eb8 <file_set_size>
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	85 c0                	test   %eax,%eax
  801b49:	79 12                	jns    801b5d <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801b4b:	50                   	push   %eax
  801b4c:	68 86 40 80 00       	push   $0x804086
  801b51:	6a 39                	push   $0x39
  801b53:	68 33 3f 80 00       	push   $0x803f33
  801b58:	e8 5d 01 00 00       	call   801cba <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	c1 ea 0c             	shr    $0xc,%edx
  801b65:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b6c:	f6 c2 40             	test   $0x40,%dl
  801b6f:	74 16                	je     801b87 <fs_test+0x300>
  801b71:	68 55 40 80 00       	push   $0x804055
  801b76:	68 5d 3a 80 00       	push   $0x803a5d
  801b7b:	6a 3a                	push   $0x3a
  801b7d:	68 33 3f 80 00       	push   $0x803f33
  801b82:	e8 33 01 00 00       	call   801cba <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801b87:	83 ec 04             	sub    $0x4,%esp
  801b8a:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801b8d:	52                   	push   %edx
  801b8e:	6a 00                	push   $0x0
  801b90:	50                   	push   %eax
  801b91:	e8 89 ef ff ff       	call   800b1f <file_get_block>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	79 12                	jns    801baf <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801b9d:	50                   	push   %eax
  801b9e:	68 9a 40 80 00       	push   $0x80409a
  801ba3:	6a 3c                	push   $0x3c
  801ba5:	68 33 3f 80 00       	push   $0x803f33
  801baa:	e8 0b 01 00 00       	call   801cba <_panic>
	strcpy(blk, msg);
  801baf:	83 ec 08             	sub    $0x8,%esp
  801bb2:	68 08 41 80 00       	push   $0x804108
  801bb7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bba:	e8 59 07 00 00       	call   802318 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc2:	c1 e8 0c             	shr    $0xc,%eax
  801bc5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	a8 40                	test   $0x40,%al
  801bd1:	75 16                	jne    801be9 <fs_test+0x362>
  801bd3:	68 00 40 80 00       	push   $0x804000
  801bd8:	68 5d 3a 80 00       	push   $0x803a5d
  801bdd:	6a 3e                	push   $0x3e
  801bdf:	68 33 3f 80 00       	push   $0x803f33
  801be4:	e8 d1 00 00 00       	call   801cba <_panic>
	file_flush(f);
  801be9:	83 ec 0c             	sub    $0xc,%esp
  801bec:	ff 75 f4             	pushl  -0xc(%ebp)
  801bef:	e8 4b f4 ff ff       	call   80103f <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf7:	c1 e8 0c             	shr    $0xc,%eax
  801bfa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	a8 40                	test   $0x40,%al
  801c06:	74 16                	je     801c1e <fs_test+0x397>
  801c08:	68 ff 3f 80 00       	push   $0x803fff
  801c0d:	68 5d 3a 80 00       	push   $0x803a5d
  801c12:	6a 40                	push   $0x40
  801c14:	68 33 3f 80 00       	push   $0x803f33
  801c19:	e8 9c 00 00 00       	call   801cba <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c21:	c1 e8 0c             	shr    $0xc,%eax
  801c24:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c2b:	a8 40                	test   $0x40,%al
  801c2d:	74 16                	je     801c45 <fs_test+0x3be>
  801c2f:	68 55 40 80 00       	push   $0x804055
  801c34:	68 5d 3a 80 00       	push   $0x803a5d
  801c39:	6a 41                	push   $0x41
  801c3b:	68 33 3f 80 00       	push   $0x803f33
  801c40:	e8 75 00 00 00       	call   801cba <_panic>
	cprintf("file rewrite is good\n");
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	68 af 40 80 00       	push   $0x8040af
  801c4d:	e8 41 01 00 00       	call   801d93 <cprintf>
}
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	56                   	push   %esi
  801c5e:	53                   	push   %ebx
  801c5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c62:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801c65:	e8 73 0a 00 00       	call   8026dd <sys_getenvid>
  801c6a:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c6f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c72:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c77:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801c7c:	85 db                	test   %ebx,%ebx
  801c7e:	7e 07                	jle    801c87 <libmain+0x2d>
		binaryname = argv[0];
  801c80:	8b 06                	mov    (%esi),%eax
  801c82:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801c87:	83 ec 08             	sub    $0x8,%esp
  801c8a:	56                   	push   %esi
  801c8b:	53                   	push   %ebx
  801c8c:	e8 b0 fb ff ff       	call   801841 <umain>

	// exit gracefully
	exit();
  801c91:	e8 0a 00 00 00       	call   801ca0 <exit>
}
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801ca6:	e8 8b 0f 00 00       	call   802c36 <close_all>
	sys_env_destroy(0);
  801cab:	83 ec 0c             	sub    $0xc,%esp
  801cae:	6a 00                	push   $0x0
  801cb0:	e8 e7 09 00 00       	call   80269c <sys_env_destroy>
}
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	c9                   	leave  
  801cb9:	c3                   	ret    

00801cba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	56                   	push   %esi
  801cbe:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cbf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cc2:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801cc8:	e8 10 0a 00 00       	call   8026dd <sys_getenvid>
  801ccd:	83 ec 0c             	sub    $0xc,%esp
  801cd0:	ff 75 0c             	pushl  0xc(%ebp)
  801cd3:	ff 75 08             	pushl  0x8(%ebp)
  801cd6:	56                   	push   %esi
  801cd7:	50                   	push   %eax
  801cd8:	68 60 41 80 00       	push   $0x804160
  801cdd:	e8 b1 00 00 00       	call   801d93 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ce2:	83 c4 18             	add    $0x18,%esp
  801ce5:	53                   	push   %ebx
  801ce6:	ff 75 10             	pushl  0x10(%ebp)
  801ce9:	e8 54 00 00 00       	call   801d42 <vcprintf>
	cprintf("\n");
  801cee:	c7 04 24 04 3d 80 00 	movl   $0x803d04,(%esp)
  801cf5:	e8 99 00 00 00       	call   801d93 <cprintf>
  801cfa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cfd:	cc                   	int3   
  801cfe:	eb fd                	jmp    801cfd <_panic+0x43>

00801d00 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	53                   	push   %ebx
  801d04:	83 ec 04             	sub    $0x4,%esp
  801d07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801d0a:	8b 13                	mov    (%ebx),%edx
  801d0c:	8d 42 01             	lea    0x1(%edx),%eax
  801d0f:	89 03                	mov    %eax,(%ebx)
  801d11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d14:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801d18:	3d ff 00 00 00       	cmp    $0xff,%eax
  801d1d:	75 1a                	jne    801d39 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801d1f:	83 ec 08             	sub    $0x8,%esp
  801d22:	68 ff 00 00 00       	push   $0xff
  801d27:	8d 43 08             	lea    0x8(%ebx),%eax
  801d2a:	50                   	push   %eax
  801d2b:	e8 2f 09 00 00       	call   80265f <sys_cputs>
		b->idx = 0;
  801d30:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d36:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801d39:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801d3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801d4b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801d52:	00 00 00 
	b.cnt = 0;
  801d55:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801d5c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801d5f:	ff 75 0c             	pushl  0xc(%ebp)
  801d62:	ff 75 08             	pushl  0x8(%ebp)
  801d65:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801d6b:	50                   	push   %eax
  801d6c:	68 00 1d 80 00       	push   $0x801d00
  801d71:	e8 54 01 00 00       	call   801eca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801d76:	83 c4 08             	add    $0x8,%esp
  801d79:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801d7f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801d85:	50                   	push   %eax
  801d86:	e8 d4 08 00 00       	call   80265f <sys_cputs>

	return b.cnt;
}
  801d8b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d99:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801d9c:	50                   	push   %eax
  801d9d:	ff 75 08             	pushl  0x8(%ebp)
  801da0:	e8 9d ff ff ff       	call   801d42 <vcprintf>
	va_end(ap);

	return cnt;
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	57                   	push   %edi
  801dab:	56                   	push   %esi
  801dac:	53                   	push   %ebx
  801dad:	83 ec 1c             	sub    $0x1c,%esp
  801db0:	89 c7                	mov    %eax,%edi
  801db2:	89 d6                	mov    %edx,%esi
  801db4:	8b 45 08             	mov    0x8(%ebp),%eax
  801db7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dbd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801dc0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dc8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801dcb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801dce:	39 d3                	cmp    %edx,%ebx
  801dd0:	72 05                	jb     801dd7 <printnum+0x30>
  801dd2:	39 45 10             	cmp    %eax,0x10(%ebp)
  801dd5:	77 45                	ja     801e1c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801dd7:	83 ec 0c             	sub    $0xc,%esp
  801dda:	ff 75 18             	pushl  0x18(%ebp)
  801ddd:	8b 45 14             	mov    0x14(%ebp),%eax
  801de0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801de3:	53                   	push   %ebx
  801de4:	ff 75 10             	pushl  0x10(%ebp)
  801de7:	83 ec 08             	sub    $0x8,%esp
  801dea:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ded:	ff 75 e0             	pushl  -0x20(%ebp)
  801df0:	ff 75 dc             	pushl  -0x24(%ebp)
  801df3:	ff 75 d8             	pushl  -0x28(%ebp)
  801df6:	e8 95 19 00 00       	call   803790 <__udivdi3>
  801dfb:	83 c4 18             	add    $0x18,%esp
  801dfe:	52                   	push   %edx
  801dff:	50                   	push   %eax
  801e00:	89 f2                	mov    %esi,%edx
  801e02:	89 f8                	mov    %edi,%eax
  801e04:	e8 9e ff ff ff       	call   801da7 <printnum>
  801e09:	83 c4 20             	add    $0x20,%esp
  801e0c:	eb 18                	jmp    801e26 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801e0e:	83 ec 08             	sub    $0x8,%esp
  801e11:	56                   	push   %esi
  801e12:	ff 75 18             	pushl  0x18(%ebp)
  801e15:	ff d7                	call   *%edi
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	eb 03                	jmp    801e1f <printnum+0x78>
  801e1c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801e1f:	83 eb 01             	sub    $0x1,%ebx
  801e22:	85 db                	test   %ebx,%ebx
  801e24:	7f e8                	jg     801e0e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801e26:	83 ec 08             	sub    $0x8,%esp
  801e29:	56                   	push   %esi
  801e2a:	83 ec 04             	sub    $0x4,%esp
  801e2d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e30:	ff 75 e0             	pushl  -0x20(%ebp)
  801e33:	ff 75 dc             	pushl  -0x24(%ebp)
  801e36:	ff 75 d8             	pushl  -0x28(%ebp)
  801e39:	e8 82 1a 00 00       	call   8038c0 <__umoddi3>
  801e3e:	83 c4 14             	add    $0x14,%esp
  801e41:	0f be 80 83 41 80 00 	movsbl 0x804183(%eax),%eax
  801e48:	50                   	push   %eax
  801e49:	ff d7                	call   *%edi
}
  801e4b:	83 c4 10             	add    $0x10,%esp
  801e4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e51:	5b                   	pop    %ebx
  801e52:	5e                   	pop    %esi
  801e53:	5f                   	pop    %edi
  801e54:	5d                   	pop    %ebp
  801e55:	c3                   	ret    

00801e56 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801e59:	83 fa 01             	cmp    $0x1,%edx
  801e5c:	7e 0e                	jle    801e6c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801e5e:	8b 10                	mov    (%eax),%edx
  801e60:	8d 4a 08             	lea    0x8(%edx),%ecx
  801e63:	89 08                	mov    %ecx,(%eax)
  801e65:	8b 02                	mov    (%edx),%eax
  801e67:	8b 52 04             	mov    0x4(%edx),%edx
  801e6a:	eb 22                	jmp    801e8e <getuint+0x38>
	else if (lflag)
  801e6c:	85 d2                	test   %edx,%edx
  801e6e:	74 10                	je     801e80 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801e70:	8b 10                	mov    (%eax),%edx
  801e72:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e75:	89 08                	mov    %ecx,(%eax)
  801e77:	8b 02                	mov    (%edx),%eax
  801e79:	ba 00 00 00 00       	mov    $0x0,%edx
  801e7e:	eb 0e                	jmp    801e8e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801e80:	8b 10                	mov    (%eax),%edx
  801e82:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e85:	89 08                	mov    %ecx,(%eax)
  801e87:	8b 02                	mov    (%edx),%eax
  801e89:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    

00801e90 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801e96:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801e9a:	8b 10                	mov    (%eax),%edx
  801e9c:	3b 50 04             	cmp    0x4(%eax),%edx
  801e9f:	73 0a                	jae    801eab <sprintputch+0x1b>
		*b->buf++ = ch;
  801ea1:	8d 4a 01             	lea    0x1(%edx),%ecx
  801ea4:	89 08                	mov    %ecx,(%eax)
  801ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea9:	88 02                	mov    %al,(%edx)
}
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    

00801ead <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801eb3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801eb6:	50                   	push   %eax
  801eb7:	ff 75 10             	pushl  0x10(%ebp)
  801eba:	ff 75 0c             	pushl  0xc(%ebp)
  801ebd:	ff 75 08             	pushl  0x8(%ebp)
  801ec0:	e8 05 00 00 00       	call   801eca <vprintfmt>
	va_end(ap);
}
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    

00801eca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	57                   	push   %edi
  801ece:	56                   	push   %esi
  801ecf:	53                   	push   %ebx
  801ed0:	83 ec 2c             	sub    $0x2c,%esp
  801ed3:	8b 75 08             	mov    0x8(%ebp),%esi
  801ed6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ed9:	8b 7d 10             	mov    0x10(%ebp),%edi
  801edc:	eb 12                	jmp    801ef0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	0f 84 89 03 00 00    	je     80226f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801ee6:	83 ec 08             	sub    $0x8,%esp
  801ee9:	53                   	push   %ebx
  801eea:	50                   	push   %eax
  801eeb:	ff d6                	call   *%esi
  801eed:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801ef0:	83 c7 01             	add    $0x1,%edi
  801ef3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ef7:	83 f8 25             	cmp    $0x25,%eax
  801efa:	75 e2                	jne    801ede <vprintfmt+0x14>
  801efc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801f00:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801f07:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801f0e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801f15:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1a:	eb 07                	jmp    801f23 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f1c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801f1f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f23:	8d 47 01             	lea    0x1(%edi),%eax
  801f26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f29:	0f b6 07             	movzbl (%edi),%eax
  801f2c:	0f b6 c8             	movzbl %al,%ecx
  801f2f:	83 e8 23             	sub    $0x23,%eax
  801f32:	3c 55                	cmp    $0x55,%al
  801f34:	0f 87 1a 03 00 00    	ja     802254 <vprintfmt+0x38a>
  801f3a:	0f b6 c0             	movzbl %al,%eax
  801f3d:	ff 24 85 c0 42 80 00 	jmp    *0x8042c0(,%eax,4)
  801f44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801f47:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801f4b:	eb d6                	jmp    801f23 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f50:	b8 00 00 00 00       	mov    $0x0,%eax
  801f55:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801f58:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801f5b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801f5f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801f62:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801f65:	83 fa 09             	cmp    $0x9,%edx
  801f68:	77 39                	ja     801fa3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801f6a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801f6d:	eb e9                	jmp    801f58 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801f6f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f72:	8d 48 04             	lea    0x4(%eax),%ecx
  801f75:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801f78:	8b 00                	mov    (%eax),%eax
  801f7a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801f80:	eb 27                	jmp    801fa9 <vprintfmt+0xdf>
  801f82:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f85:	85 c0                	test   %eax,%eax
  801f87:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f8c:	0f 49 c8             	cmovns %eax,%ecx
  801f8f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f95:	eb 8c                	jmp    801f23 <vprintfmt+0x59>
  801f97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801f9a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801fa1:	eb 80                	jmp    801f23 <vprintfmt+0x59>
  801fa3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801fa6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801fa9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801fad:	0f 89 70 ff ff ff    	jns    801f23 <vprintfmt+0x59>
				width = precision, precision = -1;
  801fb3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801fb6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fb9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801fc0:	e9 5e ff ff ff       	jmp    801f23 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801fc5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801fcb:	e9 53 ff ff ff       	jmp    801f23 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801fd0:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd3:	8d 50 04             	lea    0x4(%eax),%edx
  801fd6:	89 55 14             	mov    %edx,0x14(%ebp)
  801fd9:	83 ec 08             	sub    $0x8,%esp
  801fdc:	53                   	push   %ebx
  801fdd:	ff 30                	pushl  (%eax)
  801fdf:	ff d6                	call   *%esi
			break;
  801fe1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fe4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801fe7:	e9 04 ff ff ff       	jmp    801ef0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801fec:	8b 45 14             	mov    0x14(%ebp),%eax
  801fef:	8d 50 04             	lea    0x4(%eax),%edx
  801ff2:	89 55 14             	mov    %edx,0x14(%ebp)
  801ff5:	8b 00                	mov    (%eax),%eax
  801ff7:	99                   	cltd   
  801ff8:	31 d0                	xor    %edx,%eax
  801ffa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801ffc:	83 f8 0f             	cmp    $0xf,%eax
  801fff:	7f 0b                	jg     80200c <vprintfmt+0x142>
  802001:	8b 14 85 20 44 80 00 	mov    0x804420(,%eax,4),%edx
  802008:	85 d2                	test   %edx,%edx
  80200a:	75 18                	jne    802024 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80200c:	50                   	push   %eax
  80200d:	68 9b 41 80 00       	push   $0x80419b
  802012:	53                   	push   %ebx
  802013:	56                   	push   %esi
  802014:	e8 94 fe ff ff       	call   801ead <printfmt>
  802019:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80201c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80201f:	e9 cc fe ff ff       	jmp    801ef0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  802024:	52                   	push   %edx
  802025:	68 6f 3a 80 00       	push   $0x803a6f
  80202a:	53                   	push   %ebx
  80202b:	56                   	push   %esi
  80202c:	e8 7c fe ff ff       	call   801ead <printfmt>
  802031:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802034:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802037:	e9 b4 fe ff ff       	jmp    801ef0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80203c:	8b 45 14             	mov    0x14(%ebp),%eax
  80203f:	8d 50 04             	lea    0x4(%eax),%edx
  802042:	89 55 14             	mov    %edx,0x14(%ebp)
  802045:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  802047:	85 ff                	test   %edi,%edi
  802049:	b8 94 41 80 00       	mov    $0x804194,%eax
  80204e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  802051:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  802055:	0f 8e 94 00 00 00    	jle    8020ef <vprintfmt+0x225>
  80205b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80205f:	0f 84 98 00 00 00    	je     8020fd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  802065:	83 ec 08             	sub    $0x8,%esp
  802068:	ff 75 d0             	pushl  -0x30(%ebp)
  80206b:	57                   	push   %edi
  80206c:	e8 86 02 00 00       	call   8022f7 <strnlen>
  802071:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802074:	29 c1                	sub    %eax,%ecx
  802076:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  802079:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80207c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  802080:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802083:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  802086:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802088:	eb 0f                	jmp    802099 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80208a:	83 ec 08             	sub    $0x8,%esp
  80208d:	53                   	push   %ebx
  80208e:	ff 75 e0             	pushl  -0x20(%ebp)
  802091:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802093:	83 ef 01             	sub    $0x1,%edi
  802096:	83 c4 10             	add    $0x10,%esp
  802099:	85 ff                	test   %edi,%edi
  80209b:	7f ed                	jg     80208a <vprintfmt+0x1c0>
  80209d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8020a0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8020a3:	85 c9                	test   %ecx,%ecx
  8020a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8020aa:	0f 49 c1             	cmovns %ecx,%eax
  8020ad:	29 c1                	sub    %eax,%ecx
  8020af:	89 75 08             	mov    %esi,0x8(%ebp)
  8020b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8020b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8020b8:	89 cb                	mov    %ecx,%ebx
  8020ba:	eb 4d                	jmp    802109 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8020bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8020c0:	74 1b                	je     8020dd <vprintfmt+0x213>
  8020c2:	0f be c0             	movsbl %al,%eax
  8020c5:	83 e8 20             	sub    $0x20,%eax
  8020c8:	83 f8 5e             	cmp    $0x5e,%eax
  8020cb:	76 10                	jbe    8020dd <vprintfmt+0x213>
					putch('?', putdat);
  8020cd:	83 ec 08             	sub    $0x8,%esp
  8020d0:	ff 75 0c             	pushl  0xc(%ebp)
  8020d3:	6a 3f                	push   $0x3f
  8020d5:	ff 55 08             	call   *0x8(%ebp)
  8020d8:	83 c4 10             	add    $0x10,%esp
  8020db:	eb 0d                	jmp    8020ea <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8020dd:	83 ec 08             	sub    $0x8,%esp
  8020e0:	ff 75 0c             	pushl  0xc(%ebp)
  8020e3:	52                   	push   %edx
  8020e4:	ff 55 08             	call   *0x8(%ebp)
  8020e7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8020ea:	83 eb 01             	sub    $0x1,%ebx
  8020ed:	eb 1a                	jmp    802109 <vprintfmt+0x23f>
  8020ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8020f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8020f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8020f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8020fb:	eb 0c                	jmp    802109 <vprintfmt+0x23f>
  8020fd:	89 75 08             	mov    %esi,0x8(%ebp)
  802100:	8b 75 d0             	mov    -0x30(%ebp),%esi
  802103:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  802106:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  802109:	83 c7 01             	add    $0x1,%edi
  80210c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  802110:	0f be d0             	movsbl %al,%edx
  802113:	85 d2                	test   %edx,%edx
  802115:	74 23                	je     80213a <vprintfmt+0x270>
  802117:	85 f6                	test   %esi,%esi
  802119:	78 a1                	js     8020bc <vprintfmt+0x1f2>
  80211b:	83 ee 01             	sub    $0x1,%esi
  80211e:	79 9c                	jns    8020bc <vprintfmt+0x1f2>
  802120:	89 df                	mov    %ebx,%edi
  802122:	8b 75 08             	mov    0x8(%ebp),%esi
  802125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802128:	eb 18                	jmp    802142 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80212a:	83 ec 08             	sub    $0x8,%esp
  80212d:	53                   	push   %ebx
  80212e:	6a 20                	push   $0x20
  802130:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  802132:	83 ef 01             	sub    $0x1,%edi
  802135:	83 c4 10             	add    $0x10,%esp
  802138:	eb 08                	jmp    802142 <vprintfmt+0x278>
  80213a:	89 df                	mov    %ebx,%edi
  80213c:	8b 75 08             	mov    0x8(%ebp),%esi
  80213f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802142:	85 ff                	test   %edi,%edi
  802144:	7f e4                	jg     80212a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802146:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802149:	e9 a2 fd ff ff       	jmp    801ef0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80214e:	83 fa 01             	cmp    $0x1,%edx
  802151:	7e 16                	jle    802169 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  802153:	8b 45 14             	mov    0x14(%ebp),%eax
  802156:	8d 50 08             	lea    0x8(%eax),%edx
  802159:	89 55 14             	mov    %edx,0x14(%ebp)
  80215c:	8b 50 04             	mov    0x4(%eax),%edx
  80215f:	8b 00                	mov    (%eax),%eax
  802161:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802164:	89 55 dc             	mov    %edx,-0x24(%ebp)
  802167:	eb 32                	jmp    80219b <vprintfmt+0x2d1>
	else if (lflag)
  802169:	85 d2                	test   %edx,%edx
  80216b:	74 18                	je     802185 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80216d:	8b 45 14             	mov    0x14(%ebp),%eax
  802170:	8d 50 04             	lea    0x4(%eax),%edx
  802173:	89 55 14             	mov    %edx,0x14(%ebp)
  802176:	8b 00                	mov    (%eax),%eax
  802178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80217b:	89 c1                	mov    %eax,%ecx
  80217d:	c1 f9 1f             	sar    $0x1f,%ecx
  802180:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  802183:	eb 16                	jmp    80219b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  802185:	8b 45 14             	mov    0x14(%ebp),%eax
  802188:	8d 50 04             	lea    0x4(%eax),%edx
  80218b:	89 55 14             	mov    %edx,0x14(%ebp)
  80218e:	8b 00                	mov    (%eax),%eax
  802190:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802193:	89 c1                	mov    %eax,%ecx
  802195:	c1 f9 1f             	sar    $0x1f,%ecx
  802198:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80219b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80219e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8021a1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8021a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8021aa:	79 74                	jns    802220 <vprintfmt+0x356>
				putch('-', putdat);
  8021ac:	83 ec 08             	sub    $0x8,%esp
  8021af:	53                   	push   %ebx
  8021b0:	6a 2d                	push   $0x2d
  8021b2:	ff d6                	call   *%esi
				num = -(long long) num;
  8021b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8021b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8021ba:	f7 d8                	neg    %eax
  8021bc:	83 d2 00             	adc    $0x0,%edx
  8021bf:	f7 da                	neg    %edx
  8021c1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8021c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8021c9:	eb 55                	jmp    802220 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8021cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8021ce:	e8 83 fc ff ff       	call   801e56 <getuint>
			base = 10;
  8021d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8021d8:	eb 46                	jmp    802220 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8021da:	8d 45 14             	lea    0x14(%ebp),%eax
  8021dd:	e8 74 fc ff ff       	call   801e56 <getuint>
			base = 8;
  8021e2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8021e7:	eb 37                	jmp    802220 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8021e9:	83 ec 08             	sub    $0x8,%esp
  8021ec:	53                   	push   %ebx
  8021ed:	6a 30                	push   $0x30
  8021ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8021f1:	83 c4 08             	add    $0x8,%esp
  8021f4:	53                   	push   %ebx
  8021f5:	6a 78                	push   $0x78
  8021f7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8021f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8021fc:	8d 50 04             	lea    0x4(%eax),%edx
  8021ff:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  802202:	8b 00                	mov    (%eax),%eax
  802204:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  802209:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80220c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  802211:	eb 0d                	jmp    802220 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802213:	8d 45 14             	lea    0x14(%ebp),%eax
  802216:	e8 3b fc ff ff       	call   801e56 <getuint>
			base = 16;
  80221b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  802220:	83 ec 0c             	sub    $0xc,%esp
  802223:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  802227:	57                   	push   %edi
  802228:	ff 75 e0             	pushl  -0x20(%ebp)
  80222b:	51                   	push   %ecx
  80222c:	52                   	push   %edx
  80222d:	50                   	push   %eax
  80222e:	89 da                	mov    %ebx,%edx
  802230:	89 f0                	mov    %esi,%eax
  802232:	e8 70 fb ff ff       	call   801da7 <printnum>
			break;
  802237:	83 c4 20             	add    $0x20,%esp
  80223a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80223d:	e9 ae fc ff ff       	jmp    801ef0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  802242:	83 ec 08             	sub    $0x8,%esp
  802245:	53                   	push   %ebx
  802246:	51                   	push   %ecx
  802247:	ff d6                	call   *%esi
			break;
  802249:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80224c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80224f:	e9 9c fc ff ff       	jmp    801ef0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802254:	83 ec 08             	sub    $0x8,%esp
  802257:	53                   	push   %ebx
  802258:	6a 25                	push   $0x25
  80225a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80225c:	83 c4 10             	add    $0x10,%esp
  80225f:	eb 03                	jmp    802264 <vprintfmt+0x39a>
  802261:	83 ef 01             	sub    $0x1,%edi
  802264:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802268:	75 f7                	jne    802261 <vprintfmt+0x397>
  80226a:	e9 81 fc ff ff       	jmp    801ef0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80226f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802272:	5b                   	pop    %ebx
  802273:	5e                   	pop    %esi
  802274:	5f                   	pop    %edi
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    

00802277 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	83 ec 18             	sub    $0x18,%esp
  80227d:	8b 45 08             	mov    0x8(%ebp),%eax
  802280:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802283:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802286:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80228a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80228d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802294:	85 c0                	test   %eax,%eax
  802296:	74 26                	je     8022be <vsnprintf+0x47>
  802298:	85 d2                	test   %edx,%edx
  80229a:	7e 22                	jle    8022be <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80229c:	ff 75 14             	pushl  0x14(%ebp)
  80229f:	ff 75 10             	pushl  0x10(%ebp)
  8022a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8022a5:	50                   	push   %eax
  8022a6:	68 90 1e 80 00       	push   $0x801e90
  8022ab:	e8 1a fc ff ff       	call   801eca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8022b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8022b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8022b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b9:	83 c4 10             	add    $0x10,%esp
  8022bc:	eb 05                	jmp    8022c3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8022be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8022c3:	c9                   	leave  
  8022c4:	c3                   	ret    

008022c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8022cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8022ce:	50                   	push   %eax
  8022cf:	ff 75 10             	pushl  0x10(%ebp)
  8022d2:	ff 75 0c             	pushl  0xc(%ebp)
  8022d5:	ff 75 08             	pushl  0x8(%ebp)
  8022d8:	e8 9a ff ff ff       	call   802277 <vsnprintf>
	va_end(ap);

	return rc;
}
  8022dd:	c9                   	leave  
  8022de:	c3                   	ret    

008022df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8022df:	55                   	push   %ebp
  8022e0:	89 e5                	mov    %esp,%ebp
  8022e2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8022e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ea:	eb 03                	jmp    8022ef <strlen+0x10>
		n++;
  8022ec:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8022ef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8022f3:	75 f7                	jne    8022ec <strlen+0xd>
		n++;
	return n;
}
  8022f5:	5d                   	pop    %ebp
  8022f6:	c3                   	ret    

008022f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8022f7:	55                   	push   %ebp
  8022f8:	89 e5                	mov    %esp,%ebp
  8022fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802300:	ba 00 00 00 00       	mov    $0x0,%edx
  802305:	eb 03                	jmp    80230a <strnlen+0x13>
		n++;
  802307:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80230a:	39 c2                	cmp    %eax,%edx
  80230c:	74 08                	je     802316 <strnlen+0x1f>
  80230e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  802312:	75 f3                	jne    802307 <strnlen+0x10>
  802314:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802316:	5d                   	pop    %ebp
  802317:	c3                   	ret    

00802318 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	53                   	push   %ebx
  80231c:	8b 45 08             	mov    0x8(%ebp),%eax
  80231f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802322:	89 c2                	mov    %eax,%edx
  802324:	83 c2 01             	add    $0x1,%edx
  802327:	83 c1 01             	add    $0x1,%ecx
  80232a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80232e:	88 5a ff             	mov    %bl,-0x1(%edx)
  802331:	84 db                	test   %bl,%bl
  802333:	75 ef                	jne    802324 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802335:	5b                   	pop    %ebx
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    

00802338 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	53                   	push   %ebx
  80233c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80233f:	53                   	push   %ebx
  802340:	e8 9a ff ff ff       	call   8022df <strlen>
  802345:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802348:	ff 75 0c             	pushl  0xc(%ebp)
  80234b:	01 d8                	add    %ebx,%eax
  80234d:	50                   	push   %eax
  80234e:	e8 c5 ff ff ff       	call   802318 <strcpy>
	return dst;
}
  802353:	89 d8                	mov    %ebx,%eax
  802355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802358:	c9                   	leave  
  802359:	c3                   	ret    

0080235a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80235a:	55                   	push   %ebp
  80235b:	89 e5                	mov    %esp,%ebp
  80235d:	56                   	push   %esi
  80235e:	53                   	push   %ebx
  80235f:	8b 75 08             	mov    0x8(%ebp),%esi
  802362:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802365:	89 f3                	mov    %esi,%ebx
  802367:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80236a:	89 f2                	mov    %esi,%edx
  80236c:	eb 0f                	jmp    80237d <strncpy+0x23>
		*dst++ = *src;
  80236e:	83 c2 01             	add    $0x1,%edx
  802371:	0f b6 01             	movzbl (%ecx),%eax
  802374:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802377:	80 39 01             	cmpb   $0x1,(%ecx)
  80237a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80237d:	39 da                	cmp    %ebx,%edx
  80237f:	75 ed                	jne    80236e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802381:	89 f0                	mov    %esi,%eax
  802383:	5b                   	pop    %ebx
  802384:	5e                   	pop    %esi
  802385:	5d                   	pop    %ebp
  802386:	c3                   	ret    

00802387 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802387:	55                   	push   %ebp
  802388:	89 e5                	mov    %esp,%ebp
  80238a:	56                   	push   %esi
  80238b:	53                   	push   %ebx
  80238c:	8b 75 08             	mov    0x8(%ebp),%esi
  80238f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802392:	8b 55 10             	mov    0x10(%ebp),%edx
  802395:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802397:	85 d2                	test   %edx,%edx
  802399:	74 21                	je     8023bc <strlcpy+0x35>
  80239b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	eb 09                	jmp    8023ac <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8023a3:	83 c2 01             	add    $0x1,%edx
  8023a6:	83 c1 01             	add    $0x1,%ecx
  8023a9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8023ac:	39 c2                	cmp    %eax,%edx
  8023ae:	74 09                	je     8023b9 <strlcpy+0x32>
  8023b0:	0f b6 19             	movzbl (%ecx),%ebx
  8023b3:	84 db                	test   %bl,%bl
  8023b5:	75 ec                	jne    8023a3 <strlcpy+0x1c>
  8023b7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8023b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8023bc:	29 f0                	sub    %esi,%eax
}
  8023be:	5b                   	pop    %ebx
  8023bf:	5e                   	pop    %esi
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    

008023c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8023cb:	eb 06                	jmp    8023d3 <strcmp+0x11>
		p++, q++;
  8023cd:	83 c1 01             	add    $0x1,%ecx
  8023d0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8023d3:	0f b6 01             	movzbl (%ecx),%eax
  8023d6:	84 c0                	test   %al,%al
  8023d8:	74 04                	je     8023de <strcmp+0x1c>
  8023da:	3a 02                	cmp    (%edx),%al
  8023dc:	74 ef                	je     8023cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8023de:	0f b6 c0             	movzbl %al,%eax
  8023e1:	0f b6 12             	movzbl (%edx),%edx
  8023e4:	29 d0                	sub    %edx,%eax
}
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    

008023e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8023e8:	55                   	push   %ebp
  8023e9:	89 e5                	mov    %esp,%ebp
  8023eb:	53                   	push   %ebx
  8023ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023f2:	89 c3                	mov    %eax,%ebx
  8023f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8023f7:	eb 06                	jmp    8023ff <strncmp+0x17>
		n--, p++, q++;
  8023f9:	83 c0 01             	add    $0x1,%eax
  8023fc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8023ff:	39 d8                	cmp    %ebx,%eax
  802401:	74 15                	je     802418 <strncmp+0x30>
  802403:	0f b6 08             	movzbl (%eax),%ecx
  802406:	84 c9                	test   %cl,%cl
  802408:	74 04                	je     80240e <strncmp+0x26>
  80240a:	3a 0a                	cmp    (%edx),%cl
  80240c:	74 eb                	je     8023f9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80240e:	0f b6 00             	movzbl (%eax),%eax
  802411:	0f b6 12             	movzbl (%edx),%edx
  802414:	29 d0                	sub    %edx,%eax
  802416:	eb 05                	jmp    80241d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802418:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80241d:	5b                   	pop    %ebx
  80241e:	5d                   	pop    %ebp
  80241f:	c3                   	ret    

00802420 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	8b 45 08             	mov    0x8(%ebp),%eax
  802426:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80242a:	eb 07                	jmp    802433 <strchr+0x13>
		if (*s == c)
  80242c:	38 ca                	cmp    %cl,%dl
  80242e:	74 0f                	je     80243f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802430:	83 c0 01             	add    $0x1,%eax
  802433:	0f b6 10             	movzbl (%eax),%edx
  802436:	84 d2                	test   %dl,%dl
  802438:	75 f2                	jne    80242c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80243a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80243f:	5d                   	pop    %ebp
  802440:	c3                   	ret    

00802441 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802441:	55                   	push   %ebp
  802442:	89 e5                	mov    %esp,%ebp
  802444:	8b 45 08             	mov    0x8(%ebp),%eax
  802447:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80244b:	eb 03                	jmp    802450 <strfind+0xf>
  80244d:	83 c0 01             	add    $0x1,%eax
  802450:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802453:	38 ca                	cmp    %cl,%dl
  802455:	74 04                	je     80245b <strfind+0x1a>
  802457:	84 d2                	test   %dl,%dl
  802459:	75 f2                	jne    80244d <strfind+0xc>
			break;
	return (char *) s;
}
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    

0080245d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80245d:	55                   	push   %ebp
  80245e:	89 e5                	mov    %esp,%ebp
  802460:	57                   	push   %edi
  802461:	56                   	push   %esi
  802462:	53                   	push   %ebx
  802463:	8b 7d 08             	mov    0x8(%ebp),%edi
  802466:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802469:	85 c9                	test   %ecx,%ecx
  80246b:	74 36                	je     8024a3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80246d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802473:	75 28                	jne    80249d <memset+0x40>
  802475:	f6 c1 03             	test   $0x3,%cl
  802478:	75 23                	jne    80249d <memset+0x40>
		c &= 0xFF;
  80247a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80247e:	89 d3                	mov    %edx,%ebx
  802480:	c1 e3 08             	shl    $0x8,%ebx
  802483:	89 d6                	mov    %edx,%esi
  802485:	c1 e6 18             	shl    $0x18,%esi
  802488:	89 d0                	mov    %edx,%eax
  80248a:	c1 e0 10             	shl    $0x10,%eax
  80248d:	09 f0                	or     %esi,%eax
  80248f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  802491:	89 d8                	mov    %ebx,%eax
  802493:	09 d0                	or     %edx,%eax
  802495:	c1 e9 02             	shr    $0x2,%ecx
  802498:	fc                   	cld    
  802499:	f3 ab                	rep stos %eax,%es:(%edi)
  80249b:	eb 06                	jmp    8024a3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80249d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a0:	fc                   	cld    
  8024a1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8024a3:	89 f8                	mov    %edi,%eax
  8024a5:	5b                   	pop    %ebx
  8024a6:	5e                   	pop    %esi
  8024a7:	5f                   	pop    %edi
  8024a8:	5d                   	pop    %ebp
  8024a9:	c3                   	ret    

008024aa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8024aa:	55                   	push   %ebp
  8024ab:	89 e5                	mov    %esp,%ebp
  8024ad:	57                   	push   %edi
  8024ae:	56                   	push   %esi
  8024af:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8024b8:	39 c6                	cmp    %eax,%esi
  8024ba:	73 35                	jae    8024f1 <memmove+0x47>
  8024bc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8024bf:	39 d0                	cmp    %edx,%eax
  8024c1:	73 2e                	jae    8024f1 <memmove+0x47>
		s += n;
		d += n;
  8024c3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8024c6:	89 d6                	mov    %edx,%esi
  8024c8:	09 fe                	or     %edi,%esi
  8024ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8024d0:	75 13                	jne    8024e5 <memmove+0x3b>
  8024d2:	f6 c1 03             	test   $0x3,%cl
  8024d5:	75 0e                	jne    8024e5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8024d7:	83 ef 04             	sub    $0x4,%edi
  8024da:	8d 72 fc             	lea    -0x4(%edx),%esi
  8024dd:	c1 e9 02             	shr    $0x2,%ecx
  8024e0:	fd                   	std    
  8024e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8024e3:	eb 09                	jmp    8024ee <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8024e5:	83 ef 01             	sub    $0x1,%edi
  8024e8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8024eb:	fd                   	std    
  8024ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8024ee:	fc                   	cld    
  8024ef:	eb 1d                	jmp    80250e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8024f1:	89 f2                	mov    %esi,%edx
  8024f3:	09 c2                	or     %eax,%edx
  8024f5:	f6 c2 03             	test   $0x3,%dl
  8024f8:	75 0f                	jne    802509 <memmove+0x5f>
  8024fa:	f6 c1 03             	test   $0x3,%cl
  8024fd:	75 0a                	jne    802509 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8024ff:	c1 e9 02             	shr    $0x2,%ecx
  802502:	89 c7                	mov    %eax,%edi
  802504:	fc                   	cld    
  802505:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802507:	eb 05                	jmp    80250e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802509:	89 c7                	mov    %eax,%edi
  80250b:	fc                   	cld    
  80250c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80250e:	5e                   	pop    %esi
  80250f:	5f                   	pop    %edi
  802510:	5d                   	pop    %ebp
  802511:	c3                   	ret    

00802512 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802512:	55                   	push   %ebp
  802513:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802515:	ff 75 10             	pushl  0x10(%ebp)
  802518:	ff 75 0c             	pushl  0xc(%ebp)
  80251b:	ff 75 08             	pushl  0x8(%ebp)
  80251e:	e8 87 ff ff ff       	call   8024aa <memmove>
}
  802523:	c9                   	leave  
  802524:	c3                   	ret    

00802525 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
  802528:	56                   	push   %esi
  802529:	53                   	push   %ebx
  80252a:	8b 45 08             	mov    0x8(%ebp),%eax
  80252d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802530:	89 c6                	mov    %eax,%esi
  802532:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802535:	eb 1a                	jmp    802551 <memcmp+0x2c>
		if (*s1 != *s2)
  802537:	0f b6 08             	movzbl (%eax),%ecx
  80253a:	0f b6 1a             	movzbl (%edx),%ebx
  80253d:	38 d9                	cmp    %bl,%cl
  80253f:	74 0a                	je     80254b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802541:	0f b6 c1             	movzbl %cl,%eax
  802544:	0f b6 db             	movzbl %bl,%ebx
  802547:	29 d8                	sub    %ebx,%eax
  802549:	eb 0f                	jmp    80255a <memcmp+0x35>
		s1++, s2++;
  80254b:	83 c0 01             	add    $0x1,%eax
  80254e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802551:	39 f0                	cmp    %esi,%eax
  802553:	75 e2                	jne    802537 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802555:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80255a:	5b                   	pop    %ebx
  80255b:	5e                   	pop    %esi
  80255c:	5d                   	pop    %ebp
  80255d:	c3                   	ret    

0080255e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80255e:	55                   	push   %ebp
  80255f:	89 e5                	mov    %esp,%ebp
  802561:	53                   	push   %ebx
  802562:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802565:	89 c1                	mov    %eax,%ecx
  802567:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80256a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80256e:	eb 0a                	jmp    80257a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802570:	0f b6 10             	movzbl (%eax),%edx
  802573:	39 da                	cmp    %ebx,%edx
  802575:	74 07                	je     80257e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802577:	83 c0 01             	add    $0x1,%eax
  80257a:	39 c8                	cmp    %ecx,%eax
  80257c:	72 f2                	jb     802570 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80257e:	5b                   	pop    %ebx
  80257f:	5d                   	pop    %ebp
  802580:	c3                   	ret    

00802581 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802581:	55                   	push   %ebp
  802582:	89 e5                	mov    %esp,%ebp
  802584:	57                   	push   %edi
  802585:	56                   	push   %esi
  802586:	53                   	push   %ebx
  802587:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80258a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80258d:	eb 03                	jmp    802592 <strtol+0x11>
		s++;
  80258f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802592:	0f b6 01             	movzbl (%ecx),%eax
  802595:	3c 20                	cmp    $0x20,%al
  802597:	74 f6                	je     80258f <strtol+0xe>
  802599:	3c 09                	cmp    $0x9,%al
  80259b:	74 f2                	je     80258f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80259d:	3c 2b                	cmp    $0x2b,%al
  80259f:	75 0a                	jne    8025ab <strtol+0x2a>
		s++;
  8025a1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8025a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8025a9:	eb 11                	jmp    8025bc <strtol+0x3b>
  8025ab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8025b0:	3c 2d                	cmp    $0x2d,%al
  8025b2:	75 08                	jne    8025bc <strtol+0x3b>
		s++, neg = 1;
  8025b4:	83 c1 01             	add    $0x1,%ecx
  8025b7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8025bc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8025c2:	75 15                	jne    8025d9 <strtol+0x58>
  8025c4:	80 39 30             	cmpb   $0x30,(%ecx)
  8025c7:	75 10                	jne    8025d9 <strtol+0x58>
  8025c9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8025cd:	75 7c                	jne    80264b <strtol+0xca>
		s += 2, base = 16;
  8025cf:	83 c1 02             	add    $0x2,%ecx
  8025d2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8025d7:	eb 16                	jmp    8025ef <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8025d9:	85 db                	test   %ebx,%ebx
  8025db:	75 12                	jne    8025ef <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8025dd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8025e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8025e5:	75 08                	jne    8025ef <strtol+0x6e>
		s++, base = 8;
  8025e7:	83 c1 01             	add    $0x1,%ecx
  8025ea:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8025ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8025f4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8025f7:	0f b6 11             	movzbl (%ecx),%edx
  8025fa:	8d 72 d0             	lea    -0x30(%edx),%esi
  8025fd:	89 f3                	mov    %esi,%ebx
  8025ff:	80 fb 09             	cmp    $0x9,%bl
  802602:	77 08                	ja     80260c <strtol+0x8b>
			dig = *s - '0';
  802604:	0f be d2             	movsbl %dl,%edx
  802607:	83 ea 30             	sub    $0x30,%edx
  80260a:	eb 22                	jmp    80262e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80260c:	8d 72 9f             	lea    -0x61(%edx),%esi
  80260f:	89 f3                	mov    %esi,%ebx
  802611:	80 fb 19             	cmp    $0x19,%bl
  802614:	77 08                	ja     80261e <strtol+0x9d>
			dig = *s - 'a' + 10;
  802616:	0f be d2             	movsbl %dl,%edx
  802619:	83 ea 57             	sub    $0x57,%edx
  80261c:	eb 10                	jmp    80262e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80261e:	8d 72 bf             	lea    -0x41(%edx),%esi
  802621:	89 f3                	mov    %esi,%ebx
  802623:	80 fb 19             	cmp    $0x19,%bl
  802626:	77 16                	ja     80263e <strtol+0xbd>
			dig = *s - 'A' + 10;
  802628:	0f be d2             	movsbl %dl,%edx
  80262b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80262e:	3b 55 10             	cmp    0x10(%ebp),%edx
  802631:	7d 0b                	jge    80263e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802633:	83 c1 01             	add    $0x1,%ecx
  802636:	0f af 45 10          	imul   0x10(%ebp),%eax
  80263a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80263c:	eb b9                	jmp    8025f7 <strtol+0x76>

	if (endptr)
  80263e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802642:	74 0d                	je     802651 <strtol+0xd0>
		*endptr = (char *) s;
  802644:	8b 75 0c             	mov    0xc(%ebp),%esi
  802647:	89 0e                	mov    %ecx,(%esi)
  802649:	eb 06                	jmp    802651 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80264b:	85 db                	test   %ebx,%ebx
  80264d:	74 98                	je     8025e7 <strtol+0x66>
  80264f:	eb 9e                	jmp    8025ef <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802651:	89 c2                	mov    %eax,%edx
  802653:	f7 da                	neg    %edx
  802655:	85 ff                	test   %edi,%edi
  802657:	0f 45 c2             	cmovne %edx,%eax
}
  80265a:	5b                   	pop    %ebx
  80265b:	5e                   	pop    %esi
  80265c:	5f                   	pop    %edi
  80265d:	5d                   	pop    %ebp
  80265e:	c3                   	ret    

0080265f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80265f:	55                   	push   %ebp
  802660:	89 e5                	mov    %esp,%ebp
  802662:	57                   	push   %edi
  802663:	56                   	push   %esi
  802664:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802665:	b8 00 00 00 00       	mov    $0x0,%eax
  80266a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80266d:	8b 55 08             	mov    0x8(%ebp),%edx
  802670:	89 c3                	mov    %eax,%ebx
  802672:	89 c7                	mov    %eax,%edi
  802674:	89 c6                	mov    %eax,%esi
  802676:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802678:	5b                   	pop    %ebx
  802679:	5e                   	pop    %esi
  80267a:	5f                   	pop    %edi
  80267b:	5d                   	pop    %ebp
  80267c:	c3                   	ret    

0080267d <sys_cgetc>:

int
sys_cgetc(void)
{
  80267d:	55                   	push   %ebp
  80267e:	89 e5                	mov    %esp,%ebp
  802680:	57                   	push   %edi
  802681:	56                   	push   %esi
  802682:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802683:	ba 00 00 00 00       	mov    $0x0,%edx
  802688:	b8 01 00 00 00       	mov    $0x1,%eax
  80268d:	89 d1                	mov    %edx,%ecx
  80268f:	89 d3                	mov    %edx,%ebx
  802691:	89 d7                	mov    %edx,%edi
  802693:	89 d6                	mov    %edx,%esi
  802695:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802697:	5b                   	pop    %ebx
  802698:	5e                   	pop    %esi
  802699:	5f                   	pop    %edi
  80269a:	5d                   	pop    %ebp
  80269b:	c3                   	ret    

0080269c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80269c:	55                   	push   %ebp
  80269d:	89 e5                	mov    %esp,%ebp
  80269f:	57                   	push   %edi
  8026a0:	56                   	push   %esi
  8026a1:	53                   	push   %ebx
  8026a2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026aa:	b8 03 00 00 00       	mov    $0x3,%eax
  8026af:	8b 55 08             	mov    0x8(%ebp),%edx
  8026b2:	89 cb                	mov    %ecx,%ebx
  8026b4:	89 cf                	mov    %ecx,%edi
  8026b6:	89 ce                	mov    %ecx,%esi
  8026b8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026ba:	85 c0                	test   %eax,%eax
  8026bc:	7e 17                	jle    8026d5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026be:	83 ec 0c             	sub    $0xc,%esp
  8026c1:	50                   	push   %eax
  8026c2:	6a 03                	push   $0x3
  8026c4:	68 7f 44 80 00       	push   $0x80447f
  8026c9:	6a 23                	push   $0x23
  8026cb:	68 9c 44 80 00       	push   $0x80449c
  8026d0:	e8 e5 f5 ff ff       	call   801cba <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8026d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026d8:	5b                   	pop    %ebx
  8026d9:	5e                   	pop    %esi
  8026da:	5f                   	pop    %edi
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    

008026dd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8026dd:	55                   	push   %ebp
  8026de:	89 e5                	mov    %esp,%ebp
  8026e0:	57                   	push   %edi
  8026e1:	56                   	push   %esi
  8026e2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8026e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8026ed:	89 d1                	mov    %edx,%ecx
  8026ef:	89 d3                	mov    %edx,%ebx
  8026f1:	89 d7                	mov    %edx,%edi
  8026f3:	89 d6                	mov    %edx,%esi
  8026f5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8026f7:	5b                   	pop    %ebx
  8026f8:	5e                   	pop    %esi
  8026f9:	5f                   	pop    %edi
  8026fa:	5d                   	pop    %ebp
  8026fb:	c3                   	ret    

008026fc <sys_yield>:

void
sys_yield(void)
{
  8026fc:	55                   	push   %ebp
  8026fd:	89 e5                	mov    %esp,%ebp
  8026ff:	57                   	push   %edi
  802700:	56                   	push   %esi
  802701:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802702:	ba 00 00 00 00       	mov    $0x0,%edx
  802707:	b8 0b 00 00 00       	mov    $0xb,%eax
  80270c:	89 d1                	mov    %edx,%ecx
  80270e:	89 d3                	mov    %edx,%ebx
  802710:	89 d7                	mov    %edx,%edi
  802712:	89 d6                	mov    %edx,%esi
  802714:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802716:	5b                   	pop    %ebx
  802717:	5e                   	pop    %esi
  802718:	5f                   	pop    %edi
  802719:	5d                   	pop    %ebp
  80271a:	c3                   	ret    

0080271b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80271b:	55                   	push   %ebp
  80271c:	89 e5                	mov    %esp,%ebp
  80271e:	57                   	push   %edi
  80271f:	56                   	push   %esi
  802720:	53                   	push   %ebx
  802721:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802724:	be 00 00 00 00       	mov    $0x0,%esi
  802729:	b8 04 00 00 00       	mov    $0x4,%eax
  80272e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802731:	8b 55 08             	mov    0x8(%ebp),%edx
  802734:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802737:	89 f7                	mov    %esi,%edi
  802739:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80273b:	85 c0                	test   %eax,%eax
  80273d:	7e 17                	jle    802756 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80273f:	83 ec 0c             	sub    $0xc,%esp
  802742:	50                   	push   %eax
  802743:	6a 04                	push   $0x4
  802745:	68 7f 44 80 00       	push   $0x80447f
  80274a:	6a 23                	push   $0x23
  80274c:	68 9c 44 80 00       	push   $0x80449c
  802751:	e8 64 f5 ff ff       	call   801cba <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802756:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802759:	5b                   	pop    %ebx
  80275a:	5e                   	pop    %esi
  80275b:	5f                   	pop    %edi
  80275c:	5d                   	pop    %ebp
  80275d:	c3                   	ret    

0080275e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80275e:	55                   	push   %ebp
  80275f:	89 e5                	mov    %esp,%ebp
  802761:	57                   	push   %edi
  802762:	56                   	push   %esi
  802763:	53                   	push   %ebx
  802764:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802767:	b8 05 00 00 00       	mov    $0x5,%eax
  80276c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80276f:	8b 55 08             	mov    0x8(%ebp),%edx
  802772:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802775:	8b 7d 14             	mov    0x14(%ebp),%edi
  802778:	8b 75 18             	mov    0x18(%ebp),%esi
  80277b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80277d:	85 c0                	test   %eax,%eax
  80277f:	7e 17                	jle    802798 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802781:	83 ec 0c             	sub    $0xc,%esp
  802784:	50                   	push   %eax
  802785:	6a 05                	push   $0x5
  802787:	68 7f 44 80 00       	push   $0x80447f
  80278c:	6a 23                	push   $0x23
  80278e:	68 9c 44 80 00       	push   $0x80449c
  802793:	e8 22 f5 ff ff       	call   801cba <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802798:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80279b:	5b                   	pop    %ebx
  80279c:	5e                   	pop    %esi
  80279d:	5f                   	pop    %edi
  80279e:	5d                   	pop    %ebp
  80279f:	c3                   	ret    

008027a0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8027a0:	55                   	push   %ebp
  8027a1:	89 e5                	mov    %esp,%ebp
  8027a3:	57                   	push   %edi
  8027a4:	56                   	push   %esi
  8027a5:	53                   	push   %ebx
  8027a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8027b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8027b9:	89 df                	mov    %ebx,%edi
  8027bb:	89 de                	mov    %ebx,%esi
  8027bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8027bf:	85 c0                	test   %eax,%eax
  8027c1:	7e 17                	jle    8027da <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8027c3:	83 ec 0c             	sub    $0xc,%esp
  8027c6:	50                   	push   %eax
  8027c7:	6a 06                	push   $0x6
  8027c9:	68 7f 44 80 00       	push   $0x80447f
  8027ce:	6a 23                	push   $0x23
  8027d0:	68 9c 44 80 00       	push   $0x80449c
  8027d5:	e8 e0 f4 ff ff       	call   801cba <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8027da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027dd:	5b                   	pop    %ebx
  8027de:	5e                   	pop    %esi
  8027df:	5f                   	pop    %edi
  8027e0:	5d                   	pop    %ebp
  8027e1:	c3                   	ret    

008027e2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8027e2:	55                   	push   %ebp
  8027e3:	89 e5                	mov    %esp,%ebp
  8027e5:	57                   	push   %edi
  8027e6:	56                   	push   %esi
  8027e7:	53                   	push   %ebx
  8027e8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8027f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8027fb:	89 df                	mov    %ebx,%edi
  8027fd:	89 de                	mov    %ebx,%esi
  8027ff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802801:	85 c0                	test   %eax,%eax
  802803:	7e 17                	jle    80281c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802805:	83 ec 0c             	sub    $0xc,%esp
  802808:	50                   	push   %eax
  802809:	6a 08                	push   $0x8
  80280b:	68 7f 44 80 00       	push   $0x80447f
  802810:	6a 23                	push   $0x23
  802812:	68 9c 44 80 00       	push   $0x80449c
  802817:	e8 9e f4 ff ff       	call   801cba <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80281c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80281f:	5b                   	pop    %ebx
  802820:	5e                   	pop    %esi
  802821:	5f                   	pop    %edi
  802822:	5d                   	pop    %ebp
  802823:	c3                   	ret    

00802824 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802824:	55                   	push   %ebp
  802825:	89 e5                	mov    %esp,%ebp
  802827:	57                   	push   %edi
  802828:	56                   	push   %esi
  802829:	53                   	push   %ebx
  80282a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80282d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802832:	b8 09 00 00 00       	mov    $0x9,%eax
  802837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80283a:	8b 55 08             	mov    0x8(%ebp),%edx
  80283d:	89 df                	mov    %ebx,%edi
  80283f:	89 de                	mov    %ebx,%esi
  802841:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802843:	85 c0                	test   %eax,%eax
  802845:	7e 17                	jle    80285e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802847:	83 ec 0c             	sub    $0xc,%esp
  80284a:	50                   	push   %eax
  80284b:	6a 09                	push   $0x9
  80284d:	68 7f 44 80 00       	push   $0x80447f
  802852:	6a 23                	push   $0x23
  802854:	68 9c 44 80 00       	push   $0x80449c
  802859:	e8 5c f4 ff ff       	call   801cba <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80285e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802861:	5b                   	pop    %ebx
  802862:	5e                   	pop    %esi
  802863:	5f                   	pop    %edi
  802864:	5d                   	pop    %ebp
  802865:	c3                   	ret    

00802866 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802866:	55                   	push   %ebp
  802867:	89 e5                	mov    %esp,%ebp
  802869:	57                   	push   %edi
  80286a:	56                   	push   %esi
  80286b:	53                   	push   %ebx
  80286c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80286f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802874:	b8 0a 00 00 00       	mov    $0xa,%eax
  802879:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80287c:	8b 55 08             	mov    0x8(%ebp),%edx
  80287f:	89 df                	mov    %ebx,%edi
  802881:	89 de                	mov    %ebx,%esi
  802883:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802885:	85 c0                	test   %eax,%eax
  802887:	7e 17                	jle    8028a0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802889:	83 ec 0c             	sub    $0xc,%esp
  80288c:	50                   	push   %eax
  80288d:	6a 0a                	push   $0xa
  80288f:	68 7f 44 80 00       	push   $0x80447f
  802894:	6a 23                	push   $0x23
  802896:	68 9c 44 80 00       	push   $0x80449c
  80289b:	e8 1a f4 ff ff       	call   801cba <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8028a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028a3:	5b                   	pop    %ebx
  8028a4:	5e                   	pop    %esi
  8028a5:	5f                   	pop    %edi
  8028a6:	5d                   	pop    %ebp
  8028a7:	c3                   	ret    

008028a8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8028a8:	55                   	push   %ebp
  8028a9:	89 e5                	mov    %esp,%ebp
  8028ab:	57                   	push   %edi
  8028ac:	56                   	push   %esi
  8028ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028ae:	be 00 00 00 00       	mov    $0x0,%esi
  8028b3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8028b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8028be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8028c1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8028c4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8028c6:	5b                   	pop    %ebx
  8028c7:	5e                   	pop    %esi
  8028c8:	5f                   	pop    %edi
  8028c9:	5d                   	pop    %ebp
  8028ca:	c3                   	ret    

008028cb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8028cb:	55                   	push   %ebp
  8028cc:	89 e5                	mov    %esp,%ebp
  8028ce:	57                   	push   %edi
  8028cf:	56                   	push   %esi
  8028d0:	53                   	push   %ebx
  8028d1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8028d9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8028de:	8b 55 08             	mov    0x8(%ebp),%edx
  8028e1:	89 cb                	mov    %ecx,%ebx
  8028e3:	89 cf                	mov    %ecx,%edi
  8028e5:	89 ce                	mov    %ecx,%esi
  8028e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8028e9:	85 c0                	test   %eax,%eax
  8028eb:	7e 17                	jle    802904 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8028ed:	83 ec 0c             	sub    $0xc,%esp
  8028f0:	50                   	push   %eax
  8028f1:	6a 0d                	push   $0xd
  8028f3:	68 7f 44 80 00       	push   $0x80447f
  8028f8:	6a 23                	push   $0x23
  8028fa:	68 9c 44 80 00       	push   $0x80449c
  8028ff:	e8 b6 f3 ff ff       	call   801cba <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802904:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802907:	5b                   	pop    %ebx
  802908:	5e                   	pop    %esi
  802909:	5f                   	pop    %edi
  80290a:	5d                   	pop    %ebp
  80290b:	c3                   	ret    

0080290c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80290c:	55                   	push   %ebp
  80290d:	89 e5                	mov    %esp,%ebp
  80290f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802912:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802919:	75 2e                	jne    802949 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80291b:	e8 bd fd ff ff       	call   8026dd <sys_getenvid>
  802920:	83 ec 04             	sub    $0x4,%esp
  802923:	68 07 0e 00 00       	push   $0xe07
  802928:	68 00 f0 bf ee       	push   $0xeebff000
  80292d:	50                   	push   %eax
  80292e:	e8 e8 fd ff ff       	call   80271b <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802933:	e8 a5 fd ff ff       	call   8026dd <sys_getenvid>
  802938:	83 c4 08             	add    $0x8,%esp
  80293b:	68 53 29 80 00       	push   $0x802953
  802940:	50                   	push   %eax
  802941:	e8 20 ff ff ff       	call   802866 <sys_env_set_pgfault_upcall>
  802946:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802949:	8b 45 08             	mov    0x8(%ebp),%eax
  80294c:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  802951:	c9                   	leave  
  802952:	c3                   	ret    

00802953 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802953:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802954:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802959:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80295b:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80295e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802962:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802966:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802969:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80296c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80296d:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802970:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802971:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802972:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802976:	c3                   	ret    

00802977 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802977:	55                   	push   %ebp
  802978:	89 e5                	mov    %esp,%ebp
  80297a:	56                   	push   %esi
  80297b:	53                   	push   %ebx
  80297c:	8b 75 08             	mov    0x8(%ebp),%esi
  80297f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802982:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802985:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802987:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80298c:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80298f:	83 ec 0c             	sub    $0xc,%esp
  802992:	50                   	push   %eax
  802993:	e8 33 ff ff ff       	call   8028cb <sys_ipc_recv>

	if (from_env_store != NULL)
  802998:	83 c4 10             	add    $0x10,%esp
  80299b:	85 f6                	test   %esi,%esi
  80299d:	74 14                	je     8029b3 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80299f:	ba 00 00 00 00       	mov    $0x0,%edx
  8029a4:	85 c0                	test   %eax,%eax
  8029a6:	78 09                	js     8029b1 <ipc_recv+0x3a>
  8029a8:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8029ae:	8b 52 74             	mov    0x74(%edx),%edx
  8029b1:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8029b3:	85 db                	test   %ebx,%ebx
  8029b5:	74 14                	je     8029cb <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8029b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8029bc:	85 c0                	test   %eax,%eax
  8029be:	78 09                	js     8029c9 <ipc_recv+0x52>
  8029c0:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8029c6:	8b 52 78             	mov    0x78(%edx),%edx
  8029c9:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8029cb:	85 c0                	test   %eax,%eax
  8029cd:	78 08                	js     8029d7 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8029cf:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029d4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8029d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029da:	5b                   	pop    %ebx
  8029db:	5e                   	pop    %esi
  8029dc:	5d                   	pop    %ebp
  8029dd:	c3                   	ret    

008029de <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029de:	55                   	push   %ebp
  8029df:	89 e5                	mov    %esp,%ebp
  8029e1:	57                   	push   %edi
  8029e2:	56                   	push   %esi
  8029e3:	53                   	push   %ebx
  8029e4:	83 ec 0c             	sub    $0xc,%esp
  8029e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8029ea:	8b 75 0c             	mov    0xc(%ebp),%esi
  8029ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8029f0:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8029f2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8029f7:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8029fa:	ff 75 14             	pushl  0x14(%ebp)
  8029fd:	53                   	push   %ebx
  8029fe:	56                   	push   %esi
  8029ff:	57                   	push   %edi
  802a00:	e8 a3 fe ff ff       	call   8028a8 <sys_ipc_try_send>

		if (err < 0) {
  802a05:	83 c4 10             	add    $0x10,%esp
  802a08:	85 c0                	test   %eax,%eax
  802a0a:	79 1e                	jns    802a2a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802a0c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a0f:	75 07                	jne    802a18 <ipc_send+0x3a>
				sys_yield();
  802a11:	e8 e6 fc ff ff       	call   8026fc <sys_yield>
  802a16:	eb e2                	jmp    8029fa <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802a18:	50                   	push   %eax
  802a19:	68 aa 44 80 00       	push   $0x8044aa
  802a1e:	6a 49                	push   $0x49
  802a20:	68 b7 44 80 00       	push   $0x8044b7
  802a25:	e8 90 f2 ff ff       	call   801cba <_panic>
		}

	} while (err < 0);

}
  802a2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a2d:	5b                   	pop    %ebx
  802a2e:	5e                   	pop    %esi
  802a2f:	5f                   	pop    %edi
  802a30:	5d                   	pop    %ebp
  802a31:	c3                   	ret    

00802a32 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a32:	55                   	push   %ebp
  802a33:	89 e5                	mov    %esp,%ebp
  802a35:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a38:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a3d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a40:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a46:	8b 52 50             	mov    0x50(%edx),%edx
  802a49:	39 ca                	cmp    %ecx,%edx
  802a4b:	75 0d                	jne    802a5a <ipc_find_env+0x28>
			return envs[i].env_id;
  802a4d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a50:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a55:	8b 40 48             	mov    0x48(%eax),%eax
  802a58:	eb 0f                	jmp    802a69 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a5a:	83 c0 01             	add    $0x1,%eax
  802a5d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a62:	75 d9                	jne    802a3d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a69:	5d                   	pop    %ebp
  802a6a:	c3                   	ret    

00802a6b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802a6b:	55                   	push   %ebp
  802a6c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  802a71:	05 00 00 00 30       	add    $0x30000000,%eax
  802a76:	c1 e8 0c             	shr    $0xc,%eax
}
  802a79:	5d                   	pop    %ebp
  802a7a:	c3                   	ret    

00802a7b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802a7b:	55                   	push   %ebp
  802a7c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  802a81:	05 00 00 00 30       	add    $0x30000000,%eax
  802a86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802a8b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802a90:	5d                   	pop    %ebp
  802a91:	c3                   	ret    

00802a92 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802a92:	55                   	push   %ebp
  802a93:	89 e5                	mov    %esp,%ebp
  802a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a98:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802a9d:	89 c2                	mov    %eax,%edx
  802a9f:	c1 ea 16             	shr    $0x16,%edx
  802aa2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802aa9:	f6 c2 01             	test   $0x1,%dl
  802aac:	74 11                	je     802abf <fd_alloc+0x2d>
  802aae:	89 c2                	mov    %eax,%edx
  802ab0:	c1 ea 0c             	shr    $0xc,%edx
  802ab3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802aba:	f6 c2 01             	test   $0x1,%dl
  802abd:	75 09                	jne    802ac8 <fd_alloc+0x36>
			*fd_store = fd;
  802abf:	89 01                	mov    %eax,(%ecx)
			return 0;
  802ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  802ac6:	eb 17                	jmp    802adf <fd_alloc+0x4d>
  802ac8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802acd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802ad2:	75 c9                	jne    802a9d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802ad4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802ada:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802adf:	5d                   	pop    %ebp
  802ae0:	c3                   	ret    

00802ae1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802ae1:	55                   	push   %ebp
  802ae2:	89 e5                	mov    %esp,%ebp
  802ae4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802ae7:	83 f8 1f             	cmp    $0x1f,%eax
  802aea:	77 36                	ja     802b22 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802aec:	c1 e0 0c             	shl    $0xc,%eax
  802aef:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802af4:	89 c2                	mov    %eax,%edx
  802af6:	c1 ea 16             	shr    $0x16,%edx
  802af9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802b00:	f6 c2 01             	test   $0x1,%dl
  802b03:	74 24                	je     802b29 <fd_lookup+0x48>
  802b05:	89 c2                	mov    %eax,%edx
  802b07:	c1 ea 0c             	shr    $0xc,%edx
  802b0a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802b11:	f6 c2 01             	test   $0x1,%dl
  802b14:	74 1a                	je     802b30 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802b16:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b19:	89 02                	mov    %eax,(%edx)
	return 0;
  802b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  802b20:	eb 13                	jmp    802b35 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802b22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b27:	eb 0c                	jmp    802b35 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802b29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b2e:	eb 05                	jmp    802b35 <fd_lookup+0x54>
  802b30:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802b35:	5d                   	pop    %ebp
  802b36:	c3                   	ret    

00802b37 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802b37:	55                   	push   %ebp
  802b38:	89 e5                	mov    %esp,%ebp
  802b3a:	83 ec 08             	sub    $0x8,%esp
  802b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b40:	ba 44 45 80 00       	mov    $0x804544,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802b45:	eb 13                	jmp    802b5a <dev_lookup+0x23>
  802b47:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802b4a:	39 08                	cmp    %ecx,(%eax)
  802b4c:	75 0c                	jne    802b5a <dev_lookup+0x23>
			*dev = devtab[i];
  802b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b51:	89 01                	mov    %eax,(%ecx)
			return 0;
  802b53:	b8 00 00 00 00       	mov    $0x0,%eax
  802b58:	eb 2e                	jmp    802b88 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802b5a:	8b 02                	mov    (%edx),%eax
  802b5c:	85 c0                	test   %eax,%eax
  802b5e:	75 e7                	jne    802b47 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802b60:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b65:	8b 40 48             	mov    0x48(%eax),%eax
  802b68:	83 ec 04             	sub    $0x4,%esp
  802b6b:	51                   	push   %ecx
  802b6c:	50                   	push   %eax
  802b6d:	68 c4 44 80 00       	push   $0x8044c4
  802b72:	e8 1c f2 ff ff       	call   801d93 <cprintf>
	*dev = 0;
  802b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802b80:	83 c4 10             	add    $0x10,%esp
  802b83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802b88:	c9                   	leave  
  802b89:	c3                   	ret    

00802b8a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802b8a:	55                   	push   %ebp
  802b8b:	89 e5                	mov    %esp,%ebp
  802b8d:	56                   	push   %esi
  802b8e:	53                   	push   %ebx
  802b8f:	83 ec 10             	sub    $0x10,%esp
  802b92:	8b 75 08             	mov    0x8(%ebp),%esi
  802b95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802b98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b9b:	50                   	push   %eax
  802b9c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802ba2:	c1 e8 0c             	shr    $0xc,%eax
  802ba5:	50                   	push   %eax
  802ba6:	e8 36 ff ff ff       	call   802ae1 <fd_lookup>
  802bab:	83 c4 08             	add    $0x8,%esp
  802bae:	85 c0                	test   %eax,%eax
  802bb0:	78 05                	js     802bb7 <fd_close+0x2d>
	    || fd != fd2)
  802bb2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802bb5:	74 0c                	je     802bc3 <fd_close+0x39>
		return (must_exist ? r : 0);
  802bb7:	84 db                	test   %bl,%bl
  802bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  802bbe:	0f 44 c2             	cmove  %edx,%eax
  802bc1:	eb 41                	jmp    802c04 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802bc3:	83 ec 08             	sub    $0x8,%esp
  802bc6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bc9:	50                   	push   %eax
  802bca:	ff 36                	pushl  (%esi)
  802bcc:	e8 66 ff ff ff       	call   802b37 <dev_lookup>
  802bd1:	89 c3                	mov    %eax,%ebx
  802bd3:	83 c4 10             	add    $0x10,%esp
  802bd6:	85 c0                	test   %eax,%eax
  802bd8:	78 1a                	js     802bf4 <fd_close+0x6a>
		if (dev->dev_close)
  802bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bdd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802be0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802be5:	85 c0                	test   %eax,%eax
  802be7:	74 0b                	je     802bf4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802be9:	83 ec 0c             	sub    $0xc,%esp
  802bec:	56                   	push   %esi
  802bed:	ff d0                	call   *%eax
  802bef:	89 c3                	mov    %eax,%ebx
  802bf1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802bf4:	83 ec 08             	sub    $0x8,%esp
  802bf7:	56                   	push   %esi
  802bf8:	6a 00                	push   $0x0
  802bfa:	e8 a1 fb ff ff       	call   8027a0 <sys_page_unmap>
	return r;
  802bff:	83 c4 10             	add    $0x10,%esp
  802c02:	89 d8                	mov    %ebx,%eax
}
  802c04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c07:	5b                   	pop    %ebx
  802c08:	5e                   	pop    %esi
  802c09:	5d                   	pop    %ebp
  802c0a:	c3                   	ret    

00802c0b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802c0b:	55                   	push   %ebp
  802c0c:	89 e5                	mov    %esp,%ebp
  802c0e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c14:	50                   	push   %eax
  802c15:	ff 75 08             	pushl  0x8(%ebp)
  802c18:	e8 c4 fe ff ff       	call   802ae1 <fd_lookup>
  802c1d:	83 c4 08             	add    $0x8,%esp
  802c20:	85 c0                	test   %eax,%eax
  802c22:	78 10                	js     802c34 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802c24:	83 ec 08             	sub    $0x8,%esp
  802c27:	6a 01                	push   $0x1
  802c29:	ff 75 f4             	pushl  -0xc(%ebp)
  802c2c:	e8 59 ff ff ff       	call   802b8a <fd_close>
  802c31:	83 c4 10             	add    $0x10,%esp
}
  802c34:	c9                   	leave  
  802c35:	c3                   	ret    

00802c36 <close_all>:

void
close_all(void)
{
  802c36:	55                   	push   %ebp
  802c37:	89 e5                	mov    %esp,%ebp
  802c39:	53                   	push   %ebx
  802c3a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802c42:	83 ec 0c             	sub    $0xc,%esp
  802c45:	53                   	push   %ebx
  802c46:	e8 c0 ff ff ff       	call   802c0b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802c4b:	83 c3 01             	add    $0x1,%ebx
  802c4e:	83 c4 10             	add    $0x10,%esp
  802c51:	83 fb 20             	cmp    $0x20,%ebx
  802c54:	75 ec                	jne    802c42 <close_all+0xc>
		close(i);
}
  802c56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c59:	c9                   	leave  
  802c5a:	c3                   	ret    

00802c5b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802c5b:	55                   	push   %ebp
  802c5c:	89 e5                	mov    %esp,%ebp
  802c5e:	57                   	push   %edi
  802c5f:	56                   	push   %esi
  802c60:	53                   	push   %ebx
  802c61:	83 ec 2c             	sub    $0x2c,%esp
  802c64:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802c67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802c6a:	50                   	push   %eax
  802c6b:	ff 75 08             	pushl  0x8(%ebp)
  802c6e:	e8 6e fe ff ff       	call   802ae1 <fd_lookup>
  802c73:	83 c4 08             	add    $0x8,%esp
  802c76:	85 c0                	test   %eax,%eax
  802c78:	0f 88 c1 00 00 00    	js     802d3f <dup+0xe4>
		return r;
	close(newfdnum);
  802c7e:	83 ec 0c             	sub    $0xc,%esp
  802c81:	56                   	push   %esi
  802c82:	e8 84 ff ff ff       	call   802c0b <close>

	newfd = INDEX2FD(newfdnum);
  802c87:	89 f3                	mov    %esi,%ebx
  802c89:	c1 e3 0c             	shl    $0xc,%ebx
  802c8c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802c92:	83 c4 04             	add    $0x4,%esp
  802c95:	ff 75 e4             	pushl  -0x1c(%ebp)
  802c98:	e8 de fd ff ff       	call   802a7b <fd2data>
  802c9d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802c9f:	89 1c 24             	mov    %ebx,(%esp)
  802ca2:	e8 d4 fd ff ff       	call   802a7b <fd2data>
  802ca7:	83 c4 10             	add    $0x10,%esp
  802caa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802cad:	89 f8                	mov    %edi,%eax
  802caf:	c1 e8 16             	shr    $0x16,%eax
  802cb2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802cb9:	a8 01                	test   $0x1,%al
  802cbb:	74 37                	je     802cf4 <dup+0x99>
  802cbd:	89 f8                	mov    %edi,%eax
  802cbf:	c1 e8 0c             	shr    $0xc,%eax
  802cc2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802cc9:	f6 c2 01             	test   $0x1,%dl
  802ccc:	74 26                	je     802cf4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802cce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802cd5:	83 ec 0c             	sub    $0xc,%esp
  802cd8:	25 07 0e 00 00       	and    $0xe07,%eax
  802cdd:	50                   	push   %eax
  802cde:	ff 75 d4             	pushl  -0x2c(%ebp)
  802ce1:	6a 00                	push   $0x0
  802ce3:	57                   	push   %edi
  802ce4:	6a 00                	push   $0x0
  802ce6:	e8 73 fa ff ff       	call   80275e <sys_page_map>
  802ceb:	89 c7                	mov    %eax,%edi
  802ced:	83 c4 20             	add    $0x20,%esp
  802cf0:	85 c0                	test   %eax,%eax
  802cf2:	78 2e                	js     802d22 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802cf4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802cf7:	89 d0                	mov    %edx,%eax
  802cf9:	c1 e8 0c             	shr    $0xc,%eax
  802cfc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802d03:	83 ec 0c             	sub    $0xc,%esp
  802d06:	25 07 0e 00 00       	and    $0xe07,%eax
  802d0b:	50                   	push   %eax
  802d0c:	53                   	push   %ebx
  802d0d:	6a 00                	push   $0x0
  802d0f:	52                   	push   %edx
  802d10:	6a 00                	push   $0x0
  802d12:	e8 47 fa ff ff       	call   80275e <sys_page_map>
  802d17:	89 c7                	mov    %eax,%edi
  802d19:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802d1c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802d1e:	85 ff                	test   %edi,%edi
  802d20:	79 1d                	jns    802d3f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802d22:	83 ec 08             	sub    $0x8,%esp
  802d25:	53                   	push   %ebx
  802d26:	6a 00                	push   $0x0
  802d28:	e8 73 fa ff ff       	call   8027a0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802d2d:	83 c4 08             	add    $0x8,%esp
  802d30:	ff 75 d4             	pushl  -0x2c(%ebp)
  802d33:	6a 00                	push   $0x0
  802d35:	e8 66 fa ff ff       	call   8027a0 <sys_page_unmap>
	return r;
  802d3a:	83 c4 10             	add    $0x10,%esp
  802d3d:	89 f8                	mov    %edi,%eax
}
  802d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d42:	5b                   	pop    %ebx
  802d43:	5e                   	pop    %esi
  802d44:	5f                   	pop    %edi
  802d45:	5d                   	pop    %ebp
  802d46:	c3                   	ret    

00802d47 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802d47:	55                   	push   %ebp
  802d48:	89 e5                	mov    %esp,%ebp
  802d4a:	53                   	push   %ebx
  802d4b:	83 ec 14             	sub    $0x14,%esp
  802d4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d54:	50                   	push   %eax
  802d55:	53                   	push   %ebx
  802d56:	e8 86 fd ff ff       	call   802ae1 <fd_lookup>
  802d5b:	83 c4 08             	add    $0x8,%esp
  802d5e:	89 c2                	mov    %eax,%edx
  802d60:	85 c0                	test   %eax,%eax
  802d62:	78 6d                	js     802dd1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d64:	83 ec 08             	sub    $0x8,%esp
  802d67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d6a:	50                   	push   %eax
  802d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d6e:	ff 30                	pushl  (%eax)
  802d70:	e8 c2 fd ff ff       	call   802b37 <dev_lookup>
  802d75:	83 c4 10             	add    $0x10,%esp
  802d78:	85 c0                	test   %eax,%eax
  802d7a:	78 4c                	js     802dc8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802d7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802d7f:	8b 42 08             	mov    0x8(%edx),%eax
  802d82:	83 e0 03             	and    $0x3,%eax
  802d85:	83 f8 01             	cmp    $0x1,%eax
  802d88:	75 21                	jne    802dab <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802d8a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802d8f:	8b 40 48             	mov    0x48(%eax),%eax
  802d92:	83 ec 04             	sub    $0x4,%esp
  802d95:	53                   	push   %ebx
  802d96:	50                   	push   %eax
  802d97:	68 08 45 80 00       	push   $0x804508
  802d9c:	e8 f2 ef ff ff       	call   801d93 <cprintf>
		return -E_INVAL;
  802da1:	83 c4 10             	add    $0x10,%esp
  802da4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802da9:	eb 26                	jmp    802dd1 <read+0x8a>
	}
	if (!dev->dev_read)
  802dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dae:	8b 40 08             	mov    0x8(%eax),%eax
  802db1:	85 c0                	test   %eax,%eax
  802db3:	74 17                	je     802dcc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802db5:	83 ec 04             	sub    $0x4,%esp
  802db8:	ff 75 10             	pushl  0x10(%ebp)
  802dbb:	ff 75 0c             	pushl  0xc(%ebp)
  802dbe:	52                   	push   %edx
  802dbf:	ff d0                	call   *%eax
  802dc1:	89 c2                	mov    %eax,%edx
  802dc3:	83 c4 10             	add    $0x10,%esp
  802dc6:	eb 09                	jmp    802dd1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dc8:	89 c2                	mov    %eax,%edx
  802dca:	eb 05                	jmp    802dd1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802dcc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802dd1:	89 d0                	mov    %edx,%eax
  802dd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dd6:	c9                   	leave  
  802dd7:	c3                   	ret    

00802dd8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802dd8:	55                   	push   %ebp
  802dd9:	89 e5                	mov    %esp,%ebp
  802ddb:	57                   	push   %edi
  802ddc:	56                   	push   %esi
  802ddd:	53                   	push   %ebx
  802dde:	83 ec 0c             	sub    $0xc,%esp
  802de1:	8b 7d 08             	mov    0x8(%ebp),%edi
  802de4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  802dec:	eb 21                	jmp    802e0f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802dee:	83 ec 04             	sub    $0x4,%esp
  802df1:	89 f0                	mov    %esi,%eax
  802df3:	29 d8                	sub    %ebx,%eax
  802df5:	50                   	push   %eax
  802df6:	89 d8                	mov    %ebx,%eax
  802df8:	03 45 0c             	add    0xc(%ebp),%eax
  802dfb:	50                   	push   %eax
  802dfc:	57                   	push   %edi
  802dfd:	e8 45 ff ff ff       	call   802d47 <read>
		if (m < 0)
  802e02:	83 c4 10             	add    $0x10,%esp
  802e05:	85 c0                	test   %eax,%eax
  802e07:	78 10                	js     802e19 <readn+0x41>
			return m;
		if (m == 0)
  802e09:	85 c0                	test   %eax,%eax
  802e0b:	74 0a                	je     802e17 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802e0d:	01 c3                	add    %eax,%ebx
  802e0f:	39 f3                	cmp    %esi,%ebx
  802e11:	72 db                	jb     802dee <readn+0x16>
  802e13:	89 d8                	mov    %ebx,%eax
  802e15:	eb 02                	jmp    802e19 <readn+0x41>
  802e17:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e1c:	5b                   	pop    %ebx
  802e1d:	5e                   	pop    %esi
  802e1e:	5f                   	pop    %edi
  802e1f:	5d                   	pop    %ebp
  802e20:	c3                   	ret    

00802e21 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802e21:	55                   	push   %ebp
  802e22:	89 e5                	mov    %esp,%ebp
  802e24:	53                   	push   %ebx
  802e25:	83 ec 14             	sub    $0x14,%esp
  802e28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e2e:	50                   	push   %eax
  802e2f:	53                   	push   %ebx
  802e30:	e8 ac fc ff ff       	call   802ae1 <fd_lookup>
  802e35:	83 c4 08             	add    $0x8,%esp
  802e38:	89 c2                	mov    %eax,%edx
  802e3a:	85 c0                	test   %eax,%eax
  802e3c:	78 68                	js     802ea6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e3e:	83 ec 08             	sub    $0x8,%esp
  802e41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e44:	50                   	push   %eax
  802e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e48:	ff 30                	pushl  (%eax)
  802e4a:	e8 e8 fc ff ff       	call   802b37 <dev_lookup>
  802e4f:	83 c4 10             	add    $0x10,%esp
  802e52:	85 c0                	test   %eax,%eax
  802e54:	78 47                	js     802e9d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e59:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802e5d:	75 21                	jne    802e80 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802e5f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802e64:	8b 40 48             	mov    0x48(%eax),%eax
  802e67:	83 ec 04             	sub    $0x4,%esp
  802e6a:	53                   	push   %ebx
  802e6b:	50                   	push   %eax
  802e6c:	68 24 45 80 00       	push   $0x804524
  802e71:	e8 1d ef ff ff       	call   801d93 <cprintf>
		return -E_INVAL;
  802e76:	83 c4 10             	add    $0x10,%esp
  802e79:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802e7e:	eb 26                	jmp    802ea6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802e80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e83:	8b 52 0c             	mov    0xc(%edx),%edx
  802e86:	85 d2                	test   %edx,%edx
  802e88:	74 17                	je     802ea1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802e8a:	83 ec 04             	sub    $0x4,%esp
  802e8d:	ff 75 10             	pushl  0x10(%ebp)
  802e90:	ff 75 0c             	pushl  0xc(%ebp)
  802e93:	50                   	push   %eax
  802e94:	ff d2                	call   *%edx
  802e96:	89 c2                	mov    %eax,%edx
  802e98:	83 c4 10             	add    $0x10,%esp
  802e9b:	eb 09                	jmp    802ea6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e9d:	89 c2                	mov    %eax,%edx
  802e9f:	eb 05                	jmp    802ea6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802ea1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802ea6:	89 d0                	mov    %edx,%eax
  802ea8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802eab:	c9                   	leave  
  802eac:	c3                   	ret    

00802ead <seek>:

int
seek(int fdnum, off_t offset)
{
  802ead:	55                   	push   %ebp
  802eae:	89 e5                	mov    %esp,%ebp
  802eb0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802eb3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802eb6:	50                   	push   %eax
  802eb7:	ff 75 08             	pushl  0x8(%ebp)
  802eba:	e8 22 fc ff ff       	call   802ae1 <fd_lookup>
  802ebf:	83 c4 08             	add    $0x8,%esp
  802ec2:	85 c0                	test   %eax,%eax
  802ec4:	78 0e                	js     802ed4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802ec6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802ec9:	8b 55 0c             	mov    0xc(%ebp),%edx
  802ecc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802ecf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ed4:	c9                   	leave  
  802ed5:	c3                   	ret    

00802ed6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802ed6:	55                   	push   %ebp
  802ed7:	89 e5                	mov    %esp,%ebp
  802ed9:	53                   	push   %ebx
  802eda:	83 ec 14             	sub    $0x14,%esp
  802edd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ee0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ee3:	50                   	push   %eax
  802ee4:	53                   	push   %ebx
  802ee5:	e8 f7 fb ff ff       	call   802ae1 <fd_lookup>
  802eea:	83 c4 08             	add    $0x8,%esp
  802eed:	89 c2                	mov    %eax,%edx
  802eef:	85 c0                	test   %eax,%eax
  802ef1:	78 65                	js     802f58 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ef3:	83 ec 08             	sub    $0x8,%esp
  802ef6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ef9:	50                   	push   %eax
  802efa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802efd:	ff 30                	pushl  (%eax)
  802eff:	e8 33 fc ff ff       	call   802b37 <dev_lookup>
  802f04:	83 c4 10             	add    $0x10,%esp
  802f07:	85 c0                	test   %eax,%eax
  802f09:	78 44                	js     802f4f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f0e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802f12:	75 21                	jne    802f35 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802f14:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802f19:	8b 40 48             	mov    0x48(%eax),%eax
  802f1c:	83 ec 04             	sub    $0x4,%esp
  802f1f:	53                   	push   %ebx
  802f20:	50                   	push   %eax
  802f21:	68 e4 44 80 00       	push   $0x8044e4
  802f26:	e8 68 ee ff ff       	call   801d93 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802f2b:	83 c4 10             	add    $0x10,%esp
  802f2e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802f33:	eb 23                	jmp    802f58 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802f35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f38:	8b 52 18             	mov    0x18(%edx),%edx
  802f3b:	85 d2                	test   %edx,%edx
  802f3d:	74 14                	je     802f53 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802f3f:	83 ec 08             	sub    $0x8,%esp
  802f42:	ff 75 0c             	pushl  0xc(%ebp)
  802f45:	50                   	push   %eax
  802f46:	ff d2                	call   *%edx
  802f48:	89 c2                	mov    %eax,%edx
  802f4a:	83 c4 10             	add    $0x10,%esp
  802f4d:	eb 09                	jmp    802f58 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f4f:	89 c2                	mov    %eax,%edx
  802f51:	eb 05                	jmp    802f58 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802f53:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802f58:	89 d0                	mov    %edx,%eax
  802f5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f5d:	c9                   	leave  
  802f5e:	c3                   	ret    

00802f5f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802f5f:	55                   	push   %ebp
  802f60:	89 e5                	mov    %esp,%ebp
  802f62:	53                   	push   %ebx
  802f63:	83 ec 14             	sub    $0x14,%esp
  802f66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f6c:	50                   	push   %eax
  802f6d:	ff 75 08             	pushl  0x8(%ebp)
  802f70:	e8 6c fb ff ff       	call   802ae1 <fd_lookup>
  802f75:	83 c4 08             	add    $0x8,%esp
  802f78:	89 c2                	mov    %eax,%edx
  802f7a:	85 c0                	test   %eax,%eax
  802f7c:	78 58                	js     802fd6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f7e:	83 ec 08             	sub    $0x8,%esp
  802f81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f84:	50                   	push   %eax
  802f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f88:	ff 30                	pushl  (%eax)
  802f8a:	e8 a8 fb ff ff       	call   802b37 <dev_lookup>
  802f8f:	83 c4 10             	add    $0x10,%esp
  802f92:	85 c0                	test   %eax,%eax
  802f94:	78 37                	js     802fcd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f99:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802f9d:	74 32                	je     802fd1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802f9f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802fa2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802fa9:	00 00 00 
	stat->st_isdir = 0;
  802fac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802fb3:	00 00 00 
	stat->st_dev = dev;
  802fb6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802fbc:	83 ec 08             	sub    $0x8,%esp
  802fbf:	53                   	push   %ebx
  802fc0:	ff 75 f0             	pushl  -0x10(%ebp)
  802fc3:	ff 50 14             	call   *0x14(%eax)
  802fc6:	89 c2                	mov    %eax,%edx
  802fc8:	83 c4 10             	add    $0x10,%esp
  802fcb:	eb 09                	jmp    802fd6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802fcd:	89 c2                	mov    %eax,%edx
  802fcf:	eb 05                	jmp    802fd6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802fd1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802fd6:	89 d0                	mov    %edx,%eax
  802fd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fdb:	c9                   	leave  
  802fdc:	c3                   	ret    

00802fdd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802fdd:	55                   	push   %ebp
  802fde:	89 e5                	mov    %esp,%ebp
  802fe0:	56                   	push   %esi
  802fe1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802fe2:	83 ec 08             	sub    $0x8,%esp
  802fe5:	6a 00                	push   $0x0
  802fe7:	ff 75 08             	pushl  0x8(%ebp)
  802fea:	e8 d6 01 00 00       	call   8031c5 <open>
  802fef:	89 c3                	mov    %eax,%ebx
  802ff1:	83 c4 10             	add    $0x10,%esp
  802ff4:	85 c0                	test   %eax,%eax
  802ff6:	78 1b                	js     803013 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802ff8:	83 ec 08             	sub    $0x8,%esp
  802ffb:	ff 75 0c             	pushl  0xc(%ebp)
  802ffe:	50                   	push   %eax
  802fff:	e8 5b ff ff ff       	call   802f5f <fstat>
  803004:	89 c6                	mov    %eax,%esi
	close(fd);
  803006:	89 1c 24             	mov    %ebx,(%esp)
  803009:	e8 fd fb ff ff       	call   802c0b <close>
	return r;
  80300e:	83 c4 10             	add    $0x10,%esp
  803011:	89 f0                	mov    %esi,%eax
}
  803013:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803016:	5b                   	pop    %ebx
  803017:	5e                   	pop    %esi
  803018:	5d                   	pop    %ebp
  803019:	c3                   	ret    

0080301a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80301a:	55                   	push   %ebp
  80301b:	89 e5                	mov    %esp,%ebp
  80301d:	56                   	push   %esi
  80301e:	53                   	push   %ebx
  80301f:	89 c6                	mov    %eax,%esi
  803021:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  803023:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  80302a:	75 12                	jne    80303e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80302c:	83 ec 0c             	sub    $0xc,%esp
  80302f:	6a 01                	push   $0x1
  803031:	e8 fc f9 ff ff       	call   802a32 <ipc_find_env>
  803036:	a3 00 a0 80 00       	mov    %eax,0x80a000
  80303b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80303e:	6a 07                	push   $0x7
  803040:	68 00 b0 80 00       	push   $0x80b000
  803045:	56                   	push   %esi
  803046:	ff 35 00 a0 80 00    	pushl  0x80a000
  80304c:	e8 8d f9 ff ff       	call   8029de <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  803051:	83 c4 0c             	add    $0xc,%esp
  803054:	6a 00                	push   $0x0
  803056:	53                   	push   %ebx
  803057:	6a 00                	push   $0x0
  803059:	e8 19 f9 ff ff       	call   802977 <ipc_recv>
}
  80305e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803061:	5b                   	pop    %ebx
  803062:	5e                   	pop    %esi
  803063:	5d                   	pop    %ebp
  803064:	c3                   	ret    

00803065 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  803065:	55                   	push   %ebp
  803066:	89 e5                	mov    %esp,%ebp
  803068:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80306b:	8b 45 08             	mov    0x8(%ebp),%eax
  80306e:	8b 40 0c             	mov    0xc(%eax),%eax
  803071:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  803076:	8b 45 0c             	mov    0xc(%ebp),%eax
  803079:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80307e:	ba 00 00 00 00       	mov    $0x0,%edx
  803083:	b8 02 00 00 00       	mov    $0x2,%eax
  803088:	e8 8d ff ff ff       	call   80301a <fsipc>
}
  80308d:	c9                   	leave  
  80308e:	c3                   	ret    

0080308f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80308f:	55                   	push   %ebp
  803090:	89 e5                	mov    %esp,%ebp
  803092:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803095:	8b 45 08             	mov    0x8(%ebp),%eax
  803098:	8b 40 0c             	mov    0xc(%eax),%eax
  80309b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  8030a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8030a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8030aa:	e8 6b ff ff ff       	call   80301a <fsipc>
}
  8030af:	c9                   	leave  
  8030b0:	c3                   	ret    

008030b1 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8030b1:	55                   	push   %ebp
  8030b2:	89 e5                	mov    %esp,%ebp
  8030b4:	53                   	push   %ebx
  8030b5:	83 ec 04             	sub    $0x4,%esp
  8030b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8030bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8030be:	8b 40 0c             	mov    0xc(%eax),%eax
  8030c1:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8030c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8030cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8030d0:	e8 45 ff ff ff       	call   80301a <fsipc>
  8030d5:	85 c0                	test   %eax,%eax
  8030d7:	78 2c                	js     803105 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8030d9:	83 ec 08             	sub    $0x8,%esp
  8030dc:	68 00 b0 80 00       	push   $0x80b000
  8030e1:	53                   	push   %ebx
  8030e2:	e8 31 f2 ff ff       	call   802318 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8030e7:	a1 80 b0 80 00       	mov    0x80b080,%eax
  8030ec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8030f2:	a1 84 b0 80 00       	mov    0x80b084,%eax
  8030f7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8030fd:	83 c4 10             	add    $0x10,%esp
  803100:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803105:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803108:	c9                   	leave  
  803109:	c3                   	ret    

0080310a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80310a:	55                   	push   %ebp
  80310b:	89 e5                	mov    %esp,%ebp
  80310d:	83 ec 0c             	sub    $0xc,%esp
  803110:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  803113:	8b 55 08             	mov    0x8(%ebp),%edx
  803116:	8b 52 0c             	mov    0xc(%edx),%edx
  803119:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  80311f:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  803124:	50                   	push   %eax
  803125:	ff 75 0c             	pushl  0xc(%ebp)
  803128:	68 08 b0 80 00       	push   $0x80b008
  80312d:	e8 78 f3 ff ff       	call   8024aa <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  803132:	ba 00 00 00 00       	mov    $0x0,%edx
  803137:	b8 04 00 00 00       	mov    $0x4,%eax
  80313c:	e8 d9 fe ff ff       	call   80301a <fsipc>

}
  803141:	c9                   	leave  
  803142:	c3                   	ret    

00803143 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  803143:	55                   	push   %ebp
  803144:	89 e5                	mov    %esp,%ebp
  803146:	56                   	push   %esi
  803147:	53                   	push   %ebx
  803148:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80314b:	8b 45 08             	mov    0x8(%ebp),%eax
  80314e:	8b 40 0c             	mov    0xc(%eax),%eax
  803151:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  803156:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80315c:	ba 00 00 00 00       	mov    $0x0,%edx
  803161:	b8 03 00 00 00       	mov    $0x3,%eax
  803166:	e8 af fe ff ff       	call   80301a <fsipc>
  80316b:	89 c3                	mov    %eax,%ebx
  80316d:	85 c0                	test   %eax,%eax
  80316f:	78 4b                	js     8031bc <devfile_read+0x79>
		return r;
	assert(r <= n);
  803171:	39 c6                	cmp    %eax,%esi
  803173:	73 16                	jae    80318b <devfile_read+0x48>
  803175:	68 54 45 80 00       	push   $0x804554
  80317a:	68 5d 3a 80 00       	push   $0x803a5d
  80317f:	6a 7c                	push   $0x7c
  803181:	68 5b 45 80 00       	push   $0x80455b
  803186:	e8 2f eb ff ff       	call   801cba <_panic>
	assert(r <= PGSIZE);
  80318b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803190:	7e 16                	jle    8031a8 <devfile_read+0x65>
  803192:	68 66 45 80 00       	push   $0x804566
  803197:	68 5d 3a 80 00       	push   $0x803a5d
  80319c:	6a 7d                	push   $0x7d
  80319e:	68 5b 45 80 00       	push   $0x80455b
  8031a3:	e8 12 eb ff ff       	call   801cba <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8031a8:	83 ec 04             	sub    $0x4,%esp
  8031ab:	50                   	push   %eax
  8031ac:	68 00 b0 80 00       	push   $0x80b000
  8031b1:	ff 75 0c             	pushl  0xc(%ebp)
  8031b4:	e8 f1 f2 ff ff       	call   8024aa <memmove>
	return r;
  8031b9:	83 c4 10             	add    $0x10,%esp
}
  8031bc:	89 d8                	mov    %ebx,%eax
  8031be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031c1:	5b                   	pop    %ebx
  8031c2:	5e                   	pop    %esi
  8031c3:	5d                   	pop    %ebp
  8031c4:	c3                   	ret    

008031c5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8031c5:	55                   	push   %ebp
  8031c6:	89 e5                	mov    %esp,%ebp
  8031c8:	53                   	push   %ebx
  8031c9:	83 ec 20             	sub    $0x20,%esp
  8031cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8031cf:	53                   	push   %ebx
  8031d0:	e8 0a f1 ff ff       	call   8022df <strlen>
  8031d5:	83 c4 10             	add    $0x10,%esp
  8031d8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8031dd:	7f 67                	jg     803246 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8031df:	83 ec 0c             	sub    $0xc,%esp
  8031e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031e5:	50                   	push   %eax
  8031e6:	e8 a7 f8 ff ff       	call   802a92 <fd_alloc>
  8031eb:	83 c4 10             	add    $0x10,%esp
		return r;
  8031ee:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8031f0:	85 c0                	test   %eax,%eax
  8031f2:	78 57                	js     80324b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8031f4:	83 ec 08             	sub    $0x8,%esp
  8031f7:	53                   	push   %ebx
  8031f8:	68 00 b0 80 00       	push   $0x80b000
  8031fd:	e8 16 f1 ff ff       	call   802318 <strcpy>
	fsipcbuf.open.req_omode = mode;
  803202:	8b 45 0c             	mov    0xc(%ebp),%eax
  803205:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80320a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80320d:	b8 01 00 00 00       	mov    $0x1,%eax
  803212:	e8 03 fe ff ff       	call   80301a <fsipc>
  803217:	89 c3                	mov    %eax,%ebx
  803219:	83 c4 10             	add    $0x10,%esp
  80321c:	85 c0                	test   %eax,%eax
  80321e:	79 14                	jns    803234 <open+0x6f>
		fd_close(fd, 0);
  803220:	83 ec 08             	sub    $0x8,%esp
  803223:	6a 00                	push   $0x0
  803225:	ff 75 f4             	pushl  -0xc(%ebp)
  803228:	e8 5d f9 ff ff       	call   802b8a <fd_close>
		return r;
  80322d:	83 c4 10             	add    $0x10,%esp
  803230:	89 da                	mov    %ebx,%edx
  803232:	eb 17                	jmp    80324b <open+0x86>
	}

	return fd2num(fd);
  803234:	83 ec 0c             	sub    $0xc,%esp
  803237:	ff 75 f4             	pushl  -0xc(%ebp)
  80323a:	e8 2c f8 ff ff       	call   802a6b <fd2num>
  80323f:	89 c2                	mov    %eax,%edx
  803241:	83 c4 10             	add    $0x10,%esp
  803244:	eb 05                	jmp    80324b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  803246:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80324b:	89 d0                	mov    %edx,%eax
  80324d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803250:	c9                   	leave  
  803251:	c3                   	ret    

00803252 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803252:	55                   	push   %ebp
  803253:	89 e5                	mov    %esp,%ebp
  803255:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803258:	ba 00 00 00 00       	mov    $0x0,%edx
  80325d:	b8 08 00 00 00       	mov    $0x8,%eax
  803262:	e8 b3 fd ff ff       	call   80301a <fsipc>
}
  803267:	c9                   	leave  
  803268:	c3                   	ret    

00803269 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803269:	55                   	push   %ebp
  80326a:	89 e5                	mov    %esp,%ebp
  80326c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80326f:	89 d0                	mov    %edx,%eax
  803271:	c1 e8 16             	shr    $0x16,%eax
  803274:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80327b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803280:	f6 c1 01             	test   $0x1,%cl
  803283:	74 1d                	je     8032a2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803285:	c1 ea 0c             	shr    $0xc,%edx
  803288:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80328f:	f6 c2 01             	test   $0x1,%dl
  803292:	74 0e                	je     8032a2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803294:	c1 ea 0c             	shr    $0xc,%edx
  803297:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80329e:	ef 
  80329f:	0f b7 c0             	movzwl %ax,%eax
}
  8032a2:	5d                   	pop    %ebp
  8032a3:	c3                   	ret    

008032a4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8032a4:	55                   	push   %ebp
  8032a5:	89 e5                	mov    %esp,%ebp
  8032a7:	56                   	push   %esi
  8032a8:	53                   	push   %ebx
  8032a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8032ac:	83 ec 0c             	sub    $0xc,%esp
  8032af:	ff 75 08             	pushl  0x8(%ebp)
  8032b2:	e8 c4 f7 ff ff       	call   802a7b <fd2data>
  8032b7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8032b9:	83 c4 08             	add    $0x8,%esp
  8032bc:	68 72 45 80 00       	push   $0x804572
  8032c1:	53                   	push   %ebx
  8032c2:	e8 51 f0 ff ff       	call   802318 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8032c7:	8b 46 04             	mov    0x4(%esi),%eax
  8032ca:	2b 06                	sub    (%esi),%eax
  8032cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8032d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8032d9:	00 00 00 
	stat->st_dev = &devpipe;
  8032dc:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  8032e3:	90 80 00 
	return 0;
}
  8032e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8032eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032ee:	5b                   	pop    %ebx
  8032ef:	5e                   	pop    %esi
  8032f0:	5d                   	pop    %ebp
  8032f1:	c3                   	ret    

008032f2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8032f2:	55                   	push   %ebp
  8032f3:	89 e5                	mov    %esp,%ebp
  8032f5:	53                   	push   %ebx
  8032f6:	83 ec 0c             	sub    $0xc,%esp
  8032f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8032fc:	53                   	push   %ebx
  8032fd:	6a 00                	push   $0x0
  8032ff:	e8 9c f4 ff ff       	call   8027a0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803304:	89 1c 24             	mov    %ebx,(%esp)
  803307:	e8 6f f7 ff ff       	call   802a7b <fd2data>
  80330c:	83 c4 08             	add    $0x8,%esp
  80330f:	50                   	push   %eax
  803310:	6a 00                	push   $0x0
  803312:	e8 89 f4 ff ff       	call   8027a0 <sys_page_unmap>
}
  803317:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80331a:	c9                   	leave  
  80331b:	c3                   	ret    

0080331c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80331c:	55                   	push   %ebp
  80331d:	89 e5                	mov    %esp,%ebp
  80331f:	57                   	push   %edi
  803320:	56                   	push   %esi
  803321:	53                   	push   %ebx
  803322:	83 ec 1c             	sub    $0x1c,%esp
  803325:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803328:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80332a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80332f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  803332:	83 ec 0c             	sub    $0xc,%esp
  803335:	ff 75 e0             	pushl  -0x20(%ebp)
  803338:	e8 2c ff ff ff       	call   803269 <pageref>
  80333d:	89 c3                	mov    %eax,%ebx
  80333f:	89 3c 24             	mov    %edi,(%esp)
  803342:	e8 22 ff ff ff       	call   803269 <pageref>
  803347:	83 c4 10             	add    $0x10,%esp
  80334a:	39 c3                	cmp    %eax,%ebx
  80334c:	0f 94 c1             	sete   %cl
  80334f:	0f b6 c9             	movzbl %cl,%ecx
  803352:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  803355:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  80335b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80335e:	39 ce                	cmp    %ecx,%esi
  803360:	74 1b                	je     80337d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  803362:	39 c3                	cmp    %eax,%ebx
  803364:	75 c4                	jne    80332a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803366:	8b 42 58             	mov    0x58(%edx),%eax
  803369:	ff 75 e4             	pushl  -0x1c(%ebp)
  80336c:	50                   	push   %eax
  80336d:	56                   	push   %esi
  80336e:	68 79 45 80 00       	push   $0x804579
  803373:	e8 1b ea ff ff       	call   801d93 <cprintf>
  803378:	83 c4 10             	add    $0x10,%esp
  80337b:	eb ad                	jmp    80332a <_pipeisclosed+0xe>
	}
}
  80337d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803380:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803383:	5b                   	pop    %ebx
  803384:	5e                   	pop    %esi
  803385:	5f                   	pop    %edi
  803386:	5d                   	pop    %ebp
  803387:	c3                   	ret    

00803388 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803388:	55                   	push   %ebp
  803389:	89 e5                	mov    %esp,%ebp
  80338b:	57                   	push   %edi
  80338c:	56                   	push   %esi
  80338d:	53                   	push   %ebx
  80338e:	83 ec 28             	sub    $0x28,%esp
  803391:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803394:	56                   	push   %esi
  803395:	e8 e1 f6 ff ff       	call   802a7b <fd2data>
  80339a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80339c:	83 c4 10             	add    $0x10,%esp
  80339f:	bf 00 00 00 00       	mov    $0x0,%edi
  8033a4:	eb 4b                	jmp    8033f1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8033a6:	89 da                	mov    %ebx,%edx
  8033a8:	89 f0                	mov    %esi,%eax
  8033aa:	e8 6d ff ff ff       	call   80331c <_pipeisclosed>
  8033af:	85 c0                	test   %eax,%eax
  8033b1:	75 48                	jne    8033fb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8033b3:	e8 44 f3 ff ff       	call   8026fc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8033b8:	8b 43 04             	mov    0x4(%ebx),%eax
  8033bb:	8b 0b                	mov    (%ebx),%ecx
  8033bd:	8d 51 20             	lea    0x20(%ecx),%edx
  8033c0:	39 d0                	cmp    %edx,%eax
  8033c2:	73 e2                	jae    8033a6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8033c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8033c7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8033cb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8033ce:	89 c2                	mov    %eax,%edx
  8033d0:	c1 fa 1f             	sar    $0x1f,%edx
  8033d3:	89 d1                	mov    %edx,%ecx
  8033d5:	c1 e9 1b             	shr    $0x1b,%ecx
  8033d8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8033db:	83 e2 1f             	and    $0x1f,%edx
  8033de:	29 ca                	sub    %ecx,%edx
  8033e0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8033e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8033e8:	83 c0 01             	add    $0x1,%eax
  8033eb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8033ee:	83 c7 01             	add    $0x1,%edi
  8033f1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8033f4:	75 c2                	jne    8033b8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8033f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8033f9:	eb 05                	jmp    803400 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8033fb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803400:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803403:	5b                   	pop    %ebx
  803404:	5e                   	pop    %esi
  803405:	5f                   	pop    %edi
  803406:	5d                   	pop    %ebp
  803407:	c3                   	ret    

00803408 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803408:	55                   	push   %ebp
  803409:	89 e5                	mov    %esp,%ebp
  80340b:	57                   	push   %edi
  80340c:	56                   	push   %esi
  80340d:	53                   	push   %ebx
  80340e:	83 ec 18             	sub    $0x18,%esp
  803411:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803414:	57                   	push   %edi
  803415:	e8 61 f6 ff ff       	call   802a7b <fd2data>
  80341a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80341c:	83 c4 10             	add    $0x10,%esp
  80341f:	bb 00 00 00 00       	mov    $0x0,%ebx
  803424:	eb 3d                	jmp    803463 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803426:	85 db                	test   %ebx,%ebx
  803428:	74 04                	je     80342e <devpipe_read+0x26>
				return i;
  80342a:	89 d8                	mov    %ebx,%eax
  80342c:	eb 44                	jmp    803472 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80342e:	89 f2                	mov    %esi,%edx
  803430:	89 f8                	mov    %edi,%eax
  803432:	e8 e5 fe ff ff       	call   80331c <_pipeisclosed>
  803437:	85 c0                	test   %eax,%eax
  803439:	75 32                	jne    80346d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80343b:	e8 bc f2 ff ff       	call   8026fc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803440:	8b 06                	mov    (%esi),%eax
  803442:	3b 46 04             	cmp    0x4(%esi),%eax
  803445:	74 df                	je     803426 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803447:	99                   	cltd   
  803448:	c1 ea 1b             	shr    $0x1b,%edx
  80344b:	01 d0                	add    %edx,%eax
  80344d:	83 e0 1f             	and    $0x1f,%eax
  803450:	29 d0                	sub    %edx,%eax
  803452:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803457:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80345a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80345d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803460:	83 c3 01             	add    $0x1,%ebx
  803463:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803466:	75 d8                	jne    803440 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803468:	8b 45 10             	mov    0x10(%ebp),%eax
  80346b:	eb 05                	jmp    803472 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80346d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803472:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803475:	5b                   	pop    %ebx
  803476:	5e                   	pop    %esi
  803477:	5f                   	pop    %edi
  803478:	5d                   	pop    %ebp
  803479:	c3                   	ret    

0080347a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80347a:	55                   	push   %ebp
  80347b:	89 e5                	mov    %esp,%ebp
  80347d:	56                   	push   %esi
  80347e:	53                   	push   %ebx
  80347f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803482:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803485:	50                   	push   %eax
  803486:	e8 07 f6 ff ff       	call   802a92 <fd_alloc>
  80348b:	83 c4 10             	add    $0x10,%esp
  80348e:	89 c2                	mov    %eax,%edx
  803490:	85 c0                	test   %eax,%eax
  803492:	0f 88 2c 01 00 00    	js     8035c4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803498:	83 ec 04             	sub    $0x4,%esp
  80349b:	68 07 04 00 00       	push   $0x407
  8034a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8034a3:	6a 00                	push   $0x0
  8034a5:	e8 71 f2 ff ff       	call   80271b <sys_page_alloc>
  8034aa:	83 c4 10             	add    $0x10,%esp
  8034ad:	89 c2                	mov    %eax,%edx
  8034af:	85 c0                	test   %eax,%eax
  8034b1:	0f 88 0d 01 00 00    	js     8035c4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8034b7:	83 ec 0c             	sub    $0xc,%esp
  8034ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8034bd:	50                   	push   %eax
  8034be:	e8 cf f5 ff ff       	call   802a92 <fd_alloc>
  8034c3:	89 c3                	mov    %eax,%ebx
  8034c5:	83 c4 10             	add    $0x10,%esp
  8034c8:	85 c0                	test   %eax,%eax
  8034ca:	0f 88 e2 00 00 00    	js     8035b2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034d0:	83 ec 04             	sub    $0x4,%esp
  8034d3:	68 07 04 00 00       	push   $0x407
  8034d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8034db:	6a 00                	push   $0x0
  8034dd:	e8 39 f2 ff ff       	call   80271b <sys_page_alloc>
  8034e2:	89 c3                	mov    %eax,%ebx
  8034e4:	83 c4 10             	add    $0x10,%esp
  8034e7:	85 c0                	test   %eax,%eax
  8034e9:	0f 88 c3 00 00 00    	js     8035b2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8034ef:	83 ec 0c             	sub    $0xc,%esp
  8034f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8034f5:	e8 81 f5 ff ff       	call   802a7b <fd2data>
  8034fa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034fc:	83 c4 0c             	add    $0xc,%esp
  8034ff:	68 07 04 00 00       	push   $0x407
  803504:	50                   	push   %eax
  803505:	6a 00                	push   $0x0
  803507:	e8 0f f2 ff ff       	call   80271b <sys_page_alloc>
  80350c:	89 c3                	mov    %eax,%ebx
  80350e:	83 c4 10             	add    $0x10,%esp
  803511:	85 c0                	test   %eax,%eax
  803513:	0f 88 89 00 00 00    	js     8035a2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803519:	83 ec 0c             	sub    $0xc,%esp
  80351c:	ff 75 f0             	pushl  -0x10(%ebp)
  80351f:	e8 57 f5 ff ff       	call   802a7b <fd2data>
  803524:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80352b:	50                   	push   %eax
  80352c:	6a 00                	push   $0x0
  80352e:	56                   	push   %esi
  80352f:	6a 00                	push   $0x0
  803531:	e8 28 f2 ff ff       	call   80275e <sys_page_map>
  803536:	89 c3                	mov    %eax,%ebx
  803538:	83 c4 20             	add    $0x20,%esp
  80353b:	85 c0                	test   %eax,%eax
  80353d:	78 55                	js     803594 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80353f:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803545:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803548:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80354a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80354d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803554:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80355a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80355d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80355f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803562:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803569:	83 ec 0c             	sub    $0xc,%esp
  80356c:	ff 75 f4             	pushl  -0xc(%ebp)
  80356f:	e8 f7 f4 ff ff       	call   802a6b <fd2num>
  803574:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803577:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803579:	83 c4 04             	add    $0x4,%esp
  80357c:	ff 75 f0             	pushl  -0x10(%ebp)
  80357f:	e8 e7 f4 ff ff       	call   802a6b <fd2num>
  803584:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803587:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80358a:	83 c4 10             	add    $0x10,%esp
  80358d:	ba 00 00 00 00       	mov    $0x0,%edx
  803592:	eb 30                	jmp    8035c4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803594:	83 ec 08             	sub    $0x8,%esp
  803597:	56                   	push   %esi
  803598:	6a 00                	push   $0x0
  80359a:	e8 01 f2 ff ff       	call   8027a0 <sys_page_unmap>
  80359f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8035a2:	83 ec 08             	sub    $0x8,%esp
  8035a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8035a8:	6a 00                	push   $0x0
  8035aa:	e8 f1 f1 ff ff       	call   8027a0 <sys_page_unmap>
  8035af:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8035b2:	83 ec 08             	sub    $0x8,%esp
  8035b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8035b8:	6a 00                	push   $0x0
  8035ba:	e8 e1 f1 ff ff       	call   8027a0 <sys_page_unmap>
  8035bf:	83 c4 10             	add    $0x10,%esp
  8035c2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8035c4:	89 d0                	mov    %edx,%eax
  8035c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8035c9:	5b                   	pop    %ebx
  8035ca:	5e                   	pop    %esi
  8035cb:	5d                   	pop    %ebp
  8035cc:	c3                   	ret    

008035cd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8035cd:	55                   	push   %ebp
  8035ce:	89 e5                	mov    %esp,%ebp
  8035d0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8035d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035d6:	50                   	push   %eax
  8035d7:	ff 75 08             	pushl  0x8(%ebp)
  8035da:	e8 02 f5 ff ff       	call   802ae1 <fd_lookup>
  8035df:	83 c4 10             	add    $0x10,%esp
  8035e2:	85 c0                	test   %eax,%eax
  8035e4:	78 18                	js     8035fe <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8035e6:	83 ec 0c             	sub    $0xc,%esp
  8035e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8035ec:	e8 8a f4 ff ff       	call   802a7b <fd2data>
	return _pipeisclosed(fd, p);
  8035f1:	89 c2                	mov    %eax,%edx
  8035f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035f6:	e8 21 fd ff ff       	call   80331c <_pipeisclosed>
  8035fb:	83 c4 10             	add    $0x10,%esp
}
  8035fe:	c9                   	leave  
  8035ff:	c3                   	ret    

00803600 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803600:	55                   	push   %ebp
  803601:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803603:	b8 00 00 00 00       	mov    $0x0,%eax
  803608:	5d                   	pop    %ebp
  803609:	c3                   	ret    

0080360a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80360a:	55                   	push   %ebp
  80360b:	89 e5                	mov    %esp,%ebp
  80360d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803610:	68 91 45 80 00       	push   $0x804591
  803615:	ff 75 0c             	pushl  0xc(%ebp)
  803618:	e8 fb ec ff ff       	call   802318 <strcpy>
	return 0;
}
  80361d:	b8 00 00 00 00       	mov    $0x0,%eax
  803622:	c9                   	leave  
  803623:	c3                   	ret    

00803624 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803624:	55                   	push   %ebp
  803625:	89 e5                	mov    %esp,%ebp
  803627:	57                   	push   %edi
  803628:	56                   	push   %esi
  803629:	53                   	push   %ebx
  80362a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803630:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803635:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80363b:	eb 2d                	jmp    80366a <devcons_write+0x46>
		m = n - tot;
  80363d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803640:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803642:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803645:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80364a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80364d:	83 ec 04             	sub    $0x4,%esp
  803650:	53                   	push   %ebx
  803651:	03 45 0c             	add    0xc(%ebp),%eax
  803654:	50                   	push   %eax
  803655:	57                   	push   %edi
  803656:	e8 4f ee ff ff       	call   8024aa <memmove>
		sys_cputs(buf, m);
  80365b:	83 c4 08             	add    $0x8,%esp
  80365e:	53                   	push   %ebx
  80365f:	57                   	push   %edi
  803660:	e8 fa ef ff ff       	call   80265f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803665:	01 de                	add    %ebx,%esi
  803667:	83 c4 10             	add    $0x10,%esp
  80366a:	89 f0                	mov    %esi,%eax
  80366c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80366f:	72 cc                	jb     80363d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803671:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803674:	5b                   	pop    %ebx
  803675:	5e                   	pop    %esi
  803676:	5f                   	pop    %edi
  803677:	5d                   	pop    %ebp
  803678:	c3                   	ret    

00803679 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803679:	55                   	push   %ebp
  80367a:	89 e5                	mov    %esp,%ebp
  80367c:	83 ec 08             	sub    $0x8,%esp
  80367f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803684:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803688:	74 2a                	je     8036b4 <devcons_read+0x3b>
  80368a:	eb 05                	jmp    803691 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80368c:	e8 6b f0 ff ff       	call   8026fc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803691:	e8 e7 ef ff ff       	call   80267d <sys_cgetc>
  803696:	85 c0                	test   %eax,%eax
  803698:	74 f2                	je     80368c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80369a:	85 c0                	test   %eax,%eax
  80369c:	78 16                	js     8036b4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80369e:	83 f8 04             	cmp    $0x4,%eax
  8036a1:	74 0c                	je     8036af <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8036a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8036a6:	88 02                	mov    %al,(%edx)
	return 1;
  8036a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8036ad:	eb 05                	jmp    8036b4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8036af:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8036b4:	c9                   	leave  
  8036b5:	c3                   	ret    

008036b6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8036b6:	55                   	push   %ebp
  8036b7:	89 e5                	mov    %esp,%ebp
  8036b9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8036bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8036bf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8036c2:	6a 01                	push   $0x1
  8036c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8036c7:	50                   	push   %eax
  8036c8:	e8 92 ef ff ff       	call   80265f <sys_cputs>
}
  8036cd:	83 c4 10             	add    $0x10,%esp
  8036d0:	c9                   	leave  
  8036d1:	c3                   	ret    

008036d2 <getchar>:

int
getchar(void)
{
  8036d2:	55                   	push   %ebp
  8036d3:	89 e5                	mov    %esp,%ebp
  8036d5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8036d8:	6a 01                	push   $0x1
  8036da:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8036dd:	50                   	push   %eax
  8036de:	6a 00                	push   $0x0
  8036e0:	e8 62 f6 ff ff       	call   802d47 <read>
	if (r < 0)
  8036e5:	83 c4 10             	add    $0x10,%esp
  8036e8:	85 c0                	test   %eax,%eax
  8036ea:	78 0f                	js     8036fb <getchar+0x29>
		return r;
	if (r < 1)
  8036ec:	85 c0                	test   %eax,%eax
  8036ee:	7e 06                	jle    8036f6 <getchar+0x24>
		return -E_EOF;
	return c;
  8036f0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8036f4:	eb 05                	jmp    8036fb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8036f6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8036fb:	c9                   	leave  
  8036fc:	c3                   	ret    

008036fd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8036fd:	55                   	push   %ebp
  8036fe:	89 e5                	mov    %esp,%ebp
  803700:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803703:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803706:	50                   	push   %eax
  803707:	ff 75 08             	pushl  0x8(%ebp)
  80370a:	e8 d2 f3 ff ff       	call   802ae1 <fd_lookup>
  80370f:	83 c4 10             	add    $0x10,%esp
  803712:	85 c0                	test   %eax,%eax
  803714:	78 11                	js     803727 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803716:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803719:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80371f:	39 10                	cmp    %edx,(%eax)
  803721:	0f 94 c0             	sete   %al
  803724:	0f b6 c0             	movzbl %al,%eax
}
  803727:	c9                   	leave  
  803728:	c3                   	ret    

00803729 <opencons>:

int
opencons(void)
{
  803729:	55                   	push   %ebp
  80372a:	89 e5                	mov    %esp,%ebp
  80372c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80372f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803732:	50                   	push   %eax
  803733:	e8 5a f3 ff ff       	call   802a92 <fd_alloc>
  803738:	83 c4 10             	add    $0x10,%esp
		return r;
  80373b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80373d:	85 c0                	test   %eax,%eax
  80373f:	78 3e                	js     80377f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803741:	83 ec 04             	sub    $0x4,%esp
  803744:	68 07 04 00 00       	push   $0x407
  803749:	ff 75 f4             	pushl  -0xc(%ebp)
  80374c:	6a 00                	push   $0x0
  80374e:	e8 c8 ef ff ff       	call   80271b <sys_page_alloc>
  803753:	83 c4 10             	add    $0x10,%esp
		return r;
  803756:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803758:	85 c0                	test   %eax,%eax
  80375a:	78 23                	js     80377f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80375c:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803765:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803767:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80376a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803771:	83 ec 0c             	sub    $0xc,%esp
  803774:	50                   	push   %eax
  803775:	e8 f1 f2 ff ff       	call   802a6b <fd2num>
  80377a:	89 c2                	mov    %eax,%edx
  80377c:	83 c4 10             	add    $0x10,%esp
}
  80377f:	89 d0                	mov    %edx,%eax
  803781:	c9                   	leave  
  803782:	c3                   	ret    
  803783:	66 90                	xchg   %ax,%ax
  803785:	66 90                	xchg   %ax,%ax
  803787:	66 90                	xchg   %ax,%ax
  803789:	66 90                	xchg   %ax,%ax
  80378b:	66 90                	xchg   %ax,%ax
  80378d:	66 90                	xchg   %ax,%ax
  80378f:	90                   	nop

00803790 <__udivdi3>:
  803790:	55                   	push   %ebp
  803791:	57                   	push   %edi
  803792:	56                   	push   %esi
  803793:	53                   	push   %ebx
  803794:	83 ec 1c             	sub    $0x1c,%esp
  803797:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80379b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80379f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8037a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8037a7:	85 f6                	test   %esi,%esi
  8037a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8037ad:	89 ca                	mov    %ecx,%edx
  8037af:	89 f8                	mov    %edi,%eax
  8037b1:	75 3d                	jne    8037f0 <__udivdi3+0x60>
  8037b3:	39 cf                	cmp    %ecx,%edi
  8037b5:	0f 87 c5 00 00 00    	ja     803880 <__udivdi3+0xf0>
  8037bb:	85 ff                	test   %edi,%edi
  8037bd:	89 fd                	mov    %edi,%ebp
  8037bf:	75 0b                	jne    8037cc <__udivdi3+0x3c>
  8037c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8037c6:	31 d2                	xor    %edx,%edx
  8037c8:	f7 f7                	div    %edi
  8037ca:	89 c5                	mov    %eax,%ebp
  8037cc:	89 c8                	mov    %ecx,%eax
  8037ce:	31 d2                	xor    %edx,%edx
  8037d0:	f7 f5                	div    %ebp
  8037d2:	89 c1                	mov    %eax,%ecx
  8037d4:	89 d8                	mov    %ebx,%eax
  8037d6:	89 cf                	mov    %ecx,%edi
  8037d8:	f7 f5                	div    %ebp
  8037da:	89 c3                	mov    %eax,%ebx
  8037dc:	89 d8                	mov    %ebx,%eax
  8037de:	89 fa                	mov    %edi,%edx
  8037e0:	83 c4 1c             	add    $0x1c,%esp
  8037e3:	5b                   	pop    %ebx
  8037e4:	5e                   	pop    %esi
  8037e5:	5f                   	pop    %edi
  8037e6:	5d                   	pop    %ebp
  8037e7:	c3                   	ret    
  8037e8:	90                   	nop
  8037e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8037f0:	39 ce                	cmp    %ecx,%esi
  8037f2:	77 74                	ja     803868 <__udivdi3+0xd8>
  8037f4:	0f bd fe             	bsr    %esi,%edi
  8037f7:	83 f7 1f             	xor    $0x1f,%edi
  8037fa:	0f 84 98 00 00 00    	je     803898 <__udivdi3+0x108>
  803800:	bb 20 00 00 00       	mov    $0x20,%ebx
  803805:	89 f9                	mov    %edi,%ecx
  803807:	89 c5                	mov    %eax,%ebp
  803809:	29 fb                	sub    %edi,%ebx
  80380b:	d3 e6                	shl    %cl,%esi
  80380d:	89 d9                	mov    %ebx,%ecx
  80380f:	d3 ed                	shr    %cl,%ebp
  803811:	89 f9                	mov    %edi,%ecx
  803813:	d3 e0                	shl    %cl,%eax
  803815:	09 ee                	or     %ebp,%esi
  803817:	89 d9                	mov    %ebx,%ecx
  803819:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80381d:	89 d5                	mov    %edx,%ebp
  80381f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803823:	d3 ed                	shr    %cl,%ebp
  803825:	89 f9                	mov    %edi,%ecx
  803827:	d3 e2                	shl    %cl,%edx
  803829:	89 d9                	mov    %ebx,%ecx
  80382b:	d3 e8                	shr    %cl,%eax
  80382d:	09 c2                	or     %eax,%edx
  80382f:	89 d0                	mov    %edx,%eax
  803831:	89 ea                	mov    %ebp,%edx
  803833:	f7 f6                	div    %esi
  803835:	89 d5                	mov    %edx,%ebp
  803837:	89 c3                	mov    %eax,%ebx
  803839:	f7 64 24 0c          	mull   0xc(%esp)
  80383d:	39 d5                	cmp    %edx,%ebp
  80383f:	72 10                	jb     803851 <__udivdi3+0xc1>
  803841:	8b 74 24 08          	mov    0x8(%esp),%esi
  803845:	89 f9                	mov    %edi,%ecx
  803847:	d3 e6                	shl    %cl,%esi
  803849:	39 c6                	cmp    %eax,%esi
  80384b:	73 07                	jae    803854 <__udivdi3+0xc4>
  80384d:	39 d5                	cmp    %edx,%ebp
  80384f:	75 03                	jne    803854 <__udivdi3+0xc4>
  803851:	83 eb 01             	sub    $0x1,%ebx
  803854:	31 ff                	xor    %edi,%edi
  803856:	89 d8                	mov    %ebx,%eax
  803858:	89 fa                	mov    %edi,%edx
  80385a:	83 c4 1c             	add    $0x1c,%esp
  80385d:	5b                   	pop    %ebx
  80385e:	5e                   	pop    %esi
  80385f:	5f                   	pop    %edi
  803860:	5d                   	pop    %ebp
  803861:	c3                   	ret    
  803862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803868:	31 ff                	xor    %edi,%edi
  80386a:	31 db                	xor    %ebx,%ebx
  80386c:	89 d8                	mov    %ebx,%eax
  80386e:	89 fa                	mov    %edi,%edx
  803870:	83 c4 1c             	add    $0x1c,%esp
  803873:	5b                   	pop    %ebx
  803874:	5e                   	pop    %esi
  803875:	5f                   	pop    %edi
  803876:	5d                   	pop    %ebp
  803877:	c3                   	ret    
  803878:	90                   	nop
  803879:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803880:	89 d8                	mov    %ebx,%eax
  803882:	f7 f7                	div    %edi
  803884:	31 ff                	xor    %edi,%edi
  803886:	89 c3                	mov    %eax,%ebx
  803888:	89 d8                	mov    %ebx,%eax
  80388a:	89 fa                	mov    %edi,%edx
  80388c:	83 c4 1c             	add    $0x1c,%esp
  80388f:	5b                   	pop    %ebx
  803890:	5e                   	pop    %esi
  803891:	5f                   	pop    %edi
  803892:	5d                   	pop    %ebp
  803893:	c3                   	ret    
  803894:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803898:	39 ce                	cmp    %ecx,%esi
  80389a:	72 0c                	jb     8038a8 <__udivdi3+0x118>
  80389c:	31 db                	xor    %ebx,%ebx
  80389e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8038a2:	0f 87 34 ff ff ff    	ja     8037dc <__udivdi3+0x4c>
  8038a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8038ad:	e9 2a ff ff ff       	jmp    8037dc <__udivdi3+0x4c>
  8038b2:	66 90                	xchg   %ax,%ax
  8038b4:	66 90                	xchg   %ax,%ax
  8038b6:	66 90                	xchg   %ax,%ax
  8038b8:	66 90                	xchg   %ax,%ax
  8038ba:	66 90                	xchg   %ax,%ax
  8038bc:	66 90                	xchg   %ax,%ax
  8038be:	66 90                	xchg   %ax,%ax

008038c0 <__umoddi3>:
  8038c0:	55                   	push   %ebp
  8038c1:	57                   	push   %edi
  8038c2:	56                   	push   %esi
  8038c3:	53                   	push   %ebx
  8038c4:	83 ec 1c             	sub    $0x1c,%esp
  8038c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8038cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8038cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8038d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8038d7:	85 d2                	test   %edx,%edx
  8038d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8038dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8038e1:	89 f3                	mov    %esi,%ebx
  8038e3:	89 3c 24             	mov    %edi,(%esp)
  8038e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8038ea:	75 1c                	jne    803908 <__umoddi3+0x48>
  8038ec:	39 f7                	cmp    %esi,%edi
  8038ee:	76 50                	jbe    803940 <__umoddi3+0x80>
  8038f0:	89 c8                	mov    %ecx,%eax
  8038f2:	89 f2                	mov    %esi,%edx
  8038f4:	f7 f7                	div    %edi
  8038f6:	89 d0                	mov    %edx,%eax
  8038f8:	31 d2                	xor    %edx,%edx
  8038fa:	83 c4 1c             	add    $0x1c,%esp
  8038fd:	5b                   	pop    %ebx
  8038fe:	5e                   	pop    %esi
  8038ff:	5f                   	pop    %edi
  803900:	5d                   	pop    %ebp
  803901:	c3                   	ret    
  803902:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803908:	39 f2                	cmp    %esi,%edx
  80390a:	89 d0                	mov    %edx,%eax
  80390c:	77 52                	ja     803960 <__umoddi3+0xa0>
  80390e:	0f bd ea             	bsr    %edx,%ebp
  803911:	83 f5 1f             	xor    $0x1f,%ebp
  803914:	75 5a                	jne    803970 <__umoddi3+0xb0>
  803916:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80391a:	0f 82 e0 00 00 00    	jb     803a00 <__umoddi3+0x140>
  803920:	39 0c 24             	cmp    %ecx,(%esp)
  803923:	0f 86 d7 00 00 00    	jbe    803a00 <__umoddi3+0x140>
  803929:	8b 44 24 08          	mov    0x8(%esp),%eax
  80392d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803931:	83 c4 1c             	add    $0x1c,%esp
  803934:	5b                   	pop    %ebx
  803935:	5e                   	pop    %esi
  803936:	5f                   	pop    %edi
  803937:	5d                   	pop    %ebp
  803938:	c3                   	ret    
  803939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803940:	85 ff                	test   %edi,%edi
  803942:	89 fd                	mov    %edi,%ebp
  803944:	75 0b                	jne    803951 <__umoddi3+0x91>
  803946:	b8 01 00 00 00       	mov    $0x1,%eax
  80394b:	31 d2                	xor    %edx,%edx
  80394d:	f7 f7                	div    %edi
  80394f:	89 c5                	mov    %eax,%ebp
  803951:	89 f0                	mov    %esi,%eax
  803953:	31 d2                	xor    %edx,%edx
  803955:	f7 f5                	div    %ebp
  803957:	89 c8                	mov    %ecx,%eax
  803959:	f7 f5                	div    %ebp
  80395b:	89 d0                	mov    %edx,%eax
  80395d:	eb 99                	jmp    8038f8 <__umoddi3+0x38>
  80395f:	90                   	nop
  803960:	89 c8                	mov    %ecx,%eax
  803962:	89 f2                	mov    %esi,%edx
  803964:	83 c4 1c             	add    $0x1c,%esp
  803967:	5b                   	pop    %ebx
  803968:	5e                   	pop    %esi
  803969:	5f                   	pop    %edi
  80396a:	5d                   	pop    %ebp
  80396b:	c3                   	ret    
  80396c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803970:	8b 34 24             	mov    (%esp),%esi
  803973:	bf 20 00 00 00       	mov    $0x20,%edi
  803978:	89 e9                	mov    %ebp,%ecx
  80397a:	29 ef                	sub    %ebp,%edi
  80397c:	d3 e0                	shl    %cl,%eax
  80397e:	89 f9                	mov    %edi,%ecx
  803980:	89 f2                	mov    %esi,%edx
  803982:	d3 ea                	shr    %cl,%edx
  803984:	89 e9                	mov    %ebp,%ecx
  803986:	09 c2                	or     %eax,%edx
  803988:	89 d8                	mov    %ebx,%eax
  80398a:	89 14 24             	mov    %edx,(%esp)
  80398d:	89 f2                	mov    %esi,%edx
  80398f:	d3 e2                	shl    %cl,%edx
  803991:	89 f9                	mov    %edi,%ecx
  803993:	89 54 24 04          	mov    %edx,0x4(%esp)
  803997:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80399b:	d3 e8                	shr    %cl,%eax
  80399d:	89 e9                	mov    %ebp,%ecx
  80399f:	89 c6                	mov    %eax,%esi
  8039a1:	d3 e3                	shl    %cl,%ebx
  8039a3:	89 f9                	mov    %edi,%ecx
  8039a5:	89 d0                	mov    %edx,%eax
  8039a7:	d3 e8                	shr    %cl,%eax
  8039a9:	89 e9                	mov    %ebp,%ecx
  8039ab:	09 d8                	or     %ebx,%eax
  8039ad:	89 d3                	mov    %edx,%ebx
  8039af:	89 f2                	mov    %esi,%edx
  8039b1:	f7 34 24             	divl   (%esp)
  8039b4:	89 d6                	mov    %edx,%esi
  8039b6:	d3 e3                	shl    %cl,%ebx
  8039b8:	f7 64 24 04          	mull   0x4(%esp)
  8039bc:	39 d6                	cmp    %edx,%esi
  8039be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8039c2:	89 d1                	mov    %edx,%ecx
  8039c4:	89 c3                	mov    %eax,%ebx
  8039c6:	72 08                	jb     8039d0 <__umoddi3+0x110>
  8039c8:	75 11                	jne    8039db <__umoddi3+0x11b>
  8039ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8039ce:	73 0b                	jae    8039db <__umoddi3+0x11b>
  8039d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8039d4:	1b 14 24             	sbb    (%esp),%edx
  8039d7:	89 d1                	mov    %edx,%ecx
  8039d9:	89 c3                	mov    %eax,%ebx
  8039db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8039df:	29 da                	sub    %ebx,%edx
  8039e1:	19 ce                	sbb    %ecx,%esi
  8039e3:	89 f9                	mov    %edi,%ecx
  8039e5:	89 f0                	mov    %esi,%eax
  8039e7:	d3 e0                	shl    %cl,%eax
  8039e9:	89 e9                	mov    %ebp,%ecx
  8039eb:	d3 ea                	shr    %cl,%edx
  8039ed:	89 e9                	mov    %ebp,%ecx
  8039ef:	d3 ee                	shr    %cl,%esi
  8039f1:	09 d0                	or     %edx,%eax
  8039f3:	89 f2                	mov    %esi,%edx
  8039f5:	83 c4 1c             	add    $0x1c,%esp
  8039f8:	5b                   	pop    %ebx
  8039f9:	5e                   	pop    %esi
  8039fa:	5f                   	pop    %edi
  8039fb:	5d                   	pop    %ebp
  8039fc:	c3                   	ret    
  8039fd:	8d 76 00             	lea    0x0(%esi),%esi
  803a00:	29 f9                	sub    %edi,%ecx
  803a02:	19 d6                	sbb    %edx,%esi
  803a04:	89 74 24 04          	mov    %esi,0x4(%esp)
  803a08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803a0c:	e9 18 ff ff ff       	jmp    803929 <__umoddi3+0x69>
