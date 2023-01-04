
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
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80009a:	e8 87 04 00 00       	call   800526 <close_all>
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
  800113:	68 98 1d 80 00       	push   $0x801d98
  800118:	6a 23                	push   $0x23
  80011a:	68 b5 1d 80 00       	push   $0x801db5
  80011f:	e8 f5 0e 00 00       	call   801019 <_panic>

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
  800194:	68 98 1d 80 00       	push   $0x801d98
  800199:	6a 23                	push   $0x23
  80019b:	68 b5 1d 80 00       	push   $0x801db5
  8001a0:	e8 74 0e 00 00       	call   801019 <_panic>

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
  8001d6:	68 98 1d 80 00       	push   $0x801d98
  8001db:	6a 23                	push   $0x23
  8001dd:	68 b5 1d 80 00       	push   $0x801db5
  8001e2:	e8 32 0e 00 00       	call   801019 <_panic>

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
  800218:	68 98 1d 80 00       	push   $0x801d98
  80021d:	6a 23                	push   $0x23
  80021f:	68 b5 1d 80 00       	push   $0x801db5
  800224:	e8 f0 0d 00 00       	call   801019 <_panic>

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
  80025a:	68 98 1d 80 00       	push   $0x801d98
  80025f:	6a 23                	push   $0x23
  800261:	68 b5 1d 80 00       	push   $0x801db5
  800266:	e8 ae 0d 00 00       	call   801019 <_panic>

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
  80029c:	68 98 1d 80 00       	push   $0x801d98
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 b5 1d 80 00       	push   $0x801db5
  8002a8:	e8 6c 0d 00 00       	call   801019 <_panic>

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
  8002de:	68 98 1d 80 00       	push   $0x801d98
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 b5 1d 80 00       	push   $0x801db5
  8002ea:	e8 2a 0d 00 00       	call   801019 <_panic>

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
  800342:	68 98 1d 80 00       	push   $0x801d98
  800347:	6a 23                	push   $0x23
  800349:	68 b5 1d 80 00       	push   $0x801db5
  80034e:	e8 c6 0c 00 00       	call   801019 <_panic>

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

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 11                	je     8003af <fd_alloc+0x2d>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	75 09                	jne    8003b8 <fd_alloc+0x36>
			*fd_store = fd;
  8003af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	eb 17                	jmp    8003cf <fd_alloc+0x4d>
  8003b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003c2:	75 c9                	jne    80038d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 13                	jmp    800425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 0c                	jmp    800425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb 05                	jmp    800425 <fd_lookup+0x54>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba 40 1e 80 00       	mov    $0x801e40,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	eb 13                	jmp    80044a <dev_lookup+0x23>
  800437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	75 0c                	jne    80044a <dev_lookup+0x23>
			*dev = devtab[i];
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 01                	mov    %eax,(%ecx)
			return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 2e                	jmp    800478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 e7                	jne    800437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800450:	a1 04 40 80 00       	mov    0x804004,%eax
  800455:	8b 40 48             	mov    0x48(%eax),%eax
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	51                   	push   %ecx
  80045c:	50                   	push   %eax
  80045d:	68 c4 1d 80 00       	push   $0x801dc4
  800462:	e8 8b 0c 00 00       	call   8010f2 <cprintf>
	*dev = 0;
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 10             	sub    $0x10,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	50                   	push   %eax
  800496:	e8 36 ff ff ff       	call   8003d1 <fd_lookup>
  80049b:	83 c4 08             	add    $0x8,%esp
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	78 05                	js     8004a7 <fd_close+0x2d>
	    || fd != fd2)
  8004a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a5:	74 0c                	je     8004b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a7:	84 db                	test   %bl,%bl
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	0f 44 c2             	cmove  %edx,%eax
  8004b1:	eb 41                	jmp    8004f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 66 ff ff ff       	call   800427 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 1a                	js     8004e4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 0b                	je     8004e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	56                   	push   %esi
  8004dd:	ff d0                	call   *%eax
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 00 fd ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	89 d8                	mov    %ebx,%eax
}
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 c4 fe ff ff       	call   8003d1 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 10                	js     800524 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	6a 01                	push   $0x1
  800519:	ff 75 f4             	pushl  -0xc(%ebp)
  80051c:	e8 59 ff ff ff       	call   80047a <fd_close>
  800521:	83 c4 10             	add    $0x10,%esp
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <close_all>:

