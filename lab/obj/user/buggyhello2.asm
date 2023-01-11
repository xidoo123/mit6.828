
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 2a 05 00 00       	call   8005c9 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 d8 22 80 00       	push   $0x8022d8
  800118:	6a 23                	push   $0x23
  80011a:	68 f5 22 80 00       	push   $0x8022f5
  80011f:	e8 1e 14 00 00       	call   801542 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 d8 22 80 00       	push   $0x8022d8
  800199:	6a 23                	push   $0x23
  80019b:	68 f5 22 80 00       	push   $0x8022f5
  8001a0:	e8 9d 13 00 00       	call   801542 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 d8 22 80 00       	push   $0x8022d8
  8001db:	6a 23                	push   $0x23
  8001dd:	68 f5 22 80 00       	push   $0x8022f5
  8001e2:	e8 5b 13 00 00       	call   801542 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 d8 22 80 00       	push   $0x8022d8
  80021d:	6a 23                	push   $0x23
  80021f:	68 f5 22 80 00       	push   $0x8022f5
  800224:	e8 19 13 00 00       	call   801542 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 d8 22 80 00       	push   $0x8022d8
  80025f:	6a 23                	push   $0x23
  800261:	68 f5 22 80 00       	push   $0x8022f5
  800266:	e8 d7 12 00 00       	call   801542 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 d8 22 80 00       	push   $0x8022d8
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 f5 22 80 00       	push   $0x8022f5
  8002a8:	e8 95 12 00 00       	call   801542 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 d8 22 80 00       	push   $0x8022d8
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 f5 22 80 00       	push   $0x8022f5
  8002ea:	e8 53 12 00 00       	call   801542 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 d8 22 80 00       	push   $0x8022d8
  800347:	6a 23                	push   $0x23
  800349:	68 f5 22 80 00       	push   $0x8022f5
  80034e:	e8 ef 11 00 00       	call   801542 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036b:	89 d1                	mov    %edx,%ecx
  80036d:	89 d3                	mov    %edx,%ebx
  80036f:	89 d7                	mov    %edx,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
  800380:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800383:	bb 00 00 00 00       	mov    $0x0,%ebx
  800388:	b8 0f 00 00 00       	mov    $0xf,%eax
  80038d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	89 df                	mov    %ebx,%edi
  800395:	89 de                	mov    %ebx,%esi
  800397:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800399:	85 c0                	test   %eax,%eax
  80039b:	7e 17                	jle    8003b4 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039d:	83 ec 0c             	sub    $0xc,%esp
  8003a0:	50                   	push   %eax
  8003a1:	6a 0f                	push   $0xf
  8003a3:	68 d8 22 80 00       	push   $0x8022d8
  8003a8:	6a 23                	push   $0x23
  8003aa:	68 f5 22 80 00       	push   $0x8022f5
  8003af:	e8 8e 11 00 00       	call   801542 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b7:	5b                   	pop    %ebx
  8003b8:	5e                   	pop    %esi
  8003b9:	5f                   	pop    %edi
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	57                   	push   %edi
  8003c0:	56                   	push   %esi
  8003c1:	53                   	push   %ebx
  8003c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ca:	b8 10 00 00 00       	mov    $0x10,%eax
  8003cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d5:	89 df                	mov    %ebx,%edi
  8003d7:	89 de                	mov    %ebx,%esi
  8003d9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	7e 17                	jle    8003f6 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003df:	83 ec 0c             	sub    $0xc,%esp
  8003e2:	50                   	push   %eax
  8003e3:	6a 10                	push   $0x10
  8003e5:	68 d8 22 80 00       	push   $0x8022d8
  8003ea:	6a 23                	push   $0x23
  8003ec:	68 f5 22 80 00       	push   $0x8022f5
  8003f1:	e8 4c 11 00 00       	call   801542 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8003f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f9:	5b                   	pop    %ebx
  8003fa:	5e                   	pop    %esi
  8003fb:	5f                   	pop    %edi
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    

008003fe <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
  800404:	05 00 00 00 30       	add    $0x30000000,%eax
  800409:	c1 e8 0c             	shr    $0xc,%eax
}
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800411:	8b 45 08             	mov    0x8(%ebp),%eax
  800414:	05 00 00 00 30       	add    $0x30000000,%eax
  800419:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80041e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800423:	5d                   	pop    %ebp
  800424:	c3                   	ret    

00800425 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800430:	89 c2                	mov    %eax,%edx
  800432:	c1 ea 16             	shr    $0x16,%edx
  800435:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043c:	f6 c2 01             	test   $0x1,%dl
  80043f:	74 11                	je     800452 <fd_alloc+0x2d>
  800441:	89 c2                	mov    %eax,%edx
  800443:	c1 ea 0c             	shr    $0xc,%edx
  800446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044d:	f6 c2 01             	test   $0x1,%dl
  800450:	75 09                	jne    80045b <fd_alloc+0x36>
			*fd_store = fd;
  800452:	89 01                	mov    %eax,(%ecx)
			return 0;
  800454:	b8 00 00 00 00       	mov    $0x0,%eax
  800459:	eb 17                	jmp    800472 <fd_alloc+0x4d>
  80045b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800460:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800465:	75 c9                	jne    800430 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800467:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80046d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800472:	5d                   	pop    %ebp
  800473:	c3                   	ret    

00800474 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800474:	55                   	push   %ebp
  800475:	89 e5                	mov    %esp,%ebp
  800477:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80047a:	83 f8 1f             	cmp    $0x1f,%eax
  80047d:	77 36                	ja     8004b5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80047f:	c1 e0 0c             	shl    $0xc,%eax
  800482:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800487:	89 c2                	mov    %eax,%edx
  800489:	c1 ea 16             	shr    $0x16,%edx
  80048c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800493:	f6 c2 01             	test   $0x1,%dl
  800496:	74 24                	je     8004bc <fd_lookup+0x48>
  800498:	89 c2                	mov    %eax,%edx
  80049a:	c1 ea 0c             	shr    $0xc,%edx
  80049d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004a4:	f6 c2 01             	test   $0x1,%dl
  8004a7:	74 1a                	je     8004c3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ac:	89 02                	mov    %eax,(%edx)
	return 0;
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	eb 13                	jmp    8004c8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ba:	eb 0c                	jmp    8004c8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004c1:	eb 05                	jmp    8004c8 <fd_lookup+0x54>
  8004c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004d3:	ba 80 23 80 00       	mov    $0x802380,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004d8:	eb 13                	jmp    8004ed <dev_lookup+0x23>
  8004da:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004dd:	39 08                	cmp    %ecx,(%eax)
  8004df:	75 0c                	jne    8004ed <dev_lookup+0x23>
			*dev = devtab[i];
  8004e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004eb:	eb 2e                	jmp    80051b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004ed:	8b 02                	mov    (%edx),%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	75 e7                	jne    8004da <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004f3:	a1 08 40 80 00       	mov    0x804008,%eax
  8004f8:	8b 40 48             	mov    0x48(%eax),%eax
  8004fb:	83 ec 04             	sub    $0x4,%esp
  8004fe:	51                   	push   %ecx
  8004ff:	50                   	push   %eax
  800500:	68 04 23 80 00       	push   $0x802304
  800505:	e8 11 11 00 00       	call   80161b <cprintf>
	*dev = 0;
  80050a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	56                   	push   %esi
  800521:	53                   	push   %ebx
  800522:	83 ec 10             	sub    $0x10,%esp
  800525:	8b 75 08             	mov    0x8(%ebp),%esi
  800528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80052b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052e:	50                   	push   %eax
  80052f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800535:	c1 e8 0c             	shr    $0xc,%eax
  800538:	50                   	push   %eax
  800539:	e8 36 ff ff ff       	call   800474 <fd_lookup>
  80053e:	83 c4 08             	add    $0x8,%esp
  800541:	85 c0                	test   %eax,%eax
  800543:	78 05                	js     80054a <fd_close+0x2d>
	    || fd != fd2)
  800545:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800548:	74 0c                	je     800556 <fd_close+0x39>
		return (must_exist ? r : 0);
  80054a:	84 db                	test   %bl,%bl
  80054c:	ba 00 00 00 00       	mov    $0x0,%edx
  800551:	0f 44 c2             	cmove  %edx,%eax
  800554:	eb 41                	jmp    800597 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80055c:	50                   	push   %eax
  80055d:	ff 36                	pushl  (%esi)
  80055f:	e8 66 ff ff ff       	call   8004ca <dev_lookup>
  800564:	89 c3                	mov    %eax,%ebx
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	85 c0                	test   %eax,%eax
  80056b:	78 1a                	js     800587 <fd_close+0x6a>
		if (dev->dev_close)
  80056d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800570:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800573:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800578:	85 c0                	test   %eax,%eax
  80057a:	74 0b                	je     800587 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80057c:	83 ec 0c             	sub    $0xc,%esp
  80057f:	56                   	push   %esi
  800580:	ff d0                	call   *%eax
  800582:	89 c3                	mov    %eax,%ebx
  800584:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	56                   	push   %esi
  80058b:	6a 00                	push   $0x0
  80058d:	e8 5d fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	89 d8                	mov    %ebx,%eax
}
  800597:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80059a:	5b                   	pop    %ebx
  80059b:	5e                   	pop    %esi
  80059c:	5d                   	pop    %ebp
  80059d:	c3                   	ret    

0080059e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
  8005a1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005a7:	50                   	push   %eax
  8005a8:	ff 75 08             	pushl  0x8(%ebp)
  8005ab:	e8 c4 fe ff ff       	call   800474 <fd_lookup>
  8005b0:	83 c4 08             	add    $0x8,%esp
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	78 10                	js     8005c7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	6a 01                	push   $0x1
  8005bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8005bf:	e8 59 ff ff ff       	call   80051d <fd_close>
  8005c4:	83 c4 10             	add    $0x10,%esp
}
  8005c7:	c9                   	leave  
  8005c8:	c3                   	ret    

008005c9 <close_all>:

void
close_all(void)
{
  8005c9:	55                   	push   %ebp
  8005ca:	89 e5                	mov    %esp,%ebp
  8005cc:	53                   	push   %ebx
  8005cd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005d5:	83 ec 0c             	sub    $0xc,%esp
  8005d8:	53                   	push   %ebx
  8005d9:	e8 c0 ff ff ff       	call   80059e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005de:	83 c3 01             	add    $0x1,%ebx
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	83 fb 20             	cmp    $0x20,%ebx
  8005e7:	75 ec                	jne    8005d5 <close_all+0xc>
		close(i);
}
  8005e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005ec:	c9                   	leave  
  8005ed:	c3                   	ret    

