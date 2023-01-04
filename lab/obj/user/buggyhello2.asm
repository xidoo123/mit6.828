
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
  800113:	68 b8 1d 80 00       	push   $0x801db8
  800118:	6a 23                	push   $0x23
  80011a:	68 d5 1d 80 00       	push   $0x801dd5
  80011f:	e8 14 0f 00 00       	call   801038 <_panic>

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
  800194:	68 b8 1d 80 00       	push   $0x801db8
  800199:	6a 23                	push   $0x23
  80019b:	68 d5 1d 80 00       	push   $0x801dd5
  8001a0:	e8 93 0e 00 00       	call   801038 <_panic>

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
  8001d6:	68 b8 1d 80 00       	push   $0x801db8
  8001db:	6a 23                	push   $0x23
  8001dd:	68 d5 1d 80 00       	push   $0x801dd5
  8001e2:	e8 51 0e 00 00       	call   801038 <_panic>

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
  800218:	68 b8 1d 80 00       	push   $0x801db8
  80021d:	6a 23                	push   $0x23
  80021f:	68 d5 1d 80 00       	push   $0x801dd5
  800224:	e8 0f 0e 00 00       	call   801038 <_panic>

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
  80025a:	68 b8 1d 80 00       	push   $0x801db8
  80025f:	6a 23                	push   $0x23
  800261:	68 d5 1d 80 00       	push   $0x801dd5
  800266:	e8 cd 0d 00 00       	call   801038 <_panic>

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
  80029c:	68 b8 1d 80 00       	push   $0x801db8
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 d5 1d 80 00       	push   $0x801dd5
  8002a8:	e8 8b 0d 00 00       	call   801038 <_panic>

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
  8002de:	68 b8 1d 80 00       	push   $0x801db8
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 d5 1d 80 00       	push   $0x801dd5
  8002ea:	e8 49 0d 00 00       	call   801038 <_panic>

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
  800342:	68 b8 1d 80 00       	push   $0x801db8
  800347:	6a 23                	push   $0x23
  800349:	68 d5 1d 80 00       	push   $0x801dd5
  80034e:	e8 e5 0c 00 00       	call   801038 <_panic>

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
  800430:	ba 60 1e 80 00       	mov    $0x801e60,%edx
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
  80045d:	68 e4 1d 80 00       	push   $0x801de4
  800462:	e8 aa 0c 00 00       	call   801111 <cprintf>
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
  800687:	68 25 1e 80 00       	push   $0x801e25
  80068c:	e8 80 0a 00 00       	call   801111 <cprintf>
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
  80075c:	68 41 1e 80 00       	push   $0x801e41
  800761:	e8 ab 09 00 00       	call   801111 <cprintf>
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
  800811:	68 04 1e 80 00       	push   $0x801e04
  800816:	e8 f6 08 00 00       	call   801111 <cprintf>
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
  8008da:	e8 d6 01 00 00       	call   800ab5 <open>
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
  800921:	e8 72 11 00 00       	call   801a98 <ipc_find_env>
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
  80093c:	e8 03 11 00 00       	call   801a44 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 8f 10 00 00       	call   8019dd <ipc_recv>
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
  8009d2:	e8 bf 0c 00 00       	call   801696 <strcpy>
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
  800a00:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
  800a06:	8b 52 0c             	mov    0xc(%edx),%edx
  800a09:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a0f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a14:	50                   	push   %eax
  800a15:	ff 75 0c             	pushl  0xc(%ebp)
  800a18:	68 08 50 80 00       	push   $0x805008
  800a1d:	e8 06 0e 00 00       	call   801828 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2c:	e8 d9 fe ff ff       	call   80090a <fsipc>

}
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a41:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a46:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a51:	b8 03 00 00 00       	mov    $0x3,%eax
  800a56:	e8 af fe ff ff       	call   80090a <fsipc>
  800a5b:	89 c3                	mov    %eax,%ebx
  800a5d:	85 c0                	test   %eax,%eax
  800a5f:	78 4b                	js     800aac <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a61:	39 c6                	cmp    %eax,%esi
  800a63:	73 16                	jae    800a7b <devfile_read+0x48>
  800a65:	68 70 1e 80 00       	push   $0x801e70
  800a6a:	68 77 1e 80 00       	push   $0x801e77
  800a6f:	6a 7c                	push   $0x7c
  800a71:	68 8c 1e 80 00       	push   $0x801e8c
  800a76:	e8 bd 05 00 00       	call   801038 <_panic>
	assert(r <= PGSIZE);
  800a7b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a80:	7e 16                	jle    800a98 <devfile_read+0x65>
  800a82:	68 97 1e 80 00       	push   $0x801e97
  800a87:	68 77 1e 80 00       	push   $0x801e77
  800a8c:	6a 7d                	push   $0x7d
  800a8e:	68 8c 1e 80 00       	push   $0x801e8c
  800a93:	e8 a0 05 00 00       	call   801038 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a98:	83 ec 04             	sub    $0x4,%esp
  800a9b:	50                   	push   %eax
  800a9c:	68 00 50 80 00       	push   $0x805000
  800aa1:	ff 75 0c             	pushl  0xc(%ebp)
  800aa4:	e8 7f 0d 00 00       	call   801828 <memmove>
	return r;
  800aa9:	83 c4 10             	add    $0x10,%esp
}
  800aac:	89 d8                	mov    %ebx,%eax
  800aae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	53                   	push   %ebx
  800ab9:	83 ec 20             	sub    $0x20,%esp
  800abc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800abf:	53                   	push   %ebx
  800ac0:	e8 98 0b 00 00       	call   80165d <strlen>
  800ac5:	83 c4 10             	add    $0x10,%esp
  800ac8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800acd:	7f 67                	jg     800b36 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800acf:	83 ec 0c             	sub    $0xc,%esp
  800ad2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad5:	50                   	push   %eax
  800ad6:	e8 a7 f8 ff ff       	call   800382 <fd_alloc>
  800adb:	83 c4 10             	add    $0x10,%esp
		return r;
  800ade:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae0:	85 c0                	test   %eax,%eax
  800ae2:	78 57                	js     800b3b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae4:	83 ec 08             	sub    $0x8,%esp
  800ae7:	53                   	push   %ebx
  800ae8:	68 00 50 80 00       	push   $0x805000
  800aed:	e8 a4 0b 00 00       	call   801696 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800afd:	b8 01 00 00 00       	mov    $0x1,%eax
  800b02:	e8 03 fe ff ff       	call   80090a <fsipc>
  800b07:	89 c3                	mov    %eax,%ebx
  800b09:	83 c4 10             	add    $0x10,%esp
  800b0c:	85 c0                	test   %eax,%eax
  800b0e:	79 14                	jns    800b24 <open+0x6f>
		fd_close(fd, 0);
  800b10:	83 ec 08             	sub    $0x8,%esp
  800b13:	6a 00                	push   $0x0
  800b15:	ff 75 f4             	pushl  -0xc(%ebp)
  800b18:	e8 5d f9 ff ff       	call   80047a <fd_close>
		return r;
  800b1d:	83 c4 10             	add    $0x10,%esp
  800b20:	89 da                	mov    %ebx,%edx
  800b22:	eb 17                	jmp    800b3b <open+0x86>
	}

	return fd2num(fd);
  800b24:	83 ec 0c             	sub    $0xc,%esp
  800b27:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2a:	e8 2c f8 ff ff       	call   80035b <fd2num>
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	83 c4 10             	add    $0x10,%esp
  800b34:	eb 05                	jmp    800b3b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b36:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b3b:	89 d0                	mov    %edx,%eax
  800b3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b40:	c9                   	leave  
  800b41:	c3                   	ret    