void
close_all(void)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	53                   	push   %ebx
  80052a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	53                   	push   %ebx
  800536:	e8 c0 ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	83 c3 01             	add    $0x1,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	83 fb 20             	cmp    $0x20,%ebx
  800544:	75 ec                	jne    800532 <close_all+0xc>
		close(i);
}
  800546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800557:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 6e fe ff ff       	call   8003d1 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 88 c1 00 00 00    	js     80062f <dup+0xe4>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	56                   	push   %esi
  800572:	e8 84 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  800577:	89 f3                	mov    %esi,%ebx
  800579:	c1 e3 0c             	shl    $0xc,%ebx
  80057c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800582:	83 c4 04             	add    $0x4,%esp
  800585:	ff 75 e4             	pushl  -0x1c(%ebp)
  800588:	e8 de fd ff ff       	call   80036b <fd2data>
  80058d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 d4 fd ff ff       	call   80036b <fd2data>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 37                	je     8005e4 <dup+0x99>
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	74 26                	je     8005e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d1:	6a 00                	push   $0x0
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 d2 fb ff ff       	call   8001ad <sys_page_map>
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	83 c4 20             	add    $0x20,%esp
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	78 2e                	js     800612 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	53                   	push   %ebx
  8005fd:	6a 00                	push   $0x0
  8005ff:	52                   	push   %edx
  800600:	6a 00                	push   $0x0
  800602:	e8 a6 fb ff ff       	call   8001ad <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80060c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	85 ff                	test   %edi,%edi
  800610:	79 1d                	jns    80062f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 d2 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	pushl  -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 c5 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 f8                	mov    %edi,%eax
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 14             	sub    $0x14,%esp
  80063e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	e8 86 fd ff ff       	call   8003d1 <fd_lookup>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	89 c2                	mov    %eax,%edx
  800650:	85 c0                	test   %eax,%eax
  800652:	78 6d                	js     8006c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	ff 30                	pushl  (%eax)
  800660:	e8 c2 fd ff ff       	call   800427 <dev_lookup>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 4c                	js     8006b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066f:	8b 42 08             	mov    0x8(%edx),%eax
  800672:	83 e0 03             	and    $0x3,%eax
  800675:	83 f8 01             	cmp    $0x1,%eax
  800678:	75 21                	jne    80069b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 05 1e 80 00       	push   $0x801e05
  80068c:	e8 61 0a 00 00       	call   8010f2 <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800699:	eb 26                	jmp    8006c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	8b 40 08             	mov    0x8(%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 17                	je     8006bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 09                	jmp    8006c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	eb 05                	jmp    8006c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	eb 21                	jmp    8006ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	29 d8                	sub    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 45 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 10                	js     800709 <readn+0x41>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 0a                	je     800707 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	39 f3                	cmp    %esi,%ebx
  800701:	72 db                	jb     8006de <readn+0x16>
  800703:	89 d8                	mov    %ebx,%eax
  800705:	eb 02                	jmp    800709 <readn+0x41>
  800707:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 14             	sub    $0x14,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 ac fc ff ff       	call   8003d1 <fd_lookup>
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	89 c2                	mov    %eax,%edx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 68                	js     800796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800738:	ff 30                	pushl  (%eax)
  80073a:	e8 e8 fc ff ff       	call   800427 <dev_lookup>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 47                	js     80078d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074d:	75 21                	jne    800770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 21 1e 80 00       	push   $0x801e21
  800761:	e8 8c 09 00 00       	call   8010f2 <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076e:	eb 26                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 0c             	mov    0xc(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 17                	je     800791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	50                   	push   %eax
  800784:	ff d2                	call   *%edx
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 09                	jmp    800796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	eb 05                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800796:	89 d0                	mov    %edx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 22 fc ff ff       	call   8003d1 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 14             	sub    $0x14,%esp
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	53                   	push   %ebx
  8007d5:	e8 f7 fb ff ff       	call   8003d1 <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 65                	js     800848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	ff 30                	pushl  (%eax)
  8007ef:	e8 33 fc ff ff       	call   800427 <dev_lookup>
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 44                	js     80083f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800802:	75 21                	jne    800825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800804:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800809:	8b 40 48             	mov    0x48(%eax),%eax
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	53                   	push   %ebx
  800810:	50                   	push   %eax
  800811:	68 e4 1d 80 00       	push   $0x801de4
  800816:	e8 d7 08 00 00       	call   8010f2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800823:	eb 23                	jmp    800848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 18             	mov    0x18(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 14                	je     800843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff d2                	call   *%edx
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 09                	jmp    800848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 05                	jmp    800848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 6c fb ff ff       	call   8003d1 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 58                	js     8008c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 a8 fb ff ff       	call   800427 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 37                	js     8008bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 32                	je     8008c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 09                	jmp    8008c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 05                	jmp    8008c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	6a 00                	push   $0x0
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 b7 01 00 00       	call   800a96 <open>
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	78 1b                	js     800903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	50                   	push   %eax
  8008ef:	e8 5b ff ff ff       	call   80084f <fstat>
  8008f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 fd fb ff ff       	call   8004fb <close>
	return r;
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f0                	mov    %esi,%eax
}
  800903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091a:	75 12                	jne    80092e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	6a 01                	push   $0x1
  800921:	e8 53 11 00 00       	call   801a79 <ipc_find_env>
  800926:	a3 00 40 80 00       	mov    %eax,0x804000
  80092b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092e:	6a 07                	push   $0x7
  800930:	68 00 50 80 00       	push   $0x805000
  800935:	56                   	push   %esi
  800936:	ff 35 00 40 80 00    	pushl  0x804000
  80093c:	e8 e4 10 00 00       	call   801a25 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 70 10 00 00       	call   8019be <ipc_recv>
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 02 00 00 00       	mov    $0x2,%eax
  800978:	e8 8d ff ff ff       	call   80090a <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 06 00 00 00       	mov    $0x6,%eax
  80099a:	e8 6b ff ff ff       	call   80090a <fsipc>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c0:	e8 45 ff ff ff       	call   80090a <fsipc>
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 2c                	js     8009f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	68 00 50 80 00       	push   $0x805000
  8009d1:	53                   	push   %ebx
  8009d2:	e8 a0 0c 00 00       	call   801677 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800a00:	68 50 1e 80 00       	push   $0x801e50
  800a05:	68 90 00 00 00       	push   $0x90
  800a0a:	68 6e 1e 80 00       	push   $0x801e6e
  800a0f:	e8 05 06 00 00       	call   801019 <_panic>

00800a14 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a22:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a27:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	b8 03 00 00 00       	mov    $0x3,%eax
  800a37:	e8 ce fe ff ff       	call   80090a <fsipc>
  800a3c:	89 c3                	mov    %eax,%ebx
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	78 4b                	js     800a8d <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 16                	jae    800a5c <devfile_read+0x48>
  800a46:	68 79 1e 80 00       	push   $0x801e79
  800a4b:	68 80 1e 80 00       	push   $0x801e80
  800a50:	6a 7c                	push   $0x7c
  800a52:	68 6e 1e 80 00       	push   $0x801e6e
  800a57:	e8 bd 05 00 00       	call   801019 <_panic>
	assert(r <= PGSIZE);
  800a5c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a61:	7e 16                	jle    800a79 <devfile_read+0x65>
  800a63:	68 95 1e 80 00       	push   $0x801e95
  800a68:	68 80 1e 80 00       	push   $0x801e80
  800a6d:	6a 7d                	push   $0x7d
  800a6f:	68 6e 1e 80 00       	push   $0x801e6e
  800a74:	e8 a0 05 00 00       	call   801019 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a79:	83 ec 04             	sub    $0x4,%esp
  800a7c:	50                   	push   %eax
  800a7d:	68 00 50 80 00       	push   $0x805000
  800a82:	ff 75 0c             	pushl  0xc(%ebp)
  800a85:	e8 7f 0d 00 00       	call   801809 <memmove>
	return r;
  800a8a:	83 c4 10             	add    $0x10,%esp
}
  800a8d:	89 d8                	mov    %ebx,%eax
  800a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	53                   	push   %ebx
  800a9a:	83 ec 20             	sub    $0x20,%esp
  800a9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aa0:	53                   	push   %ebx
  800aa1:	e8 98 0b 00 00       	call   80163e <strlen>
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aae:	7f 67                	jg     800b17 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ab0:	83 ec 0c             	sub    $0xc,%esp
  800ab3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab6:	50                   	push   %eax
  800ab7:	e8 c6 f8 ff ff       	call   800382 <fd_alloc>
  800abc:	83 c4 10             	add    $0x10,%esp
		return r;
  800abf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	78 57                	js     800b1c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ac5:	83 ec 08             	sub    $0x8,%esp
  800ac8:	53                   	push   %ebx
  800ac9:	68 00 50 80 00       	push   $0x805000
  800ace:	e8 a4 0b 00 00       	call   801677 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800adb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ade:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae3:	e8 22 fe ff ff       	call   80090a <fsipc>
  800ae8:	89 c3                	mov    %eax,%ebx
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	85 c0                	test   %eax,%eax
  800aef:	79 14                	jns    800b05 <open+0x6f>
		fd_close(fd, 0);
  800af1:	83 ec 08             	sub    $0x8,%esp
  800af4:	6a 00                	push   $0x0
  800af6:	ff 75 f4             	pushl  -0xc(%ebp)
  800af9:	e8 7c f9 ff ff       	call   80047a <fd_close>
		return r;
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	89 da                	mov    %ebx,%edx
  800b03:	eb 17                	jmp    800b1c <open+0x86>
	}

	return fd2num(fd);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0b:	e8 4b f8 ff ff       	call   80035b <fd2num>
  800b10:	89 c2                	mov    %eax,%edx
  800b12:	83 c4 10             	add    $0x10,%esp
  800b15:	eb 05                	jmp    800b1c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b17:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b1c:	89 d0                	mov    %edx,%eax
  800b1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b33:	e8 d2 fd ff ff       	call   80090a <fsipc>
}
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	ff 75 08             	pushl  0x8(%ebp)
  800b48:	e8 1e f8 ff ff       	call   80036b <fd2data>
  800b4d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b4f:	83 c4 08             	add    $0x8,%esp
  800b52:	68 a1 1e 80 00       	push   $0x801ea1
  800b57:	53                   	push   %ebx
  800b58:	e8 1a 0b 00 00       	call   801677 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b5d:	8b 46 04             	mov    0x4(%esi),%eax
  800b60:	2b 06                	sub    (%esi),%eax
  800b62:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b68:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b6f:	00 00 00 
	stat->st_dev = &devpipe;
  800b72:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800b79:	30 80 00 
	return 0;
}
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
  800b8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b92:	53                   	push   %ebx
  800b93:	6a 00                	push   $0x0
  800b95:	e8 55 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b9a:	89 1c 24             	mov    %ebx,(%esp)
  800b9d:	e8 c9 f7 ff ff       	call   80036b <fd2data>
  800ba2:	83 c4 08             	add    $0x8,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 00                	push   $0x0
  800ba8:	e8 42 f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 1c             	sub    $0x1c,%esp
  800bbb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bbe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bc0:	a1 04 40 80 00       	mov    0x804004,%eax
  800bc5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	ff 75 e0             	pushl  -0x20(%ebp)
  800bce:	e8 df 0e 00 00       	call   801ab2 <pageref>
  800bd3:	89 c3                	mov    %eax,%ebx
  800bd5:	89 3c 24             	mov    %edi,(%esp)
  800bd8:	e8 d5 0e 00 00       	call   801ab2 <pageref>
  800bdd:	83 c4 10             	add    $0x10,%esp
  800be0:	39 c3                	cmp    %eax,%ebx
  800be2:	0f 94 c1             	sete   %cl
  800be5:	0f b6 c9             	movzbl %cl,%ecx
  800be8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800beb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bf1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bf4:	39 ce                	cmp    %ecx,%esi
  800bf6:	74 1b                	je     800c13 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bf8:	39 c3                	cmp    %eax,%ebx
  800bfa:	75 c4                	jne    800bc0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bfc:	8b 42 58             	mov    0x58(%edx),%eax
  800bff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c02:	50                   	push   %eax
  800c03:	56                   	push   %esi
  800c04:	68 a8 1e 80 00       	push   $0x801ea8
  800c09:	e8 e4 04 00 00       	call   8010f2 <cprintf>
  800c0e:	83 c4 10             	add    $0x10,%esp
  800c11:	eb ad                	jmp    800bc0 <_pipeisclosed+0xe>
	}
}
  800c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 28             	sub    $0x28,%esp
  800c27:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c2a:	56                   	push   %esi
  800c2b:	e8 3b f7 ff ff       	call   80036b <fd2data>
  800c30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c32:	83 c4 10             	add    $0x10,%esp
  800c35:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3a:	eb 4b                	jmp    800c87 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c3c:	89 da                	mov    %ebx,%edx
  800c3e:	89 f0                	mov    %esi,%eax
  800c40:	e8 6d ff ff ff       	call   800bb2 <_pipeisclosed>
  800c45:	85 c0                	test   %eax,%eax
  800c47:	75 48                	jne    800c91 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c49:	e8 fd f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c51:	8b 0b                	mov    (%ebx),%ecx
  800c53:	8d 51 20             	lea    0x20(%ecx),%edx
  800c56:	39 d0                	cmp    %edx,%eax
  800c58:	73 e2                	jae    800c3c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c61:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c64:	89 c2                	mov    %eax,%edx
  800c66:	c1 fa 1f             	sar    $0x1f,%edx
  800c69:	89 d1                	mov    %edx,%ecx
  800c6b:	c1 e9 1b             	shr    $0x1b,%ecx
  800c6e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c71:	83 e2 1f             	and    $0x1f,%edx
  800c74:	29 ca                	sub    %ecx,%edx
  800c76:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c7a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c7e:	83 c0 01             	add    $0x1,%eax
  800c81:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c84:	83 c7 01             	add    $0x1,%edi
  800c87:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c8a:	75 c2                	jne    800c4e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8f:	eb 05                	jmp    800c96 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c91:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 18             	sub    $0x18,%esp
  800ca7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800caa:	57                   	push   %edi
  800cab:	e8 bb f6 ff ff       	call   80036b <fd2data>
  800cb0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb2:	83 c4 10             	add    $0x10,%esp
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	eb 3d                	jmp    800cf9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cbc:	85 db                	test   %ebx,%ebx
  800cbe:	74 04                	je     800cc4 <devpipe_read+0x26>
				return i;
  800cc0:	89 d8                	mov    %ebx,%eax
  800cc2:	eb 44                	jmp    800d08 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cc4:	89 f2                	mov    %esi,%edx
  800cc6:	89 f8                	mov    %edi,%eax
  800cc8:	e8 e5 fe ff ff       	call   800bb2 <_pipeisclosed>
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	75 32                	jne    800d03 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cd1:	e8 75 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cd6:	8b 06                	mov    (%esi),%eax
  800cd8:	3b 46 04             	cmp    0x4(%esi),%eax
  800cdb:	74 df                	je     800cbc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cdd:	99                   	cltd   
  800cde:	c1 ea 1b             	shr    $0x1b,%edx
  800ce1:	01 d0                	add    %edx,%eax
  800ce3:	83 e0 1f             	and    $0x1f,%eax
  800ce6:	29 d0                	sub    %edx,%eax
  800ce8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cf3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf6:	83 c3 01             	add    $0x1,%ebx
  800cf9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800cfc:	75 d8                	jne    800cd6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cfe:	8b 45 10             	mov    0x10(%ebp),%eax
  800d01:	eb 05                	jmp    800d08 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d03:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d1b:	50                   	push   %eax
  800d1c:	e8 61 f6 ff ff       	call   800382 <fd_alloc>
  800d21:	83 c4 10             	add    $0x10,%esp
  800d24:	89 c2                	mov    %eax,%edx
  800d26:	85 c0                	test   %eax,%eax
  800d28:	0f 88 2c 01 00 00    	js     800e5a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d2e:	83 ec 04             	sub    $0x4,%esp
  800d31:	68 07 04 00 00       	push   $0x407
  800d36:	ff 75 f4             	pushl  -0xc(%ebp)
  800d39:	6a 00                	push   $0x0
  800d3b:	e8 2a f4 ff ff       	call   80016a <sys_page_alloc>
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	89 c2                	mov    %eax,%edx
  800d45:	85 c0                	test   %eax,%eax
  800d47:	0f 88 0d 01 00 00    	js     800e5a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d53:	50                   	push   %eax
  800d54:	e8 29 f6 ff ff       	call   800382 <fd_alloc>
  800d59:	89 c3                	mov    %eax,%ebx
  800d5b:	83 c4 10             	add    $0x10,%esp
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	0f 88 e2 00 00 00    	js     800e48 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d66:	83 ec 04             	sub    $0x4,%esp
  800d69:	68 07 04 00 00       	push   $0x407
  800d6e:	ff 75 f0             	pushl  -0x10(%ebp)
  800d71:	6a 00                	push   $0x0
  800d73:	e8 f2 f3 ff ff       	call   80016a <sys_page_alloc>
  800d78:	89 c3                	mov    %eax,%ebx
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	0f 88 c3 00 00 00    	js     800e48 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8b:	e8 db f5 ff ff       	call   80036b <fd2data>
  800d90:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d92:	83 c4 0c             	add    $0xc,%esp
  800d95:	68 07 04 00 00       	push   $0x407
  800d9a:	50                   	push   %eax
  800d9b:	6a 00                	push   $0x0
  800d9d:	e8 c8 f3 ff ff       	call   80016a <sys_page_alloc>
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	0f 88 89 00 00 00    	js     800e38 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	ff 75 f0             	pushl  -0x10(%ebp)
  800db5:	e8 b1 f5 ff ff       	call   80036b <fd2data>
  800dba:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dc1:	50                   	push   %eax
  800dc2:	6a 00                	push   $0x0
  800dc4:	56                   	push   %esi
  800dc5:	6a 00                	push   $0x0
  800dc7:	e8 e1 f3 ff ff       	call   8001ad <sys_page_map>
  800dcc:	89 c3                	mov    %eax,%ebx
  800dce:	83 c4 20             	add    $0x20,%esp
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	78 55                	js     800e2a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dd5:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dde:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dea:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	ff 75 f4             	pushl  -0xc(%ebp)
  800e05:	e8 51 f5 ff ff       	call   80035b <fd2num>
  800e0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e0f:	83 c4 04             	add    $0x4,%esp
  800e12:	ff 75 f0             	pushl  -0x10(%ebp)
  800e15:	e8 41 f5 ff ff       	call   80035b <fd2num>
  800e1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	ba 00 00 00 00       	mov    $0x0,%edx
  800e28:	eb 30                	jmp    800e5a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e2a:	83 ec 08             	sub    $0x8,%esp
  800e2d:	56                   	push   %esi
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 ba f3 ff ff       	call   8001ef <sys_page_unmap>
  800e35:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 aa f3 ff ff       	call   8001ef <sys_page_unmap>
  800e45:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 9a f3 ff ff       	call   8001ef <sys_page_unmap>
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e5a:	89 d0                	mov    %edx,%eax
  800e5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e6c:	50                   	push   %eax
  800e6d:	ff 75 08             	pushl  0x8(%ebp)
  800e70:	e8 5c f5 ff ff       	call   8003d1 <fd_lookup>
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	78 18                	js     800e94 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e7c:	83 ec 0c             	sub    $0xc,%esp
  800e7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e82:	e8 e4 f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800e87:	89 c2                	mov    %eax,%edx
  800e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8c:	e8 21 fd ff ff       	call   800bb2 <_pipeisclosed>
  800e91:	83 c4 10             	add    $0x10,%esp
}
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ea6:	68 c0 1e 80 00       	push   $0x801ec0
  800eab:	ff 75 0c             	pushl  0xc(%ebp)
  800eae:	e8 c4 07 00 00       	call   801677 <strcpy>
	return 0;
}
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ecb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ed1:	eb 2d                	jmp    800f00 <devcons_write+0x46>
		m = n - tot;
  800ed3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ed8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800edb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ee0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee3:	83 ec 04             	sub    $0x4,%esp
  800ee6:	53                   	push   %ebx
  800ee7:	03 45 0c             	add    0xc(%ebp),%eax
  800eea:	50                   	push   %eax
  800eeb:	57                   	push   %edi
  800eec:	e8 18 09 00 00       	call   801809 <memmove>
		sys_cputs(buf, m);
  800ef1:	83 c4 08             	add    $0x8,%esp
  800ef4:	53                   	push   %ebx
  800ef5:	57                   	push   %edi
  800ef6:	e8 b3 f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800efb:	01 de                	add    %ebx,%esi
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	89 f0                	mov    %esi,%eax
  800f02:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f05:	72 cc                	jb     800ed3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 08             	sub    $0x8,%esp
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f1e:	74 2a                	je     800f4a <devcons_read+0x3b>
  800f20:	eb 05                	jmp    800f27 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f22:	e8 24 f2 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f27:	e8 a0 f1 ff ff       	call   8000cc <sys_cgetc>
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	74 f2                	je     800f22 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 16                	js     800f4a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f34:	83 f8 04             	cmp    $0x4,%eax
  800f37:	74 0c                	je     800f45 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3c:	88 02                	mov    %al,(%edx)
	return 1;
  800f3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f43:	eb 05                	jmp    800f4a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f52:	8b 45 08             	mov    0x8(%ebp),%eax
  800f55:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f58:	6a 01                	push   $0x1
  800f5a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5d:	50                   	push   %eax
  800f5e:	e8 4b f1 ff ff       	call   8000ae <sys_cputs>
}
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <getchar>:

int
getchar(void)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f6e:	6a 01                	push   $0x1
  800f70:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f73:	50                   	push   %eax
  800f74:	6a 00                	push   $0x0
  800f76:	e8 bc f6 ff ff       	call   800637 <read>
	if (r < 0)
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 0f                	js     800f91 <getchar+0x29>
		return r;
	if (r < 1)
  800f82:	85 c0                	test   %eax,%eax
  800f84:	7e 06                	jle    800f8c <getchar+0x24>
		return -E_EOF;
	return c;
  800f86:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f8a:	eb 05                	jmp    800f91 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f8c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9c:	50                   	push   %eax
  800f9d:	ff 75 08             	pushl  0x8(%ebp)
  800fa0:	e8 2c f4 ff ff       	call   8003d1 <fd_lookup>
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 11                	js     800fbd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800faf:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fb5:	39 10                	cmp    %edx,(%eax)
  800fb7:	0f 94 c0             	sete   %al
  800fba:	0f b6 c0             	movzbl %al,%eax
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    

00800fbf <opencons>:

int
opencons(void)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	e8 b4 f3 ff ff       	call   800382 <fd_alloc>
  800fce:	83 c4 10             	add    $0x10,%esp
		return r;
  800fd1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 3e                	js     801015 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	68 07 04 00 00       	push   $0x407
  800fdf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 81 f1 ff ff       	call   80016a <sys_page_alloc>
  800fe9:	83 c4 10             	add    $0x10,%esp
		return r;
  800fec:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 23                	js     801015 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800ff2:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801000:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	50                   	push   %eax
  80100b:	e8 4b f3 ff ff       	call   80035b <fd2num>
  801010:	89 c2                	mov    %eax,%edx
  801012:	83 c4 10             	add    $0x10,%esp
}
  801015:	89 d0                	mov    %edx,%eax
  801017:	c9                   	leave  
  801018:	c3                   	ret    

00801019 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	56                   	push   %esi
  80101d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80101e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801021:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801027:	e8 00 f1 ff ff       	call   80012c <sys_getenvid>
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	ff 75 0c             	pushl  0xc(%ebp)
  801032:	ff 75 08             	pushl  0x8(%ebp)
  801035:	56                   	push   %esi
  801036:	50                   	push   %eax
  801037:	68 cc 1e 80 00       	push   $0x801ecc
  80103c:	e8 b1 00 00 00       	call   8010f2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801041:	83 c4 18             	add    $0x18,%esp
  801044:	53                   	push   %ebx
  801045:	ff 75 10             	pushl  0x10(%ebp)
  801048:	e8 54 00 00 00       	call   8010a1 <vcprintf>
	cprintf("\n");
  80104d:	c7 04 24 b9 1e 80 00 	movl   $0x801eb9,(%esp)
  801054:	e8 99 00 00 00       	call   8010f2 <cprintf>
  801059:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80105c:	cc                   	int3   
  80105d:	eb fd                	jmp    80105c <_panic+0x43>

0080105f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	53                   	push   %ebx
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801069:	8b 13                	mov    (%ebx),%edx
  80106b:	8d 42 01             	lea    0x1(%edx),%eax
  80106e:	89 03                	mov    %eax,(%ebx)
  801070:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801073:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801077:	3d ff 00 00 00       	cmp    $0xff,%eax
  80107c:	75 1a                	jne    801098 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80107e:	83 ec 08             	sub    $0x8,%esp
  801081:	68 ff 00 00 00       	push   $0xff
  801086:	8d 43 08             	lea    0x8(%ebx),%eax
  801089:	50                   	push   %eax
  80108a:	e8 1f f0 ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  80108f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801095:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801098:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80109c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109f:	c9                   	leave  
  8010a0:	c3                   	ret    