008005ee <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ee:	55                   	push   %ebp
  8005ef:	89 e5                	mov    %esp,%ebp
  8005f1:	57                   	push   %edi
  8005f2:	56                   	push   %esi
  8005f3:	53                   	push   %ebx
  8005f4:	83 ec 2c             	sub    $0x2c,%esp
  8005f7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005fd:	50                   	push   %eax
  8005fe:	ff 75 08             	pushl  0x8(%ebp)
  800601:	e8 6e fe ff ff       	call   800474 <fd_lookup>
  800606:	83 c4 08             	add    $0x8,%esp
  800609:	85 c0                	test   %eax,%eax
  80060b:	0f 88 c1 00 00 00    	js     8006d2 <dup+0xe4>
		return r;
	close(newfdnum);
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	56                   	push   %esi
  800615:	e8 84 ff ff ff       	call   80059e <close>

	newfd = INDEX2FD(newfdnum);
  80061a:	89 f3                	mov    %esi,%ebx
  80061c:	c1 e3 0c             	shl    $0xc,%ebx
  80061f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800625:	83 c4 04             	add    $0x4,%esp
  800628:	ff 75 e4             	pushl  -0x1c(%ebp)
  80062b:	e8 de fd ff ff       	call   80040e <fd2data>
  800630:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800632:	89 1c 24             	mov    %ebx,(%esp)
  800635:	e8 d4 fd ff ff       	call   80040e <fd2data>
  80063a:	83 c4 10             	add    $0x10,%esp
  80063d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800640:	89 f8                	mov    %edi,%eax
  800642:	c1 e8 16             	shr    $0x16,%eax
  800645:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80064c:	a8 01                	test   $0x1,%al
  80064e:	74 37                	je     800687 <dup+0x99>
  800650:	89 f8                	mov    %edi,%eax
  800652:	c1 e8 0c             	shr    $0xc,%eax
  800655:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80065c:	f6 c2 01             	test   $0x1,%dl
  80065f:	74 26                	je     800687 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800661:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800668:	83 ec 0c             	sub    $0xc,%esp
  80066b:	25 07 0e 00 00       	and    $0xe07,%eax
  800670:	50                   	push   %eax
  800671:	ff 75 d4             	pushl  -0x2c(%ebp)
  800674:	6a 00                	push   $0x0
  800676:	57                   	push   %edi
  800677:	6a 00                	push   $0x0
  800679:	e8 2f fb ff ff       	call   8001ad <sys_page_map>
  80067e:	89 c7                	mov    %eax,%edi
  800680:	83 c4 20             	add    $0x20,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	78 2e                	js     8006b5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800687:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068a:	89 d0                	mov    %edx,%eax
  80068c:	c1 e8 0c             	shr    $0xc,%eax
  80068f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800696:	83 ec 0c             	sub    $0xc,%esp
  800699:	25 07 0e 00 00       	and    $0xe07,%eax
  80069e:	50                   	push   %eax
  80069f:	53                   	push   %ebx
  8006a0:	6a 00                	push   $0x0
  8006a2:	52                   	push   %edx
  8006a3:	6a 00                	push   $0x0
  8006a5:	e8 03 fb ff ff       	call   8001ad <sys_page_map>
  8006aa:	89 c7                	mov    %eax,%edi
  8006ac:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006af:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	79 1d                	jns    8006d2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 00                	push   $0x0
  8006bb:	e8 2f fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006c0:	83 c4 08             	add    $0x8,%esp
  8006c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006c6:	6a 00                	push   $0x0
  8006c8:	e8 22 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	89 f8                	mov    %edi,%eax
}
  8006d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d5:	5b                   	pop    %ebx
  8006d6:	5e                   	pop    %esi
  8006d7:	5f                   	pop    %edi
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	53                   	push   %ebx
  8006de:	83 ec 14             	sub    $0x14,%esp
  8006e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	53                   	push   %ebx
  8006e9:	e8 86 fd ff ff       	call   800474 <fd_lookup>
  8006ee:	83 c4 08             	add    $0x8,%esp
  8006f1:	89 c2                	mov    %eax,%edx
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	78 6d                	js     800764 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006fd:	50                   	push   %eax
  8006fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800701:	ff 30                	pushl  (%eax)
  800703:	e8 c2 fd ff ff       	call   8004ca <dev_lookup>
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	85 c0                	test   %eax,%eax
  80070d:	78 4c                	js     80075b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80070f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800712:	8b 42 08             	mov    0x8(%edx),%eax
  800715:	83 e0 03             	and    $0x3,%eax
  800718:	83 f8 01             	cmp    $0x1,%eax
  80071b:	75 21                	jne    80073e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80071d:	a1 08 40 80 00       	mov    0x804008,%eax
  800722:	8b 40 48             	mov    0x48(%eax),%eax
  800725:	83 ec 04             	sub    $0x4,%esp
  800728:	53                   	push   %ebx
  800729:	50                   	push   %eax
  80072a:	68 45 23 80 00       	push   $0x802345
  80072f:	e8 e7 0e 00 00       	call   80161b <cprintf>
		return -E_INVAL;
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80073c:	eb 26                	jmp    800764 <read+0x8a>
	}
	if (!dev->dev_read)
  80073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800741:	8b 40 08             	mov    0x8(%eax),%eax
  800744:	85 c0                	test   %eax,%eax
  800746:	74 17                	je     80075f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800748:	83 ec 04             	sub    $0x4,%esp
  80074b:	ff 75 10             	pushl  0x10(%ebp)
  80074e:	ff 75 0c             	pushl  0xc(%ebp)
  800751:	52                   	push   %edx
  800752:	ff d0                	call   *%eax
  800754:	89 c2                	mov    %eax,%edx
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 09                	jmp    800764 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80075b:	89 c2                	mov    %eax,%edx
  80075d:	eb 05                	jmp    800764 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80075f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800764:	89 d0                	mov    %edx,%eax
  800766:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	57                   	push   %edi
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
  800771:	83 ec 0c             	sub    $0xc,%esp
  800774:	8b 7d 08             	mov    0x8(%ebp),%edi
  800777:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80077a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077f:	eb 21                	jmp    8007a2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800781:	83 ec 04             	sub    $0x4,%esp
  800784:	89 f0                	mov    %esi,%eax
  800786:	29 d8                	sub    %ebx,%eax
  800788:	50                   	push   %eax
  800789:	89 d8                	mov    %ebx,%eax
  80078b:	03 45 0c             	add    0xc(%ebp),%eax
  80078e:	50                   	push   %eax
  80078f:	57                   	push   %edi
  800790:	e8 45 ff ff ff       	call   8006da <read>
		if (m < 0)
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	85 c0                	test   %eax,%eax
  80079a:	78 10                	js     8007ac <readn+0x41>
			return m;
		if (m == 0)
  80079c:	85 c0                	test   %eax,%eax
  80079e:	74 0a                	je     8007aa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007a0:	01 c3                	add    %eax,%ebx
  8007a2:	39 f3                	cmp    %esi,%ebx
  8007a4:	72 db                	jb     800781 <readn+0x16>
  8007a6:	89 d8                	mov    %ebx,%eax
  8007a8:	eb 02                	jmp    8007ac <readn+0x41>
  8007aa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8007ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007af:	5b                   	pop    %ebx
  8007b0:	5e                   	pop    %esi
  8007b1:	5f                   	pop    %edi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	83 ec 14             	sub    $0x14,%esp
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c1:	50                   	push   %eax
  8007c2:	53                   	push   %ebx
  8007c3:	e8 ac fc ff ff       	call   800474 <fd_lookup>
  8007c8:	83 c4 08             	add    $0x8,%esp
  8007cb:	89 c2                	mov    %eax,%edx
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 68                	js     800839 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d1:	83 ec 08             	sub    $0x8,%esp
  8007d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d7:	50                   	push   %eax
  8007d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007db:	ff 30                	pushl  (%eax)
  8007dd:	e8 e8 fc ff ff       	call   8004ca <dev_lookup>
  8007e2:	83 c4 10             	add    $0x10,%esp
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	78 47                	js     800830 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f0:	75 21                	jne    800813 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8007f7:	8b 40 48             	mov    0x48(%eax),%eax
  8007fa:	83 ec 04             	sub    $0x4,%esp
  8007fd:	53                   	push   %ebx
  8007fe:	50                   	push   %eax
  8007ff:	68 61 23 80 00       	push   $0x802361
  800804:	e8 12 0e 00 00       	call   80161b <cprintf>
		return -E_INVAL;
  800809:	83 c4 10             	add    $0x10,%esp
  80080c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800811:	eb 26                	jmp    800839 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800813:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800816:	8b 52 0c             	mov    0xc(%edx),%edx
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 17                	je     800834 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80081d:	83 ec 04             	sub    $0x4,%esp
  800820:	ff 75 10             	pushl  0x10(%ebp)
  800823:	ff 75 0c             	pushl  0xc(%ebp)
  800826:	50                   	push   %eax
  800827:	ff d2                	call   *%edx
  800829:	89 c2                	mov    %eax,%edx
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	eb 09                	jmp    800839 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800830:	89 c2                	mov    %eax,%edx
  800832:	eb 05                	jmp    800839 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800834:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800839:	89 d0                	mov    %edx,%eax
  80083b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <seek>:

int
seek(int fdnum, off_t offset)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800846:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800849:	50                   	push   %eax
  80084a:	ff 75 08             	pushl  0x8(%ebp)
  80084d:	e8 22 fc ff ff       	call   800474 <fd_lookup>
  800852:	83 c4 08             	add    $0x8,%esp
  800855:	85 c0                	test   %eax,%eax
  800857:	78 0e                	js     800867 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800859:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	83 ec 14             	sub    $0x14,%esp
  800870:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800873:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800876:	50                   	push   %eax
  800877:	53                   	push   %ebx
  800878:	e8 f7 fb ff ff       	call   800474 <fd_lookup>
  80087d:	83 c4 08             	add    $0x8,%esp
  800880:	89 c2                	mov    %eax,%edx
  800882:	85 c0                	test   %eax,%eax
  800884:	78 65                	js     8008eb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088c:	50                   	push   %eax
  80088d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800890:	ff 30                	pushl  (%eax)
  800892:	e8 33 fc ff ff       	call   8004ca <dev_lookup>
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	85 c0                	test   %eax,%eax
  80089c:	78 44                	js     8008e2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80089e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008a5:	75 21                	jne    8008c8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008a7:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008ac:	8b 40 48             	mov    0x48(%eax),%eax
  8008af:	83 ec 04             	sub    $0x4,%esp
  8008b2:	53                   	push   %ebx
  8008b3:	50                   	push   %eax
  8008b4:	68 24 23 80 00       	push   $0x802324
  8008b9:	e8 5d 0d 00 00       	call   80161b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008c6:	eb 23                	jmp    8008eb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008cb:	8b 52 18             	mov    0x18(%edx),%edx
  8008ce:	85 d2                	test   %edx,%edx
  8008d0:	74 14                	je     8008e6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	ff 75 0c             	pushl  0xc(%ebp)
  8008d8:	50                   	push   %eax
  8008d9:	ff d2                	call   *%edx
  8008db:	89 c2                	mov    %eax,%edx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	eb 09                	jmp    8008eb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e2:	89 c2                	mov    %eax,%edx
  8008e4:	eb 05                	jmp    8008eb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008eb:	89 d0                	mov    %edx,%eax
  8008ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	83 ec 14             	sub    $0x14,%esp
  8008f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ff:	50                   	push   %eax
  800900:	ff 75 08             	pushl  0x8(%ebp)
  800903:	e8 6c fb ff ff       	call   800474 <fd_lookup>
  800908:	83 c4 08             	add    $0x8,%esp
  80090b:	89 c2                	mov    %eax,%edx
  80090d:	85 c0                	test   %eax,%eax
  80090f:	78 58                	js     800969 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800917:	50                   	push   %eax
  800918:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80091b:	ff 30                	pushl  (%eax)
  80091d:	e8 a8 fb ff ff       	call   8004ca <dev_lookup>
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	85 c0                	test   %eax,%eax
  800927:	78 37                	js     800960 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800929:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800930:	74 32                	je     800964 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800932:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800935:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80093c:	00 00 00 
	stat->st_isdir = 0;
  80093f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800946:	00 00 00 
	stat->st_dev = dev;
  800949:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80094f:	83 ec 08             	sub    $0x8,%esp
  800952:	53                   	push   %ebx
  800953:	ff 75 f0             	pushl  -0x10(%ebp)
  800956:	ff 50 14             	call   *0x14(%eax)
  800959:	89 c2                	mov    %eax,%edx
  80095b:	83 c4 10             	add    $0x10,%esp
  80095e:	eb 09                	jmp    800969 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800960:	89 c2                	mov    %eax,%edx
  800962:	eb 05                	jmp    800969 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800964:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800969:	89 d0                	mov    %edx,%eax
  80096b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800975:	83 ec 08             	sub    $0x8,%esp
  800978:	6a 00                	push   $0x0
  80097a:	ff 75 08             	pushl  0x8(%ebp)
  80097d:	e8 d6 01 00 00       	call   800b58 <open>
  800982:	89 c3                	mov    %eax,%ebx
  800984:	83 c4 10             	add    $0x10,%esp
  800987:	85 c0                	test   %eax,%eax
  800989:	78 1b                	js     8009a6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80098b:	83 ec 08             	sub    $0x8,%esp
  80098e:	ff 75 0c             	pushl  0xc(%ebp)
  800991:	50                   	push   %eax
  800992:	e8 5b ff ff ff       	call   8008f2 <fstat>
  800997:	89 c6                	mov    %eax,%esi
	close(fd);
  800999:	89 1c 24             	mov    %ebx,(%esp)
  80099c:	e8 fd fb ff ff       	call   80059e <close>
	return r;
  8009a1:	83 c4 10             	add    $0x10,%esp
  8009a4:	89 f0                	mov    %esi,%eax
}
  8009a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	89 c6                	mov    %eax,%esi
  8009b4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009b6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009bd:	75 12                	jne    8009d1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009bf:	83 ec 0c             	sub    $0xc,%esp
  8009c2:	6a 01                	push   $0x1
  8009c4:	e8 d9 15 00 00       	call   801fa2 <ipc_find_env>
  8009c9:	a3 00 40 80 00       	mov    %eax,0x804000
  8009ce:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009d1:	6a 07                	push   $0x7
  8009d3:	68 00 50 80 00       	push   $0x805000
  8009d8:	56                   	push   %esi
  8009d9:	ff 35 00 40 80 00    	pushl  0x804000
  8009df:	e8 6a 15 00 00       	call   801f4e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009e4:	83 c4 0c             	add    $0xc,%esp
  8009e7:	6a 00                	push   $0x0
  8009e9:	53                   	push   %ebx
  8009ea:	6a 00                	push   $0x0
  8009ec:	e8 f6 14 00 00       	call   801ee7 <ipc_recv>
}
  8009f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f4:	5b                   	pop    %ebx
  8009f5:	5e                   	pop    %esi
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 40 0c             	mov    0xc(%eax),%eax
  800a04:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a11:	ba 00 00 00 00       	mov    $0x0,%edx
  800a16:	b8 02 00 00 00       	mov    $0x2,%eax
  800a1b:	e8 8d ff ff ff       	call   8009ad <fsipc>
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a33:	ba 00 00 00 00       	mov    $0x0,%edx
  800a38:	b8 06 00 00 00       	mov    $0x6,%eax
  800a3d:	e8 6b ff ff ff       	call   8009ad <fsipc>
}
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	53                   	push   %ebx
  800a48:	83 ec 04             	sub    $0x4,%esp
  800a4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 40 0c             	mov    0xc(%eax),%eax
  800a54:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a59:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800a63:	e8 45 ff ff ff       	call   8009ad <fsipc>
  800a68:	85 c0                	test   %eax,%eax
  800a6a:	78 2c                	js     800a98 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	68 00 50 80 00       	push   $0x805000
  800a74:	53                   	push   %ebx
  800a75:	e8 26 11 00 00       	call   801ba0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a7a:	a1 80 50 80 00       	mov    0x805080,%eax
  800a7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a85:	a1 84 50 80 00       	mov    0x805084,%eax
  800a8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a90:	83 c4 10             	add    $0x10,%esp
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	83 ec 0c             	sub    $0xc,%esp
  800aa3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa9:	8b 52 0c             	mov    0xc(%edx),%edx
  800aac:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800ab2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800ab7:	50                   	push   %eax
  800ab8:	ff 75 0c             	pushl  0xc(%ebp)
  800abb:	68 08 50 80 00       	push   $0x805008
  800ac0:	e8 6d 12 00 00       	call   801d32 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 04 00 00 00       	mov    $0x4,%eax
  800acf:	e8 d9 fe ff ff       	call   8009ad <fsipc>

}
  800ad4:	c9                   	leave  
  800ad5:	c3                   	ret    