00800b42 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b52:	e8 b3 fd ff ff       	call   80090a <fsipc>
}
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	ff 75 08             	pushl  0x8(%ebp)
  800b67:	e8 ff f7 ff ff       	call   80036b <fd2data>
  800b6c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6e:	83 c4 08             	add    $0x8,%esp
  800b71:	68 a3 1e 80 00       	push   $0x801ea3
  800b76:	53                   	push   %ebx
  800b77:	e8 1a 0b 00 00       	call   801696 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b7c:	8b 46 04             	mov    0x4(%esi),%eax
  800b7f:	2b 06                	sub    (%esi),%eax
  800b81:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b87:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8e:	00 00 00 
	stat->st_dev = &devpipe;
  800b91:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800b98:	30 80 00 
	return 0;
}
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	53                   	push   %ebx
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb1:	53                   	push   %ebx
  800bb2:	6a 00                	push   $0x0
  800bb4:	e8 36 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb9:	89 1c 24             	mov    %ebx,(%esp)
  800bbc:	e8 aa f7 ff ff       	call   80036b <fd2data>
  800bc1:	83 c4 08             	add    $0x8,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 00                	push   $0x0
  800bc7:	e8 23 f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bcc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 1c             	sub    $0x1c,%esp
  800bda:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bdd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bdf:	a1 04 40 80 00       	mov    0x804004,%eax
  800be4:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	ff 75 e0             	pushl  -0x20(%ebp)
  800bed:	e8 df 0e 00 00       	call   801ad1 <pageref>
  800bf2:	89 c3                	mov    %eax,%ebx
  800bf4:	89 3c 24             	mov    %edi,(%esp)
  800bf7:	e8 d5 0e 00 00       	call   801ad1 <pageref>
  800bfc:	83 c4 10             	add    $0x10,%esp
  800bff:	39 c3                	cmp    %eax,%ebx
  800c01:	0f 94 c1             	sete   %cl
  800c04:	0f b6 c9             	movzbl %cl,%ecx
  800c07:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c0a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c10:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c13:	39 ce                	cmp    %ecx,%esi
  800c15:	74 1b                	je     800c32 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c17:	39 c3                	cmp    %eax,%ebx
  800c19:	75 c4                	jne    800bdf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c1b:	8b 42 58             	mov    0x58(%edx),%eax
  800c1e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c21:	50                   	push   %eax
  800c22:	56                   	push   %esi
  800c23:	68 aa 1e 80 00       	push   $0x801eaa
  800c28:	e8 e4 04 00 00       	call   801111 <cprintf>
  800c2d:	83 c4 10             	add    $0x10,%esp
  800c30:	eb ad                	jmp    800bdf <_pipeisclosed+0xe>
	}
}
  800c32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 28             	sub    $0x28,%esp
  800c46:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c49:	56                   	push   %esi
  800c4a:	e8 1c f7 ff ff       	call   80036b <fd2data>
  800c4f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c51:	83 c4 10             	add    $0x10,%esp
  800c54:	bf 00 00 00 00       	mov    $0x0,%edi
  800c59:	eb 4b                	jmp    800ca6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c5b:	89 da                	mov    %ebx,%edx
  800c5d:	89 f0                	mov    %esi,%eax
  800c5f:	e8 6d ff ff ff       	call   800bd1 <_pipeisclosed>
  800c64:	85 c0                	test   %eax,%eax
  800c66:	75 48                	jne    800cb0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c68:	e8 de f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c6d:	8b 43 04             	mov    0x4(%ebx),%eax
  800c70:	8b 0b                	mov    (%ebx),%ecx
  800c72:	8d 51 20             	lea    0x20(%ecx),%edx
  800c75:	39 d0                	cmp    %edx,%eax
  800c77:	73 e2                	jae    800c5b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c80:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c83:	89 c2                	mov    %eax,%edx
  800c85:	c1 fa 1f             	sar    $0x1f,%edx
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	c1 e9 1b             	shr    $0x1b,%ecx
  800c8d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c90:	83 e2 1f             	and    $0x1f,%edx
  800c93:	29 ca                	sub    %ecx,%edx
  800c95:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c99:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c9d:	83 c0 01             	add    $0x1,%eax
  800ca0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca3:	83 c7 01             	add    $0x1,%edi
  800ca6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca9:	75 c2                	jne    800c6d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cab:	8b 45 10             	mov    0x10(%ebp),%eax
  800cae:	eb 05                	jmp    800cb5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 18             	sub    $0x18,%esp
  800cc6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc9:	57                   	push   %edi
  800cca:	e8 9c f6 ff ff       	call   80036b <fd2data>
  800ccf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd1:	83 c4 10             	add    $0x10,%esp
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	eb 3d                	jmp    800d18 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cdb:	85 db                	test   %ebx,%ebx
  800cdd:	74 04                	je     800ce3 <devpipe_read+0x26>
				return i;
  800cdf:	89 d8                	mov    %ebx,%eax
  800ce1:	eb 44                	jmp    800d27 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce3:	89 f2                	mov    %esi,%edx
  800ce5:	89 f8                	mov    %edi,%eax
  800ce7:	e8 e5 fe ff ff       	call   800bd1 <_pipeisclosed>
  800cec:	85 c0                	test   %eax,%eax
  800cee:	75 32                	jne    800d22 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf0:	e8 56 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cf5:	8b 06                	mov    (%esi),%eax
  800cf7:	3b 46 04             	cmp    0x4(%esi),%eax
  800cfa:	74 df                	je     800cdb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cfc:	99                   	cltd   
  800cfd:	c1 ea 1b             	shr    $0x1b,%edx
  800d00:	01 d0                	add    %edx,%eax
  800d02:	83 e0 1f             	and    $0x1f,%eax
  800d05:	29 d0                	sub    %edx,%eax
  800d07:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d12:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d15:	83 c3 01             	add    $0x1,%ebx
  800d18:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d1b:	75 d8                	jne    800cf5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d20:	eb 05                	jmp    800d27 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d22:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d3a:	50                   	push   %eax
  800d3b:	e8 42 f6 ff ff       	call   800382 <fd_alloc>
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	89 c2                	mov    %eax,%edx
  800d45:	85 c0                	test   %eax,%eax
  800d47:	0f 88 2c 01 00 00    	js     800e79 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4d:	83 ec 04             	sub    $0x4,%esp
  800d50:	68 07 04 00 00       	push   $0x407
  800d55:	ff 75 f4             	pushl  -0xc(%ebp)
  800d58:	6a 00                	push   $0x0
  800d5a:	e8 0b f4 ff ff       	call   80016a <sys_page_alloc>
  800d5f:	83 c4 10             	add    $0x10,%esp
  800d62:	89 c2                	mov    %eax,%edx
  800d64:	85 c0                	test   %eax,%eax
  800d66:	0f 88 0d 01 00 00    	js     800e79 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d72:	50                   	push   %eax
  800d73:	e8 0a f6 ff ff       	call   800382 <fd_alloc>
  800d78:	89 c3                	mov    %eax,%ebx
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	0f 88 e2 00 00 00    	js     800e67 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d85:	83 ec 04             	sub    $0x4,%esp
  800d88:	68 07 04 00 00       	push   $0x407
  800d8d:	ff 75 f0             	pushl  -0x10(%ebp)
  800d90:	6a 00                	push   $0x0
  800d92:	e8 d3 f3 ff ff       	call   80016a <sys_page_alloc>
  800d97:	89 c3                	mov    %eax,%ebx
  800d99:	83 c4 10             	add    $0x10,%esp
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	0f 88 c3 00 00 00    	js     800e67 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	ff 75 f4             	pushl  -0xc(%ebp)
  800daa:	e8 bc f5 ff ff       	call   80036b <fd2data>
  800daf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db1:	83 c4 0c             	add    $0xc,%esp
  800db4:	68 07 04 00 00       	push   $0x407
  800db9:	50                   	push   %eax
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 a9 f3 ff ff       	call   80016a <sys_page_alloc>
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	0f 88 89 00 00 00    	js     800e57 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd4:	e8 92 f5 ff ff       	call   80036b <fd2data>
  800dd9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de0:	50                   	push   %eax
  800de1:	6a 00                	push   $0x0
  800de3:	56                   	push   %esi
  800de4:	6a 00                	push   $0x0
  800de6:	e8 c2 f3 ff ff       	call   8001ad <sys_page_map>
  800deb:	89 c3                	mov    %eax,%ebx
  800ded:	83 c4 20             	add    $0x20,%esp
  800df0:	85 c0                	test   %eax,%eax
  800df2:	78 55                	js     800e49 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800df4:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e02:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e09:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e12:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e17:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e1e:	83 ec 0c             	sub    $0xc,%esp
  800e21:	ff 75 f4             	pushl  -0xc(%ebp)
  800e24:	e8 32 f5 ff ff       	call   80035b <fd2num>
  800e29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2e:	83 c4 04             	add    $0x4,%esp
  800e31:	ff 75 f0             	pushl  -0x10(%ebp)
  800e34:	e8 22 f5 ff ff       	call   80035b <fd2num>
  800e39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	ba 00 00 00 00       	mov    $0x0,%edx
  800e47:	eb 30                	jmp    800e79 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e49:	83 ec 08             	sub    $0x8,%esp
  800e4c:	56                   	push   %esi
  800e4d:	6a 00                	push   $0x0
  800e4f:	e8 9b f3 ff ff       	call   8001ef <sys_page_unmap>
  800e54:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e57:	83 ec 08             	sub    $0x8,%esp
  800e5a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5d:	6a 00                	push   $0x0
  800e5f:	e8 8b f3 ff ff       	call   8001ef <sys_page_unmap>
  800e64:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e67:	83 ec 08             	sub    $0x8,%esp
  800e6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6d:	6a 00                	push   $0x0
  800e6f:	e8 7b f3 ff ff       	call   8001ef <sys_page_unmap>
  800e74:	83 c4 10             	add    $0x10,%esp
  800e77:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e79:	89 d0                	mov    %edx,%eax
  800e7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8b:	50                   	push   %eax
  800e8c:	ff 75 08             	pushl  0x8(%ebp)
  800e8f:	e8 3d f5 ff ff       	call   8003d1 <fd_lookup>
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	78 18                	js     800eb3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e9b:	83 ec 0c             	sub    $0xc,%esp
  800e9e:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea1:	e8 c5 f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800ea6:	89 c2                	mov    %eax,%edx
  800ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eab:	e8 21 fd ff ff       	call   800bd1 <_pipeisclosed>
  800eb0:	83 c4 10             	add    $0x10,%esp
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec5:	68 c2 1e 80 00       	push   $0x801ec2
  800eca:	ff 75 0c             	pushl  0xc(%ebp)
  800ecd:	e8 c4 07 00 00       	call   801696 <strcpy>
	return 0;
}
  800ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	57                   	push   %edi
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
  800edf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eea:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef0:	eb 2d                	jmp    800f1f <devcons_write+0x46>
		m = n - tot;
  800ef2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800efa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800eff:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	53                   	push   %ebx
  800f06:	03 45 0c             	add    0xc(%ebp),%eax
  800f09:	50                   	push   %eax
  800f0a:	57                   	push   %edi
  800f0b:	e8 18 09 00 00       	call   801828 <memmove>
		sys_cputs(buf, m);
  800f10:	83 c4 08             	add    $0x8,%esp
  800f13:	53                   	push   %ebx
  800f14:	57                   	push   %edi
  800f15:	e8 94 f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1a:	01 de                	add    %ebx,%esi
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	89 f0                	mov    %esi,%eax
  800f21:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f24:	72 cc                	jb     800ef2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3d:	74 2a                	je     800f69 <devcons_read+0x3b>
  800f3f:	eb 05                	jmp    800f46 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f41:	e8 05 f2 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f46:	e8 81 f1 ff ff       	call   8000cc <sys_cgetc>
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	74 f2                	je     800f41 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	78 16                	js     800f69 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f53:	83 f8 04             	cmp    $0x4,%eax
  800f56:	74 0c                	je     800f64 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5b:	88 02                	mov    %al,(%edx)
	return 1;
  800f5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f62:	eb 05                	jmp    800f69 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    