008010a1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010aa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010b1:	00 00 00 
	b.cnt = 0;
  8010b4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010bb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010be:	ff 75 0c             	pushl  0xc(%ebp)
  8010c1:	ff 75 08             	pushl  0x8(%ebp)
  8010c4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ca:	50                   	push   %eax
  8010cb:	68 5f 10 80 00       	push   $0x80105f
  8010d0:	e8 54 01 00 00       	call   801229 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010d5:	83 c4 08             	add    $0x8,%esp
  8010d8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010de:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010e4:	50                   	push   %eax
  8010e5:	e8 c4 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  8010ea:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010fb:	50                   	push   %eax
  8010fc:	ff 75 08             	pushl  0x8(%ebp)
  8010ff:	e8 9d ff ff ff       	call   8010a1 <vcprintf>
	va_end(ap);

	return cnt;
}
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	57                   	push   %edi
  80110a:	56                   	push   %esi
  80110b:	53                   	push   %ebx
  80110c:	83 ec 1c             	sub    $0x1c,%esp
  80110f:	89 c7                	mov    %eax,%edi
  801111:	89 d6                	mov    %edx,%esi
  801113:	8b 45 08             	mov    0x8(%ebp),%eax
  801116:	8b 55 0c             	mov    0xc(%ebp),%edx
  801119:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80111c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80111f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801122:	bb 00 00 00 00       	mov    $0x0,%ebx
  801127:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80112a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80112d:	39 d3                	cmp    %edx,%ebx
  80112f:	72 05                	jb     801136 <printnum+0x30>
  801131:	39 45 10             	cmp    %eax,0x10(%ebp)
  801134:	77 45                	ja     80117b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	ff 75 18             	pushl  0x18(%ebp)
  80113c:	8b 45 14             	mov    0x14(%ebp),%eax
  80113f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801142:	53                   	push   %ebx
  801143:	ff 75 10             	pushl  0x10(%ebp)
  801146:	83 ec 08             	sub    $0x8,%esp
  801149:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114c:	ff 75 e0             	pushl  -0x20(%ebp)
  80114f:	ff 75 dc             	pushl  -0x24(%ebp)
  801152:	ff 75 d8             	pushl  -0x28(%ebp)
  801155:	e8 96 09 00 00       	call   801af0 <__udivdi3>
  80115a:	83 c4 18             	add    $0x18,%esp
  80115d:	52                   	push   %edx
  80115e:	50                   	push   %eax
  80115f:	89 f2                	mov    %esi,%edx
  801161:	89 f8                	mov    %edi,%eax
  801163:	e8 9e ff ff ff       	call   801106 <printnum>
  801168:	83 c4 20             	add    $0x20,%esp
  80116b:	eb 18                	jmp    801185 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	56                   	push   %esi
  801171:	ff 75 18             	pushl  0x18(%ebp)
  801174:	ff d7                	call   *%edi
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	eb 03                	jmp    80117e <printnum+0x78>
  80117b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80117e:	83 eb 01             	sub    $0x1,%ebx
  801181:	85 db                	test   %ebx,%ebx
  801183:	7f e8                	jg     80116d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	56                   	push   %esi
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118f:	ff 75 e0             	pushl  -0x20(%ebp)
  801192:	ff 75 dc             	pushl  -0x24(%ebp)
  801195:	ff 75 d8             	pushl  -0x28(%ebp)
  801198:	e8 83 0a 00 00       	call   801c20 <__umoddi3>
  80119d:	83 c4 14             	add    $0x14,%esp
  8011a0:	0f be 80 ef 1e 80 00 	movsbl 0x801eef(%eax),%eax
  8011a7:	50                   	push   %eax
  8011a8:	ff d7                	call   *%edi
}
  8011aa:	83 c4 10             	add    $0x10,%esp
  8011ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011b8:	83 fa 01             	cmp    $0x1,%edx
  8011bb:	7e 0e                	jle    8011cb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011bd:	8b 10                	mov    (%eax),%edx
  8011bf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011c2:	89 08                	mov    %ecx,(%eax)
  8011c4:	8b 02                	mov    (%edx),%eax
  8011c6:	8b 52 04             	mov    0x4(%edx),%edx
  8011c9:	eb 22                	jmp    8011ed <getuint+0x38>
	else if (lflag)
  8011cb:	85 d2                	test   %edx,%edx
  8011cd:	74 10                	je     8011df <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011cf:	8b 10                	mov    (%eax),%edx
  8011d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d4:	89 08                	mov    %ecx,(%eax)
  8011d6:	8b 02                	mov    (%edx),%eax
  8011d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011dd:	eb 0e                	jmp    8011ed <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011df:	8b 10                	mov    (%eax),%edx
  8011e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011e4:	89 08                	mov    %ecx,(%eax)
  8011e6:	8b 02                	mov    (%edx),%eax
  8011e8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011f9:	8b 10                	mov    (%eax),%edx
  8011fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8011fe:	73 0a                	jae    80120a <sprintputch+0x1b>
		*b->buf++ = ch;
  801200:	8d 4a 01             	lea    0x1(%edx),%ecx
  801203:	89 08                	mov    %ecx,(%eax)
  801205:	8b 45 08             	mov    0x8(%ebp),%eax
  801208:	88 02                	mov    %al,(%edx)
}
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801212:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801215:	50                   	push   %eax
  801216:	ff 75 10             	pushl  0x10(%ebp)
  801219:	ff 75 0c             	pushl  0xc(%ebp)
  80121c:	ff 75 08             	pushl  0x8(%ebp)
  80121f:	e8 05 00 00 00       	call   801229 <vprintfmt>
	va_end(ap);
}
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	c9                   	leave  
  801228:	c3                   	ret    