00800ad6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ae4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ae9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aef:	ba 00 00 00 00       	mov    $0x0,%edx
  800af4:	b8 03 00 00 00       	mov    $0x3,%eax
  800af9:	e8 af fe ff ff       	call   8009ad <fsipc>
  800afe:	89 c3                	mov    %eax,%ebx
  800b00:	85 c0                	test   %eax,%eax
  800b02:	78 4b                	js     800b4f <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b04:	39 c6                	cmp    %eax,%esi
  800b06:	73 16                	jae    800b1e <devfile_read+0x48>
  800b08:	68 94 23 80 00       	push   $0x802394
  800b0d:	68 9b 23 80 00       	push   $0x80239b
  800b12:	6a 7c                	push   $0x7c
  800b14:	68 b0 23 80 00       	push   $0x8023b0
  800b19:	e8 24 0a 00 00       	call   801542 <_panic>
	assert(r <= PGSIZE);
  800b1e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b23:	7e 16                	jle    800b3b <devfile_read+0x65>
  800b25:	68 bb 23 80 00       	push   $0x8023bb
  800b2a:	68 9b 23 80 00       	push   $0x80239b
  800b2f:	6a 7d                	push   $0x7d
  800b31:	68 b0 23 80 00       	push   $0x8023b0
  800b36:	e8 07 0a 00 00       	call   801542 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b3b:	83 ec 04             	sub    $0x4,%esp
  800b3e:	50                   	push   %eax
  800b3f:	68 00 50 80 00       	push   $0x805000
  800b44:	ff 75 0c             	pushl  0xc(%ebp)
  800b47:	e8 e6 11 00 00       	call   801d32 <memmove>
	return r;
  800b4c:	83 c4 10             	add    $0x10,%esp
}
  800b4f:	89 d8                	mov    %ebx,%eax
  800b51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	53                   	push   %ebx
  800b5c:	83 ec 20             	sub    $0x20,%esp
  800b5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b62:	53                   	push   %ebx
  800b63:	e8 ff 0f 00 00       	call   801b67 <strlen>
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b70:	7f 67                	jg     800bd9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b78:	50                   	push   %eax
  800b79:	e8 a7 f8 ff ff       	call   800425 <fd_alloc>
  800b7e:	83 c4 10             	add    $0x10,%esp
		return r;
  800b81:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	78 57                	js     800bde <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b87:	83 ec 08             	sub    $0x8,%esp
  800b8a:	53                   	push   %ebx
  800b8b:	68 00 50 80 00       	push   $0x805000
  800b90:	e8 0b 10 00 00       	call   801ba0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b98:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ba0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba5:	e8 03 fe ff ff       	call   8009ad <fsipc>
  800baa:	89 c3                	mov    %eax,%ebx
  800bac:	83 c4 10             	add    $0x10,%esp
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	79 14                	jns    800bc7 <open+0x6f>
		fd_close(fd, 0);
  800bb3:	83 ec 08             	sub    $0x8,%esp
  800bb6:	6a 00                	push   $0x0
  800bb8:	ff 75 f4             	pushl  -0xc(%ebp)
  800bbb:	e8 5d f9 ff ff       	call   80051d <fd_close>
		return r;
  800bc0:	83 c4 10             	add    $0x10,%esp
  800bc3:	89 da                	mov    %ebx,%edx
  800bc5:	eb 17                	jmp    800bde <open+0x86>
	}

	return fd2num(fd);
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	ff 75 f4             	pushl  -0xc(%ebp)
  800bcd:	e8 2c f8 ff ff       	call   8003fe <fd2num>
  800bd2:	89 c2                	mov    %eax,%edx
  800bd4:	83 c4 10             	add    $0x10,%esp
  800bd7:	eb 05                	jmp    800bde <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bd9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bde:	89 d0                	mov    %edx,%eax
  800be0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    

00800be5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800beb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf5:	e8 b3 fd ff ff       	call   8009ad <fsipc>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c02:	68 c7 23 80 00       	push   $0x8023c7
  800c07:	ff 75 0c             	pushl  0xc(%ebp)
  800c0a:	e8 91 0f 00 00       	call   801ba0 <strcpy>
	return 0;
}
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 10             	sub    $0x10,%esp
  800c1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c20:	53                   	push   %ebx
  800c21:	e8 b5 13 00 00       	call   801fdb <pageref>
  800c26:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c29:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c2e:	83 f8 01             	cmp    $0x1,%eax
  800c31:	75 10                	jne    800c43 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	ff 73 0c             	pushl  0xc(%ebx)
  800c39:	e8 c0 02 00 00       	call   800efe <nsipc_close>
  800c3e:	89 c2                	mov    %eax,%edx
  800c40:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c43:	89 d0                	mov    %edx,%eax
  800c45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    

00800c4a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c50:	6a 00                	push   $0x0
  800c52:	ff 75 10             	pushl  0x10(%ebp)
  800c55:	ff 75 0c             	pushl  0xc(%ebp)
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	ff 70 0c             	pushl  0xc(%eax)
  800c5e:	e8 78 03 00 00       	call   800fdb <nsipc_send>
}
  800c63:	c9                   	leave  
  800c64:	c3                   	ret    

00800c65 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c6b:	6a 00                	push   $0x0
  800c6d:	ff 75 10             	pushl  0x10(%ebp)
  800c70:	ff 75 0c             	pushl  0xc(%ebp)
  800c73:	8b 45 08             	mov    0x8(%ebp),%eax
  800c76:	ff 70 0c             	pushl  0xc(%eax)
  800c79:	e8 f1 02 00 00       	call   800f6f <nsipc_recv>
}
  800c7e:	c9                   	leave  
  800c7f:	c3                   	ret    

00800c80 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c86:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c89:	52                   	push   %edx
  800c8a:	50                   	push   %eax
  800c8b:	e8 e4 f7 ff ff       	call   800474 <fd_lookup>
  800c90:	83 c4 10             	add    $0x10,%esp
  800c93:	85 c0                	test   %eax,%eax
  800c95:	78 17                	js     800cae <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9a:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800ca0:	39 08                	cmp    %ecx,(%eax)
  800ca2:	75 05                	jne    800ca9 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800ca4:	8b 40 0c             	mov    0xc(%eax),%eax
  800ca7:	eb 05                	jmp    800cae <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800ca9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800cae:	c9                   	leave  
  800caf:	c3                   	ret    

00800cb0 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 1c             	sub    $0x1c,%esp
  800cb8:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800cba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cbd:	50                   	push   %eax
  800cbe:	e8 62 f7 ff ff       	call   800425 <fd_alloc>
  800cc3:	89 c3                	mov    %eax,%ebx
  800cc5:	83 c4 10             	add    $0x10,%esp
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	78 1b                	js     800ce7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800ccc:	83 ec 04             	sub    $0x4,%esp
  800ccf:	68 07 04 00 00       	push   $0x407
  800cd4:	ff 75 f4             	pushl  -0xc(%ebp)
  800cd7:	6a 00                	push   $0x0
  800cd9:	e8 8c f4 ff ff       	call   80016a <sys_page_alloc>
  800cde:	89 c3                	mov    %eax,%ebx
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	79 10                	jns    800cf7 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	56                   	push   %esi
  800ceb:	e8 0e 02 00 00       	call   800efe <nsipc_close>
		return r;
  800cf0:	83 c4 10             	add    $0x10,%esp
  800cf3:	89 d8                	mov    %ebx,%eax
  800cf5:	eb 24                	jmp    800d1b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cf7:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d00:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d05:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800d0c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	50                   	push   %eax
  800d13:	e8 e6 f6 ff ff       	call   8003fe <fd2num>
  800d18:	83 c4 10             	add    $0x10,%esp
}
  800d1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	e8 50 ff ff ff       	call   800c80 <fd2sockid>
		return r;
  800d30:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	78 1f                	js     800d55 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d36:	83 ec 04             	sub    $0x4,%esp
  800d39:	ff 75 10             	pushl  0x10(%ebp)
  800d3c:	ff 75 0c             	pushl  0xc(%ebp)
  800d3f:	50                   	push   %eax
  800d40:	e8 12 01 00 00       	call   800e57 <nsipc_accept>
  800d45:	83 c4 10             	add    $0x10,%esp
		return r;
  800d48:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	78 07                	js     800d55 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d4e:	e8 5d ff ff ff       	call   800cb0 <alloc_sockfd>
  800d53:	89 c1                	mov    %eax,%ecx
}
  800d55:	89 c8                	mov    %ecx,%eax
  800d57:	c9                   	leave  
  800d58:	c3                   	ret    

00800d59 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	e8 19 ff ff ff       	call   800c80 <fd2sockid>
  800d67:	85 c0                	test   %eax,%eax
  800d69:	78 12                	js     800d7d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d6b:	83 ec 04             	sub    $0x4,%esp
  800d6e:	ff 75 10             	pushl  0x10(%ebp)
  800d71:	ff 75 0c             	pushl  0xc(%ebp)
  800d74:	50                   	push   %eax
  800d75:	e8 2d 01 00 00       	call   800ea7 <nsipc_bind>
  800d7a:	83 c4 10             	add    $0x10,%esp
}
  800d7d:	c9                   	leave  
  800d7e:	c3                   	ret    

00800d7f <shutdown>:

int
shutdown(int s, int how)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	e8 f3 fe ff ff       	call   800c80 <fd2sockid>
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	78 0f                	js     800da0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d91:	83 ec 08             	sub    $0x8,%esp
  800d94:	ff 75 0c             	pushl  0xc(%ebp)
  800d97:	50                   	push   %eax
  800d98:	e8 3f 01 00 00       	call   800edc <nsipc_shutdown>
  800d9d:	83 c4 10             	add    $0x10,%esp
}
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    

00800da2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	e8 d0 fe ff ff       	call   800c80 <fd2sockid>
  800db0:	85 c0                	test   %eax,%eax
  800db2:	78 12                	js     800dc6 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800db4:	83 ec 04             	sub    $0x4,%esp
  800db7:	ff 75 10             	pushl  0x10(%ebp)
  800dba:	ff 75 0c             	pushl  0xc(%ebp)
  800dbd:	50                   	push   %eax
  800dbe:	e8 55 01 00 00       	call   800f18 <nsipc_connect>
  800dc3:	83 c4 10             	add    $0x10,%esp
}
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <listen>:

int
listen(int s, int backlog)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	e8 aa fe ff ff       	call   800c80 <fd2sockid>
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	78 0f                	js     800de9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dda:	83 ec 08             	sub    $0x8,%esp
  800ddd:	ff 75 0c             	pushl  0xc(%ebp)
  800de0:	50                   	push   %eax
  800de1:	e8 67 01 00 00       	call   800f4d <nsipc_listen>
  800de6:	83 c4 10             	add    $0x10,%esp
}
  800de9:	c9                   	leave  
  800dea:	c3                   	ret    

00800deb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800df1:	ff 75 10             	pushl  0x10(%ebp)
  800df4:	ff 75 0c             	pushl  0xc(%ebp)
  800df7:	ff 75 08             	pushl  0x8(%ebp)
  800dfa:	e8 3a 02 00 00       	call   801039 <nsipc_socket>
  800dff:	83 c4 10             	add    $0x10,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	78 05                	js     800e0b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800e06:	e8 a5 fe ff ff       	call   800cb0 <alloc_sockfd>
}
  800e0b:	c9                   	leave  
  800e0c:	c3                   	ret    

00800e0d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	53                   	push   %ebx
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e16:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e1d:	75 12                	jne    800e31 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	6a 02                	push   $0x2
  800e24:	e8 79 11 00 00       	call   801fa2 <ipc_find_env>
  800e29:	a3 04 40 80 00       	mov    %eax,0x804004
  800e2e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e31:	6a 07                	push   $0x7
  800e33:	68 00 60 80 00       	push   $0x806000
  800e38:	53                   	push   %ebx
  800e39:	ff 35 04 40 80 00    	pushl  0x804004
  800e3f:	e8 0a 11 00 00       	call   801f4e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e44:	83 c4 0c             	add    $0xc,%esp
  800e47:	6a 00                	push   $0x0
  800e49:	6a 00                	push   $0x0
  800e4b:	6a 00                	push   $0x0
  800e4d:	e8 95 10 00 00       	call   801ee7 <ipc_recv>
}
  800e52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e55:	c9                   	leave  
  800e56:	c3                   	ret    