00800f6b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f71:	8b 45 08             	mov    0x8(%ebp),%eax
  800f74:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f77:	6a 01                	push   $0x1
  800f79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7c:	50                   	push   %eax
  800f7d:	e8 2c f1 ff ff       	call   8000ae <sys_cputs>
}
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <getchar>:

int
getchar(void)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f8d:	6a 01                	push   $0x1
  800f8f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f92:	50                   	push   %eax
  800f93:	6a 00                	push   $0x0
  800f95:	e8 9d f6 ff ff       	call   800637 <read>
	if (r < 0)
  800f9a:	83 c4 10             	add    $0x10,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	78 0f                	js     800fb0 <getchar+0x29>
		return r;
	if (r < 1)
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	7e 06                	jle    800fab <getchar+0x24>
		return -E_EOF;
	return c;
  800fa5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa9:	eb 05                	jmp    800fb0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fab:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	ff 75 08             	pushl  0x8(%ebp)
  800fbf:	e8 0d f4 ff ff       	call   8003d1 <fd_lookup>
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 11                	js     800fdc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fce:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fd4:	39 10                	cmp    %edx,(%eax)
  800fd6:	0f 94 c0             	sete   %al
  800fd9:	0f b6 c0             	movzbl %al,%eax
}
  800fdc:	c9                   	leave  
  800fdd:	c3                   	ret    

00800fde <opencons>:

int
opencons(void)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	e8 95 f3 ff ff       	call   800382 <fd_alloc>
  800fed:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 3e                	js     801034 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	68 07 04 00 00       	push   $0x407
  800ffe:	ff 75 f4             	pushl  -0xc(%ebp)
  801001:	6a 00                	push   $0x0
  801003:	e8 62 f1 ff ff       	call   80016a <sys_page_alloc>
  801008:	83 c4 10             	add    $0x10,%esp
		return r;
  80100b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 23                	js     801034 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801011:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	50                   	push   %eax
  80102a:	e8 2c f3 ff ff       	call   80035b <fd2num>
  80102f:	89 c2                	mov    %eax,%edx
  801031:	83 c4 10             	add    $0x10,%esp
}
  801034:	89 d0                	mov    %edx,%eax
  801036:	c9                   	leave  
  801037:	c3                   	ret    

00801038 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80103d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801040:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801046:	e8 e1 f0 ff ff       	call   80012c <sys_getenvid>
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	ff 75 0c             	pushl  0xc(%ebp)
  801051:	ff 75 08             	pushl  0x8(%ebp)
  801054:	56                   	push   %esi
  801055:	50                   	push   %eax
  801056:	68 d0 1e 80 00       	push   $0x801ed0
  80105b:	e8 b1 00 00 00       	call   801111 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801060:	83 c4 18             	add    $0x18,%esp
  801063:	53                   	push   %ebx
  801064:	ff 75 10             	pushl  0x10(%ebp)
  801067:	e8 54 00 00 00       	call   8010c0 <vcprintf>
	cprintf("\n");
  80106c:	c7 04 24 bb 1e 80 00 	movl   $0x801ebb,(%esp)
  801073:	e8 99 00 00 00       	call   801111 <cprintf>
  801078:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80107b:	cc                   	int3   
  80107c:	eb fd                	jmp    80107b <_panic+0x43>

0080107e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	53                   	push   %ebx
  801082:	83 ec 04             	sub    $0x4,%esp
  801085:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801088:	8b 13                	mov    (%ebx),%edx
  80108a:	8d 42 01             	lea    0x1(%edx),%eax
  80108d:	89 03                	mov    %eax,(%ebx)
  80108f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801092:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801096:	3d ff 00 00 00       	cmp    $0xff,%eax
  80109b:	75 1a                	jne    8010b7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	68 ff 00 00 00       	push   $0xff
  8010a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a8:	50                   	push   %eax
  8010a9:	e8 00 f0 ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8010ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d0:	00 00 00 
	b.cnt = 0;
  8010d3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010da:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010dd:	ff 75 0c             	pushl  0xc(%ebp)
  8010e0:	ff 75 08             	pushl  0x8(%ebp)
  8010e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e9:	50                   	push   %eax
  8010ea:	68 7e 10 80 00       	push   $0x80107e
  8010ef:	e8 54 01 00 00       	call   801248 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f4:	83 c4 08             	add    $0x8,%esp
  8010f7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010fd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801103:	50                   	push   %eax
  801104:	e8 a5 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  801109:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80110f:	c9                   	leave  
  801110:	c3                   	ret    

00801111 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801117:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80111a:	50                   	push   %eax
  80111b:	ff 75 08             	pushl  0x8(%ebp)
  80111e:	e8 9d ff ff ff       	call   8010c0 <vcprintf>
	va_end(ap);

	return cnt;
}
  801123:	c9                   	leave  
  801124:	c3                   	ret    

00801125 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	57                   	push   %edi
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	83 ec 1c             	sub    $0x1c,%esp
  80112e:	89 c7                	mov    %eax,%edi
  801130:	89 d6                	mov    %edx,%esi
  801132:	8b 45 08             	mov    0x8(%ebp),%eax
  801135:	8b 55 0c             	mov    0xc(%ebp),%edx
  801138:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80113b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801141:	bb 00 00 00 00       	mov    $0x0,%ebx
  801146:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801149:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114c:	39 d3                	cmp    %edx,%ebx
  80114e:	72 05                	jb     801155 <printnum+0x30>
  801150:	39 45 10             	cmp    %eax,0x10(%ebp)
  801153:	77 45                	ja     80119a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	ff 75 18             	pushl  0x18(%ebp)
  80115b:	8b 45 14             	mov    0x14(%ebp),%eax
  80115e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801161:	53                   	push   %ebx
  801162:	ff 75 10             	pushl  0x10(%ebp)
  801165:	83 ec 08             	sub    $0x8,%esp
  801168:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116b:	ff 75 e0             	pushl  -0x20(%ebp)
  80116e:	ff 75 dc             	pushl  -0x24(%ebp)
  801171:	ff 75 d8             	pushl  -0x28(%ebp)
  801174:	e8 97 09 00 00       	call   801b10 <__udivdi3>
  801179:	83 c4 18             	add    $0x18,%esp
  80117c:	52                   	push   %edx
  80117d:	50                   	push   %eax
  80117e:	89 f2                	mov    %esi,%edx
  801180:	89 f8                	mov    %edi,%eax
  801182:	e8 9e ff ff ff       	call   801125 <printnum>
  801187:	83 c4 20             	add    $0x20,%esp
  80118a:	eb 18                	jmp    8011a4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	56                   	push   %esi
  801190:	ff 75 18             	pushl  0x18(%ebp)
  801193:	ff d7                	call   *%edi
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	eb 03                	jmp    80119d <printnum+0x78>
  80119a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80119d:	83 eb 01             	sub    $0x1,%ebx
  8011a0:	85 db                	test   %ebx,%ebx
  8011a2:	7f e8                	jg     80118c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a4:	83 ec 08             	sub    $0x8,%esp
  8011a7:	56                   	push   %esi
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b7:	e8 84 0a 00 00       	call   801c40 <__umoddi3>
  8011bc:	83 c4 14             	add    $0x14,%esp
  8011bf:	0f be 80 f3 1e 80 00 	movsbl 0x801ef3(%eax),%eax
  8011c6:	50                   	push   %eax
  8011c7:	ff d7                	call   *%edi
}
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5f                   	pop    %edi
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    