00801229 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	57                   	push   %edi
  80122d:	56                   	push   %esi
  80122e:	53                   	push   %ebx
  80122f:	83 ec 2c             	sub    $0x2c,%esp
  801232:	8b 75 08             	mov    0x8(%ebp),%esi
  801235:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801238:	8b 7d 10             	mov    0x10(%ebp),%edi
  80123b:	eb 12                	jmp    80124f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80123d:	85 c0                	test   %eax,%eax
  80123f:	0f 84 89 03 00 00    	je     8015ce <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801245:	83 ec 08             	sub    $0x8,%esp
  801248:	53                   	push   %ebx
  801249:	50                   	push   %eax
  80124a:	ff d6                	call   *%esi
  80124c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80124f:	83 c7 01             	add    $0x1,%edi
  801252:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801256:	83 f8 25             	cmp    $0x25,%eax
  801259:	75 e2                	jne    80123d <vprintfmt+0x14>
  80125b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80125f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801266:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80126d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801274:	ba 00 00 00 00       	mov    $0x0,%edx
  801279:	eb 07                	jmp    801282 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80127b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80127e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801282:	8d 47 01             	lea    0x1(%edi),%eax
  801285:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801288:	0f b6 07             	movzbl (%edi),%eax
  80128b:	0f b6 c8             	movzbl %al,%ecx
  80128e:	83 e8 23             	sub    $0x23,%eax
  801291:	3c 55                	cmp    $0x55,%al
  801293:	0f 87 1a 03 00 00    	ja     8015b3 <vprintfmt+0x38a>
  801299:	0f b6 c0             	movzbl %al,%eax
  80129c:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8012a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012a6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012aa:	eb d6                	jmp    801282 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012af:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012b7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012ba:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012be:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012c1:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012c4:	83 fa 09             	cmp    $0x9,%edx
  8012c7:	77 39                	ja     801302 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012c9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012cc:	eb e9                	jmp    8012b7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d1:	8d 48 04             	lea    0x4(%eax),%ecx
  8012d4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012d7:	8b 00                	mov    (%eax),%eax
  8012d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012df:	eb 27                	jmp    801308 <vprintfmt+0xdf>
  8012e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012eb:	0f 49 c8             	cmovns %eax,%ecx
  8012ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f4:	eb 8c                	jmp    801282 <vprintfmt+0x59>
  8012f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012f9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801300:	eb 80                	jmp    801282 <vprintfmt+0x59>
  801302:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801305:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801308:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80130c:	0f 89 70 ff ff ff    	jns    801282 <vprintfmt+0x59>
				width = precision, precision = -1;
  801312:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801315:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801318:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80131f:	e9 5e ff ff ff       	jmp    801282 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801324:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80132a:	e9 53 ff ff ff       	jmp    801282 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80132f:	8b 45 14             	mov    0x14(%ebp),%eax
  801332:	8d 50 04             	lea    0x4(%eax),%edx
  801335:	89 55 14             	mov    %edx,0x14(%ebp)
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	53                   	push   %ebx
  80133c:	ff 30                	pushl  (%eax)
  80133e:	ff d6                	call   *%esi
			break;
  801340:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801346:	e9 04 ff ff ff       	jmp    80124f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80134b:	8b 45 14             	mov    0x14(%ebp),%eax
  80134e:	8d 50 04             	lea    0x4(%eax),%edx
  801351:	89 55 14             	mov    %edx,0x14(%ebp)
  801354:	8b 00                	mov    (%eax),%eax
  801356:	99                   	cltd   
  801357:	31 d0                	xor    %edx,%eax
  801359:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80135b:	83 f8 0f             	cmp    $0xf,%eax
  80135e:	7f 0b                	jg     80136b <vprintfmt+0x142>
  801360:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  801367:	85 d2                	test   %edx,%edx
  801369:	75 18                	jne    801383 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80136b:	50                   	push   %eax
  80136c:	68 07 1f 80 00       	push   $0x801f07
  801371:	53                   	push   %ebx
  801372:	56                   	push   %esi
  801373:	e8 94 fe ff ff       	call   80120c <printfmt>
  801378:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80137e:	e9 cc fe ff ff       	jmp    80124f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801383:	52                   	push   %edx
  801384:	68 92 1e 80 00       	push   $0x801e92
  801389:	53                   	push   %ebx
  80138a:	56                   	push   %esi
  80138b:	e8 7c fe ff ff       	call   80120c <printfmt>
  801390:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801396:	e9 b4 fe ff ff       	jmp    80124f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80139b:	8b 45 14             	mov    0x14(%ebp),%eax
  80139e:	8d 50 04             	lea    0x4(%eax),%edx
  8013a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013a6:	85 ff                	test   %edi,%edi
  8013a8:	b8 00 1f 80 00       	mov    $0x801f00,%eax
  8013ad:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013b4:	0f 8e 94 00 00 00    	jle    80144e <vprintfmt+0x225>
  8013ba:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013be:	0f 84 98 00 00 00    	je     80145c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	ff 75 d0             	pushl  -0x30(%ebp)
  8013ca:	57                   	push   %edi
  8013cb:	e8 86 02 00 00       	call   801656 <strnlen>
  8013d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013d3:	29 c1                	sub    %eax,%ecx
  8013d5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013d8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013db:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013e2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013e5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e7:	eb 0f                	jmp    8013f8 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	53                   	push   %ebx
  8013ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8013f0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f2:	83 ef 01             	sub    $0x1,%edi
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	85 ff                	test   %edi,%edi
  8013fa:	7f ed                	jg     8013e9 <vprintfmt+0x1c0>
  8013fc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013ff:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801402:	85 c9                	test   %ecx,%ecx
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
  801409:	0f 49 c1             	cmovns %ecx,%eax
  80140c:	29 c1                	sub    %eax,%ecx
  80140e:	89 75 08             	mov    %esi,0x8(%ebp)
  801411:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801414:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801417:	89 cb                	mov    %ecx,%ebx
  801419:	eb 4d                	jmp    801468 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80141b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80141f:	74 1b                	je     80143c <vprintfmt+0x213>
  801421:	0f be c0             	movsbl %al,%eax
  801424:	83 e8 20             	sub    $0x20,%eax
  801427:	83 f8 5e             	cmp    $0x5e,%eax
  80142a:	76 10                	jbe    80143c <vprintfmt+0x213>
					putch('?', putdat);
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	ff 75 0c             	pushl  0xc(%ebp)
  801432:	6a 3f                	push   $0x3f
  801434:	ff 55 08             	call   *0x8(%ebp)
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	eb 0d                	jmp    801449 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80143c:	83 ec 08             	sub    $0x8,%esp
  80143f:	ff 75 0c             	pushl  0xc(%ebp)
  801442:	52                   	push   %edx
  801443:	ff 55 08             	call   *0x8(%ebp)
  801446:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801449:	83 eb 01             	sub    $0x1,%ebx
  80144c:	eb 1a                	jmp    801468 <vprintfmt+0x23f>
  80144e:	89 75 08             	mov    %esi,0x8(%ebp)
  801451:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801454:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801457:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80145a:	eb 0c                	jmp    801468 <vprintfmt+0x23f>
  80145c:	89 75 08             	mov    %esi,0x8(%ebp)
  80145f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801462:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801465:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801468:	83 c7 01             	add    $0x1,%edi
  80146b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80146f:	0f be d0             	movsbl %al,%edx
  801472:	85 d2                	test   %edx,%edx
  801474:	74 23                	je     801499 <vprintfmt+0x270>
  801476:	85 f6                	test   %esi,%esi
  801478:	78 a1                	js     80141b <vprintfmt+0x1f2>
  80147a:	83 ee 01             	sub    $0x1,%esi
  80147d:	79 9c                	jns    80141b <vprintfmt+0x1f2>
  80147f:	89 df                	mov    %ebx,%edi
  801481:	8b 75 08             	mov    0x8(%ebp),%esi
  801484:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801487:	eb 18                	jmp    8014a1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	53                   	push   %ebx
  80148d:	6a 20                	push   $0x20
  80148f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801491:	83 ef 01             	sub    $0x1,%edi
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	eb 08                	jmp    8014a1 <vprintfmt+0x278>
  801499:	89 df                	mov    %ebx,%edi
  80149b:	8b 75 08             	mov    0x8(%ebp),%esi
  80149e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a1:	85 ff                	test   %edi,%edi
  8014a3:	7f e4                	jg     801489 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014a8:	e9 a2 fd ff ff       	jmp    80124f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ad:	83 fa 01             	cmp    $0x1,%edx
  8014b0:	7e 16                	jle    8014c8 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b5:	8d 50 08             	lea    0x8(%eax),%edx
  8014b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8014bb:	8b 50 04             	mov    0x4(%eax),%edx
  8014be:	8b 00                	mov    (%eax),%eax
  8014c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014c6:	eb 32                	jmp    8014fa <vprintfmt+0x2d1>
	else if (lflag)
  8014c8:	85 d2                	test   %edx,%edx
  8014ca:	74 18                	je     8014e4 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cf:	8d 50 04             	lea    0x4(%eax),%edx
  8014d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d5:	8b 00                	mov    (%eax),%eax
  8014d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014da:	89 c1                	mov    %eax,%ecx
  8014dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8014df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e2:	eb 16                	jmp    8014fa <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e7:	8d 50 04             	lea    0x4(%eax),%edx
  8014ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ed:	8b 00                	mov    (%eax),%eax
  8014ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f2:	89 c1                	mov    %eax,%ecx
  8014f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014fd:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801500:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801505:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801509:	79 74                	jns    80157f <vprintfmt+0x356>
				putch('-', putdat);
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	53                   	push   %ebx
  80150f:	6a 2d                	push   $0x2d
  801511:	ff d6                	call   *%esi
				num = -(long long) num;
  801513:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801516:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801519:	f7 d8                	neg    %eax
  80151b:	83 d2 00             	adc    $0x0,%edx
  80151e:	f7 da                	neg    %edx
  801520:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801523:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801528:	eb 55                	jmp    80157f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80152a:	8d 45 14             	lea    0x14(%ebp),%eax
  80152d:	e8 83 fc ff ff       	call   8011b5 <getuint>
			base = 10;
  801532:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801537:	eb 46                	jmp    80157f <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801539:	8d 45 14             	lea    0x14(%ebp),%eax
  80153c:	e8 74 fc ff ff       	call   8011b5 <getuint>
			base = 8;
  801541:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801546:	eb 37                	jmp    80157f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	53                   	push   %ebx
  80154c:	6a 30                	push   $0x30
  80154e:	ff d6                	call   *%esi
			putch('x', putdat);
  801550:	83 c4 08             	add    $0x8,%esp
  801553:	53                   	push   %ebx
  801554:	6a 78                	push   $0x78
  801556:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801558:	8b 45 14             	mov    0x14(%ebp),%eax
  80155b:	8d 50 04             	lea    0x4(%eax),%edx
  80155e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801561:	8b 00                	mov    (%eax),%eax
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801568:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80156b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801570:	eb 0d                	jmp    80157f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801572:	8d 45 14             	lea    0x14(%ebp),%eax
  801575:	e8 3b fc ff ff       	call   8011b5 <getuint>
			base = 16;
  80157a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80157f:	83 ec 0c             	sub    $0xc,%esp
  801582:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801586:	57                   	push   %edi
  801587:	ff 75 e0             	pushl  -0x20(%ebp)
  80158a:	51                   	push   %ecx
  80158b:	52                   	push   %edx
  80158c:	50                   	push   %eax
  80158d:	89 da                	mov    %ebx,%edx
  80158f:	89 f0                	mov    %esi,%eax
  801591:	e8 70 fb ff ff       	call   801106 <printnum>
			break;
  801596:	83 c4 20             	add    $0x20,%esp
  801599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80159c:	e9 ae fc ff ff       	jmp    80124f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	51                   	push   %ecx
  8015a6:	ff d6                	call   *%esi
			break;
  8015a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ae:	e9 9c fc ff ff       	jmp    80124f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015b3:	83 ec 08             	sub    $0x8,%esp
  8015b6:	53                   	push   %ebx
  8015b7:	6a 25                	push   $0x25
  8015b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	eb 03                	jmp    8015c3 <vprintfmt+0x39a>
  8015c0:	83 ef 01             	sub    $0x1,%edi
  8015c3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015c7:	75 f7                	jne    8015c0 <vprintfmt+0x397>
  8015c9:	e9 81 fc ff ff       	jmp    80124f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5f                   	pop    %edi
  8015d4:	5d                   	pop    %ebp
  8015d5:	c3                   	ret    

008015d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	83 ec 18             	sub    $0x18,%esp
  8015dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	74 26                	je     80161d <vsnprintf+0x47>
  8015f7:	85 d2                	test   %edx,%edx
  8015f9:	7e 22                	jle    80161d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015fb:	ff 75 14             	pushl  0x14(%ebp)
  8015fe:	ff 75 10             	pushl  0x10(%ebp)
  801601:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801604:	50                   	push   %eax
  801605:	68 ef 11 80 00       	push   $0x8011ef
  80160a:	e8 1a fc ff ff       	call   801229 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80160f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801612:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801615:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	eb 05                	jmp    801622 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80161d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80162a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80162d:	50                   	push   %eax
  80162e:	ff 75 10             	pushl  0x10(%ebp)
  801631:	ff 75 0c             	pushl  0xc(%ebp)
  801634:	ff 75 08             	pushl  0x8(%ebp)
  801637:	e8 9a ff ff ff       	call   8015d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801644:	b8 00 00 00 00       	mov    $0x0,%eax
  801649:	eb 03                	jmp    80164e <strlen+0x10>
		n++;
  80164b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80164e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801652:	75 f7                	jne    80164b <strlen+0xd>
		n++;
	return n;
}
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    