00800e57 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e67:	8b 06                	mov    (%esi),%eax
  800e69:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e73:	e8 95 ff ff ff       	call   800e0d <nsipc>
  800e78:	89 c3                	mov    %eax,%ebx
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	78 20                	js     800e9e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e7e:	83 ec 04             	sub    $0x4,%esp
  800e81:	ff 35 10 60 80 00    	pushl  0x806010
  800e87:	68 00 60 80 00       	push   $0x806000
  800e8c:	ff 75 0c             	pushl  0xc(%ebp)
  800e8f:	e8 9e 0e 00 00       	call   801d32 <memmove>
		*addrlen = ret->ret_addrlen;
  800e94:	a1 10 60 80 00       	mov    0x806010,%eax
  800e99:	89 06                	mov    %eax,(%esi)
  800e9b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e9e:	89 d8                	mov    %ebx,%eax
  800ea0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 08             	sub    $0x8,%esp
  800eae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800eb9:	53                   	push   %ebx
  800eba:	ff 75 0c             	pushl  0xc(%ebp)
  800ebd:	68 04 60 80 00       	push   $0x806004
  800ec2:	e8 6b 0e 00 00       	call   801d32 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ec7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ecd:	b8 02 00 00 00       	mov    $0x2,%eax
  800ed2:	e8 36 ff ff ff       	call   800e0d <nsipc>
}
  800ed7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ef2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ef7:	e8 11 ff ff ff       	call   800e0d <nsipc>
}
  800efc:	c9                   	leave  
  800efd:	c3                   	ret    

00800efe <nsipc_close>:

int
nsipc_close(int s)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f04:	8b 45 08             	mov    0x8(%ebp),%eax
  800f07:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f0c:	b8 04 00 00 00       	mov    $0x4,%eax
  800f11:	e8 f7 fe ff ff       	call   800e0d <nsipc>
}
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    

00800f18 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f22:	8b 45 08             	mov    0x8(%ebp),%eax
  800f25:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f2a:	53                   	push   %ebx
  800f2b:	ff 75 0c             	pushl  0xc(%ebp)
  800f2e:	68 04 60 80 00       	push   $0x806004
  800f33:	e8 fa 0d 00 00       	call   801d32 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f38:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800f43:	e8 c5 fe ff ff       	call   800e0d <nsipc>
}
  800f48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4b:	c9                   	leave  
  800f4c:	c3                   	ret    

00800f4d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
  800f56:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f63:	b8 06 00 00 00       	mov    $0x6,%eax
  800f68:	e8 a0 fe ff ff       	call   800e0d <nsipc>
}
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    

00800f6f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f7f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f85:	8b 45 14             	mov    0x14(%ebp),%eax
  800f88:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f8d:	b8 07 00 00 00       	mov    $0x7,%eax
  800f92:	e8 76 fe ff ff       	call   800e0d <nsipc>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 35                	js     800fd2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f9d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800fa2:	7f 04                	jg     800fa8 <nsipc_recv+0x39>
  800fa4:	39 c6                	cmp    %eax,%esi
  800fa6:	7d 16                	jge    800fbe <nsipc_recv+0x4f>
  800fa8:	68 d3 23 80 00       	push   $0x8023d3
  800fad:	68 9b 23 80 00       	push   $0x80239b
  800fb2:	6a 62                	push   $0x62
  800fb4:	68 e8 23 80 00       	push   $0x8023e8
  800fb9:	e8 84 05 00 00       	call   801542 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fbe:	83 ec 04             	sub    $0x4,%esp
  800fc1:	50                   	push   %eax
  800fc2:	68 00 60 80 00       	push   $0x806000
  800fc7:	ff 75 0c             	pushl  0xc(%ebp)
  800fca:	e8 63 0d 00 00       	call   801d32 <memmove>
  800fcf:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fd2:	89 d8                	mov    %ebx,%eax
  800fd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fed:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800ff3:	7e 16                	jle    80100b <nsipc_send+0x30>
  800ff5:	68 f4 23 80 00       	push   $0x8023f4
  800ffa:	68 9b 23 80 00       	push   $0x80239b
  800fff:	6a 6d                	push   $0x6d
  801001:	68 e8 23 80 00       	push   $0x8023e8
  801006:	e8 37 05 00 00       	call   801542 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80100b:	83 ec 04             	sub    $0x4,%esp
  80100e:	53                   	push   %ebx
  80100f:	ff 75 0c             	pushl  0xc(%ebp)
  801012:	68 0c 60 80 00       	push   $0x80600c
  801017:	e8 16 0d 00 00       	call   801d32 <memmove>
	nsipcbuf.send.req_size = size;
  80101c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801022:	8b 45 14             	mov    0x14(%ebp),%eax
  801025:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80102a:	b8 08 00 00 00       	mov    $0x8,%eax
  80102f:	e8 d9 fd ff ff       	call   800e0d <nsipc>
}
  801034:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801037:	c9                   	leave  
  801038:	c3                   	ret    

00801039 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80103f:	8b 45 08             	mov    0x8(%ebp),%eax
  801042:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80104f:	8b 45 10             	mov    0x10(%ebp),%eax
  801052:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801057:	b8 09 00 00 00       	mov    $0x9,%eax
  80105c:	e8 ac fd ff ff       	call   800e0d <nsipc>
}
  801061:	c9                   	leave  
  801062:	c3                   	ret    

00801063 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
  801068:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	ff 75 08             	pushl  0x8(%ebp)
  801071:	e8 98 f3 ff ff       	call   80040e <fd2data>
  801076:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801078:	83 c4 08             	add    $0x8,%esp
  80107b:	68 00 24 80 00       	push   $0x802400
  801080:	53                   	push   %ebx
  801081:	e8 1a 0b 00 00       	call   801ba0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801086:	8b 46 04             	mov    0x4(%esi),%eax
  801089:	2b 06                	sub    (%esi),%eax
  80108b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801091:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801098:	00 00 00 
	stat->st_dev = &devpipe;
  80109b:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  8010a2:	30 80 00 
	return 0;
}
  8010a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	53                   	push   %ebx
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010bb:	53                   	push   %ebx
  8010bc:	6a 00                	push   $0x0
  8010be:	e8 2c f1 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010c3:	89 1c 24             	mov    %ebx,(%esp)
  8010c6:	e8 43 f3 ff ff       	call   80040e <fd2data>
  8010cb:	83 c4 08             	add    $0x8,%esp
  8010ce:	50                   	push   %eax
  8010cf:	6a 00                	push   $0x0
  8010d1:	e8 19 f1 ff ff       	call   8001ef <sys_page_unmap>
}
  8010d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 1c             	sub    $0x1c,%esp
  8010e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010e7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010e9:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ee:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f7:	e8 df 0e 00 00       	call   801fdb <pageref>
  8010fc:	89 c3                	mov    %eax,%ebx
  8010fe:	89 3c 24             	mov    %edi,(%esp)
  801101:	e8 d5 0e 00 00       	call   801fdb <pageref>
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	39 c3                	cmp    %eax,%ebx
  80110b:	0f 94 c1             	sete   %cl
  80110e:	0f b6 c9             	movzbl %cl,%ecx
  801111:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801114:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80111a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80111d:	39 ce                	cmp    %ecx,%esi
  80111f:	74 1b                	je     80113c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801121:	39 c3                	cmp    %eax,%ebx
  801123:	75 c4                	jne    8010e9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801125:	8b 42 58             	mov    0x58(%edx),%eax
  801128:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112b:	50                   	push   %eax
  80112c:	56                   	push   %esi
  80112d:	68 07 24 80 00       	push   $0x802407
  801132:	e8 e4 04 00 00       	call   80161b <cprintf>
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	eb ad                	jmp    8010e9 <_pipeisclosed+0xe>
	}
}
  80113c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80113f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801142:	5b                   	pop    %ebx
  801143:	5e                   	pop    %esi
  801144:	5f                   	pop    %edi
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	57                   	push   %edi
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	83 ec 28             	sub    $0x28,%esp
  801150:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801153:	56                   	push   %esi
  801154:	e8 b5 f2 ff ff       	call   80040e <fd2data>
  801159:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	bf 00 00 00 00       	mov    $0x0,%edi
  801163:	eb 4b                	jmp    8011b0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801165:	89 da                	mov    %ebx,%edx
  801167:	89 f0                	mov    %esi,%eax
  801169:	e8 6d ff ff ff       	call   8010db <_pipeisclosed>
  80116e:	85 c0                	test   %eax,%eax
  801170:	75 48                	jne    8011ba <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801172:	e8 d4 ef ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801177:	8b 43 04             	mov    0x4(%ebx),%eax
  80117a:	8b 0b                	mov    (%ebx),%ecx
  80117c:	8d 51 20             	lea    0x20(%ecx),%edx
  80117f:	39 d0                	cmp    %edx,%eax
  801181:	73 e2                	jae    801165 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801186:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80118a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	c1 fa 1f             	sar    $0x1f,%edx
  801192:	89 d1                	mov    %edx,%ecx
  801194:	c1 e9 1b             	shr    $0x1b,%ecx
  801197:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80119a:	83 e2 1f             	and    $0x1f,%edx
  80119d:	29 ca                	sub    %ecx,%edx
  80119f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011a3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011a7:	83 c0 01             	add    $0x1,%eax
  8011aa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011ad:	83 c7 01             	add    $0x1,%edi
  8011b0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011b3:	75 c2                	jne    801177 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b8:	eb 05                	jmp    8011bf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011ba:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 18             	sub    $0x18,%esp
  8011d0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011d3:	57                   	push   %edi
  8011d4:	e8 35 f2 ff ff       	call   80040e <fd2data>
  8011d9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e3:	eb 3d                	jmp    801222 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011e5:	85 db                	test   %ebx,%ebx
  8011e7:	74 04                	je     8011ed <devpipe_read+0x26>
				return i;
  8011e9:	89 d8                	mov    %ebx,%eax
  8011eb:	eb 44                	jmp    801231 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011ed:	89 f2                	mov    %esi,%edx
  8011ef:	89 f8                	mov    %edi,%eax
  8011f1:	e8 e5 fe ff ff       	call   8010db <_pipeisclosed>
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	75 32                	jne    80122c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011fa:	e8 4c ef ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011ff:	8b 06                	mov    (%esi),%eax
  801201:	3b 46 04             	cmp    0x4(%esi),%eax
  801204:	74 df                	je     8011e5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801206:	99                   	cltd   
  801207:	c1 ea 1b             	shr    $0x1b,%edx
  80120a:	01 d0                	add    %edx,%eax
  80120c:	83 e0 1f             	and    $0x1f,%eax
  80120f:	29 d0                	sub    %edx,%eax
  801211:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801219:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80121c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80121f:	83 c3 01             	add    $0x1,%ebx
  801222:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801225:	75 d8                	jne    8011ff <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801227:	8b 45 10             	mov    0x10(%ebp),%eax
  80122a:	eb 05                	jmp    801231 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80122c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801231:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801234:	5b                   	pop    %ebx
  801235:	5e                   	pop    %esi
  801236:	5f                   	pop    %edi
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	56                   	push   %esi
  80123d:	53                   	push   %ebx
  80123e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801241:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	e8 db f1 ff ff       	call   800425 <fd_alloc>
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	89 c2                	mov    %eax,%edx
  80124f:	85 c0                	test   %eax,%eax
  801251:	0f 88 2c 01 00 00    	js     801383 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801257:	83 ec 04             	sub    $0x4,%esp
  80125a:	68 07 04 00 00       	push   $0x407
  80125f:	ff 75 f4             	pushl  -0xc(%ebp)
  801262:	6a 00                	push   $0x0
  801264:	e8 01 ef ff ff       	call   80016a <sys_page_alloc>
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	85 c0                	test   %eax,%eax
  801270:	0f 88 0d 01 00 00    	js     801383 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801276:	83 ec 0c             	sub    $0xc,%esp
  801279:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	e8 a3 f1 ff ff       	call   800425 <fd_alloc>
  801282:	89 c3                	mov    %eax,%ebx
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	0f 88 e2 00 00 00    	js     801371 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	68 07 04 00 00       	push   $0x407
  801297:	ff 75 f0             	pushl  -0x10(%ebp)
  80129a:	6a 00                	push   $0x0
  80129c:	e8 c9 ee ff ff       	call   80016a <sys_page_alloc>
  8012a1:	89 c3                	mov    %eax,%ebx
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	0f 88 c3 00 00 00    	js     801371 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012ae:	83 ec 0c             	sub    $0xc,%esp
  8012b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b4:	e8 55 f1 ff ff       	call   80040e <fd2data>
  8012b9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012bb:	83 c4 0c             	add    $0xc,%esp
  8012be:	68 07 04 00 00       	push   $0x407
  8012c3:	50                   	push   %eax
  8012c4:	6a 00                	push   $0x0
  8012c6:	e8 9f ee ff ff       	call   80016a <sys_page_alloc>
  8012cb:	89 c3                	mov    %eax,%ebx
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	0f 88 89 00 00 00    	js     801361 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012d8:	83 ec 0c             	sub    $0xc,%esp
  8012db:	ff 75 f0             	pushl  -0x10(%ebp)
  8012de:	e8 2b f1 ff ff       	call   80040e <fd2data>
  8012e3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012ea:	50                   	push   %eax
  8012eb:	6a 00                	push   $0x0
  8012ed:	56                   	push   %esi
  8012ee:	6a 00                	push   $0x0
  8012f0:	e8 b8 ee ff ff       	call   8001ad <sys_page_map>
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 20             	add    $0x20,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 55                	js     801353 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012fe:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801304:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801307:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801309:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801313:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80131e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801321:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801328:	83 ec 0c             	sub    $0xc,%esp
  80132b:	ff 75 f4             	pushl  -0xc(%ebp)
  80132e:	e8 cb f0 ff ff       	call   8003fe <fd2num>
  801333:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801336:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801338:	83 c4 04             	add    $0x4,%esp
  80133b:	ff 75 f0             	pushl  -0x10(%ebp)
  80133e:	e8 bb f0 ff ff       	call   8003fe <fd2num>
  801343:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801346:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	ba 00 00 00 00       	mov    $0x0,%edx
  801351:	eb 30                	jmp    801383 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	56                   	push   %esi
  801357:	6a 00                	push   $0x0
  801359:	e8 91 ee ff ff       	call   8001ef <sys_page_unmap>
  80135e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	ff 75 f0             	pushl  -0x10(%ebp)
  801367:	6a 00                	push   $0x0
  801369:	e8 81 ee ff ff       	call   8001ef <sys_page_unmap>
  80136e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	ff 75 f4             	pushl  -0xc(%ebp)
  801377:	6a 00                	push   $0x0
  801379:	e8 71 ee ff ff       	call   8001ef <sys_page_unmap>
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801383:	89 d0                	mov    %edx,%eax
  801385:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801388:	5b                   	pop    %ebx
  801389:	5e                   	pop    %esi
  80138a:	5d                   	pop    %ebp
  80138b:	c3                   	ret    