008011d4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011d7:	83 fa 01             	cmp    $0x1,%edx
  8011da:	7e 0e                	jle    8011ea <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011dc:	8b 10                	mov    (%eax),%edx
  8011de:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011e1:	89 08                	mov    %ecx,(%eax)
  8011e3:	8b 02                	mov    (%edx),%eax
  8011e5:	8b 52 04             	mov    0x4(%edx),%edx
  8011e8:	eb 22                	jmp    80120c <getuint+0x38>
	else if (lflag)
  8011ea:	85 d2                	test   %edx,%edx
  8011ec:	74 10                	je     8011fe <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011ee:	8b 10                	mov    (%eax),%edx
  8011f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f3:	89 08                	mov    %ecx,(%eax)
  8011f5:	8b 02                	mov    (%edx),%eax
  8011f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fc:	eb 0e                	jmp    80120c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011fe:	8b 10                	mov    (%eax),%edx
  801200:	8d 4a 04             	lea    0x4(%edx),%ecx
  801203:	89 08                	mov    %ecx,(%eax)
  801205:	8b 02                	mov    (%edx),%eax
  801207:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801214:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801218:	8b 10                	mov    (%eax),%edx
  80121a:	3b 50 04             	cmp    0x4(%eax),%edx
  80121d:	73 0a                	jae    801229 <sprintputch+0x1b>
		*b->buf++ = ch;
  80121f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801222:	89 08                	mov    %ecx,(%eax)
  801224:	8b 45 08             	mov    0x8(%ebp),%eax
  801227:	88 02                	mov    %al,(%edx)
}
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801231:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801234:	50                   	push   %eax
  801235:	ff 75 10             	pushl  0x10(%ebp)
  801238:	ff 75 0c             	pushl  0xc(%ebp)
  80123b:	ff 75 08             	pushl  0x8(%ebp)
  80123e:	e8 05 00 00 00       	call   801248 <vprintfmt>
	va_end(ap);
}
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	c9                   	leave  
  801247:	c3                   	ret    

00801248 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	57                   	push   %edi
  80124c:	56                   	push   %esi
  80124d:	53                   	push   %ebx
  80124e:	83 ec 2c             	sub    $0x2c,%esp
  801251:	8b 75 08             	mov    0x8(%ebp),%esi
  801254:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801257:	8b 7d 10             	mov    0x10(%ebp),%edi
  80125a:	eb 12                	jmp    80126e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80125c:	85 c0                	test   %eax,%eax
  80125e:	0f 84 89 03 00 00    	je     8015ed <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	53                   	push   %ebx
  801268:	50                   	push   %eax
  801269:	ff d6                	call   *%esi
  80126b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80126e:	83 c7 01             	add    $0x1,%edi
  801271:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801275:	83 f8 25             	cmp    $0x25,%eax
  801278:	75 e2                	jne    80125c <vprintfmt+0x14>
  80127a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80127e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801285:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80128c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801293:	ba 00 00 00 00       	mov    $0x0,%edx
  801298:	eb 07                	jmp    8012a1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80129d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a1:	8d 47 01             	lea    0x1(%edi),%eax
  8012a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a7:	0f b6 07             	movzbl (%edi),%eax
  8012aa:	0f b6 c8             	movzbl %al,%ecx
  8012ad:	83 e8 23             	sub    $0x23,%eax
  8012b0:	3c 55                	cmp    $0x55,%al
  8012b2:	0f 87 1a 03 00 00    	ja     8015d2 <vprintfmt+0x38a>
  8012b8:	0f b6 c0             	movzbl %al,%eax
  8012bb:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8012c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012c5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012c9:	eb d6                	jmp    8012a1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012d6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012d9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012dd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012e0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012e3:	83 fa 09             	cmp    $0x9,%edx
  8012e6:	77 39                	ja     801321 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012e8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012eb:	eb e9                	jmp    8012d6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f0:	8d 48 04             	lea    0x4(%eax),%ecx
  8012f3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012f6:	8b 00                	mov    (%eax),%eax
  8012f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012fe:	eb 27                	jmp    801327 <vprintfmt+0xdf>
  801300:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801303:	85 c0                	test   %eax,%eax
  801305:	b9 00 00 00 00       	mov    $0x0,%ecx
  80130a:	0f 49 c8             	cmovns %eax,%ecx
  80130d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801313:	eb 8c                	jmp    8012a1 <vprintfmt+0x59>
  801315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801318:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80131f:	eb 80                	jmp    8012a1 <vprintfmt+0x59>
  801321:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801324:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801327:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80132b:	0f 89 70 ff ff ff    	jns    8012a1 <vprintfmt+0x59>
				width = precision, precision = -1;
  801331:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801334:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801337:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80133e:	e9 5e ff ff ff       	jmp    8012a1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801343:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801349:	e9 53 ff ff ff       	jmp    8012a1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80134e:	8b 45 14             	mov    0x14(%ebp),%eax
  801351:	8d 50 04             	lea    0x4(%eax),%edx
  801354:	89 55 14             	mov    %edx,0x14(%ebp)
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	53                   	push   %ebx
  80135b:	ff 30                	pushl  (%eax)
  80135d:	ff d6                	call   *%esi
			break;
  80135f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801365:	e9 04 ff ff ff       	jmp    80126e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80136a:	8b 45 14             	mov    0x14(%ebp),%eax
  80136d:	8d 50 04             	lea    0x4(%eax),%edx
  801370:	89 55 14             	mov    %edx,0x14(%ebp)
  801373:	8b 00                	mov    (%eax),%eax
  801375:	99                   	cltd   
  801376:	31 d0                	xor    %edx,%eax
  801378:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80137a:	83 f8 0f             	cmp    $0xf,%eax
  80137d:	7f 0b                	jg     80138a <vprintfmt+0x142>
  80137f:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  801386:	85 d2                	test   %edx,%edx
  801388:	75 18                	jne    8013a2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80138a:	50                   	push   %eax
  80138b:	68 0b 1f 80 00       	push   $0x801f0b
  801390:	53                   	push   %ebx
  801391:	56                   	push   %esi
  801392:	e8 94 fe ff ff       	call   80122b <printfmt>
  801397:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80139d:	e9 cc fe ff ff       	jmp    80126e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013a2:	52                   	push   %edx
  8013a3:	68 89 1e 80 00       	push   $0x801e89
  8013a8:	53                   	push   %ebx
  8013a9:	56                   	push   %esi
  8013aa:	e8 7c fe ff ff       	call   80122b <printfmt>
  8013af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013b5:	e9 b4 fe ff ff       	jmp    80126e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8013bd:	8d 50 04             	lea    0x4(%eax),%edx
  8013c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013c5:	85 ff                	test   %edi,%edi
  8013c7:	b8 04 1f 80 00       	mov    $0x801f04,%eax
  8013cc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013d3:	0f 8e 94 00 00 00    	jle    80146d <vprintfmt+0x225>
  8013d9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013dd:	0f 84 98 00 00 00    	je     80147b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	ff 75 d0             	pushl  -0x30(%ebp)
  8013e9:	57                   	push   %edi
  8013ea:	e8 86 02 00 00       	call   801675 <strnlen>
  8013ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013f2:	29 c1                	sub    %eax,%ecx
  8013f4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013f7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013fa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801401:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801404:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801406:	eb 0f                	jmp    801417 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	53                   	push   %ebx
  80140c:	ff 75 e0             	pushl  -0x20(%ebp)
  80140f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801411:	83 ef 01             	sub    $0x1,%edi
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 ff                	test   %edi,%edi
  801419:	7f ed                	jg     801408 <vprintfmt+0x1c0>
  80141b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80141e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801421:	85 c9                	test   %ecx,%ecx
  801423:	b8 00 00 00 00       	mov    $0x0,%eax
  801428:	0f 49 c1             	cmovns %ecx,%eax
  80142b:	29 c1                	sub    %eax,%ecx
  80142d:	89 75 08             	mov    %esi,0x8(%ebp)
  801430:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801433:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801436:	89 cb                	mov    %ecx,%ebx
  801438:	eb 4d                	jmp    801487 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80143a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80143e:	74 1b                	je     80145b <vprintfmt+0x213>
  801440:	0f be c0             	movsbl %al,%eax
  801443:	83 e8 20             	sub    $0x20,%eax
  801446:	83 f8 5e             	cmp    $0x5e,%eax
  801449:	76 10                	jbe    80145b <vprintfmt+0x213>
					putch('?', putdat);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	ff 75 0c             	pushl  0xc(%ebp)
  801451:	6a 3f                	push   $0x3f
  801453:	ff 55 08             	call   *0x8(%ebp)
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	eb 0d                	jmp    801468 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	ff 75 0c             	pushl  0xc(%ebp)
  801461:	52                   	push   %edx
  801462:	ff 55 08             	call   *0x8(%ebp)
  801465:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801468:	83 eb 01             	sub    $0x1,%ebx
  80146b:	eb 1a                	jmp    801487 <vprintfmt+0x23f>
  80146d:	89 75 08             	mov    %esi,0x8(%ebp)
  801470:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801473:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801476:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801479:	eb 0c                	jmp    801487 <vprintfmt+0x23f>
  80147b:	89 75 08             	mov    %esi,0x8(%ebp)
  80147e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801481:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801484:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801487:	83 c7 01             	add    $0x1,%edi
  80148a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80148e:	0f be d0             	movsbl %al,%edx
  801491:	85 d2                	test   %edx,%edx
  801493:	74 23                	je     8014b8 <vprintfmt+0x270>
  801495:	85 f6                	test   %esi,%esi
  801497:	78 a1                	js     80143a <vprintfmt+0x1f2>
  801499:	83 ee 01             	sub    $0x1,%esi
  80149c:	79 9c                	jns    80143a <vprintfmt+0x1f2>
  80149e:	89 df                	mov    %ebx,%edi
  8014a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a6:	eb 18                	jmp    8014c0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	53                   	push   %ebx
  8014ac:	6a 20                	push   $0x20
  8014ae:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014b0:	83 ef 01             	sub    $0x1,%edi
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	eb 08                	jmp    8014c0 <vprintfmt+0x278>
  8014b8:	89 df                	mov    %ebx,%edi
  8014ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8014bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c0:	85 ff                	test   %edi,%edi
  8014c2:	7f e4                	jg     8014a8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c7:	e9 a2 fd ff ff       	jmp    80126e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014cc:	83 fa 01             	cmp    $0x1,%edx
  8014cf:	7e 16                	jle    8014e7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d4:	8d 50 08             	lea    0x8(%eax),%edx
  8014d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014da:	8b 50 04             	mov    0x4(%eax),%edx
  8014dd:	8b 00                	mov    (%eax),%eax
  8014df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014e5:	eb 32                	jmp    801519 <vprintfmt+0x2d1>
	else if (lflag)
  8014e7:	85 d2                	test   %edx,%edx
  8014e9:	74 18                	je     801503 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ee:	8d 50 04             	lea    0x4(%eax),%edx
  8014f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f4:	8b 00                	mov    (%eax),%eax
  8014f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f9:	89 c1                	mov    %eax,%ecx
  8014fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8014fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801501:	eb 16                	jmp    801519 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801503:	8b 45 14             	mov    0x14(%ebp),%eax
  801506:	8d 50 04             	lea    0x4(%eax),%edx
  801509:	89 55 14             	mov    %edx,0x14(%ebp)
  80150c:	8b 00                	mov    (%eax),%eax
  80150e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801511:	89 c1                	mov    %eax,%ecx
  801513:	c1 f9 1f             	sar    $0x1f,%ecx
  801516:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801519:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80151c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80151f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801524:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801528:	79 74                	jns    80159e <vprintfmt+0x356>
				putch('-', putdat);
  80152a:	83 ec 08             	sub    $0x8,%esp
  80152d:	53                   	push   %ebx
  80152e:	6a 2d                	push   $0x2d
  801530:	ff d6                	call   *%esi
				num = -(long long) num;
  801532:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801535:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801538:	f7 d8                	neg    %eax
  80153a:	83 d2 00             	adc    $0x0,%edx
  80153d:	f7 da                	neg    %edx
  80153f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801542:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801547:	eb 55                	jmp    80159e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801549:	8d 45 14             	lea    0x14(%ebp),%eax
  80154c:	e8 83 fc ff ff       	call   8011d4 <getuint>
			base = 10;
  801551:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801556:	eb 46                	jmp    80159e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801558:	8d 45 14             	lea    0x14(%ebp),%eax
  80155b:	e8 74 fc ff ff       	call   8011d4 <getuint>
			base = 8;
  801560:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801565:	eb 37                	jmp    80159e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	53                   	push   %ebx
  80156b:	6a 30                	push   $0x30
  80156d:	ff d6                	call   *%esi
			putch('x', putdat);
  80156f:	83 c4 08             	add    $0x8,%esp
  801572:	53                   	push   %ebx
  801573:	6a 78                	push   $0x78
  801575:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801577:	8b 45 14             	mov    0x14(%ebp),%eax
  80157a:	8d 50 04             	lea    0x4(%eax),%edx
  80157d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801580:	8b 00                	mov    (%eax),%eax
  801582:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801587:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80158a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80158f:	eb 0d                	jmp    80159e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801591:	8d 45 14             	lea    0x14(%ebp),%eax
  801594:	e8 3b fc ff ff       	call   8011d4 <getuint>
			base = 16;
  801599:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80159e:	83 ec 0c             	sub    $0xc,%esp
  8015a1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015a5:	57                   	push   %edi
  8015a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a9:	51                   	push   %ecx
  8015aa:	52                   	push   %edx
  8015ab:	50                   	push   %eax
  8015ac:	89 da                	mov    %ebx,%edx
  8015ae:	89 f0                	mov    %esi,%eax
  8015b0:	e8 70 fb ff ff       	call   801125 <printnum>
			break;
  8015b5:	83 c4 20             	add    $0x20,%esp
  8015b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015bb:	e9 ae fc ff ff       	jmp    80126e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	53                   	push   %ebx
  8015c4:	51                   	push   %ecx
  8015c5:	ff d6                	call   *%esi
			break;
  8015c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015cd:	e9 9c fc ff ff       	jmp    80126e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	53                   	push   %ebx
  8015d6:	6a 25                	push   $0x25
  8015d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	eb 03                	jmp    8015e2 <vprintfmt+0x39a>
  8015df:	83 ef 01             	sub    $0x1,%edi
  8015e2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015e6:	75 f7                	jne    8015df <vprintfmt+0x397>
  8015e8:	e9 81 fc ff ff       	jmp    80126e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f0:	5b                   	pop    %ebx
  8015f1:	5e                   	pop    %esi
  8015f2:	5f                   	pop    %edi
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    