00801656 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80165c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80165f:	ba 00 00 00 00       	mov    $0x0,%edx
  801664:	eb 03                	jmp    801669 <strnlen+0x13>
		n++;
  801666:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801669:	39 c2                	cmp    %eax,%edx
  80166b:	74 08                	je     801675 <strnlen+0x1f>
  80166d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801671:	75 f3                	jne    801666 <strnlen+0x10>
  801673:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801681:	89 c2                	mov    %eax,%edx
  801683:	83 c2 01             	add    $0x1,%edx
  801686:	83 c1 01             	add    $0x1,%ecx
  801689:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80168d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801690:	84 db                	test   %bl,%bl
  801692:	75 ef                	jne    801683 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801694:	5b                   	pop    %ebx
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80169e:	53                   	push   %ebx
  80169f:	e8 9a ff ff ff       	call   80163e <strlen>
  8016a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016a7:	ff 75 0c             	pushl  0xc(%ebp)
  8016aa:	01 d8                	add    %ebx,%eax
  8016ac:	50                   	push   %eax
  8016ad:	e8 c5 ff ff ff       	call   801677 <strcpy>
	return dst;
}
  8016b2:	89 d8                	mov    %ebx,%eax
  8016b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b7:	c9                   	leave  
  8016b8:	c3                   	ret    

008016b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	56                   	push   %esi
  8016bd:	53                   	push   %ebx
  8016be:	8b 75 08             	mov    0x8(%ebp),%esi
  8016c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c4:	89 f3                	mov    %esi,%ebx
  8016c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c9:	89 f2                	mov    %esi,%edx
  8016cb:	eb 0f                	jmp    8016dc <strncpy+0x23>
		*dst++ = *src;
  8016cd:	83 c2 01             	add    $0x1,%edx
  8016d0:	0f b6 01             	movzbl (%ecx),%eax
  8016d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8016d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016dc:	39 da                	cmp    %ebx,%edx
  8016de:	75 ed                	jne    8016cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016e0:	89 f0                	mov    %esi,%eax
  8016e2:	5b                   	pop    %ebx
  8016e3:	5e                   	pop    %esi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8016f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016f6:	85 d2                	test   %edx,%edx
  8016f8:	74 21                	je     80171b <strlcpy+0x35>
  8016fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8016fe:	89 f2                	mov    %esi,%edx
  801700:	eb 09                	jmp    80170b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801702:	83 c2 01             	add    $0x1,%edx
  801705:	83 c1 01             	add    $0x1,%ecx
  801708:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80170b:	39 c2                	cmp    %eax,%edx
  80170d:	74 09                	je     801718 <strlcpy+0x32>
  80170f:	0f b6 19             	movzbl (%ecx),%ebx
  801712:	84 db                	test   %bl,%bl
  801714:	75 ec                	jne    801702 <strlcpy+0x1c>
  801716:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801718:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80171b:	29 f0                	sub    %esi,%eax
}
  80171d:	5b                   	pop    %ebx
  80171e:	5e                   	pop    %esi
  80171f:	5d                   	pop    %ebp
  801720:	c3                   	ret    

00801721 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801727:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80172a:	eb 06                	jmp    801732 <strcmp+0x11>
		p++, q++;
  80172c:	83 c1 01             	add    $0x1,%ecx
  80172f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801732:	0f b6 01             	movzbl (%ecx),%eax
  801735:	84 c0                	test   %al,%al
  801737:	74 04                	je     80173d <strcmp+0x1c>
  801739:	3a 02                	cmp    (%edx),%al
  80173b:	74 ef                	je     80172c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80173d:	0f b6 c0             	movzbl %al,%eax
  801740:	0f b6 12             	movzbl (%edx),%edx
  801743:	29 d0                	sub    %edx,%eax
}
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	53                   	push   %ebx
  80174b:	8b 45 08             	mov    0x8(%ebp),%eax
  80174e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801751:	89 c3                	mov    %eax,%ebx
  801753:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801756:	eb 06                	jmp    80175e <strncmp+0x17>
		n--, p++, q++;
  801758:	83 c0 01             	add    $0x1,%eax
  80175b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80175e:	39 d8                	cmp    %ebx,%eax
  801760:	74 15                	je     801777 <strncmp+0x30>
  801762:	0f b6 08             	movzbl (%eax),%ecx
  801765:	84 c9                	test   %cl,%cl
  801767:	74 04                	je     80176d <strncmp+0x26>
  801769:	3a 0a                	cmp    (%edx),%cl
  80176b:	74 eb                	je     801758 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80176d:	0f b6 00             	movzbl (%eax),%eax
  801770:	0f b6 12             	movzbl (%edx),%edx
  801773:	29 d0                	sub    %edx,%eax
  801775:	eb 05                	jmp    80177c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801777:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80177c:	5b                   	pop    %ebx
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    

0080177f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	8b 45 08             	mov    0x8(%ebp),%eax
  801785:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801789:	eb 07                	jmp    801792 <strchr+0x13>
		if (*s == c)
  80178b:	38 ca                	cmp    %cl,%dl
  80178d:	74 0f                	je     80179e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80178f:	83 c0 01             	add    $0x1,%eax
  801792:	0f b6 10             	movzbl (%eax),%edx
  801795:	84 d2                	test   %dl,%dl
  801797:	75 f2                	jne    80178b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801799:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017aa:	eb 03                	jmp    8017af <strfind+0xf>
  8017ac:	83 c0 01             	add    $0x1,%eax
  8017af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017b2:	38 ca                	cmp    %cl,%dl
  8017b4:	74 04                	je     8017ba <strfind+0x1a>
  8017b6:	84 d2                	test   %dl,%dl
  8017b8:	75 f2                	jne    8017ac <strfind+0xc>
			break;
	return (char *) s;
}
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	57                   	push   %edi
  8017c0:	56                   	push   %esi
  8017c1:	53                   	push   %ebx
  8017c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017c8:	85 c9                	test   %ecx,%ecx
  8017ca:	74 36                	je     801802 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017d2:	75 28                	jne    8017fc <memset+0x40>
  8017d4:	f6 c1 03             	test   $0x3,%cl
  8017d7:	75 23                	jne    8017fc <memset+0x40>
		c &= 0xFF;
  8017d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017dd:	89 d3                	mov    %edx,%ebx
  8017df:	c1 e3 08             	shl    $0x8,%ebx
  8017e2:	89 d6                	mov    %edx,%esi
  8017e4:	c1 e6 18             	shl    $0x18,%esi
  8017e7:	89 d0                	mov    %edx,%eax
  8017e9:	c1 e0 10             	shl    $0x10,%eax
  8017ec:	09 f0                	or     %esi,%eax
  8017ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8017f0:	89 d8                	mov    %ebx,%eax
  8017f2:	09 d0                	or     %edx,%eax
  8017f4:	c1 e9 02             	shr    $0x2,%ecx
  8017f7:	fc                   	cld    
  8017f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8017fa:	eb 06                	jmp    801802 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ff:	fc                   	cld    
  801800:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801802:	89 f8                	mov    %edi,%eax
  801804:	5b                   	pop    %ebx
  801805:	5e                   	pop    %esi
  801806:	5f                   	pop    %edi
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	57                   	push   %edi
  80180d:	56                   	push   %esi
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	8b 75 0c             	mov    0xc(%ebp),%esi
  801814:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801817:	39 c6                	cmp    %eax,%esi
  801819:	73 35                	jae    801850 <memmove+0x47>
  80181b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80181e:	39 d0                	cmp    %edx,%eax
  801820:	73 2e                	jae    801850 <memmove+0x47>
		s += n;
		d += n;
  801822:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801825:	89 d6                	mov    %edx,%esi
  801827:	09 fe                	or     %edi,%esi
  801829:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80182f:	75 13                	jne    801844 <memmove+0x3b>
  801831:	f6 c1 03             	test   $0x3,%cl
  801834:	75 0e                	jne    801844 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801836:	83 ef 04             	sub    $0x4,%edi
  801839:	8d 72 fc             	lea    -0x4(%edx),%esi
  80183c:	c1 e9 02             	shr    $0x2,%ecx
  80183f:	fd                   	std    
  801840:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801842:	eb 09                	jmp    80184d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801844:	83 ef 01             	sub    $0x1,%edi
  801847:	8d 72 ff             	lea    -0x1(%edx),%esi
  80184a:	fd                   	std    
  80184b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80184d:	fc                   	cld    
  80184e:	eb 1d                	jmp    80186d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801850:	89 f2                	mov    %esi,%edx
  801852:	09 c2                	or     %eax,%edx
  801854:	f6 c2 03             	test   $0x3,%dl
  801857:	75 0f                	jne    801868 <memmove+0x5f>
  801859:	f6 c1 03             	test   $0x3,%cl
  80185c:	75 0a                	jne    801868 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80185e:	c1 e9 02             	shr    $0x2,%ecx
  801861:	89 c7                	mov    %eax,%edi
  801863:	fc                   	cld    
  801864:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801866:	eb 05                	jmp    80186d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801868:	89 c7                	mov    %eax,%edi
  80186a:	fc                   	cld    
  80186b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80186d:	5e                   	pop    %esi
  80186e:	5f                   	pop    %edi
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801874:	ff 75 10             	pushl  0x10(%ebp)
  801877:	ff 75 0c             	pushl  0xc(%ebp)
  80187a:	ff 75 08             	pushl  0x8(%ebp)
  80187d:	e8 87 ff ff ff       	call   801809 <memmove>
}
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	56                   	push   %esi
  801888:	53                   	push   %ebx
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188f:	89 c6                	mov    %eax,%esi
  801891:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801894:	eb 1a                	jmp    8018b0 <memcmp+0x2c>
		if (*s1 != *s2)
  801896:	0f b6 08             	movzbl (%eax),%ecx
  801899:	0f b6 1a             	movzbl (%edx),%ebx
  80189c:	38 d9                	cmp    %bl,%cl
  80189e:	74 0a                	je     8018aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018a0:	0f b6 c1             	movzbl %cl,%eax
  8018a3:	0f b6 db             	movzbl %bl,%ebx
  8018a6:	29 d8                	sub    %ebx,%eax
  8018a8:	eb 0f                	jmp    8018b9 <memcmp+0x35>
		s1++, s2++;
  8018aa:	83 c0 01             	add    $0x1,%eax
  8018ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018b0:	39 f0                	cmp    %esi,%eax
  8018b2:	75 e2                	jne    801896 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b9:	5b                   	pop    %ebx
  8018ba:	5e                   	pop    %esi
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	53                   	push   %ebx
  8018c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018c4:	89 c1                	mov    %eax,%ecx
  8018c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018cd:	eb 0a                	jmp    8018d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018cf:	0f b6 10             	movzbl (%eax),%edx
  8018d2:	39 da                	cmp    %ebx,%edx
  8018d4:	74 07                	je     8018dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018d6:	83 c0 01             	add    $0x1,%eax
  8018d9:	39 c8                	cmp    %ecx,%eax
  8018db:	72 f2                	jb     8018cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018dd:	5b                   	pop    %ebx
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	57                   	push   %edi
  8018e4:	56                   	push   %esi
  8018e5:	53                   	push   %ebx
  8018e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018ec:	eb 03                	jmp    8018f1 <strtol+0x11>
		s++;
  8018ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018f1:	0f b6 01             	movzbl (%ecx),%eax
  8018f4:	3c 20                	cmp    $0x20,%al
  8018f6:	74 f6                	je     8018ee <strtol+0xe>
  8018f8:	3c 09                	cmp    $0x9,%al
  8018fa:	74 f2                	je     8018ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8018fc:	3c 2b                	cmp    $0x2b,%al
  8018fe:	75 0a                	jne    80190a <strtol+0x2a>
		s++;
  801900:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801903:	bf 00 00 00 00       	mov    $0x0,%edi
  801908:	eb 11                	jmp    80191b <strtol+0x3b>
  80190a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80190f:	3c 2d                	cmp    $0x2d,%al
  801911:	75 08                	jne    80191b <strtol+0x3b>
		s++, neg = 1;
  801913:	83 c1 01             	add    $0x1,%ecx
  801916:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80191b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801921:	75 15                	jne    801938 <strtol+0x58>
  801923:	80 39 30             	cmpb   $0x30,(%ecx)
  801926:	75 10                	jne    801938 <strtol+0x58>
  801928:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80192c:	75 7c                	jne    8019aa <strtol+0xca>
		s += 2, base = 16;
  80192e:	83 c1 02             	add    $0x2,%ecx
  801931:	bb 10 00 00 00       	mov    $0x10,%ebx
  801936:	eb 16                	jmp    80194e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801938:	85 db                	test   %ebx,%ebx
  80193a:	75 12                	jne    80194e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80193c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801941:	80 39 30             	cmpb   $0x30,(%ecx)
  801944:	75 08                	jne    80194e <strtol+0x6e>
		s++, base = 8;
  801946:	83 c1 01             	add    $0x1,%ecx
  801949:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80194e:	b8 00 00 00 00       	mov    $0x0,%eax
  801953:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801956:	0f b6 11             	movzbl (%ecx),%edx
  801959:	8d 72 d0             	lea    -0x30(%edx),%esi
  80195c:	89 f3                	mov    %esi,%ebx
  80195e:	80 fb 09             	cmp    $0x9,%bl
  801961:	77 08                	ja     80196b <strtol+0x8b>
			dig = *s - '0';
  801963:	0f be d2             	movsbl %dl,%edx
  801966:	83 ea 30             	sub    $0x30,%edx
  801969:	eb 22                	jmp    80198d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80196b:	8d 72 9f             	lea    -0x61(%edx),%esi
  80196e:	89 f3                	mov    %esi,%ebx
  801970:	80 fb 19             	cmp    $0x19,%bl
  801973:	77 08                	ja     80197d <strtol+0x9d>
			dig = *s - 'a' + 10;
  801975:	0f be d2             	movsbl %dl,%edx
  801978:	83 ea 57             	sub    $0x57,%edx
  80197b:	eb 10                	jmp    80198d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80197d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801980:	89 f3                	mov    %esi,%ebx
  801982:	80 fb 19             	cmp    $0x19,%bl
  801985:	77 16                	ja     80199d <strtol+0xbd>
			dig = *s - 'A' + 10;
  801987:	0f be d2             	movsbl %dl,%edx
  80198a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80198d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801990:	7d 0b                	jge    80199d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801992:	83 c1 01             	add    $0x1,%ecx
  801995:	0f af 45 10          	imul   0x10(%ebp),%eax
  801999:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80199b:	eb b9                	jmp    801956 <strtol+0x76>

	if (endptr)
  80199d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019a1:	74 0d                	je     8019b0 <strtol+0xd0>
		*endptr = (char *) s;
  8019a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019a6:	89 0e                	mov    %ecx,(%esi)
  8019a8:	eb 06                	jmp    8019b0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019aa:	85 db                	test   %ebx,%ebx
  8019ac:	74 98                	je     801946 <strtol+0x66>
  8019ae:	eb 9e                	jmp    80194e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019b0:	89 c2                	mov    %eax,%edx
  8019b2:	f7 da                	neg    %edx
  8019b4:	85 ff                	test   %edi,%edi
  8019b6:	0f 45 c2             	cmovne %edx,%eax
}
  8019b9:	5b                   	pop    %ebx
  8019ba:	5e                   	pop    %esi
  8019bb:	5f                   	pop    %edi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019cc:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019ce:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019d3:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	50                   	push   %eax
  8019da:	e8 3b e9 ff ff       	call   80031a <sys_ipc_recv>

	if (from_env_store != NULL)
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	85 f6                	test   %esi,%esi
  8019e4:	74 14                	je     8019fa <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 09                	js     8019f8 <ipc_recv+0x3a>
  8019ef:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019f5:	8b 52 74             	mov    0x74(%edx),%edx
  8019f8:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8019fa:	85 db                	test   %ebx,%ebx
  8019fc:	74 14                	je     801a12 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8019fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 09                	js     801a10 <ipc_recv+0x52>
  801a07:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a0d:	8b 52 78             	mov    0x78(%edx),%edx
  801a10:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 08                	js     801a1e <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a16:	a1 04 40 80 00       	mov    0x804004,%eax
  801a1b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5e                   	pop    %esi
  801a23:	5d                   	pop    %ebp
  801a24:	c3                   	ret    