0080138c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801392:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	ff 75 08             	pushl  0x8(%ebp)
  801399:	e8 d6 f0 ff ff       	call   800474 <fd_lookup>
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 18                	js     8013bd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013a5:	83 ec 0c             	sub    $0xc,%esp
  8013a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ab:	e8 5e f0 ff ff       	call   80040e <fd2data>
	return _pipeisclosed(fd, p);
  8013b0:	89 c2                	mov    %eax,%edx
  8013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b5:	e8 21 fd ff ff       	call   8010db <_pipeisclosed>
  8013ba:	83 c4 10             	add    $0x10,%esp
}
  8013bd:	c9                   	leave  
  8013be:	c3                   	ret    

008013bf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    

008013c9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013cf:	68 1f 24 80 00       	push   $0x80241f
  8013d4:	ff 75 0c             	pushl  0xc(%ebp)
  8013d7:	e8 c4 07 00 00       	call   801ba0 <strcpy>
	return 0;
}
  8013dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e1:	c9                   	leave  
  8013e2:	c3                   	ret    

008013e3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	57                   	push   %edi
  8013e7:	56                   	push   %esi
  8013e8:	53                   	push   %ebx
  8013e9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ef:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013f4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013fa:	eb 2d                	jmp    801429 <devcons_write+0x46>
		m = n - tot;
  8013fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ff:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801401:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801404:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801409:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80140c:	83 ec 04             	sub    $0x4,%esp
  80140f:	53                   	push   %ebx
  801410:	03 45 0c             	add    0xc(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	57                   	push   %edi
  801415:	e8 18 09 00 00       	call   801d32 <memmove>
		sys_cputs(buf, m);
  80141a:	83 c4 08             	add    $0x8,%esp
  80141d:	53                   	push   %ebx
  80141e:	57                   	push   %edi
  80141f:	e8 8a ec ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801424:	01 de                	add    %ebx,%esi
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	89 f0                	mov    %esi,%eax
  80142b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80142e:	72 cc                	jb     8013fc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801430:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801433:	5b                   	pop    %ebx
  801434:	5e                   	pop    %esi
  801435:	5f                   	pop    %edi
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801443:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801447:	74 2a                	je     801473 <devcons_read+0x3b>
  801449:	eb 05                	jmp    801450 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80144b:	e8 fb ec ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801450:	e8 77 ec ff ff       	call   8000cc <sys_cgetc>
  801455:	85 c0                	test   %eax,%eax
  801457:	74 f2                	je     80144b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 16                	js     801473 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80145d:	83 f8 04             	cmp    $0x4,%eax
  801460:	74 0c                	je     80146e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801462:	8b 55 0c             	mov    0xc(%ebp),%edx
  801465:	88 02                	mov    %al,(%edx)
	return 1;
  801467:	b8 01 00 00 00       	mov    $0x1,%eax
  80146c:	eb 05                	jmp    801473 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80146e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80147b:	8b 45 08             	mov    0x8(%ebp),%eax
  80147e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801481:	6a 01                	push   $0x1
  801483:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801486:	50                   	push   %eax
  801487:	e8 22 ec ff ff       	call   8000ae <sys_cputs>
}
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <getchar>:

int
getchar(void)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801497:	6a 01                	push   $0x1
  801499:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	6a 00                	push   $0x0
  80149f:	e8 36 f2 ff ff       	call   8006da <read>
	if (r < 0)
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 0f                	js     8014ba <getchar+0x29>
		return r;
	if (r < 1)
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	7e 06                	jle    8014b5 <getchar+0x24>
		return -E_EOF;
	return c;
  8014af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014b3:	eb 05                	jmp    8014ba <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	ff 75 08             	pushl  0x8(%ebp)
  8014c9:	e8 a6 ef ff ff       	call   800474 <fd_lookup>
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 11                	js     8014e6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d8:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8014de:	39 10                	cmp    %edx,(%eax)
  8014e0:	0f 94 c0             	sete   %al
  8014e3:	0f b6 c0             	movzbl %al,%eax
}
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <opencons>:

int
opencons(void)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f1:	50                   	push   %eax
  8014f2:	e8 2e ef ff ff       	call   800425 <fd_alloc>
  8014f7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014fa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 3e                	js     80153e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	68 07 04 00 00       	push   $0x407
  801508:	ff 75 f4             	pushl  -0xc(%ebp)
  80150b:	6a 00                	push   $0x0
  80150d:	e8 58 ec ff ff       	call   80016a <sys_page_alloc>
  801512:	83 c4 10             	add    $0x10,%esp
		return r;
  801515:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801517:	85 c0                	test   %eax,%eax
  801519:	78 23                	js     80153e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80151b:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  801521:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801524:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801526:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801529:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801530:	83 ec 0c             	sub    $0xc,%esp
  801533:	50                   	push   %eax
  801534:	e8 c5 ee ff ff       	call   8003fe <fd2num>
  801539:	89 c2                	mov    %eax,%edx
  80153b:	83 c4 10             	add    $0x10,%esp
}
  80153e:	89 d0                	mov    %edx,%eax
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801547:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80154a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801550:	e8 d7 eb ff ff       	call   80012c <sys_getenvid>
  801555:	83 ec 0c             	sub    $0xc,%esp
  801558:	ff 75 0c             	pushl  0xc(%ebp)
  80155b:	ff 75 08             	pushl  0x8(%ebp)
  80155e:	56                   	push   %esi
  80155f:	50                   	push   %eax
  801560:	68 2c 24 80 00       	push   $0x80242c
  801565:	e8 b1 00 00 00       	call   80161b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80156a:	83 c4 18             	add    $0x18,%esp
  80156d:	53                   	push   %ebx
  80156e:	ff 75 10             	pushl  0x10(%ebp)
  801571:	e8 54 00 00 00       	call   8015ca <vcprintf>
	cprintf("\n");
  801576:	c7 04 24 18 24 80 00 	movl   $0x802418,(%esp)
  80157d:	e8 99 00 00 00       	call   80161b <cprintf>
  801582:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801585:	cc                   	int3   
  801586:	eb fd                	jmp    801585 <_panic+0x43>

00801588 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	53                   	push   %ebx
  80158c:	83 ec 04             	sub    $0x4,%esp
  80158f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801592:	8b 13                	mov    (%ebx),%edx
  801594:	8d 42 01             	lea    0x1(%edx),%eax
  801597:	89 03                	mov    %eax,(%ebx)
  801599:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80159c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015a0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015a5:	75 1a                	jne    8015c1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	68 ff 00 00 00       	push   $0xff
  8015af:	8d 43 08             	lea    0x8(%ebx),%eax
  8015b2:	50                   	push   %eax
  8015b3:	e8 f6 ea ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8015b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015be:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015c1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015d3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015da:	00 00 00 
	b.cnt = 0;
  8015dd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015e4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015e7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ea:	ff 75 08             	pushl  0x8(%ebp)
  8015ed:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	68 88 15 80 00       	push   $0x801588
  8015f9:	e8 54 01 00 00       	call   801752 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015fe:	83 c4 08             	add    $0x8,%esp
  801601:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801607:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	e8 9b ea ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  801613:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801621:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801624:	50                   	push   %eax
  801625:	ff 75 08             	pushl  0x8(%ebp)
  801628:	e8 9d ff ff ff       	call   8015ca <vcprintf>
	va_end(ap);

	return cnt;
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	57                   	push   %edi
  801633:	56                   	push   %esi
  801634:	53                   	push   %ebx
  801635:	83 ec 1c             	sub    $0x1c,%esp
  801638:	89 c7                	mov    %eax,%edi
  80163a:	89 d6                	mov    %edx,%esi
  80163c:	8b 45 08             	mov    0x8(%ebp),%eax
  80163f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801645:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801648:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80164b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801650:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801653:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801656:	39 d3                	cmp    %edx,%ebx
  801658:	72 05                	jb     80165f <printnum+0x30>
  80165a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80165d:	77 45                	ja     8016a4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80165f:	83 ec 0c             	sub    $0xc,%esp
  801662:	ff 75 18             	pushl  0x18(%ebp)
  801665:	8b 45 14             	mov    0x14(%ebp),%eax
  801668:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80166b:	53                   	push   %ebx
  80166c:	ff 75 10             	pushl  0x10(%ebp)
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	ff 75 e4             	pushl  -0x1c(%ebp)
  801675:	ff 75 e0             	pushl  -0x20(%ebp)
  801678:	ff 75 dc             	pushl  -0x24(%ebp)
  80167b:	ff 75 d8             	pushl  -0x28(%ebp)
  80167e:	e8 9d 09 00 00       	call   802020 <__udivdi3>
  801683:	83 c4 18             	add    $0x18,%esp
  801686:	52                   	push   %edx
  801687:	50                   	push   %eax
  801688:	89 f2                	mov    %esi,%edx
  80168a:	89 f8                	mov    %edi,%eax
  80168c:	e8 9e ff ff ff       	call   80162f <printnum>
  801691:	83 c4 20             	add    $0x20,%esp
  801694:	eb 18                	jmp    8016ae <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	56                   	push   %esi
  80169a:	ff 75 18             	pushl  0x18(%ebp)
  80169d:	ff d7                	call   *%edi
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	eb 03                	jmp    8016a7 <printnum+0x78>
  8016a4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016a7:	83 eb 01             	sub    $0x1,%ebx
  8016aa:	85 db                	test   %ebx,%ebx
  8016ac:	7f e8                	jg     801696 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	56                   	push   %esi
  8016b2:	83 ec 04             	sub    $0x4,%esp
  8016b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8016bb:	ff 75 dc             	pushl  -0x24(%ebp)
  8016be:	ff 75 d8             	pushl  -0x28(%ebp)
  8016c1:	e8 8a 0a 00 00       	call   802150 <__umoddi3>
  8016c6:	83 c4 14             	add    $0x14,%esp
  8016c9:	0f be 80 4f 24 80 00 	movsbl 0x80244f(%eax),%eax
  8016d0:	50                   	push   %eax
  8016d1:	ff d7                	call   *%edi
}
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d9:	5b                   	pop    %ebx
  8016da:	5e                   	pop    %esi
  8016db:	5f                   	pop    %edi
  8016dc:	5d                   	pop    %ebp
  8016dd:	c3                   	ret    

008016de <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016e1:	83 fa 01             	cmp    $0x1,%edx
  8016e4:	7e 0e                	jle    8016f4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016e6:	8b 10                	mov    (%eax),%edx
  8016e8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016eb:	89 08                	mov    %ecx,(%eax)
  8016ed:	8b 02                	mov    (%edx),%eax
  8016ef:	8b 52 04             	mov    0x4(%edx),%edx
  8016f2:	eb 22                	jmp    801716 <getuint+0x38>
	else if (lflag)
  8016f4:	85 d2                	test   %edx,%edx
  8016f6:	74 10                	je     801708 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016f8:	8b 10                	mov    (%eax),%edx
  8016fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016fd:	89 08                	mov    %ecx,(%eax)
  8016ff:	8b 02                	mov    (%edx),%eax
  801701:	ba 00 00 00 00       	mov    $0x0,%edx
  801706:	eb 0e                	jmp    801716 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801708:	8b 10                	mov    (%eax),%edx
  80170a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80170d:	89 08                	mov    %ecx,(%eax)
  80170f:	8b 02                	mov    (%edx),%eax
  801711:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80171e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801722:	8b 10                	mov    (%eax),%edx
  801724:	3b 50 04             	cmp    0x4(%eax),%edx
  801727:	73 0a                	jae    801733 <sprintputch+0x1b>
		*b->buf++ = ch;
  801729:	8d 4a 01             	lea    0x1(%edx),%ecx
  80172c:	89 08                	mov    %ecx,(%eax)
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	88 02                	mov    %al,(%edx)
}
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    