008015f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	83 ec 18             	sub    $0x18,%esp
  8015fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801601:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801604:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801608:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80160b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801612:	85 c0                	test   %eax,%eax
  801614:	74 26                	je     80163c <vsnprintf+0x47>
  801616:	85 d2                	test   %edx,%edx
  801618:	7e 22                	jle    80163c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80161a:	ff 75 14             	pushl  0x14(%ebp)
  80161d:	ff 75 10             	pushl  0x10(%ebp)
  801620:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	68 0e 12 80 00       	push   $0x80120e
  801629:	e8 1a fc ff ff       	call   801248 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80162e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801631:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801634:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	eb 05                	jmp    801641 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80163c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801649:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80164c:	50                   	push   %eax
  80164d:	ff 75 10             	pushl  0x10(%ebp)
  801650:	ff 75 0c             	pushl  0xc(%ebp)
  801653:	ff 75 08             	pushl  0x8(%ebp)
  801656:	e8 9a ff ff ff       	call   8015f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
  801668:	eb 03                	jmp    80166d <strlen+0x10>
		n++;
  80166a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80166d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801671:	75 f7                	jne    80166a <strlen+0xd>
		n++;
	return n;
}
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80167e:	ba 00 00 00 00       	mov    $0x0,%edx
  801683:	eb 03                	jmp    801688 <strnlen+0x13>
		n++;
  801685:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801688:	39 c2                	cmp    %eax,%edx
  80168a:	74 08                	je     801694 <strnlen+0x1f>
  80168c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801690:	75 f3                	jne    801685 <strnlen+0x10>
  801692:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801694:	5d                   	pop    %ebp
  801695:	c3                   	ret    