00801a25 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	57                   	push   %edi
  801a29:	56                   	push   %esi
  801a2a:	53                   	push   %ebx
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a31:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a37:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a39:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a3e:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a41:	ff 75 14             	pushl  0x14(%ebp)
  801a44:	53                   	push   %ebx
  801a45:	56                   	push   %esi
  801a46:	57                   	push   %edi
  801a47:	e8 ab e8 ff ff       	call   8002f7 <sys_ipc_try_send>

		if (err < 0) {
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	79 1e                	jns    801a71 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a53:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a56:	75 07                	jne    801a5f <ipc_send+0x3a>
				sys_yield();
  801a58:	e8 ee e6 ff ff       	call   80014b <sys_yield>
  801a5d:	eb e2                	jmp    801a41 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a5f:	50                   	push   %eax
  801a60:	68 00 22 80 00       	push   $0x802200
  801a65:	6a 49                	push   $0x49
  801a67:	68 0d 22 80 00       	push   $0x80220d
  801a6c:	e8 a8 f5 ff ff       	call   801019 <_panic>
		}

	} while (err < 0);

}
  801a71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5f                   	pop    %edi
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a7f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a84:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a87:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a8d:	8b 52 50             	mov    0x50(%edx),%edx
  801a90:	39 ca                	cmp    %ecx,%edx
  801a92:	75 0d                	jne    801aa1 <ipc_find_env+0x28>
			return envs[i].env_id;
  801a94:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a97:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a9c:	8b 40 48             	mov    0x48(%eax),%eax
  801a9f:	eb 0f                	jmp    801ab0 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aa1:	83 c0 01             	add    $0x1,%eax
  801aa4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aa9:	75 d9                	jne    801a84 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab0:	5d                   	pop    %ebp
  801ab1:	c3                   	ret    

00801ab2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ab8:	89 d0                	mov    %edx,%eax
  801aba:	c1 e8 16             	shr    $0x16,%eax
  801abd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ac9:	f6 c1 01             	test   $0x1,%cl
  801acc:	74 1d                	je     801aeb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ace:	c1 ea 0c             	shr    $0xc,%edx
  801ad1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ad8:	f6 c2 01             	test   $0x1,%dl
  801adb:	74 0e                	je     801aeb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801add:	c1 ea 0c             	shr    $0xc,%edx
  801ae0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ae7:	ef 
  801ae8:	0f b7 c0             	movzwl %ax,%eax
}
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    
  801aed:	66 90                	xchg   %ax,%ax
  801aef:	90                   	nop