00801735 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80173b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80173e:	50                   	push   %eax
  80173f:	ff 75 10             	pushl  0x10(%ebp)
  801742:	ff 75 0c             	pushl  0xc(%ebp)
  801745:	ff 75 08             	pushl  0x8(%ebp)
  801748:	e8 05 00 00 00       	call   801752 <vprintfmt>
	va_end(ap);
}
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	57                   	push   %edi
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
  801758:	83 ec 2c             	sub    $0x2c,%esp
  80175b:	8b 75 08             	mov    0x8(%ebp),%esi
  80175e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801761:	8b 7d 10             	mov    0x10(%ebp),%edi
  801764:	eb 12                	jmp    801778 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801766:	85 c0                	test   %eax,%eax
  801768:	0f 84 89 03 00 00    	je     801af7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80176e:	83 ec 08             	sub    $0x8,%esp
  801771:	53                   	push   %ebx
  801772:	50                   	push   %eax
  801773:	ff d6                	call   *%esi
  801775:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801778:	83 c7 01             	add    $0x1,%edi
  80177b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80177f:	83 f8 25             	cmp    $0x25,%eax
  801782:	75 e2                	jne    801766 <vprintfmt+0x14>
  801784:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801788:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80178f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801796:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80179d:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a2:	eb 07                	jmp    8017ab <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017a7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ab:	8d 47 01             	lea    0x1(%edi),%eax
  8017ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017b1:	0f b6 07             	movzbl (%edi),%eax
  8017b4:	0f b6 c8             	movzbl %al,%ecx
  8017b7:	83 e8 23             	sub    $0x23,%eax
  8017ba:	3c 55                	cmp    $0x55,%al
  8017bc:	0f 87 1a 03 00 00    	ja     801adc <vprintfmt+0x38a>
  8017c2:	0f b6 c0             	movzbl %al,%eax
  8017c5:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  8017cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017cf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017d3:	eb d6                	jmp    8017ab <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017e3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017e7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017ea:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017ed:	83 fa 09             	cmp    $0x9,%edx
  8017f0:	77 39                	ja     80182b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017f2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017f5:	eb e9                	jmp    8017e0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fa:	8d 48 04             	lea    0x4(%eax),%ecx
  8017fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801800:	8b 00                	mov    (%eax),%eax
  801802:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801805:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801808:	eb 27                	jmp    801831 <vprintfmt+0xdf>
  80180a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80180d:	85 c0                	test   %eax,%eax
  80180f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801814:	0f 49 c8             	cmovns %eax,%ecx
  801817:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80181d:	eb 8c                	jmp    8017ab <vprintfmt+0x59>
  80181f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801822:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801829:	eb 80                	jmp    8017ab <vprintfmt+0x59>
  80182b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80182e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801831:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801835:	0f 89 70 ff ff ff    	jns    8017ab <vprintfmt+0x59>
				width = precision, precision = -1;
  80183b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80183e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801841:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801848:	e9 5e ff ff ff       	jmp    8017ab <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80184d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801853:	e9 53 ff ff ff       	jmp    8017ab <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801858:	8b 45 14             	mov    0x14(%ebp),%eax
  80185b:	8d 50 04             	lea    0x4(%eax),%edx
  80185e:	89 55 14             	mov    %edx,0x14(%ebp)
  801861:	83 ec 08             	sub    $0x8,%esp
  801864:	53                   	push   %ebx
  801865:	ff 30                	pushl  (%eax)
  801867:	ff d6                	call   *%esi
			break;
  801869:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80186f:	e9 04 ff ff ff       	jmp    801778 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801874:	8b 45 14             	mov    0x14(%ebp),%eax
  801877:	8d 50 04             	lea    0x4(%eax),%edx
  80187a:	89 55 14             	mov    %edx,0x14(%ebp)
  80187d:	8b 00                	mov    (%eax),%eax
  80187f:	99                   	cltd   
  801880:	31 d0                	xor    %edx,%eax
  801882:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801884:	83 f8 0f             	cmp    $0xf,%eax
  801887:	7f 0b                	jg     801894 <vprintfmt+0x142>
  801889:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  801890:	85 d2                	test   %edx,%edx
  801892:	75 18                	jne    8018ac <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801894:	50                   	push   %eax
  801895:	68 67 24 80 00       	push   $0x802467
  80189a:	53                   	push   %ebx
  80189b:	56                   	push   %esi
  80189c:	e8 94 fe ff ff       	call   801735 <printfmt>
  8018a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018a7:	e9 cc fe ff ff       	jmp    801778 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018ac:	52                   	push   %edx
  8018ad:	68 ad 23 80 00       	push   $0x8023ad
  8018b2:	53                   	push   %ebx
  8018b3:	56                   	push   %esi
  8018b4:	e8 7c fe ff ff       	call   801735 <printfmt>
  8018b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018bf:	e9 b4 fe ff ff       	jmp    801778 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c7:	8d 50 04             	lea    0x4(%eax),%edx
  8018ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8018cd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018cf:	85 ff                	test   %edi,%edi
  8018d1:	b8 60 24 80 00       	mov    $0x802460,%eax
  8018d6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018dd:	0f 8e 94 00 00 00    	jle    801977 <vprintfmt+0x225>
  8018e3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018e7:	0f 84 98 00 00 00    	je     801985 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	ff 75 d0             	pushl  -0x30(%ebp)
  8018f3:	57                   	push   %edi
  8018f4:	e8 86 02 00 00       	call   801b7f <strnlen>
  8018f9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018fc:	29 c1                	sub    %eax,%ecx
  8018fe:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801901:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801904:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801908:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80190b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80190e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801910:	eb 0f                	jmp    801921 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801912:	83 ec 08             	sub    $0x8,%esp
  801915:	53                   	push   %ebx
  801916:	ff 75 e0             	pushl  -0x20(%ebp)
  801919:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80191b:	83 ef 01             	sub    $0x1,%edi
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	85 ff                	test   %edi,%edi
  801923:	7f ed                	jg     801912 <vprintfmt+0x1c0>
  801925:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801928:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80192b:	85 c9                	test   %ecx,%ecx
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
  801932:	0f 49 c1             	cmovns %ecx,%eax
  801935:	29 c1                	sub    %eax,%ecx
  801937:	89 75 08             	mov    %esi,0x8(%ebp)
  80193a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80193d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801940:	89 cb                	mov    %ecx,%ebx
  801942:	eb 4d                	jmp    801991 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801944:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801948:	74 1b                	je     801965 <vprintfmt+0x213>
  80194a:	0f be c0             	movsbl %al,%eax
  80194d:	83 e8 20             	sub    $0x20,%eax
  801950:	83 f8 5e             	cmp    $0x5e,%eax
  801953:	76 10                	jbe    801965 <vprintfmt+0x213>
					putch('?', putdat);
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	ff 75 0c             	pushl  0xc(%ebp)
  80195b:	6a 3f                	push   $0x3f
  80195d:	ff 55 08             	call   *0x8(%ebp)
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	eb 0d                	jmp    801972 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801965:	83 ec 08             	sub    $0x8,%esp
  801968:	ff 75 0c             	pushl  0xc(%ebp)
  80196b:	52                   	push   %edx
  80196c:	ff 55 08             	call   *0x8(%ebp)
  80196f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801972:	83 eb 01             	sub    $0x1,%ebx
  801975:	eb 1a                	jmp    801991 <vprintfmt+0x23f>
  801977:	89 75 08             	mov    %esi,0x8(%ebp)
  80197a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80197d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801980:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801983:	eb 0c                	jmp    801991 <vprintfmt+0x23f>
  801985:	89 75 08             	mov    %esi,0x8(%ebp)
  801988:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80198b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80198e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801991:	83 c7 01             	add    $0x1,%edi
  801994:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801998:	0f be d0             	movsbl %al,%edx
  80199b:	85 d2                	test   %edx,%edx
  80199d:	74 23                	je     8019c2 <vprintfmt+0x270>
  80199f:	85 f6                	test   %esi,%esi
  8019a1:	78 a1                	js     801944 <vprintfmt+0x1f2>
  8019a3:	83 ee 01             	sub    $0x1,%esi
  8019a6:	79 9c                	jns    801944 <vprintfmt+0x1f2>
  8019a8:	89 df                	mov    %ebx,%edi
  8019aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8019ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019b0:	eb 18                	jmp    8019ca <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019b2:	83 ec 08             	sub    $0x8,%esp
  8019b5:	53                   	push   %ebx
  8019b6:	6a 20                	push   $0x20
  8019b8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019ba:	83 ef 01             	sub    $0x1,%edi
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	eb 08                	jmp    8019ca <vprintfmt+0x278>
  8019c2:	89 df                	mov    %ebx,%edi
  8019c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ca:	85 ff                	test   %edi,%edi
  8019cc:	7f e4                	jg     8019b2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019d1:	e9 a2 fd ff ff       	jmp    801778 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019d6:	83 fa 01             	cmp    $0x1,%edx
  8019d9:	7e 16                	jle    8019f1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019db:	8b 45 14             	mov    0x14(%ebp),%eax
  8019de:	8d 50 08             	lea    0x8(%eax),%edx
  8019e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019e4:	8b 50 04             	mov    0x4(%eax),%edx
  8019e7:	8b 00                	mov    (%eax),%eax
  8019e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019ef:	eb 32                	jmp    801a23 <vprintfmt+0x2d1>
	else if (lflag)
  8019f1:	85 d2                	test   %edx,%edx
  8019f3:	74 18                	je     801a0d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f8:	8d 50 04             	lea    0x4(%eax),%edx
  8019fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8019fe:	8b 00                	mov    (%eax),%eax
  801a00:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a03:	89 c1                	mov    %eax,%ecx
  801a05:	c1 f9 1f             	sar    $0x1f,%ecx
  801a08:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a0b:	eb 16                	jmp    801a23 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a0d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a10:	8d 50 04             	lea    0x4(%eax),%edx
  801a13:	89 55 14             	mov    %edx,0x14(%ebp)
  801a16:	8b 00                	mov    (%eax),%eax
  801a18:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a1b:	89 c1                	mov    %eax,%ecx
  801a1d:	c1 f9 1f             	sar    $0x1f,%ecx
  801a20:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a23:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a26:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a29:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a2e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a32:	79 74                	jns    801aa8 <vprintfmt+0x356>
				putch('-', putdat);
  801a34:	83 ec 08             	sub    $0x8,%esp
  801a37:	53                   	push   %ebx
  801a38:	6a 2d                	push   $0x2d
  801a3a:	ff d6                	call   *%esi
				num = -(long long) num;
  801a3c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a3f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a42:	f7 d8                	neg    %eax
  801a44:	83 d2 00             	adc    $0x0,%edx
  801a47:	f7 da                	neg    %edx
  801a49:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a4c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a51:	eb 55                	jmp    801aa8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a53:	8d 45 14             	lea    0x14(%ebp),%eax
  801a56:	e8 83 fc ff ff       	call   8016de <getuint>
			base = 10;
  801a5b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a60:	eb 46                	jmp    801aa8 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a62:	8d 45 14             	lea    0x14(%ebp),%eax
  801a65:	e8 74 fc ff ff       	call   8016de <getuint>
			base = 8;
  801a6a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a6f:	eb 37                	jmp    801aa8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a71:	83 ec 08             	sub    $0x8,%esp
  801a74:	53                   	push   %ebx
  801a75:	6a 30                	push   $0x30
  801a77:	ff d6                	call   *%esi
			putch('x', putdat);
  801a79:	83 c4 08             	add    $0x8,%esp
  801a7c:	53                   	push   %ebx
  801a7d:	6a 78                	push   $0x78
  801a7f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a81:	8b 45 14             	mov    0x14(%ebp),%eax
  801a84:	8d 50 04             	lea    0x4(%eax),%edx
  801a87:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a8a:	8b 00                	mov    (%eax),%eax
  801a8c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a91:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a94:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a99:	eb 0d                	jmp    801aa8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a9b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a9e:	e8 3b fc ff ff       	call   8016de <getuint>
			base = 16;
  801aa3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801aaf:	57                   	push   %edi
  801ab0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab3:	51                   	push   %ecx
  801ab4:	52                   	push   %edx
  801ab5:	50                   	push   %eax
  801ab6:	89 da                	mov    %ebx,%edx
  801ab8:	89 f0                	mov    %esi,%eax
  801aba:	e8 70 fb ff ff       	call   80162f <printnum>
			break;
  801abf:	83 c4 20             	add    $0x20,%esp
  801ac2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ac5:	e9 ae fc ff ff       	jmp    801778 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801aca:	83 ec 08             	sub    $0x8,%esp
  801acd:	53                   	push   %ebx
  801ace:	51                   	push   %ecx
  801acf:	ff d6                	call   *%esi
			break;
  801ad1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ad4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ad7:	e9 9c fc ff ff       	jmp    801778 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801adc:	83 ec 08             	sub    $0x8,%esp
  801adf:	53                   	push   %ebx
  801ae0:	6a 25                	push   $0x25
  801ae2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	eb 03                	jmp    801aec <vprintfmt+0x39a>
  801ae9:	83 ef 01             	sub    $0x1,%edi
  801aec:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801af0:	75 f7                	jne    801ae9 <vprintfmt+0x397>
  801af2:	e9 81 fc ff ff       	jmp    801778 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801af7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afa:	5b                   	pop    %ebx
  801afb:	5e                   	pop    %esi
  801afc:	5f                   	pop    %edi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    