00801696 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	53                   	push   %ebx
  80169a:	8b 45 08             	mov    0x8(%ebp),%eax
  80169d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	83 c2 01             	add    $0x1,%edx
  8016a5:	83 c1 01             	add    $0x1,%ecx
  8016a8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016af:	84 db                	test   %bl,%bl
  8016b1:	75 ef                	jne    8016a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016b3:	5b                   	pop    %ebx
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016bd:	53                   	push   %ebx
  8016be:	e8 9a ff ff ff       	call   80165d <strlen>
  8016c3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016c6:	ff 75 0c             	pushl  0xc(%ebp)
  8016c9:	01 d8                	add    %ebx,%eax
  8016cb:	50                   	push   %eax
  8016cc:	e8 c5 ff ff ff       	call   801696 <strcpy>
	return dst;
}
  8016d1:	89 d8                	mov    %ebx,%eax
  8016d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	56                   	push   %esi
  8016dc:	53                   	push   %ebx
  8016dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8016e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e3:	89 f3                	mov    %esi,%ebx
  8016e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016e8:	89 f2                	mov    %esi,%edx
  8016ea:	eb 0f                	jmp    8016fb <strncpy+0x23>
		*dst++ = *src;
  8016ec:	83 c2 01             	add    $0x1,%edx
  8016ef:	0f b6 01             	movzbl (%ecx),%eax
  8016f2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016f5:	80 39 01             	cmpb   $0x1,(%ecx)
  8016f8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016fb:	39 da                	cmp    %ebx,%edx
  8016fd:	75 ed                	jne    8016ec <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016ff:	89 f0                	mov    %esi,%eax
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	56                   	push   %esi
  801709:	53                   	push   %ebx
  80170a:	8b 75 08             	mov    0x8(%ebp),%esi
  80170d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801710:	8b 55 10             	mov    0x10(%ebp),%edx
  801713:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801715:	85 d2                	test   %edx,%edx
  801717:	74 21                	je     80173a <strlcpy+0x35>
  801719:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80171d:	89 f2                	mov    %esi,%edx
  80171f:	eb 09                	jmp    80172a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801721:	83 c2 01             	add    $0x1,%edx
  801724:	83 c1 01             	add    $0x1,%ecx
  801727:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80172a:	39 c2                	cmp    %eax,%edx
  80172c:	74 09                	je     801737 <strlcpy+0x32>
  80172e:	0f b6 19             	movzbl (%ecx),%ebx
  801731:	84 db                	test   %bl,%bl
  801733:	75 ec                	jne    801721 <strlcpy+0x1c>
  801735:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801737:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80173a:	29 f0                	sub    %esi,%eax
}
  80173c:	5b                   	pop    %ebx
  80173d:	5e                   	pop    %esi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801746:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801749:	eb 06                	jmp    801751 <strcmp+0x11>
		p++, q++;
  80174b:	83 c1 01             	add    $0x1,%ecx
  80174e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801751:	0f b6 01             	movzbl (%ecx),%eax
  801754:	84 c0                	test   %al,%al
  801756:	74 04                	je     80175c <strcmp+0x1c>
  801758:	3a 02                	cmp    (%edx),%al
  80175a:	74 ef                	je     80174b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80175c:	0f b6 c0             	movzbl %al,%eax
  80175f:	0f b6 12             	movzbl (%edx),%edx
  801762:	29 d0                	sub    %edx,%eax
}
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	53                   	push   %ebx
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
  80176d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801770:	89 c3                	mov    %eax,%ebx
  801772:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801775:	eb 06                	jmp    80177d <strncmp+0x17>
		n--, p++, q++;
  801777:	83 c0 01             	add    $0x1,%eax
  80177a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80177d:	39 d8                	cmp    %ebx,%eax
  80177f:	74 15                	je     801796 <strncmp+0x30>
  801781:	0f b6 08             	movzbl (%eax),%ecx
  801784:	84 c9                	test   %cl,%cl
  801786:	74 04                	je     80178c <strncmp+0x26>
  801788:	3a 0a                	cmp    (%edx),%cl
  80178a:	74 eb                	je     801777 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80178c:	0f b6 00             	movzbl (%eax),%eax
  80178f:	0f b6 12             	movzbl (%edx),%edx
  801792:	29 d0                	sub    %edx,%eax
  801794:	eb 05                	jmp    80179b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801796:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80179b:	5b                   	pop    %ebx
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017a8:	eb 07                	jmp    8017b1 <strchr+0x13>
		if (*s == c)
  8017aa:	38 ca                	cmp    %cl,%dl
  8017ac:	74 0f                	je     8017bd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017ae:	83 c0 01             	add    $0x1,%eax
  8017b1:	0f b6 10             	movzbl (%eax),%edx
  8017b4:	84 d2                	test   %dl,%dl
  8017b6:	75 f2                	jne    8017aa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c9:	eb 03                	jmp    8017ce <strfind+0xf>
  8017cb:	83 c0 01             	add    $0x1,%eax
  8017ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017d1:	38 ca                	cmp    %cl,%dl
  8017d3:	74 04                	je     8017d9 <strfind+0x1a>
  8017d5:	84 d2                	test   %dl,%dl
  8017d7:	75 f2                	jne    8017cb <strfind+0xc>
			break;
	return (char *) s;
}
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	57                   	push   %edi
  8017df:	56                   	push   %esi
  8017e0:	53                   	push   %ebx
  8017e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017e7:	85 c9                	test   %ecx,%ecx
  8017e9:	74 36                	je     801821 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017f1:	75 28                	jne    80181b <memset+0x40>
  8017f3:	f6 c1 03             	test   $0x3,%cl
  8017f6:	75 23                	jne    80181b <memset+0x40>
		c &= 0xFF;
  8017f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017fc:	89 d3                	mov    %edx,%ebx
  8017fe:	c1 e3 08             	shl    $0x8,%ebx
  801801:	89 d6                	mov    %edx,%esi
  801803:	c1 e6 18             	shl    $0x18,%esi
  801806:	89 d0                	mov    %edx,%eax
  801808:	c1 e0 10             	shl    $0x10,%eax
  80180b:	09 f0                	or     %esi,%eax
  80180d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80180f:	89 d8                	mov    %ebx,%eax
  801811:	09 d0                	or     %edx,%eax
  801813:	c1 e9 02             	shr    $0x2,%ecx
  801816:	fc                   	cld    
  801817:	f3 ab                	rep stos %eax,%es:(%edi)
  801819:	eb 06                	jmp    801821 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80181b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181e:	fc                   	cld    
  80181f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801821:	89 f8                	mov    %edi,%eax
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5f                   	pop    %edi
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    