00801af0 <__udivdi3>:
  801af0:	55                   	push   %ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 1c             	sub    $0x1c,%esp
  801af7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801afb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801aff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b07:	85 f6                	test   %esi,%esi
  801b09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b0d:	89 ca                	mov    %ecx,%edx
  801b0f:	89 f8                	mov    %edi,%eax
  801b11:	75 3d                	jne    801b50 <__udivdi3+0x60>
  801b13:	39 cf                	cmp    %ecx,%edi
  801b15:	0f 87 c5 00 00 00    	ja     801be0 <__udivdi3+0xf0>
  801b1b:	85 ff                	test   %edi,%edi
  801b1d:	89 fd                	mov    %edi,%ebp
  801b1f:	75 0b                	jne    801b2c <__udivdi3+0x3c>
  801b21:	b8 01 00 00 00       	mov    $0x1,%eax
  801b26:	31 d2                	xor    %edx,%edx
  801b28:	f7 f7                	div    %edi
  801b2a:	89 c5                	mov    %eax,%ebp
  801b2c:	89 c8                	mov    %ecx,%eax
  801b2e:	31 d2                	xor    %edx,%edx
  801b30:	f7 f5                	div    %ebp
  801b32:	89 c1                	mov    %eax,%ecx
  801b34:	89 d8                	mov    %ebx,%eax
  801b36:	89 cf                	mov    %ecx,%edi
  801b38:	f7 f5                	div    %ebp
  801b3a:	89 c3                	mov    %eax,%ebx
  801b3c:	89 d8                	mov    %ebx,%eax
  801b3e:	89 fa                	mov    %edi,%edx
  801b40:	83 c4 1c             	add    $0x1c,%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	5f                   	pop    %edi
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    
  801b48:	90                   	nop
  801b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b50:	39 ce                	cmp    %ecx,%esi
  801b52:	77 74                	ja     801bc8 <__udivdi3+0xd8>
  801b54:	0f bd fe             	bsr    %esi,%edi
  801b57:	83 f7 1f             	xor    $0x1f,%edi
  801b5a:	0f 84 98 00 00 00    	je     801bf8 <__udivdi3+0x108>
  801b60:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b65:	89 f9                	mov    %edi,%ecx
  801b67:	89 c5                	mov    %eax,%ebp
  801b69:	29 fb                	sub    %edi,%ebx
  801b6b:	d3 e6                	shl    %cl,%esi
  801b6d:	89 d9                	mov    %ebx,%ecx
  801b6f:	d3 ed                	shr    %cl,%ebp
  801b71:	89 f9                	mov    %edi,%ecx
  801b73:	d3 e0                	shl    %cl,%eax
  801b75:	09 ee                	or     %ebp,%esi
  801b77:	89 d9                	mov    %ebx,%ecx
  801b79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b7d:	89 d5                	mov    %edx,%ebp
  801b7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b83:	d3 ed                	shr    %cl,%ebp
  801b85:	89 f9                	mov    %edi,%ecx
  801b87:	d3 e2                	shl    %cl,%edx
  801b89:	89 d9                	mov    %ebx,%ecx
  801b8b:	d3 e8                	shr    %cl,%eax
  801b8d:	09 c2                	or     %eax,%edx
  801b8f:	89 d0                	mov    %edx,%eax
  801b91:	89 ea                	mov    %ebp,%edx
  801b93:	f7 f6                	div    %esi
  801b95:	89 d5                	mov    %edx,%ebp
  801b97:	89 c3                	mov    %eax,%ebx
  801b99:	f7 64 24 0c          	mull   0xc(%esp)
  801b9d:	39 d5                	cmp    %edx,%ebp
  801b9f:	72 10                	jb     801bb1 <__udivdi3+0xc1>
  801ba1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	d3 e6                	shl    %cl,%esi
  801ba9:	39 c6                	cmp    %eax,%esi
  801bab:	73 07                	jae    801bb4 <__udivdi3+0xc4>
  801bad:	39 d5                	cmp    %edx,%ebp
  801baf:	75 03                	jne    801bb4 <__udivdi3+0xc4>
  801bb1:	83 eb 01             	sub    $0x1,%ebx
  801bb4:	31 ff                	xor    %edi,%edi
  801bb6:	89 d8                	mov    %ebx,%eax
  801bb8:	89 fa                	mov    %edi,%edx
  801bba:	83 c4 1c             	add    $0x1c,%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    
  801bc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc8:	31 ff                	xor    %edi,%edi
  801bca:	31 db                	xor    %ebx,%ebx
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	89 fa                	mov    %edi,%edx
  801bd0:	83 c4 1c             	add    $0x1c,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	90                   	nop
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 d8                	mov    %ebx,%eax
  801be2:	f7 f7                	div    %edi
  801be4:	31 ff                	xor    %edi,%edi
  801be6:	89 c3                	mov    %eax,%ebx
  801be8:	89 d8                	mov    %ebx,%eax
  801bea:	89 fa                	mov    %edi,%edx
  801bec:	83 c4 1c             	add    $0x1c,%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5e                   	pop    %esi
  801bf1:	5f                   	pop    %edi
  801bf2:	5d                   	pop    %ebp
  801bf3:	c3                   	ret    
  801bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	39 ce                	cmp    %ecx,%esi
  801bfa:	72 0c                	jb     801c08 <__udivdi3+0x118>
  801bfc:	31 db                	xor    %ebx,%ebx
  801bfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c02:	0f 87 34 ff ff ff    	ja     801b3c <__udivdi3+0x4c>
  801c08:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c0d:	e9 2a ff ff ff       	jmp    801b3c <__udivdi3+0x4c>
  801c12:	66 90                	xchg   %ax,%ax
  801c14:	66 90                	xchg   %ax,%ax
  801c16:	66 90                	xchg   %ax,%ax
  801c18:	66 90                	xchg   %ax,%ax
  801c1a:	66 90                	xchg   %ax,%ax
  801c1c:	66 90                	xchg   %ax,%ax
  801c1e:	66 90                	xchg   %ax,%ax

00801c20 <__umoddi3>:
  801c20:	55                   	push   %ebp
  801c21:	57                   	push   %edi
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 1c             	sub    $0x1c,%esp
  801c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c37:	85 d2                	test   %edx,%edx
  801c39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c41:	89 f3                	mov    %esi,%ebx
  801c43:	89 3c 24             	mov    %edi,(%esp)
  801c46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c4a:	75 1c                	jne    801c68 <__umoddi3+0x48>
  801c4c:	39 f7                	cmp    %esi,%edi
  801c4e:	76 50                	jbe    801ca0 <__umoddi3+0x80>
  801c50:	89 c8                	mov    %ecx,%eax
  801c52:	89 f2                	mov    %esi,%edx
  801c54:	f7 f7                	div    %edi
  801c56:	89 d0                	mov    %edx,%eax
  801c58:	31 d2                	xor    %edx,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	39 f2                	cmp    %esi,%edx
  801c6a:	89 d0                	mov    %edx,%eax
  801c6c:	77 52                	ja     801cc0 <__umoddi3+0xa0>
  801c6e:	0f bd ea             	bsr    %edx,%ebp
  801c71:	83 f5 1f             	xor    $0x1f,%ebp
  801c74:	75 5a                	jne    801cd0 <__umoddi3+0xb0>
  801c76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c7a:	0f 82 e0 00 00 00    	jb     801d60 <__umoddi3+0x140>
  801c80:	39 0c 24             	cmp    %ecx,(%esp)
  801c83:	0f 86 d7 00 00 00    	jbe    801d60 <__umoddi3+0x140>
  801c89:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c91:	83 c4 1c             	add    $0x1c,%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5f                   	pop    %edi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	85 ff                	test   %edi,%edi
  801ca2:	89 fd                	mov    %edi,%ebp
  801ca4:	75 0b                	jne    801cb1 <__umoddi3+0x91>
  801ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	f7 f7                	div    %edi
  801caf:	89 c5                	mov    %eax,%ebp
  801cb1:	89 f0                	mov    %esi,%eax
  801cb3:	31 d2                	xor    %edx,%edx
  801cb5:	f7 f5                	div    %ebp
  801cb7:	89 c8                	mov    %ecx,%eax
  801cb9:	f7 f5                	div    %ebp
  801cbb:	89 d0                	mov    %edx,%eax
  801cbd:	eb 99                	jmp    801c58 <__umoddi3+0x38>
  801cbf:	90                   	nop
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	83 c4 1c             	add    $0x1c,%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    
  801ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	8b 34 24             	mov    (%esp),%esi
  801cd3:	bf 20 00 00 00       	mov    $0x20,%edi
  801cd8:	89 e9                	mov    %ebp,%ecx
  801cda:	29 ef                	sub    %ebp,%edi
  801cdc:	d3 e0                	shl    %cl,%eax
  801cde:	89 f9                	mov    %edi,%ecx
  801ce0:	89 f2                	mov    %esi,%edx
  801ce2:	d3 ea                	shr    %cl,%edx
  801ce4:	89 e9                	mov    %ebp,%ecx
  801ce6:	09 c2                	or     %eax,%edx
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	89 14 24             	mov    %edx,(%esp)
  801ced:	89 f2                	mov    %esi,%edx
  801cef:	d3 e2                	shl    %cl,%edx
  801cf1:	89 f9                	mov    %edi,%ecx
  801cf3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cf7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801cfb:	d3 e8                	shr    %cl,%eax
  801cfd:	89 e9                	mov    %ebp,%ecx
  801cff:	89 c6                	mov    %eax,%esi
  801d01:	d3 e3                	shl    %cl,%ebx
  801d03:	89 f9                	mov    %edi,%ecx
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	d3 e8                	shr    %cl,%eax
  801d09:	89 e9                	mov    %ebp,%ecx
  801d0b:	09 d8                	or     %ebx,%eax
  801d0d:	89 d3                	mov    %edx,%ebx
  801d0f:	89 f2                	mov    %esi,%edx
  801d11:	f7 34 24             	divl   (%esp)
  801d14:	89 d6                	mov    %edx,%esi
  801d16:	d3 e3                	shl    %cl,%ebx
  801d18:	f7 64 24 04          	mull   0x4(%esp)
  801d1c:	39 d6                	cmp    %edx,%esi
  801d1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d22:	89 d1                	mov    %edx,%ecx
  801d24:	89 c3                	mov    %eax,%ebx
  801d26:	72 08                	jb     801d30 <__umoddi3+0x110>
  801d28:	75 11                	jne    801d3b <__umoddi3+0x11b>
  801d2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d2e:	73 0b                	jae    801d3b <__umoddi3+0x11b>
  801d30:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d34:	1b 14 24             	sbb    (%esp),%edx
  801d37:	89 d1                	mov    %edx,%ecx
  801d39:	89 c3                	mov    %eax,%ebx
  801d3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d3f:	29 da                	sub    %ebx,%edx
  801d41:	19 ce                	sbb    %ecx,%esi
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	89 f0                	mov    %esi,%eax
  801d47:	d3 e0                	shl    %cl,%eax
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	d3 ea                	shr    %cl,%edx
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	d3 ee                	shr    %cl,%esi
  801d51:	09 d0                	or     %edx,%eax
  801d53:	89 f2                	mov    %esi,%edx
  801d55:	83 c4 1c             	add    $0x1c,%esp
  801d58:	5b                   	pop    %ebx
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    
  801d5d:	8d 76 00             	lea    0x0(%esi),%esi
  801d60:	29 f9                	sub    %edi,%ecx
  801d62:	19 d6                	sbb    %edx,%esi
  801d64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d6c:	e9 18 ff ff ff       	jmp    801c89 <__umoddi3+0x69>