00801aff <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 18             	sub    $0x18,%esp
  801b05:	8b 45 08             	mov    0x8(%ebp),%eax
  801b08:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b0e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b12:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	74 26                	je     801b46 <vsnprintf+0x47>
  801b20:	85 d2                	test   %edx,%edx
  801b22:	7e 22                	jle    801b46 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b24:	ff 75 14             	pushl  0x14(%ebp)
  801b27:	ff 75 10             	pushl  0x10(%ebp)
  801b2a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b2d:	50                   	push   %eax
  801b2e:	68 18 17 80 00       	push   $0x801718
  801b33:	e8 1a fc ff ff       	call   801752 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b38:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b3b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	eb 05                	jmp    801b4b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b53:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b56:	50                   	push   %eax
  801b57:	ff 75 10             	pushl  0x10(%ebp)
  801b5a:	ff 75 0c             	pushl  0xc(%ebp)
  801b5d:	ff 75 08             	pushl  0x8(%ebp)
  801b60:	e8 9a ff ff ff       	call   801aff <vsnprintf>
	va_end(ap);

	return rc;
}
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    

00801b67 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b72:	eb 03                	jmp    801b77 <strlen+0x10>
		n++;
  801b74:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b77:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b7b:	75 f7                	jne    801b74 <strlen+0xd>
		n++;
	return n;
}
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    

00801b7f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b85:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b88:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8d:	eb 03                	jmp    801b92 <strnlen+0x13>
		n++;
  801b8f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b92:	39 c2                	cmp    %eax,%edx
  801b94:	74 08                	je     801b9e <strnlen+0x1f>
  801b96:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b9a:	75 f3                	jne    801b8f <strnlen+0x10>
  801b9c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	53                   	push   %ebx
  801ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801baa:	89 c2                	mov    %eax,%edx
  801bac:	83 c2 01             	add    $0x1,%edx
  801baf:	83 c1 01             	add    $0x1,%ecx
  801bb2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bb6:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bb9:	84 db                	test   %bl,%bl
  801bbb:	75 ef                	jne    801bac <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bbd:	5b                   	pop    %ebx
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	53                   	push   %ebx
  801bc4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bc7:	53                   	push   %ebx
  801bc8:	e8 9a ff ff ff       	call   801b67 <strlen>
  801bcd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bd0:	ff 75 0c             	pushl  0xc(%ebp)
  801bd3:	01 d8                	add    %ebx,%eax
  801bd5:	50                   	push   %eax
  801bd6:	e8 c5 ff ff ff       	call   801ba0 <strcpy>
	return dst;
}
  801bdb:	89 d8                	mov    %ebx,%eax
  801bdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	56                   	push   %esi
  801be6:	53                   	push   %ebx
  801be7:	8b 75 08             	mov    0x8(%ebp),%esi
  801bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bed:	89 f3                	mov    %esi,%ebx
  801bef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bf2:	89 f2                	mov    %esi,%edx
  801bf4:	eb 0f                	jmp    801c05 <strncpy+0x23>
		*dst++ = *src;
  801bf6:	83 c2 01             	add    $0x1,%edx
  801bf9:	0f b6 01             	movzbl (%ecx),%eax
  801bfc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bff:	80 39 01             	cmpb   $0x1,(%ecx)
  801c02:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c05:	39 da                	cmp    %ebx,%edx
  801c07:	75 ed                	jne    801bf6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c09:	89 f0                	mov    %esi,%eax
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	8b 75 08             	mov    0x8(%ebp),%esi
  801c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1a:	8b 55 10             	mov    0x10(%ebp),%edx
  801c1d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c1f:	85 d2                	test   %edx,%edx
  801c21:	74 21                	je     801c44 <strlcpy+0x35>
  801c23:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c27:	89 f2                	mov    %esi,%edx
  801c29:	eb 09                	jmp    801c34 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c2b:	83 c2 01             	add    $0x1,%edx
  801c2e:	83 c1 01             	add    $0x1,%ecx
  801c31:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c34:	39 c2                	cmp    %eax,%edx
  801c36:	74 09                	je     801c41 <strlcpy+0x32>
  801c38:	0f b6 19             	movzbl (%ecx),%ebx
  801c3b:	84 db                	test   %bl,%bl
  801c3d:	75 ec                	jne    801c2b <strlcpy+0x1c>
  801c3f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c41:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c44:	29 f0                	sub    %esi,%eax
}
  801c46:	5b                   	pop    %ebx
  801c47:	5e                   	pop    %esi
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c50:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c53:	eb 06                	jmp    801c5b <strcmp+0x11>
		p++, q++;
  801c55:	83 c1 01             	add    $0x1,%ecx
  801c58:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c5b:	0f b6 01             	movzbl (%ecx),%eax
  801c5e:	84 c0                	test   %al,%al
  801c60:	74 04                	je     801c66 <strcmp+0x1c>
  801c62:	3a 02                	cmp    (%edx),%al
  801c64:	74 ef                	je     801c55 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c66:	0f b6 c0             	movzbl %al,%eax
  801c69:	0f b6 12             	movzbl (%edx),%edx
  801c6c:	29 d0                	sub    %edx,%eax
}
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	53                   	push   %ebx
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c7a:	89 c3                	mov    %eax,%ebx
  801c7c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c7f:	eb 06                	jmp    801c87 <strncmp+0x17>
		n--, p++, q++;
  801c81:	83 c0 01             	add    $0x1,%eax
  801c84:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c87:	39 d8                	cmp    %ebx,%eax
  801c89:	74 15                	je     801ca0 <strncmp+0x30>
  801c8b:	0f b6 08             	movzbl (%eax),%ecx
  801c8e:	84 c9                	test   %cl,%cl
  801c90:	74 04                	je     801c96 <strncmp+0x26>
  801c92:	3a 0a                	cmp    (%edx),%cl
  801c94:	74 eb                	je     801c81 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c96:	0f b6 00             	movzbl (%eax),%eax
  801c99:	0f b6 12             	movzbl (%edx),%edx
  801c9c:	29 d0                	sub    %edx,%eax
  801c9e:	eb 05                	jmp    801ca5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801ca0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ca5:	5b                   	pop    %ebx
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	8b 45 08             	mov    0x8(%ebp),%eax
  801cae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cb2:	eb 07                	jmp    801cbb <strchr+0x13>
		if (*s == c)
  801cb4:	38 ca                	cmp    %cl,%dl
  801cb6:	74 0f                	je     801cc7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cb8:	83 c0 01             	add    $0x1,%eax
  801cbb:	0f b6 10             	movzbl (%eax),%edx
  801cbe:	84 d2                	test   %dl,%dl
  801cc0:	75 f2                	jne    801cb4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cd3:	eb 03                	jmp    801cd8 <strfind+0xf>
  801cd5:	83 c0 01             	add    $0x1,%eax
  801cd8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cdb:	38 ca                	cmp    %cl,%dl
  801cdd:	74 04                	je     801ce3 <strfind+0x1a>
  801cdf:	84 d2                	test   %dl,%dl
  801ce1:	75 f2                	jne    801cd5 <strfind+0xc>
			break;
	return (char *) s;
}
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	57                   	push   %edi
  801ce9:	56                   	push   %esi
  801cea:	53                   	push   %ebx
  801ceb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cf1:	85 c9                	test   %ecx,%ecx
  801cf3:	74 36                	je     801d2b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cf5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cfb:	75 28                	jne    801d25 <memset+0x40>
  801cfd:	f6 c1 03             	test   $0x3,%cl
  801d00:	75 23                	jne    801d25 <memset+0x40>
		c &= 0xFF;
  801d02:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d06:	89 d3                	mov    %edx,%ebx
  801d08:	c1 e3 08             	shl    $0x8,%ebx
  801d0b:	89 d6                	mov    %edx,%esi
  801d0d:	c1 e6 18             	shl    $0x18,%esi
  801d10:	89 d0                	mov    %edx,%eax
  801d12:	c1 e0 10             	shl    $0x10,%eax
  801d15:	09 f0                	or     %esi,%eax
  801d17:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d19:	89 d8                	mov    %ebx,%eax
  801d1b:	09 d0                	or     %edx,%eax
  801d1d:	c1 e9 02             	shr    $0x2,%ecx
  801d20:	fc                   	cld    
  801d21:	f3 ab                	rep stos %eax,%es:(%edi)
  801d23:	eb 06                	jmp    801d2b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d28:	fc                   	cld    
  801d29:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d2b:	89 f8                	mov    %edi,%eax
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    

00801d32 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	57                   	push   %edi
  801d36:	56                   	push   %esi
  801d37:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d40:	39 c6                	cmp    %eax,%esi
  801d42:	73 35                	jae    801d79 <memmove+0x47>
  801d44:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d47:	39 d0                	cmp    %edx,%eax
  801d49:	73 2e                	jae    801d79 <memmove+0x47>
		s += n;
		d += n;
  801d4b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d4e:	89 d6                	mov    %edx,%esi
  801d50:	09 fe                	or     %edi,%esi
  801d52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d58:	75 13                	jne    801d6d <memmove+0x3b>
  801d5a:	f6 c1 03             	test   $0x3,%cl
  801d5d:	75 0e                	jne    801d6d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d5f:	83 ef 04             	sub    $0x4,%edi
  801d62:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d65:	c1 e9 02             	shr    $0x2,%ecx
  801d68:	fd                   	std    
  801d69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d6b:	eb 09                	jmp    801d76 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d6d:	83 ef 01             	sub    $0x1,%edi
  801d70:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d73:	fd                   	std    
  801d74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d76:	fc                   	cld    
  801d77:	eb 1d                	jmp    801d96 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d79:	89 f2                	mov    %esi,%edx
  801d7b:	09 c2                	or     %eax,%edx
  801d7d:	f6 c2 03             	test   $0x3,%dl
  801d80:	75 0f                	jne    801d91 <memmove+0x5f>
  801d82:	f6 c1 03             	test   $0x3,%cl
  801d85:	75 0a                	jne    801d91 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d87:	c1 e9 02             	shr    $0x2,%ecx
  801d8a:	89 c7                	mov    %eax,%edi
  801d8c:	fc                   	cld    
  801d8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d8f:	eb 05                	jmp    801d96 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d91:	89 c7                	mov    %eax,%edi
  801d93:	fc                   	cld    
  801d94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d96:	5e                   	pop    %esi
  801d97:	5f                   	pop    %edi
  801d98:	5d                   	pop    %ebp
  801d99:	c3                   	ret    

00801d9a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d9d:	ff 75 10             	pushl  0x10(%ebp)
  801da0:	ff 75 0c             	pushl  0xc(%ebp)
  801da3:	ff 75 08             	pushl  0x8(%ebp)
  801da6:	e8 87 ff ff ff       	call   801d32 <memmove>
}
  801dab:	c9                   	leave  
  801dac:	c3                   	ret    

00801dad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	56                   	push   %esi
  801db1:	53                   	push   %ebx
  801db2:	8b 45 08             	mov    0x8(%ebp),%eax
  801db5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db8:	89 c6                	mov    %eax,%esi
  801dba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dbd:	eb 1a                	jmp    801dd9 <memcmp+0x2c>
		if (*s1 != *s2)
  801dbf:	0f b6 08             	movzbl (%eax),%ecx
  801dc2:	0f b6 1a             	movzbl (%edx),%ebx
  801dc5:	38 d9                	cmp    %bl,%cl
  801dc7:	74 0a                	je     801dd3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801dc9:	0f b6 c1             	movzbl %cl,%eax
  801dcc:	0f b6 db             	movzbl %bl,%ebx
  801dcf:	29 d8                	sub    %ebx,%eax
  801dd1:	eb 0f                	jmp    801de2 <memcmp+0x35>
		s1++, s2++;
  801dd3:	83 c0 01             	add    $0x1,%eax
  801dd6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dd9:	39 f0                	cmp    %esi,%eax
  801ddb:	75 e2                	jne    801dbf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801de2:	5b                   	pop    %ebx
  801de3:	5e                   	pop    %esi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    