00801828 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	57                   	push   %edi
  80182c:	56                   	push   %esi
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	8b 75 0c             	mov    0xc(%ebp),%esi
  801833:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801836:	39 c6                	cmp    %eax,%esi
  801838:	73 35                	jae    80186f <memmove+0x47>
  80183a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80183d:	39 d0                	cmp    %edx,%eax
  80183f:	73 2e                	jae    80186f <memmove+0x47>
		s += n;
		d += n;
  801841:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801844:	89 d6                	mov    %edx,%esi
  801846:	09 fe                	or     %edi,%esi
  801848:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80184e:	75 13                	jne    801863 <memmove+0x3b>
  801850:	f6 c1 03             	test   $0x3,%cl
  801853:	75 0e                	jne    801863 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801855:	83 ef 04             	sub    $0x4,%edi
  801858:	8d 72 fc             	lea    -0x4(%edx),%esi
  80185b:	c1 e9 02             	shr    $0x2,%ecx
  80185e:	fd                   	std    
  80185f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801861:	eb 09                	jmp    80186c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801863:	83 ef 01             	sub    $0x1,%edi
  801866:	8d 72 ff             	lea    -0x1(%edx),%esi
  801869:	fd                   	std    
  80186a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80186c:	fc                   	cld    
  80186d:	eb 1d                	jmp    80188c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186f:	89 f2                	mov    %esi,%edx
  801871:	09 c2                	or     %eax,%edx
  801873:	f6 c2 03             	test   $0x3,%dl
  801876:	75 0f                	jne    801887 <memmove+0x5f>
  801878:	f6 c1 03             	test   $0x3,%cl
  80187b:	75 0a                	jne    801887 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80187d:	c1 e9 02             	shr    $0x2,%ecx
  801880:	89 c7                	mov    %eax,%edi
  801882:	fc                   	cld    
  801883:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801885:	eb 05                	jmp    80188c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801887:	89 c7                	mov    %eax,%edi
  801889:	fc                   	cld    
  80188a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80188c:	5e                   	pop    %esi
  80188d:	5f                   	pop    %edi
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801893:	ff 75 10             	pushl  0x10(%ebp)
  801896:	ff 75 0c             	pushl  0xc(%ebp)
  801899:	ff 75 08             	pushl  0x8(%ebp)
  80189c:	e8 87 ff ff ff       	call   801828 <memmove>
}
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	56                   	push   %esi
  8018a7:	53                   	push   %ebx
  8018a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ae:	89 c6                	mov    %eax,%esi
  8018b0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018b3:	eb 1a                	jmp    8018cf <memcmp+0x2c>
		if (*s1 != *s2)
  8018b5:	0f b6 08             	movzbl (%eax),%ecx
  8018b8:	0f b6 1a             	movzbl (%edx),%ebx
  8018bb:	38 d9                	cmp    %bl,%cl
  8018bd:	74 0a                	je     8018c9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018bf:	0f b6 c1             	movzbl %cl,%eax
  8018c2:	0f b6 db             	movzbl %bl,%ebx
  8018c5:	29 d8                	sub    %ebx,%eax
  8018c7:	eb 0f                	jmp    8018d8 <memcmp+0x35>
		s1++, s2++;
  8018c9:	83 c0 01             	add    $0x1,%eax
  8018cc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018cf:	39 f0                	cmp    %esi,%eax
  8018d1:	75 e2                	jne    8018b5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	53                   	push   %ebx
  8018e0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018e3:	89 c1                	mov    %eax,%ecx
  8018e5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018e8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018ec:	eb 0a                	jmp    8018f8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018ee:	0f b6 10             	movzbl (%eax),%edx
  8018f1:	39 da                	cmp    %ebx,%edx
  8018f3:	74 07                	je     8018fc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018f5:	83 c0 01             	add    $0x1,%eax
  8018f8:	39 c8                	cmp    %ecx,%eax
  8018fa:	72 f2                	jb     8018ee <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018fc:	5b                   	pop    %ebx
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	57                   	push   %edi
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801908:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80190b:	eb 03                	jmp    801910 <strtol+0x11>
		s++;
  80190d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801910:	0f b6 01             	movzbl (%ecx),%eax
  801913:	3c 20                	cmp    $0x20,%al
  801915:	74 f6                	je     80190d <strtol+0xe>
  801917:	3c 09                	cmp    $0x9,%al
  801919:	74 f2                	je     80190d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80191b:	3c 2b                	cmp    $0x2b,%al
  80191d:	75 0a                	jne    801929 <strtol+0x2a>
		s++;
  80191f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801922:	bf 00 00 00 00       	mov    $0x0,%edi
  801927:	eb 11                	jmp    80193a <strtol+0x3b>
  801929:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80192e:	3c 2d                	cmp    $0x2d,%al
  801930:	75 08                	jne    80193a <strtol+0x3b>
		s++, neg = 1;
  801932:	83 c1 01             	add    $0x1,%ecx
  801935:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80193a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801940:	75 15                	jne    801957 <strtol+0x58>
  801942:	80 39 30             	cmpb   $0x30,(%ecx)
  801945:	75 10                	jne    801957 <strtol+0x58>
  801947:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80194b:	75 7c                	jne    8019c9 <strtol+0xca>
		s += 2, base = 16;
  80194d:	83 c1 02             	add    $0x2,%ecx
  801950:	bb 10 00 00 00       	mov    $0x10,%ebx
  801955:	eb 16                	jmp    80196d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801957:	85 db                	test   %ebx,%ebx
  801959:	75 12                	jne    80196d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80195b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801960:	80 39 30             	cmpb   $0x30,(%ecx)
  801963:	75 08                	jne    80196d <strtol+0x6e>
		s++, base = 8;
  801965:	83 c1 01             	add    $0x1,%ecx
  801968:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80196d:	b8 00 00 00 00       	mov    $0x0,%eax
  801972:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801975:	0f b6 11             	movzbl (%ecx),%edx
  801978:	8d 72 d0             	lea    -0x30(%edx),%esi
  80197b:	89 f3                	mov    %esi,%ebx
  80197d:	80 fb 09             	cmp    $0x9,%bl
  801980:	77 08                	ja     80198a <strtol+0x8b>
			dig = *s - '0';
  801982:	0f be d2             	movsbl %dl,%edx
  801985:	83 ea 30             	sub    $0x30,%edx
  801988:	eb 22                	jmp    8019ac <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80198a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80198d:	89 f3                	mov    %esi,%ebx
  80198f:	80 fb 19             	cmp    $0x19,%bl
  801992:	77 08                	ja     80199c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801994:	0f be d2             	movsbl %dl,%edx
  801997:	83 ea 57             	sub    $0x57,%edx
  80199a:	eb 10                	jmp    8019ac <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80199c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80199f:	89 f3                	mov    %esi,%ebx
  8019a1:	80 fb 19             	cmp    $0x19,%bl
  8019a4:	77 16                	ja     8019bc <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019a6:	0f be d2             	movsbl %dl,%edx
  8019a9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019ac:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019af:	7d 0b                	jge    8019bc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019b1:	83 c1 01             	add    $0x1,%ecx
  8019b4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019b8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019ba:	eb b9                	jmp    801975 <strtol+0x76>

	if (endptr)
  8019bc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019c0:	74 0d                	je     8019cf <strtol+0xd0>
		*endptr = (char *) s;
  8019c2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019c5:	89 0e                	mov    %ecx,(%esi)
  8019c7:	eb 06                	jmp    8019cf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019c9:	85 db                	test   %ebx,%ebx
  8019cb:	74 98                	je     801965 <strtol+0x66>
  8019cd:	eb 9e                	jmp    80196d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019cf:	89 c2                	mov    %eax,%edx
  8019d1:	f7 da                	neg    %edx
  8019d3:	85 ff                	test   %edi,%edi
  8019d5:	0f 45 c2             	cmovne %edx,%eax
}
  8019d8:	5b                   	pop    %ebx
  8019d9:	5e                   	pop    %esi
  8019da:	5f                   	pop    %edi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
  8019e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019eb:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019ed:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019f2:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019f5:	83 ec 0c             	sub    $0xc,%esp
  8019f8:	50                   	push   %eax
  8019f9:	e8 1c e9 ff ff       	call   80031a <sys_ipc_recv>

	if (from_env_store != NULL)
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	85 f6                	test   %esi,%esi
  801a03:	74 14                	je     801a19 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801a05:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 09                	js     801a17 <ipc_recv+0x3a>
  801a0e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a14:	8b 52 74             	mov    0x74(%edx),%edx
  801a17:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a19:	85 db                	test   %ebx,%ebx
  801a1b:	74 14                	je     801a31 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a22:	85 c0                	test   %eax,%eax
  801a24:	78 09                	js     801a2f <ipc_recv+0x52>
  801a26:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a2c:	8b 52 78             	mov    0x78(%edx),%edx
  801a2f:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a31:	85 c0                	test   %eax,%eax
  801a33:	78 08                	js     801a3d <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a35:	a1 04 40 80 00       	mov    0x804004,%eax
  801a3a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a40:	5b                   	pop    %ebx
  801a41:	5e                   	pop    %esi
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	57                   	push   %edi
  801a48:	56                   	push   %esi
  801a49:	53                   	push   %ebx
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a50:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a56:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a58:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a5d:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a60:	ff 75 14             	pushl  0x14(%ebp)
  801a63:	53                   	push   %ebx
  801a64:	56                   	push   %esi
  801a65:	57                   	push   %edi
  801a66:	e8 8c e8 ff ff       	call   8002f7 <sys_ipc_try_send>

		if (err < 0) {
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	79 1e                	jns    801a90 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a72:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a75:	75 07                	jne    801a7e <ipc_send+0x3a>
				sys_yield();
  801a77:	e8 cf e6 ff ff       	call   80014b <sys_yield>
  801a7c:	eb e2                	jmp    801a60 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a7e:	50                   	push   %eax
  801a7f:	68 00 22 80 00       	push   $0x802200
  801a84:	6a 49                	push   $0x49
  801a86:	68 0d 22 80 00       	push   $0x80220d
  801a8b:	e8 a8 f5 ff ff       	call   801038 <_panic>
		}

	} while (err < 0);

}
  801a90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a93:	5b                   	pop    %ebx
  801a94:	5e                   	pop    %esi
  801a95:	5f                   	pop    %edi
  801a96:	5d                   	pop    %ebp
  801a97:	c3                   	ret    

00801a98 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a9e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aa3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aa6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aac:	8b 52 50             	mov    0x50(%edx),%edx
  801aaf:	39 ca                	cmp    %ecx,%edx
  801ab1:	75 0d                	jne    801ac0 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ab3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ab6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801abb:	8b 40 48             	mov    0x48(%eax),%eax
  801abe:	eb 0f                	jmp    801acf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ac0:	83 c0 01             	add    $0x1,%eax
  801ac3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ac8:	75 d9                	jne    801aa3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad7:	89 d0                	mov    %edx,%eax
  801ad9:	c1 e8 16             	shr    $0x16,%eax
  801adc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae8:	f6 c1 01             	test   $0x1,%cl
  801aeb:	74 1d                	je     801b0a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801aed:	c1 ea 0c             	shr    $0xc,%edx
  801af0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801af7:	f6 c2 01             	test   $0x1,%dl
  801afa:	74 0e                	je     801b0a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801afc:	c1 ea 0c             	shr    $0xc,%edx
  801aff:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b06:	ef 
  801b07:	0f b7 c0             	movzwl %ax,%eax
}
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    
  801b0c:	66 90                	xchg   %ax,%ax
  801b0e:	66 90                	xchg   %ax,%ax

00801b10 <__udivdi3>:
  801b10:	55                   	push   %ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 1c             	sub    $0x1c,%esp
  801b17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b27:	85 f6                	test   %esi,%esi
  801b29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b2d:	89 ca                	mov    %ecx,%edx
  801b2f:	89 f8                	mov    %edi,%eax
  801b31:	75 3d                	jne    801b70 <__udivdi3+0x60>
  801b33:	39 cf                	cmp    %ecx,%edi
  801b35:	0f 87 c5 00 00 00    	ja     801c00 <__udivdi3+0xf0>
  801b3b:	85 ff                	test   %edi,%edi
  801b3d:	89 fd                	mov    %edi,%ebp
  801b3f:	75 0b                	jne    801b4c <__udivdi3+0x3c>
  801b41:	b8 01 00 00 00       	mov    $0x1,%eax
  801b46:	31 d2                	xor    %edx,%edx
  801b48:	f7 f7                	div    %edi
  801b4a:	89 c5                	mov    %eax,%ebp
  801b4c:	89 c8                	mov    %ecx,%eax
  801b4e:	31 d2                	xor    %edx,%edx
  801b50:	f7 f5                	div    %ebp
  801b52:	89 c1                	mov    %eax,%ecx
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	89 cf                	mov    %ecx,%edi
  801b58:	f7 f5                	div    %ebp
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	89 d8                	mov    %ebx,%eax
  801b5e:	89 fa                	mov    %edi,%edx
  801b60:	83 c4 1c             	add    $0x1c,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5f                   	pop    %edi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    
  801b68:	90                   	nop
  801b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b70:	39 ce                	cmp    %ecx,%esi
  801b72:	77 74                	ja     801be8 <__udivdi3+0xd8>
  801b74:	0f bd fe             	bsr    %esi,%edi
  801b77:	83 f7 1f             	xor    $0x1f,%edi
  801b7a:	0f 84 98 00 00 00    	je     801c18 <__udivdi3+0x108>
  801b80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b85:	89 f9                	mov    %edi,%ecx
  801b87:	89 c5                	mov    %eax,%ebp
  801b89:	29 fb                	sub    %edi,%ebx
  801b8b:	d3 e6                	shl    %cl,%esi
  801b8d:	89 d9                	mov    %ebx,%ecx
  801b8f:	d3 ed                	shr    %cl,%ebp
  801b91:	89 f9                	mov    %edi,%ecx
  801b93:	d3 e0                	shl    %cl,%eax
  801b95:	09 ee                	or     %ebp,%esi
  801b97:	89 d9                	mov    %ebx,%ecx
  801b99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b9d:	89 d5                	mov    %edx,%ebp
  801b9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ba3:	d3 ed                	shr    %cl,%ebp
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	d3 e2                	shl    %cl,%edx
  801ba9:	89 d9                	mov    %ebx,%ecx
  801bab:	d3 e8                	shr    %cl,%eax
  801bad:	09 c2                	or     %eax,%edx
  801baf:	89 d0                	mov    %edx,%eax
  801bb1:	89 ea                	mov    %ebp,%edx
  801bb3:	f7 f6                	div    %esi
  801bb5:	89 d5                	mov    %edx,%ebp
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	f7 64 24 0c          	mull   0xc(%esp)
  801bbd:	39 d5                	cmp    %edx,%ebp
  801bbf:	72 10                	jb     801bd1 <__udivdi3+0xc1>
  801bc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	d3 e6                	shl    %cl,%esi
  801bc9:	39 c6                	cmp    %eax,%esi
  801bcb:	73 07                	jae    801bd4 <__udivdi3+0xc4>
  801bcd:	39 d5                	cmp    %edx,%ebp
  801bcf:	75 03                	jne    801bd4 <__udivdi3+0xc4>
  801bd1:	83 eb 01             	sub    $0x1,%ebx
  801bd4:	31 ff                	xor    %edi,%edi
  801bd6:	89 d8                	mov    %ebx,%eax
  801bd8:	89 fa                	mov    %edi,%edx
  801bda:	83 c4 1c             	add    $0x1c,%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    
  801be2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801be8:	31 ff                	xor    %edi,%edi
  801bea:	31 db                	xor    %ebx,%ebx
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	89 fa                	mov    %edi,%edx
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
  801bf8:	90                   	nop
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	89 d8                	mov    %ebx,%eax
  801c02:	f7 f7                	div    %edi
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 c3                	mov    %eax,%ebx
  801c08:	89 d8                	mov    %ebx,%eax
  801c0a:	89 fa                	mov    %edi,%edx
  801c0c:	83 c4 1c             	add    $0x1c,%esp
  801c0f:	5b                   	pop    %ebx
  801c10:	5e                   	pop    %esi
  801c11:	5f                   	pop    %edi
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	39 ce                	cmp    %ecx,%esi
  801c1a:	72 0c                	jb     801c28 <__udivdi3+0x118>
  801c1c:	31 db                	xor    %ebx,%ebx
  801c1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c22:	0f 87 34 ff ff ff    	ja     801b5c <__udivdi3+0x4c>
  801c28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c2d:	e9 2a ff ff ff       	jmp    801b5c <__udivdi3+0x4c>
  801c32:	66 90                	xchg   %ax,%ax
  801c34:	66 90                	xchg   %ax,%ax
  801c36:	66 90                	xchg   %ax,%ax
  801c38:	66 90                	xchg   %ax,%ax
  801c3a:	66 90                	xchg   %ax,%ax
  801c3c:	66 90                	xchg   %ax,%ax
  801c3e:	66 90                	xchg   %ax,%ax

00801c40 <__umoddi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c57:	85 d2                	test   %edx,%edx
  801c59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c61:	89 f3                	mov    %esi,%ebx
  801c63:	89 3c 24             	mov    %edi,(%esp)
  801c66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6a:	75 1c                	jne    801c88 <__umoddi3+0x48>
  801c6c:	39 f7                	cmp    %esi,%edi
  801c6e:	76 50                	jbe    801cc0 <__umoddi3+0x80>
  801c70:	89 c8                	mov    %ecx,%eax
  801c72:	89 f2                	mov    %esi,%edx
  801c74:	f7 f7                	div    %edi
  801c76:	89 d0                	mov    %edx,%eax
  801c78:	31 d2                	xor    %edx,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	89 d0                	mov    %edx,%eax
  801c8c:	77 52                	ja     801ce0 <__umoddi3+0xa0>
  801c8e:	0f bd ea             	bsr    %edx,%ebp
  801c91:	83 f5 1f             	xor    $0x1f,%ebp
  801c94:	75 5a                	jne    801cf0 <__umoddi3+0xb0>
  801c96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c9a:	0f 82 e0 00 00 00    	jb     801d80 <__umoddi3+0x140>
  801ca0:	39 0c 24             	cmp    %ecx,(%esp)
  801ca3:	0f 86 d7 00 00 00    	jbe    801d80 <__umoddi3+0x140>
  801ca9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cb1:	83 c4 1c             	add    $0x1c,%esp
  801cb4:	5b                   	pop    %ebx
  801cb5:	5e                   	pop    %esi
  801cb6:	5f                   	pop    %edi
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	85 ff                	test   %edi,%edi
  801cc2:	89 fd                	mov    %edi,%ebp
  801cc4:	75 0b                	jne    801cd1 <__umoddi3+0x91>
  801cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	f7 f7                	div    %edi
  801ccf:	89 c5                	mov    %eax,%ebp
  801cd1:	89 f0                	mov    %esi,%eax
  801cd3:	31 d2                	xor    %edx,%edx
  801cd5:	f7 f5                	div    %ebp
  801cd7:	89 c8                	mov    %ecx,%eax
  801cd9:	f7 f5                	div    %ebp
  801cdb:	89 d0                	mov    %edx,%eax
  801cdd:	eb 99                	jmp    801c78 <__umoddi3+0x38>
  801cdf:	90                   	nop
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	83 c4 1c             	add    $0x1c,%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5f                   	pop    %edi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    
  801cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	8b 34 24             	mov    (%esp),%esi
  801cf3:	bf 20 00 00 00       	mov    $0x20,%edi
  801cf8:	89 e9                	mov    %ebp,%ecx
  801cfa:	29 ef                	sub    %ebp,%edi
  801cfc:	d3 e0                	shl    %cl,%eax
  801cfe:	89 f9                	mov    %edi,%ecx
  801d00:	89 f2                	mov    %esi,%edx
  801d02:	d3 ea                	shr    %cl,%edx
  801d04:	89 e9                	mov    %ebp,%ecx
  801d06:	09 c2                	or     %eax,%edx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 14 24             	mov    %edx,(%esp)
  801d0d:	89 f2                	mov    %esi,%edx
  801d0f:	d3 e2                	shl    %cl,%edx
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	89 e9                	mov    %ebp,%ecx
  801d1f:	89 c6                	mov    %eax,%esi
  801d21:	d3 e3                	shl    %cl,%ebx
  801d23:	89 f9                	mov    %edi,%ecx
  801d25:	89 d0                	mov    %edx,%eax
  801d27:	d3 e8                	shr    %cl,%eax
  801d29:	89 e9                	mov    %ebp,%ecx
  801d2b:	09 d8                	or     %ebx,%eax
  801d2d:	89 d3                	mov    %edx,%ebx
  801d2f:	89 f2                	mov    %esi,%edx
  801d31:	f7 34 24             	divl   (%esp)
  801d34:	89 d6                	mov    %edx,%esi
  801d36:	d3 e3                	shl    %cl,%ebx
  801d38:	f7 64 24 04          	mull   0x4(%esp)
  801d3c:	39 d6                	cmp    %edx,%esi
  801d3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d42:	89 d1                	mov    %edx,%ecx
  801d44:	89 c3                	mov    %eax,%ebx
  801d46:	72 08                	jb     801d50 <__umoddi3+0x110>
  801d48:	75 11                	jne    801d5b <__umoddi3+0x11b>
  801d4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d4e:	73 0b                	jae    801d5b <__umoddi3+0x11b>
  801d50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d54:	1b 14 24             	sbb    (%esp),%edx
  801d57:	89 d1                	mov    %edx,%ecx
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d5f:	29 da                	sub    %ebx,%edx
  801d61:	19 ce                	sbb    %ecx,%esi
  801d63:	89 f9                	mov    %edi,%ecx
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	d3 e0                	shl    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	d3 ea                	shr    %cl,%edx
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	d3 ee                	shr    %cl,%esi
  801d71:	09 d0                	or     %edx,%eax
  801d73:	89 f2                	mov    %esi,%edx
  801d75:	83 c4 1c             	add    $0x1c,%esp
  801d78:	5b                   	pop    %ebx
  801d79:	5e                   	pop    %esi
  801d7a:	5f                   	pop    %edi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    
  801d7d:	8d 76 00             	lea    0x0(%esi),%esi
  801d80:	29 f9                	sub    %edi,%ecx
  801d82:	19 d6                	sbb    %edx,%esi
  801d84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d8c:	e9 18 ff ff ff       	jmp    801ca9 <__umoddi3+0x69>