00801de6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	53                   	push   %ebx
  801dea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801ded:	89 c1                	mov    %eax,%ecx
  801def:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801df2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801df6:	eb 0a                	jmp    801e02 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801df8:	0f b6 10             	movzbl (%eax),%edx
  801dfb:	39 da                	cmp    %ebx,%edx
  801dfd:	74 07                	je     801e06 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dff:	83 c0 01             	add    $0x1,%eax
  801e02:	39 c8                	cmp    %ecx,%eax
  801e04:	72 f2                	jb     801df8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e06:	5b                   	pop    %ebx
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	57                   	push   %edi
  801e0d:	56                   	push   %esi
  801e0e:	53                   	push   %ebx
  801e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e15:	eb 03                	jmp    801e1a <strtol+0x11>
		s++;
  801e17:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e1a:	0f b6 01             	movzbl (%ecx),%eax
  801e1d:	3c 20                	cmp    $0x20,%al
  801e1f:	74 f6                	je     801e17 <strtol+0xe>
  801e21:	3c 09                	cmp    $0x9,%al
  801e23:	74 f2                	je     801e17 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e25:	3c 2b                	cmp    $0x2b,%al
  801e27:	75 0a                	jne    801e33 <strtol+0x2a>
		s++;
  801e29:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e2c:	bf 00 00 00 00       	mov    $0x0,%edi
  801e31:	eb 11                	jmp    801e44 <strtol+0x3b>
  801e33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e38:	3c 2d                	cmp    $0x2d,%al
  801e3a:	75 08                	jne    801e44 <strtol+0x3b>
		s++, neg = 1;
  801e3c:	83 c1 01             	add    $0x1,%ecx
  801e3f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e44:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e4a:	75 15                	jne    801e61 <strtol+0x58>
  801e4c:	80 39 30             	cmpb   $0x30,(%ecx)
  801e4f:	75 10                	jne    801e61 <strtol+0x58>
  801e51:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e55:	75 7c                	jne    801ed3 <strtol+0xca>
		s += 2, base = 16;
  801e57:	83 c1 02             	add    $0x2,%ecx
  801e5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e5f:	eb 16                	jmp    801e77 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e61:	85 db                	test   %ebx,%ebx
  801e63:	75 12                	jne    801e77 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e65:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e6a:	80 39 30             	cmpb   $0x30,(%ecx)
  801e6d:	75 08                	jne    801e77 <strtol+0x6e>
		s++, base = 8;
  801e6f:	83 c1 01             	add    $0x1,%ecx
  801e72:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e77:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e7f:	0f b6 11             	movzbl (%ecx),%edx
  801e82:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e85:	89 f3                	mov    %esi,%ebx
  801e87:	80 fb 09             	cmp    $0x9,%bl
  801e8a:	77 08                	ja     801e94 <strtol+0x8b>
			dig = *s - '0';
  801e8c:	0f be d2             	movsbl %dl,%edx
  801e8f:	83 ea 30             	sub    $0x30,%edx
  801e92:	eb 22                	jmp    801eb6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e94:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e97:	89 f3                	mov    %esi,%ebx
  801e99:	80 fb 19             	cmp    $0x19,%bl
  801e9c:	77 08                	ja     801ea6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e9e:	0f be d2             	movsbl %dl,%edx
  801ea1:	83 ea 57             	sub    $0x57,%edx
  801ea4:	eb 10                	jmp    801eb6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ea6:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ea9:	89 f3                	mov    %esi,%ebx
  801eab:	80 fb 19             	cmp    $0x19,%bl
  801eae:	77 16                	ja     801ec6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801eb0:	0f be d2             	movsbl %dl,%edx
  801eb3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801eb6:	3b 55 10             	cmp    0x10(%ebp),%edx
  801eb9:	7d 0b                	jge    801ec6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ebb:	83 c1 01             	add    $0x1,%ecx
  801ebe:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ec2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ec4:	eb b9                	jmp    801e7f <strtol+0x76>

	if (endptr)
  801ec6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eca:	74 0d                	je     801ed9 <strtol+0xd0>
		*endptr = (char *) s;
  801ecc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ecf:	89 0e                	mov    %ecx,(%esi)
  801ed1:	eb 06                	jmp    801ed9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ed3:	85 db                	test   %ebx,%ebx
  801ed5:	74 98                	je     801e6f <strtol+0x66>
  801ed7:	eb 9e                	jmp    801e77 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ed9:	89 c2                	mov    %eax,%edx
  801edb:	f7 da                	neg    %edx
  801edd:	85 ff                	test   %edi,%edi
  801edf:	0f 45 c2             	cmovne %edx,%eax
}
  801ee2:	5b                   	pop    %ebx
  801ee3:	5e                   	pop    %esi
  801ee4:	5f                   	pop    %edi
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    

00801ee7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	56                   	push   %esi
  801eeb:	53                   	push   %ebx
  801eec:	8b 75 08             	mov    0x8(%ebp),%esi
  801eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ef5:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ef7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801efc:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	50                   	push   %eax
  801f03:	e8 12 e4 ff ff       	call   80031a <sys_ipc_recv>

	if (from_env_store != NULL)
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 f6                	test   %esi,%esi
  801f0d:	74 14                	je     801f23 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 09                	js     801f21 <ipc_recv+0x3a>
  801f18:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f1e:	8b 52 74             	mov    0x74(%edx),%edx
  801f21:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f23:	85 db                	test   %ebx,%ebx
  801f25:	74 14                	je     801f3b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f27:	ba 00 00 00 00       	mov    $0x0,%edx
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	78 09                	js     801f39 <ipc_recv+0x52>
  801f30:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f36:	8b 52 78             	mov    0x78(%edx),%edx
  801f39:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	78 08                	js     801f47 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f3f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f44:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5d                   	pop    %ebp
  801f4d:	c3                   	ret    

00801f4e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 0c             	sub    $0xc,%esp
  801f57:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f60:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f62:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f67:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f6a:	ff 75 14             	pushl  0x14(%ebp)
  801f6d:	53                   	push   %ebx
  801f6e:	56                   	push   %esi
  801f6f:	57                   	push   %edi
  801f70:	e8 82 e3 ff ff       	call   8002f7 <sys_ipc_try_send>

		if (err < 0) {
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	79 1e                	jns    801f9a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f7c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f7f:	75 07                	jne    801f88 <ipc_send+0x3a>
				sys_yield();
  801f81:	e8 c5 e1 ff ff       	call   80014b <sys_yield>
  801f86:	eb e2                	jmp    801f6a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f88:	50                   	push   %eax
  801f89:	68 60 27 80 00       	push   $0x802760
  801f8e:	6a 49                	push   $0x49
  801f90:	68 6d 27 80 00       	push   $0x80276d
  801f95:	e8 a8 f5 ff ff       	call   801542 <_panic>
		}

	} while (err < 0);

}
  801f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9d:	5b                   	pop    %ebx
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    

00801fa2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fad:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fb0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fb6:	8b 52 50             	mov    0x50(%edx),%edx
  801fb9:	39 ca                	cmp    %ecx,%edx
  801fbb:	75 0d                	jne    801fca <ipc_find_env+0x28>
			return envs[i].env_id;
  801fbd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fc0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc5:	8b 40 48             	mov    0x48(%eax),%eax
  801fc8:	eb 0f                	jmp    801fd9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fca:	83 c0 01             	add    $0x1,%eax
  801fcd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fd2:	75 d9                	jne    801fad <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe1:	89 d0                	mov    %edx,%eax
  801fe3:	c1 e8 16             	shr    $0x16,%eax
  801fe6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fed:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff2:	f6 c1 01             	test   $0x1,%cl
  801ff5:	74 1d                	je     802014 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ff7:	c1 ea 0c             	shr    $0xc,%edx
  801ffa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802001:	f6 c2 01             	test   $0x1,%dl
  802004:	74 0e                	je     802014 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802006:	c1 ea 0c             	shr    $0xc,%edx
  802009:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802010:	ef 
  802011:	0f b7 c0             	movzwl %ax,%eax
}
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    
  802016:	66 90                	xchg   %ax,%ax
  802018:	66 90                	xchg   %ax,%ax
  80201a:	66 90                	xchg   %ax,%ax
  80201c:	66 90                	xchg   %ax,%ax
  80201e:	66 90                	xchg   %ax,%ax

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 1c             	sub    $0x1c,%esp
  802027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80202b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80202f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802037:	85 f6                	test   %esi,%esi
  802039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203d:	89 ca                	mov    %ecx,%edx
  80203f:	89 f8                	mov    %edi,%eax
  802041:	75 3d                	jne    802080 <__udivdi3+0x60>
  802043:	39 cf                	cmp    %ecx,%edi
  802045:	0f 87 c5 00 00 00    	ja     802110 <__udivdi3+0xf0>
  80204b:	85 ff                	test   %edi,%edi
  80204d:	89 fd                	mov    %edi,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f7                	div    %edi
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 c8                	mov    %ecx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c1                	mov    %eax,%ecx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	89 cf                	mov    %ecx,%edi
  802068:	f7 f5                	div    %ebp
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 ce                	cmp    %ecx,%esi
  802082:	77 74                	ja     8020f8 <__udivdi3+0xd8>
  802084:	0f bd fe             	bsr    %esi,%edi
  802087:	83 f7 1f             	xor    $0x1f,%edi
  80208a:	0f 84 98 00 00 00    	je     802128 <__udivdi3+0x108>
  802090:	bb 20 00 00 00       	mov    $0x20,%ebx
  802095:	89 f9                	mov    %edi,%ecx
  802097:	89 c5                	mov    %eax,%ebp
  802099:	29 fb                	sub    %edi,%ebx
  80209b:	d3 e6                	shl    %cl,%esi
  80209d:	89 d9                	mov    %ebx,%ecx
  80209f:	d3 ed                	shr    %cl,%ebp
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	09 ee                	or     %ebp,%esi
  8020a7:	89 d9                	mov    %ebx,%ecx
  8020a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ad:	89 d5                	mov    %edx,%ebp
  8020af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b3:	d3 ed                	shr    %cl,%ebp
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e2                	shl    %cl,%edx
  8020b9:	89 d9                	mov    %ebx,%ecx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	09 c2                	or     %eax,%edx
  8020bf:	89 d0                	mov    %edx,%eax
  8020c1:	89 ea                	mov    %ebp,%edx
  8020c3:	f7 f6                	div    %esi
  8020c5:	89 d5                	mov    %edx,%ebp
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	f7 64 24 0c          	mull   0xc(%esp)
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	72 10                	jb     8020e1 <__udivdi3+0xc1>
  8020d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e6                	shl    %cl,%esi
  8020d9:	39 c6                	cmp    %eax,%esi
  8020db:	73 07                	jae    8020e4 <__udivdi3+0xc4>
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	75 03                	jne    8020e4 <__udivdi3+0xc4>
  8020e1:	83 eb 01             	sub    $0x1,%ebx
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	31 db                	xor    %ebx,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f7                	div    %edi
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 c3                	mov    %eax,%ebx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	39 ce                	cmp    %ecx,%esi
  80212a:	72 0c                	jb     802138 <__udivdi3+0x118>
  80212c:	31 db                	xor    %ebx,%ebx
  80212e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802132:	0f 87 34 ff ff ff    	ja     80206c <__udivdi3+0x4c>
  802138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80213d:	e9 2a ff ff ff       	jmp    80206c <__udivdi3+0x4c>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 d2                	test   %edx,%edx
  802169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f3                	mov    %esi,%ebx
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	75 1c                	jne    802198 <__umoddi3+0x48>
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	76 50                	jbe    8021d0 <__umoddi3+0x80>
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	f7 f7                	div    %edi
  802186:	89 d0                	mov    %edx,%eax
  802188:	31 d2                	xor    %edx,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	77 52                	ja     8021f0 <__umoddi3+0xa0>
  80219e:	0f bd ea             	bsr    %edx,%ebp
  8021a1:	83 f5 1f             	xor    $0x1f,%ebp
  8021a4:	75 5a                	jne    802200 <__umoddi3+0xb0>
  8021a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021aa:	0f 82 e0 00 00 00    	jb     802290 <__umoddi3+0x140>
  8021b0:	39 0c 24             	cmp    %ecx,(%esp)
  8021b3:	0f 86 d7 00 00 00    	jbe    802290 <__umoddi3+0x140>
  8021b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	89 fd                	mov    %edi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f7                	div    %edi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f5                	div    %ebp
  8021e7:	89 c8                	mov    %ecx,%eax
  8021e9:	f7 f5                	div    %ebp
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	eb 99                	jmp    802188 <__umoddi3+0x38>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 34 24             	mov    (%esp),%esi
  802203:	bf 20 00 00 00       	mov    $0x20,%edi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ef                	sub    %ebp,%edi
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 f9                	mov    %edi,%ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	d3 ea                	shr    %cl,%edx
  802214:	89 e9                	mov    %ebp,%ecx
  802216:	09 c2                	or     %eax,%edx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 14 24             	mov    %edx,(%esp)
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	d3 e2                	shl    %cl,%edx
  802221:	89 f9                	mov    %edi,%ecx
  802223:	89 54 24 04          	mov    %edx,0x4(%esp)
  802227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	89 c6                	mov    %eax,%esi
  802231:	d3 e3                	shl    %cl,%ebx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 d0                	mov    %edx,%eax
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	09 d8                	or     %ebx,%eax
  80223d:	89 d3                	mov    %edx,%ebx
  80223f:	89 f2                	mov    %esi,%edx
  802241:	f7 34 24             	divl   (%esp)
  802244:	89 d6                	mov    %edx,%esi
  802246:	d3 e3                	shl    %cl,%ebx
  802248:	f7 64 24 04          	mull   0x4(%esp)
  80224c:	39 d6                	cmp    %edx,%esi
  80224e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802252:	89 d1                	mov    %edx,%ecx
  802254:	89 c3                	mov    %eax,%ebx
  802256:	72 08                	jb     802260 <__umoddi3+0x110>
  802258:	75 11                	jne    80226b <__umoddi3+0x11b>
  80225a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80225e:	73 0b                	jae    80226b <__umoddi3+0x11b>
  802260:	2b 44 24 04          	sub    0x4(%esp),%eax
  802264:	1b 14 24             	sbb    (%esp),%edx
  802267:	89 d1                	mov    %edx,%ecx
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80226f:	29 da                	sub    %ebx,%edx
  802271:	19 ce                	sbb    %ecx,%esi
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 f0                	mov    %esi,%eax
  802277:	d3 e0                	shl    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	d3 ee                	shr    %cl,%esi
  802281:	09 d0                	or     %edx,%eax
  802283:	89 f2                	mov    %esi,%edx
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	29 f9                	sub    %edi,%ecx
  802292:	19 d6                	sbb    %edx,%esi
  802294:	89 74 24 04          	mov    %esi,0x4(%esp)
  802298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229c:	e9 18 ff ff ff       	jmp    8021b9 <__umoddi3+0x69>
