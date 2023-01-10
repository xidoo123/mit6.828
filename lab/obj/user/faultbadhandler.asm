
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 e8 04 00 00       	call   80059e <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 8a 22 80 00       	push   $0x80228a
  80012f:	6a 23                	push   $0x23
  800131:	68 a7 22 80 00       	push   $0x8022a7
  800136:	e8 dc 13 00 00       	call   801517 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 8a 22 80 00       	push   $0x80228a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 a7 22 80 00       	push   $0x8022a7
  8001b7:	e8 5b 13 00 00       	call   801517 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 8a 22 80 00       	push   $0x80228a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 a7 22 80 00       	push   $0x8022a7
  8001f9:	e8 19 13 00 00       	call   801517 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 8a 22 80 00       	push   $0x80228a
  800234:	6a 23                	push   $0x23
  800236:	68 a7 22 80 00       	push   $0x8022a7
  80023b:	e8 d7 12 00 00       	call   801517 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 8a 22 80 00       	push   $0x80228a
  800276:	6a 23                	push   $0x23
  800278:	68 a7 22 80 00       	push   $0x8022a7
  80027d:	e8 95 12 00 00       	call   801517 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 8a 22 80 00       	push   $0x80228a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 a7 22 80 00       	push   $0x8022a7
  8002bf:	e8 53 12 00 00       	call   801517 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 8a 22 80 00       	push   $0x80228a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 a7 22 80 00       	push   $0x8022a7
  800301:	e8 11 12 00 00       	call   801517 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 8a 22 80 00       	push   $0x80228a
  80035e:	6a 23                	push   $0x23
  800360:	68 a7 22 80 00       	push   $0x8022a7
  800365:	e8 ad 11 00 00       	call   801517 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800382:	89 d1                	mov    %edx,%ecx
  800384:	89 d3                	mov    %edx,%ebx
  800386:	89 d7                	mov    %edx,%edi
  800388:	89 d6                	mov    %edx,%esi
  80038a:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
  800397:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80039f:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	89 df                	mov    %ebx,%edi
  8003ac:	89 de                	mov    %ebx,%esi
  8003ae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003b0:	85 c0                	test   %eax,%eax
  8003b2:	7e 17                	jle    8003cb <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b4:	83 ec 0c             	sub    $0xc,%esp
  8003b7:	50                   	push   %eax
  8003b8:	6a 0f                	push   $0xf
  8003ba:	68 8a 22 80 00       	push   $0x80228a
  8003bf:	6a 23                	push   $0x23
  8003c1:	68 a7 22 80 00       	push   $0x8022a7
  8003c6:	e8 4c 11 00 00       	call   801517 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ce:	5b                   	pop    %ebx
  8003cf:	5e                   	pop    %esi
  8003d0:	5f                   	pop    %edi
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8003de:	c1 e8 0c             	shr    $0xc,%eax
}
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003f3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800400:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800405:	89 c2                	mov    %eax,%edx
  800407:	c1 ea 16             	shr    $0x16,%edx
  80040a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800411:	f6 c2 01             	test   $0x1,%dl
  800414:	74 11                	je     800427 <fd_alloc+0x2d>
  800416:	89 c2                	mov    %eax,%edx
  800418:	c1 ea 0c             	shr    $0xc,%edx
  80041b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800422:	f6 c2 01             	test   $0x1,%dl
  800425:	75 09                	jne    800430 <fd_alloc+0x36>
			*fd_store = fd;
  800427:	89 01                	mov    %eax,(%ecx)
			return 0;
  800429:	b8 00 00 00 00       	mov    $0x0,%eax
  80042e:	eb 17                	jmp    800447 <fd_alloc+0x4d>
  800430:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800435:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80043a:	75 c9                	jne    800405 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80043c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800442:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800447:	5d                   	pop    %ebp
  800448:	c3                   	ret    

00800449 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800449:	55                   	push   %ebp
  80044a:	89 e5                	mov    %esp,%ebp
  80044c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80044f:	83 f8 1f             	cmp    $0x1f,%eax
  800452:	77 36                	ja     80048a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800454:	c1 e0 0c             	shl    $0xc,%eax
  800457:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80045c:	89 c2                	mov    %eax,%edx
  80045e:	c1 ea 16             	shr    $0x16,%edx
  800461:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800468:	f6 c2 01             	test   $0x1,%dl
  80046b:	74 24                	je     800491 <fd_lookup+0x48>
  80046d:	89 c2                	mov    %eax,%edx
  80046f:	c1 ea 0c             	shr    $0xc,%edx
  800472:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800479:	f6 c2 01             	test   $0x1,%dl
  80047c:	74 1a                	je     800498 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80047e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800481:	89 02                	mov    %eax,(%edx)
	return 0;
  800483:	b8 00 00 00 00       	mov    $0x0,%eax
  800488:	eb 13                	jmp    80049d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80048f:	eb 0c                	jmp    80049d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800491:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800496:	eb 05                	jmp    80049d <fd_lookup+0x54>
  800498:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80049d:	5d                   	pop    %ebp
  80049e:	c3                   	ret    

0080049f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a8:	ba 34 23 80 00       	mov    $0x802334,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004ad:	eb 13                	jmp    8004c2 <dev_lookup+0x23>
  8004af:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004b2:	39 08                	cmp    %ecx,(%eax)
  8004b4:	75 0c                	jne    8004c2 <dev_lookup+0x23>
			*dev = devtab[i];
  8004b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004b9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c0:	eb 2e                	jmp    8004f0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004c2:	8b 02                	mov    (%edx),%eax
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	75 e7                	jne    8004af <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004c8:	a1 08 40 80 00       	mov    0x804008,%eax
  8004cd:	8b 40 48             	mov    0x48(%eax),%eax
  8004d0:	83 ec 04             	sub    $0x4,%esp
  8004d3:	51                   	push   %ecx
  8004d4:	50                   	push   %eax
  8004d5:	68 b8 22 80 00       	push   $0x8022b8
  8004da:	e8 11 11 00 00       	call   8015f0 <cprintf>
	*dev = 0;
  8004df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004f0:	c9                   	leave  
  8004f1:	c3                   	ret    

008004f2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	56                   	push   %esi
  8004f6:	53                   	push   %ebx
  8004f7:	83 ec 10             	sub    $0x10,%esp
  8004fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800500:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800503:	50                   	push   %eax
  800504:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80050a:	c1 e8 0c             	shr    $0xc,%eax
  80050d:	50                   	push   %eax
  80050e:	e8 36 ff ff ff       	call   800449 <fd_lookup>
  800513:	83 c4 08             	add    $0x8,%esp
  800516:	85 c0                	test   %eax,%eax
  800518:	78 05                	js     80051f <fd_close+0x2d>
	    || fd != fd2)
  80051a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80051d:	74 0c                	je     80052b <fd_close+0x39>
		return (must_exist ? r : 0);
  80051f:	84 db                	test   %bl,%bl
  800521:	ba 00 00 00 00       	mov    $0x0,%edx
  800526:	0f 44 c2             	cmove  %edx,%eax
  800529:	eb 41                	jmp    80056c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800531:	50                   	push   %eax
  800532:	ff 36                	pushl  (%esi)
  800534:	e8 66 ff ff ff       	call   80049f <dev_lookup>
  800539:	89 c3                	mov    %eax,%ebx
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	85 c0                	test   %eax,%eax
  800540:	78 1a                	js     80055c <fd_close+0x6a>
		if (dev->dev_close)
  800542:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800545:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800548:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80054d:	85 c0                	test   %eax,%eax
  80054f:	74 0b                	je     80055c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	56                   	push   %esi
  800555:	ff d0                	call   *%eax
  800557:	89 c3                	mov    %eax,%ebx
  800559:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	56                   	push   %esi
  800560:	6a 00                	push   $0x0
  800562:	e8 9f fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	89 d8                	mov    %ebx,%eax
}
  80056c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80056f:	5b                   	pop    %ebx
  800570:	5e                   	pop    %esi
  800571:	5d                   	pop    %ebp
  800572:	c3                   	ret    

00800573 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800573:	55                   	push   %ebp
  800574:	89 e5                	mov    %esp,%ebp
  800576:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800579:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80057c:	50                   	push   %eax
  80057d:	ff 75 08             	pushl  0x8(%ebp)
  800580:	e8 c4 fe ff ff       	call   800449 <fd_lookup>
  800585:	83 c4 08             	add    $0x8,%esp
  800588:	85 c0                	test   %eax,%eax
  80058a:	78 10                	js     80059c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	6a 01                	push   $0x1
  800591:	ff 75 f4             	pushl  -0xc(%ebp)
  800594:	e8 59 ff ff ff       	call   8004f2 <fd_close>
  800599:	83 c4 10             	add    $0x10,%esp
}
  80059c:	c9                   	leave  
  80059d:	c3                   	ret    

0080059e <close_all>:

void
close_all(void)
{
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
  8005a1:	53                   	push   %ebx
  8005a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005aa:	83 ec 0c             	sub    $0xc,%esp
  8005ad:	53                   	push   %ebx
  8005ae:	e8 c0 ff ff ff       	call   800573 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005b3:	83 c3 01             	add    $0x1,%ebx
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	83 fb 20             	cmp    $0x20,%ebx
  8005bc:	75 ec                	jne    8005aa <close_all+0xc>
		close(i);
}
  8005be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005c1:	c9                   	leave  
  8005c2:	c3                   	ret    

008005c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005c3:	55                   	push   %ebp
  8005c4:	89 e5                	mov    %esp,%ebp
  8005c6:	57                   	push   %edi
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	83 ec 2c             	sub    $0x2c,%esp
  8005cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005d2:	50                   	push   %eax
  8005d3:	ff 75 08             	pushl  0x8(%ebp)
  8005d6:	e8 6e fe ff ff       	call   800449 <fd_lookup>
  8005db:	83 c4 08             	add    $0x8,%esp
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	0f 88 c1 00 00 00    	js     8006a7 <dup+0xe4>
		return r;
	close(newfdnum);
  8005e6:	83 ec 0c             	sub    $0xc,%esp
  8005e9:	56                   	push   %esi
  8005ea:	e8 84 ff ff ff       	call   800573 <close>

	newfd = INDEX2FD(newfdnum);
  8005ef:	89 f3                	mov    %esi,%ebx
  8005f1:	c1 e3 0c             	shl    $0xc,%ebx
  8005f4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005fa:	83 c4 04             	add    $0x4,%esp
  8005fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800600:	e8 de fd ff ff       	call   8003e3 <fd2data>
  800605:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800607:	89 1c 24             	mov    %ebx,(%esp)
  80060a:	e8 d4 fd ff ff       	call   8003e3 <fd2data>
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800615:	89 f8                	mov    %edi,%eax
  800617:	c1 e8 16             	shr    $0x16,%eax
  80061a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800621:	a8 01                	test   $0x1,%al
  800623:	74 37                	je     80065c <dup+0x99>
  800625:	89 f8                	mov    %edi,%eax
  800627:	c1 e8 0c             	shr    $0xc,%eax
  80062a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800631:	f6 c2 01             	test   $0x1,%dl
  800634:	74 26                	je     80065c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800636:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80063d:	83 ec 0c             	sub    $0xc,%esp
  800640:	25 07 0e 00 00       	and    $0xe07,%eax
  800645:	50                   	push   %eax
  800646:	ff 75 d4             	pushl  -0x2c(%ebp)
  800649:	6a 00                	push   $0x0
  80064b:	57                   	push   %edi
  80064c:	6a 00                	push   $0x0
  80064e:	e8 71 fb ff ff       	call   8001c4 <sys_page_map>
  800653:	89 c7                	mov    %eax,%edi
  800655:	83 c4 20             	add    $0x20,%esp
  800658:	85 c0                	test   %eax,%eax
  80065a:	78 2e                	js     80068a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80065c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065f:	89 d0                	mov    %edx,%eax
  800661:	c1 e8 0c             	shr    $0xc,%eax
  800664:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80066b:	83 ec 0c             	sub    $0xc,%esp
  80066e:	25 07 0e 00 00       	and    $0xe07,%eax
  800673:	50                   	push   %eax
  800674:	53                   	push   %ebx
  800675:	6a 00                	push   $0x0
  800677:	52                   	push   %edx
  800678:	6a 00                	push   $0x0
  80067a:	e8 45 fb ff ff       	call   8001c4 <sys_page_map>
  80067f:	89 c7                	mov    %eax,%edi
  800681:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800684:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800686:	85 ff                	test   %edi,%edi
  800688:	79 1d                	jns    8006a7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 00                	push   $0x0
  800690:	e8 71 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800695:	83 c4 08             	add    $0x8,%esp
  800698:	ff 75 d4             	pushl  -0x2c(%ebp)
  80069b:	6a 00                	push   $0x0
  80069d:	e8 64 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  8006a2:	83 c4 10             	add    $0x10,%esp
  8006a5:	89 f8                	mov    %edi,%eax
}
  8006a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006aa:	5b                   	pop    %ebx
  8006ab:	5e                   	pop    %esi
  8006ac:	5f                   	pop    %edi
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    

008006af <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	53                   	push   %ebx
  8006b3:	83 ec 14             	sub    $0x14,%esp
  8006b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	53                   	push   %ebx
  8006be:	e8 86 fd ff ff       	call   800449 <fd_lookup>
  8006c3:	83 c4 08             	add    $0x8,%esp
  8006c6:	89 c2                	mov    %eax,%edx
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	78 6d                	js     800739 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d6:	ff 30                	pushl  (%eax)
  8006d8:	e8 c2 fd ff ff       	call   80049f <dev_lookup>
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 4c                	js     800730 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006e7:	8b 42 08             	mov    0x8(%edx),%eax
  8006ea:	83 e0 03             	and    $0x3,%eax
  8006ed:	83 f8 01             	cmp    $0x1,%eax
  8006f0:	75 21                	jne    800713 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8006f7:	8b 40 48             	mov    0x48(%eax),%eax
  8006fa:	83 ec 04             	sub    $0x4,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	50                   	push   %eax
  8006ff:	68 f9 22 80 00       	push   $0x8022f9
  800704:	e8 e7 0e 00 00       	call   8015f0 <cprintf>
		return -E_INVAL;
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800711:	eb 26                	jmp    800739 <read+0x8a>
	}
	if (!dev->dev_read)
  800713:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800716:	8b 40 08             	mov    0x8(%eax),%eax
  800719:	85 c0                	test   %eax,%eax
  80071b:	74 17                	je     800734 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80071d:	83 ec 04             	sub    $0x4,%esp
  800720:	ff 75 10             	pushl  0x10(%ebp)
  800723:	ff 75 0c             	pushl  0xc(%ebp)
  800726:	52                   	push   %edx
  800727:	ff d0                	call   *%eax
  800729:	89 c2                	mov    %eax,%edx
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	eb 09                	jmp    800739 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800730:	89 c2                	mov    %eax,%edx
  800732:	eb 05                	jmp    800739 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800734:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800739:	89 d0                	mov    %edx,%eax
  80073b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	57                   	push   %edi
  800744:	56                   	push   %esi
  800745:	53                   	push   %ebx
  800746:	83 ec 0c             	sub    $0xc,%esp
  800749:	8b 7d 08             	mov    0x8(%ebp),%edi
  80074c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80074f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800754:	eb 21                	jmp    800777 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800756:	83 ec 04             	sub    $0x4,%esp
  800759:	89 f0                	mov    %esi,%eax
  80075b:	29 d8                	sub    %ebx,%eax
  80075d:	50                   	push   %eax
  80075e:	89 d8                	mov    %ebx,%eax
  800760:	03 45 0c             	add    0xc(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	57                   	push   %edi
  800765:	e8 45 ff ff ff       	call   8006af <read>
		if (m < 0)
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	85 c0                	test   %eax,%eax
  80076f:	78 10                	js     800781 <readn+0x41>
			return m;
		if (m == 0)
  800771:	85 c0                	test   %eax,%eax
  800773:	74 0a                	je     80077f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800775:	01 c3                	add    %eax,%ebx
  800777:	39 f3                	cmp    %esi,%ebx
  800779:	72 db                	jb     800756 <readn+0x16>
  80077b:	89 d8                	mov    %ebx,%eax
  80077d:	eb 02                	jmp    800781 <readn+0x41>
  80077f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5f                   	pop    %edi
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    

00800789 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	53                   	push   %ebx
  80078d:	83 ec 14             	sub    $0x14,%esp
  800790:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800793:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	53                   	push   %ebx
  800798:	e8 ac fc ff ff       	call   800449 <fd_lookup>
  80079d:	83 c4 08             	add    $0x8,%esp
  8007a0:	89 c2                	mov    %eax,%edx
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 68                	js     80080e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a6:	83 ec 08             	sub    $0x8,%esp
  8007a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007ac:	50                   	push   %eax
  8007ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b0:	ff 30                	pushl  (%eax)
  8007b2:	e8 e8 fc ff ff       	call   80049f <dev_lookup>
  8007b7:	83 c4 10             	add    $0x10,%esp
  8007ba:	85 c0                	test   %eax,%eax
  8007bc:	78 47                	js     800805 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007c5:	75 21                	jne    8007e8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8007cc:	8b 40 48             	mov    0x48(%eax),%eax
  8007cf:	83 ec 04             	sub    $0x4,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	50                   	push   %eax
  8007d4:	68 15 23 80 00       	push   $0x802315
  8007d9:	e8 12 0e 00 00       	call   8015f0 <cprintf>
		return -E_INVAL;
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007e6:	eb 26                	jmp    80080e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	74 17                	je     800809 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007f2:	83 ec 04             	sub    $0x4,%esp
  8007f5:	ff 75 10             	pushl  0x10(%ebp)
  8007f8:	ff 75 0c             	pushl  0xc(%ebp)
  8007fb:	50                   	push   %eax
  8007fc:	ff d2                	call   *%edx
  8007fe:	89 c2                	mov    %eax,%edx
  800800:	83 c4 10             	add    $0x10,%esp
  800803:	eb 09                	jmp    80080e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800805:	89 c2                	mov    %eax,%edx
  800807:	eb 05                	jmp    80080e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800809:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80080e:	89 d0                	mov    %edx,%eax
  800810:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <seek>:

int
seek(int fdnum, off_t offset)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80081b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80081e:	50                   	push   %eax
  80081f:	ff 75 08             	pushl  0x8(%ebp)
  800822:	e8 22 fc ff ff       	call   800449 <fd_lookup>
  800827:	83 c4 08             	add    $0x8,%esp
  80082a:	85 c0                	test   %eax,%eax
  80082c:	78 0e                	js     80083c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80082e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
  800834:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    

0080083e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	83 ec 14             	sub    $0x14,%esp
  800845:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800848:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084b:	50                   	push   %eax
  80084c:	53                   	push   %ebx
  80084d:	e8 f7 fb ff ff       	call   800449 <fd_lookup>
  800852:	83 c4 08             	add    $0x8,%esp
  800855:	89 c2                	mov    %eax,%edx
  800857:	85 c0                	test   %eax,%eax
  800859:	78 65                	js     8008c0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800861:	50                   	push   %eax
  800862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800865:	ff 30                	pushl  (%eax)
  800867:	e8 33 fc ff ff       	call   80049f <dev_lookup>
  80086c:	83 c4 10             	add    $0x10,%esp
  80086f:	85 c0                	test   %eax,%eax
  800871:	78 44                	js     8008b7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800873:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800876:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80087a:	75 21                	jne    80089d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80087c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800881:	8b 40 48             	mov    0x48(%eax),%eax
  800884:	83 ec 04             	sub    $0x4,%esp
  800887:	53                   	push   %ebx
  800888:	50                   	push   %eax
  800889:	68 d8 22 80 00       	push   $0x8022d8
  80088e:	e8 5d 0d 00 00       	call   8015f0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80089b:	eb 23                	jmp    8008c0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80089d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008a0:	8b 52 18             	mov    0x18(%edx),%edx
  8008a3:	85 d2                	test   %edx,%edx
  8008a5:	74 14                	je     8008bb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	ff 75 0c             	pushl  0xc(%ebp)
  8008ad:	50                   	push   %eax
  8008ae:	ff d2                	call   *%edx
  8008b0:	89 c2                	mov    %eax,%edx
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	eb 09                	jmp    8008c0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b7:	89 c2                	mov    %eax,%edx
  8008b9:	eb 05                	jmp    8008c0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008c0:	89 d0                	mov    %edx,%eax
  8008c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	83 ec 14             	sub    $0x14,%esp
  8008ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008d4:	50                   	push   %eax
  8008d5:	ff 75 08             	pushl  0x8(%ebp)
  8008d8:	e8 6c fb ff ff       	call   800449 <fd_lookup>
  8008dd:	83 c4 08             	add    $0x8,%esp
  8008e0:	89 c2                	mov    %eax,%edx
  8008e2:	85 c0                	test   %eax,%eax
  8008e4:	78 58                	js     80093e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e6:	83 ec 08             	sub    $0x8,%esp
  8008e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ec:	50                   	push   %eax
  8008ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f0:	ff 30                	pushl  (%eax)
  8008f2:	e8 a8 fb ff ff       	call   80049f <dev_lookup>
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	85 c0                	test   %eax,%eax
  8008fc:	78 37                	js     800935 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800901:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800905:	74 32                	je     800939 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800907:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80090a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800911:	00 00 00 
	stat->st_isdir = 0;
  800914:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80091b:	00 00 00 
	stat->st_dev = dev;
  80091e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	53                   	push   %ebx
  800928:	ff 75 f0             	pushl  -0x10(%ebp)
  80092b:	ff 50 14             	call   *0x14(%eax)
  80092e:	89 c2                	mov    %eax,%edx
  800930:	83 c4 10             	add    $0x10,%esp
  800933:	eb 09                	jmp    80093e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800935:	89 c2                	mov    %eax,%edx
  800937:	eb 05                	jmp    80093e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800939:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80093e:	89 d0                	mov    %edx,%eax
  800940:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80094a:	83 ec 08             	sub    $0x8,%esp
  80094d:	6a 00                	push   $0x0
  80094f:	ff 75 08             	pushl  0x8(%ebp)
  800952:	e8 d6 01 00 00       	call   800b2d <open>
  800957:	89 c3                	mov    %eax,%ebx
  800959:	83 c4 10             	add    $0x10,%esp
  80095c:	85 c0                	test   %eax,%eax
  80095e:	78 1b                	js     80097b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800960:	83 ec 08             	sub    $0x8,%esp
  800963:	ff 75 0c             	pushl  0xc(%ebp)
  800966:	50                   	push   %eax
  800967:	e8 5b ff ff ff       	call   8008c7 <fstat>
  80096c:	89 c6                	mov    %eax,%esi
	close(fd);
  80096e:	89 1c 24             	mov    %ebx,(%esp)
  800971:	e8 fd fb ff ff       	call   800573 <close>
	return r;
  800976:	83 c4 10             	add    $0x10,%esp
  800979:	89 f0                	mov    %esi,%eax
}
  80097b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	89 c6                	mov    %eax,%esi
  800989:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80098b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800992:	75 12                	jne    8009a6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800994:	83 ec 0c             	sub    $0xc,%esp
  800997:	6a 01                	push   $0x1
  800999:	e8 d9 15 00 00       	call   801f77 <ipc_find_env>
  80099e:	a3 00 40 80 00       	mov    %eax,0x804000
  8009a3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009a6:	6a 07                	push   $0x7
  8009a8:	68 00 50 80 00       	push   $0x805000
  8009ad:	56                   	push   %esi
  8009ae:	ff 35 00 40 80 00    	pushl  0x804000
  8009b4:	e8 6a 15 00 00       	call   801f23 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009b9:	83 c4 0c             	add    $0xc,%esp
  8009bc:	6a 00                	push   $0x0
  8009be:	53                   	push   %ebx
  8009bf:	6a 00                	push   $0x0
  8009c1:	e8 f6 14 00 00       	call   801ebc <ipc_recv>
}
  8009c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009c9:	5b                   	pop    %ebx
  8009ca:	5e                   	pop    %esi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8009f0:	e8 8d ff ff ff       	call   800982 <fsipc>
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 40 0c             	mov    0xc(%eax),%eax
  800a03:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a08:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0d:	b8 06 00 00 00       	mov    $0x6,%eax
  800a12:	e8 6b ff ff ff       	call   800982 <fsipc>
}
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	53                   	push   %ebx
  800a1d:	83 ec 04             	sub    $0x4,%esp
  800a20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 40 0c             	mov    0xc(%eax),%eax
  800a29:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a33:	b8 05 00 00 00       	mov    $0x5,%eax
  800a38:	e8 45 ff ff ff       	call   800982 <fsipc>
  800a3d:	85 c0                	test   %eax,%eax
  800a3f:	78 2c                	js     800a6d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a41:	83 ec 08             	sub    $0x8,%esp
  800a44:	68 00 50 80 00       	push   $0x805000
  800a49:	53                   	push   %ebx
  800a4a:	e8 26 11 00 00       	call   801b75 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a4f:	a1 80 50 80 00       	mov    0x805080,%eax
  800a54:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a5a:	a1 84 50 80 00       	mov    0x805084,%eax
  800a5f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a65:	83 c4 10             	add    $0x10,%esp
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	83 ec 0c             	sub    $0xc,%esp
  800a78:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7e:	8b 52 0c             	mov    0xc(%edx),%edx
  800a81:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a87:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a8c:	50                   	push   %eax
  800a8d:	ff 75 0c             	pushl  0xc(%ebp)
  800a90:	68 08 50 80 00       	push   $0x805008
  800a95:	e8 6d 12 00 00       	call   801d07 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800aa4:	e8 d9 fe ff ff       	call   800982 <fsipc>

}
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    

00800aab <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800abe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 03 00 00 00       	mov    $0x3,%eax
  800ace:	e8 af fe ff ff       	call   800982 <fsipc>
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	85 c0                	test   %eax,%eax
  800ad7:	78 4b                	js     800b24 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ad9:	39 c6                	cmp    %eax,%esi
  800adb:	73 16                	jae    800af3 <devfile_read+0x48>
  800add:	68 48 23 80 00       	push   $0x802348
  800ae2:	68 4f 23 80 00       	push   $0x80234f
  800ae7:	6a 7c                	push   $0x7c
  800ae9:	68 64 23 80 00       	push   $0x802364
  800aee:	e8 24 0a 00 00       	call   801517 <_panic>
	assert(r <= PGSIZE);
  800af3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800af8:	7e 16                	jle    800b10 <devfile_read+0x65>
  800afa:	68 6f 23 80 00       	push   $0x80236f
  800aff:	68 4f 23 80 00       	push   $0x80234f
  800b04:	6a 7d                	push   $0x7d
  800b06:	68 64 23 80 00       	push   $0x802364
  800b0b:	e8 07 0a 00 00       	call   801517 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b10:	83 ec 04             	sub    $0x4,%esp
  800b13:	50                   	push   %eax
  800b14:	68 00 50 80 00       	push   $0x805000
  800b19:	ff 75 0c             	pushl  0xc(%ebp)
  800b1c:	e8 e6 11 00 00       	call   801d07 <memmove>
	return r;
  800b21:	83 c4 10             	add    $0x10,%esp
}
  800b24:	89 d8                	mov    %ebx,%eax
  800b26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	53                   	push   %ebx
  800b31:	83 ec 20             	sub    $0x20,%esp
  800b34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b37:	53                   	push   %ebx
  800b38:	e8 ff 0f 00 00       	call   801b3c <strlen>
  800b3d:	83 c4 10             	add    $0x10,%esp
  800b40:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b45:	7f 67                	jg     800bae <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b4d:	50                   	push   %eax
  800b4e:	e8 a7 f8 ff ff       	call   8003fa <fd_alloc>
  800b53:	83 c4 10             	add    $0x10,%esp
		return r;
  800b56:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	78 57                	js     800bb3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b5c:	83 ec 08             	sub    $0x8,%esp
  800b5f:	53                   	push   %ebx
  800b60:	68 00 50 80 00       	push   $0x805000
  800b65:	e8 0b 10 00 00       	call   801b75 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b75:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7a:	e8 03 fe ff ff       	call   800982 <fsipc>
  800b7f:	89 c3                	mov    %eax,%ebx
  800b81:	83 c4 10             	add    $0x10,%esp
  800b84:	85 c0                	test   %eax,%eax
  800b86:	79 14                	jns    800b9c <open+0x6f>
		fd_close(fd, 0);
  800b88:	83 ec 08             	sub    $0x8,%esp
  800b8b:	6a 00                	push   $0x0
  800b8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b90:	e8 5d f9 ff ff       	call   8004f2 <fd_close>
		return r;
  800b95:	83 c4 10             	add    $0x10,%esp
  800b98:	89 da                	mov    %ebx,%edx
  800b9a:	eb 17                	jmp    800bb3 <open+0x86>
	}

	return fd2num(fd);
  800b9c:	83 ec 0c             	sub    $0xc,%esp
  800b9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba2:	e8 2c f8 ff ff       	call   8003d3 <fd2num>
  800ba7:	89 c2                	mov    %eax,%edx
  800ba9:	83 c4 10             	add    $0x10,%esp
  800bac:	eb 05                	jmp    800bb3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bae:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bb3:	89 d0                	mov    %edx,%eax
  800bb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 08 00 00 00       	mov    $0x8,%eax
  800bca:	e8 b3 fd ff ff       	call   800982 <fsipc>
}
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bd7:	68 7b 23 80 00       	push   $0x80237b
  800bdc:	ff 75 0c             	pushl  0xc(%ebp)
  800bdf:	e8 91 0f 00 00       	call   801b75 <strcpy>
	return 0;
}
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	53                   	push   %ebx
  800bef:	83 ec 10             	sub    $0x10,%esp
  800bf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bf5:	53                   	push   %ebx
  800bf6:	e8 b5 13 00 00       	call   801fb0 <pageref>
  800bfb:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bfe:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c03:	83 f8 01             	cmp    $0x1,%eax
  800c06:	75 10                	jne    800c18 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	ff 73 0c             	pushl  0xc(%ebx)
  800c0e:	e8 c0 02 00 00       	call   800ed3 <nsipc_close>
  800c13:	89 c2                	mov    %eax,%edx
  800c15:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c18:	89 d0                	mov    %edx,%eax
  800c1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c25:	6a 00                	push   $0x0
  800c27:	ff 75 10             	pushl  0x10(%ebp)
  800c2a:	ff 75 0c             	pushl  0xc(%ebp)
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	ff 70 0c             	pushl  0xc(%eax)
  800c33:	e8 78 03 00 00       	call   800fb0 <nsipc_send>
}
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c40:	6a 00                	push   $0x0
  800c42:	ff 75 10             	pushl  0x10(%ebp)
  800c45:	ff 75 0c             	pushl  0xc(%ebp)
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4b:	ff 70 0c             	pushl  0xc(%eax)
  800c4e:	e8 f1 02 00 00       	call   800f44 <nsipc_recv>
}
  800c53:	c9                   	leave  
  800c54:	c3                   	ret    

00800c55 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c5b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c5e:	52                   	push   %edx
  800c5f:	50                   	push   %eax
  800c60:	e8 e4 f7 ff ff       	call   800449 <fd_lookup>
  800c65:	83 c4 10             	add    $0x10,%esp
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	78 17                	js     800c83 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c6f:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c75:	39 08                	cmp    %ecx,(%eax)
  800c77:	75 05                	jne    800c7e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c79:	8b 40 0c             	mov    0xc(%eax),%eax
  800c7c:	eb 05                	jmp    800c83 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c7e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c83:	c9                   	leave  
  800c84:	c3                   	ret    

00800c85 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 1c             	sub    $0x1c,%esp
  800c8d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c92:	50                   	push   %eax
  800c93:	e8 62 f7 ff ff       	call   8003fa <fd_alloc>
  800c98:	89 c3                	mov    %eax,%ebx
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	78 1b                	js     800cbc <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800ca1:	83 ec 04             	sub    $0x4,%esp
  800ca4:	68 07 04 00 00       	push   $0x407
  800ca9:	ff 75 f4             	pushl  -0xc(%ebp)
  800cac:	6a 00                	push   $0x0
  800cae:	e8 ce f4 ff ff       	call   800181 <sys_page_alloc>
  800cb3:	89 c3                	mov    %eax,%ebx
  800cb5:	83 c4 10             	add    $0x10,%esp
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	79 10                	jns    800ccc <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	56                   	push   %esi
  800cc0:	e8 0e 02 00 00       	call   800ed3 <nsipc_close>
		return r;
  800cc5:	83 c4 10             	add    $0x10,%esp
  800cc8:	89 d8                	mov    %ebx,%eax
  800cca:	eb 24                	jmp    800cf0 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ccc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cda:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ce1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	e8 e6 f6 ff ff       	call   8003d3 <fd2num>
  800ced:	83 c4 10             	add    $0x10,%esp
}
  800cf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	e8 50 ff ff ff       	call   800c55 <fd2sockid>
		return r;
  800d05:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	78 1f                	js     800d2a <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d0b:	83 ec 04             	sub    $0x4,%esp
  800d0e:	ff 75 10             	pushl  0x10(%ebp)
  800d11:	ff 75 0c             	pushl  0xc(%ebp)
  800d14:	50                   	push   %eax
  800d15:	e8 12 01 00 00       	call   800e2c <nsipc_accept>
  800d1a:	83 c4 10             	add    $0x10,%esp
		return r;
  800d1d:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 07                	js     800d2a <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d23:	e8 5d ff ff ff       	call   800c85 <alloc_sockfd>
  800d28:	89 c1                	mov    %eax,%ecx
}
  800d2a:	89 c8                	mov    %ecx,%eax
  800d2c:	c9                   	leave  
  800d2d:	c3                   	ret    

00800d2e <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	e8 19 ff ff ff       	call   800c55 <fd2sockid>
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	78 12                	js     800d52 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d40:	83 ec 04             	sub    $0x4,%esp
  800d43:	ff 75 10             	pushl  0x10(%ebp)
  800d46:	ff 75 0c             	pushl  0xc(%ebp)
  800d49:	50                   	push   %eax
  800d4a:	e8 2d 01 00 00       	call   800e7c <nsipc_bind>
  800d4f:	83 c4 10             	add    $0x10,%esp
}
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <shutdown>:

int
shutdown(int s, int how)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5d:	e8 f3 fe ff ff       	call   800c55 <fd2sockid>
  800d62:	85 c0                	test   %eax,%eax
  800d64:	78 0f                	js     800d75 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d66:	83 ec 08             	sub    $0x8,%esp
  800d69:	ff 75 0c             	pushl  0xc(%ebp)
  800d6c:	50                   	push   %eax
  800d6d:	e8 3f 01 00 00       	call   800eb1 <nsipc_shutdown>
  800d72:	83 c4 10             	add    $0x10,%esp
}
  800d75:	c9                   	leave  
  800d76:	c3                   	ret    

00800d77 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	e8 d0 fe ff ff       	call   800c55 <fd2sockid>
  800d85:	85 c0                	test   %eax,%eax
  800d87:	78 12                	js     800d9b <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d89:	83 ec 04             	sub    $0x4,%esp
  800d8c:	ff 75 10             	pushl  0x10(%ebp)
  800d8f:	ff 75 0c             	pushl  0xc(%ebp)
  800d92:	50                   	push   %eax
  800d93:	e8 55 01 00 00       	call   800eed <nsipc_connect>
  800d98:	83 c4 10             	add    $0x10,%esp
}
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    

00800d9d <listen>:

int
listen(int s, int backlog)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
  800da6:	e8 aa fe ff ff       	call   800c55 <fd2sockid>
  800dab:	85 c0                	test   %eax,%eax
  800dad:	78 0f                	js     800dbe <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800daf:	83 ec 08             	sub    $0x8,%esp
  800db2:	ff 75 0c             	pushl  0xc(%ebp)
  800db5:	50                   	push   %eax
  800db6:	e8 67 01 00 00       	call   800f22 <nsipc_listen>
  800dbb:	83 c4 10             	add    $0x10,%esp
}
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    

00800dc0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dc6:	ff 75 10             	pushl  0x10(%ebp)
  800dc9:	ff 75 0c             	pushl  0xc(%ebp)
  800dcc:	ff 75 08             	pushl  0x8(%ebp)
  800dcf:	e8 3a 02 00 00       	call   80100e <nsipc_socket>
  800dd4:	83 c4 10             	add    $0x10,%esp
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	78 05                	js     800de0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800ddb:	e8 a5 fe ff ff       	call   800c85 <alloc_sockfd>
}
  800de0:	c9                   	leave  
  800de1:	c3                   	ret    

00800de2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	53                   	push   %ebx
  800de6:	83 ec 04             	sub    $0x4,%esp
  800de9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800deb:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800df2:	75 12                	jne    800e06 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800df4:	83 ec 0c             	sub    $0xc,%esp
  800df7:	6a 02                	push   $0x2
  800df9:	e8 79 11 00 00       	call   801f77 <ipc_find_env>
  800dfe:	a3 04 40 80 00       	mov    %eax,0x804004
  800e03:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e06:	6a 07                	push   $0x7
  800e08:	68 00 60 80 00       	push   $0x806000
  800e0d:	53                   	push   %ebx
  800e0e:	ff 35 04 40 80 00    	pushl  0x804004
  800e14:	e8 0a 11 00 00       	call   801f23 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e19:	83 c4 0c             	add    $0xc,%esp
  800e1c:	6a 00                	push   $0x0
  800e1e:	6a 00                	push   $0x0
  800e20:	6a 00                	push   $0x0
  800e22:	e8 95 10 00 00       	call   801ebc <ipc_recv>
}
  800e27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2a:	c9                   	leave  
  800e2b:	c3                   	ret    

00800e2c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e3c:	8b 06                	mov    (%esi),%eax
  800e3e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e43:	b8 01 00 00 00       	mov    $0x1,%eax
  800e48:	e8 95 ff ff ff       	call   800de2 <nsipc>
  800e4d:	89 c3                	mov    %eax,%ebx
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	78 20                	js     800e73 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	ff 35 10 60 80 00    	pushl  0x806010
  800e5c:	68 00 60 80 00       	push   $0x806000
  800e61:	ff 75 0c             	pushl  0xc(%ebp)
  800e64:	e8 9e 0e 00 00       	call   801d07 <memmove>
		*addrlen = ret->ret_addrlen;
  800e69:	a1 10 60 80 00       	mov    0x806010,%eax
  800e6e:	89 06                	mov    %eax,(%esi)
  800e70:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e73:	89 d8                	mov    %ebx,%eax
  800e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 08             	sub    $0x8,%esp
  800e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e8e:	53                   	push   %ebx
  800e8f:	ff 75 0c             	pushl  0xc(%ebp)
  800e92:	68 04 60 80 00       	push   $0x806004
  800e97:	e8 6b 0e 00 00       	call   801d07 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e9c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ea2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ea7:	e8 36 ff ff ff       	call   800de2 <nsipc>
}
  800eac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eaf:	c9                   	leave  
  800eb0:	c3                   	ret    

00800eb1 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ec7:	b8 03 00 00 00       	mov    $0x3,%eax
  800ecc:	e8 11 ff ff ff       	call   800de2 <nsipc>
}
  800ed1:	c9                   	leave  
  800ed2:	c3                   	ret    

00800ed3 <nsipc_close>:

int
nsipc_close(int s)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  800edc:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ee1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ee6:	e8 f7 fe ff ff       	call   800de2 <nsipc>
}
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    

00800eed <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 08             	sub    $0x8,%esp
  800ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800eff:	53                   	push   %ebx
  800f00:	ff 75 0c             	pushl  0xc(%ebp)
  800f03:	68 04 60 80 00       	push   $0x806004
  800f08:	e8 fa 0d 00 00       	call   801d07 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f0d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f13:	b8 05 00 00 00       	mov    $0x5,%eax
  800f18:	e8 c5 fe ff ff       	call   800de2 <nsipc>
}
  800f1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f28:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f33:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f38:	b8 06 00 00 00       	mov    $0x6,%eax
  800f3d:	e8 a0 fe ff ff       	call   800de2 <nsipc>
}
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f54:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f62:	b8 07 00 00 00       	mov    $0x7,%eax
  800f67:	e8 76 fe ff ff       	call   800de2 <nsipc>
  800f6c:	89 c3                	mov    %eax,%ebx
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 35                	js     800fa7 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f72:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f77:	7f 04                	jg     800f7d <nsipc_recv+0x39>
  800f79:	39 c6                	cmp    %eax,%esi
  800f7b:	7d 16                	jge    800f93 <nsipc_recv+0x4f>
  800f7d:	68 87 23 80 00       	push   $0x802387
  800f82:	68 4f 23 80 00       	push   $0x80234f
  800f87:	6a 62                	push   $0x62
  800f89:	68 9c 23 80 00       	push   $0x80239c
  800f8e:	e8 84 05 00 00       	call   801517 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f93:	83 ec 04             	sub    $0x4,%esp
  800f96:	50                   	push   %eax
  800f97:	68 00 60 80 00       	push   $0x806000
  800f9c:	ff 75 0c             	pushl  0xc(%ebp)
  800f9f:	e8 63 0d 00 00       	call   801d07 <memmove>
  800fa4:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fa7:	89 d8                	mov    %ebx,%eax
  800fa9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fc2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fc8:	7e 16                	jle    800fe0 <nsipc_send+0x30>
  800fca:	68 a8 23 80 00       	push   $0x8023a8
  800fcf:	68 4f 23 80 00       	push   $0x80234f
  800fd4:	6a 6d                	push   $0x6d
  800fd6:	68 9c 23 80 00       	push   $0x80239c
  800fdb:	e8 37 05 00 00       	call   801517 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fe0:	83 ec 04             	sub    $0x4,%esp
  800fe3:	53                   	push   %ebx
  800fe4:	ff 75 0c             	pushl  0xc(%ebp)
  800fe7:	68 0c 60 80 00       	push   $0x80600c
  800fec:	e8 16 0d 00 00       	call   801d07 <memmove>
	nsipcbuf.send.req_size = size;
  800ff1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800ff7:	8b 45 14             	mov    0x14(%ebp),%eax
  800ffa:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fff:	b8 08 00 00 00       	mov    $0x8,%eax
  801004:	e8 d9 fd ff ff       	call   800de2 <nsipc>
}
  801009:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80100c:	c9                   	leave  
  80100d:	c3                   	ret    

0080100e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801014:	8b 45 08             	mov    0x8(%ebp),%eax
  801017:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80101c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801024:	8b 45 10             	mov    0x10(%ebp),%eax
  801027:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80102c:	b8 09 00 00 00       	mov    $0x9,%eax
  801031:	e8 ac fd ff ff       	call   800de2 <nsipc>
}
  801036:	c9                   	leave  
  801037:	c3                   	ret    

00801038 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	ff 75 08             	pushl  0x8(%ebp)
  801046:	e8 98 f3 ff ff       	call   8003e3 <fd2data>
  80104b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80104d:	83 c4 08             	add    $0x8,%esp
  801050:	68 b4 23 80 00       	push   $0x8023b4
  801055:	53                   	push   %ebx
  801056:	e8 1a 0b 00 00       	call   801b75 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80105b:	8b 46 04             	mov    0x4(%esi),%eax
  80105e:	2b 06                	sub    (%esi),%eax
  801060:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801066:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80106d:	00 00 00 
	stat->st_dev = &devpipe;
  801070:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801077:	30 80 00 
	return 0;
}
  80107a:	b8 00 00 00 00       	mov    $0x0,%eax
  80107f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	53                   	push   %ebx
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801090:	53                   	push   %ebx
  801091:	6a 00                	push   $0x0
  801093:	e8 6e f1 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801098:	89 1c 24             	mov    %ebx,(%esp)
  80109b:	e8 43 f3 ff ff       	call   8003e3 <fd2data>
  8010a0:	83 c4 08             	add    $0x8,%esp
  8010a3:	50                   	push   %eax
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 5b f1 ff ff       	call   800206 <sys_page_unmap>
}
  8010ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 1c             	sub    $0x1c,%esp
  8010b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010bc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010be:	a1 08 40 80 00       	mov    0x804008,%eax
  8010c3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8010cc:	e8 df 0e 00 00       	call   801fb0 <pageref>
  8010d1:	89 c3                	mov    %eax,%ebx
  8010d3:	89 3c 24             	mov    %edi,(%esp)
  8010d6:	e8 d5 0e 00 00       	call   801fb0 <pageref>
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	39 c3                	cmp    %eax,%ebx
  8010e0:	0f 94 c1             	sete   %cl
  8010e3:	0f b6 c9             	movzbl %cl,%ecx
  8010e6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010e9:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010ef:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010f2:	39 ce                	cmp    %ecx,%esi
  8010f4:	74 1b                	je     801111 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010f6:	39 c3                	cmp    %eax,%ebx
  8010f8:	75 c4                	jne    8010be <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010fa:	8b 42 58             	mov    0x58(%edx),%eax
  8010fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801100:	50                   	push   %eax
  801101:	56                   	push   %esi
  801102:	68 bb 23 80 00       	push   $0x8023bb
  801107:	e8 e4 04 00 00       	call   8015f0 <cprintf>
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	eb ad                	jmp    8010be <_pipeisclosed+0xe>
	}
}
  801111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5f                   	pop    %edi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	57                   	push   %edi
  801120:	56                   	push   %esi
  801121:	53                   	push   %ebx
  801122:	83 ec 28             	sub    $0x28,%esp
  801125:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801128:	56                   	push   %esi
  801129:	e8 b5 f2 ff ff       	call   8003e3 <fd2data>
  80112e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	bf 00 00 00 00       	mov    $0x0,%edi
  801138:	eb 4b                	jmp    801185 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80113a:	89 da                	mov    %ebx,%edx
  80113c:	89 f0                	mov    %esi,%eax
  80113e:	e8 6d ff ff ff       	call   8010b0 <_pipeisclosed>
  801143:	85 c0                	test   %eax,%eax
  801145:	75 48                	jne    80118f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801147:	e8 16 f0 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80114c:	8b 43 04             	mov    0x4(%ebx),%eax
  80114f:	8b 0b                	mov    (%ebx),%ecx
  801151:	8d 51 20             	lea    0x20(%ecx),%edx
  801154:	39 d0                	cmp    %edx,%eax
  801156:	73 e2                	jae    80113a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80115f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801162:	89 c2                	mov    %eax,%edx
  801164:	c1 fa 1f             	sar    $0x1f,%edx
  801167:	89 d1                	mov    %edx,%ecx
  801169:	c1 e9 1b             	shr    $0x1b,%ecx
  80116c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80116f:	83 e2 1f             	and    $0x1f,%edx
  801172:	29 ca                	sub    %ecx,%edx
  801174:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801178:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80117c:	83 c0 01             	add    $0x1,%eax
  80117f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801182:	83 c7 01             	add    $0x1,%edi
  801185:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801188:	75 c2                	jne    80114c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80118a:	8b 45 10             	mov    0x10(%ebp),%eax
  80118d:	eb 05                	jmp    801194 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80118f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	57                   	push   %edi
  8011a0:	56                   	push   %esi
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 18             	sub    $0x18,%esp
  8011a5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011a8:	57                   	push   %edi
  8011a9:	e8 35 f2 ff ff       	call   8003e3 <fd2data>
  8011ae:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b8:	eb 3d                	jmp    8011f7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011ba:	85 db                	test   %ebx,%ebx
  8011bc:	74 04                	je     8011c2 <devpipe_read+0x26>
				return i;
  8011be:	89 d8                	mov    %ebx,%eax
  8011c0:	eb 44                	jmp    801206 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011c2:	89 f2                	mov    %esi,%edx
  8011c4:	89 f8                	mov    %edi,%eax
  8011c6:	e8 e5 fe ff ff       	call   8010b0 <_pipeisclosed>
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	75 32                	jne    801201 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011cf:	e8 8e ef ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011d4:	8b 06                	mov    (%esi),%eax
  8011d6:	3b 46 04             	cmp    0x4(%esi),%eax
  8011d9:	74 df                	je     8011ba <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011db:	99                   	cltd   
  8011dc:	c1 ea 1b             	shr    $0x1b,%edx
  8011df:	01 d0                	add    %edx,%eax
  8011e1:	83 e0 1f             	and    $0x1f,%eax
  8011e4:	29 d0                	sub    %edx,%eax
  8011e6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ee:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011f1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011f4:	83 c3 01             	add    $0x1,%ebx
  8011f7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011fa:	75 d8                	jne    8011d4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ff:	eb 05                	jmp    801206 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801201:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801209:	5b                   	pop    %ebx
  80120a:	5e                   	pop    %esi
  80120b:	5f                   	pop    %edi
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	e8 db f1 ff ff       	call   8003fa <fd_alloc>
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	89 c2                	mov    %eax,%edx
  801224:	85 c0                	test   %eax,%eax
  801226:	0f 88 2c 01 00 00    	js     801358 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	68 07 04 00 00       	push   $0x407
  801234:	ff 75 f4             	pushl  -0xc(%ebp)
  801237:	6a 00                	push   $0x0
  801239:	e8 43 ef ff ff       	call   800181 <sys_page_alloc>
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	89 c2                	mov    %eax,%edx
  801243:	85 c0                	test   %eax,%eax
  801245:	0f 88 0d 01 00 00    	js     801358 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80124b:	83 ec 0c             	sub    $0xc,%esp
  80124e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	e8 a3 f1 ff ff       	call   8003fa <fd_alloc>
  801257:	89 c3                	mov    %eax,%ebx
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	0f 88 e2 00 00 00    	js     801346 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801264:	83 ec 04             	sub    $0x4,%esp
  801267:	68 07 04 00 00       	push   $0x407
  80126c:	ff 75 f0             	pushl  -0x10(%ebp)
  80126f:	6a 00                	push   $0x0
  801271:	e8 0b ef ff ff       	call   800181 <sys_page_alloc>
  801276:	89 c3                	mov    %eax,%ebx
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	0f 88 c3 00 00 00    	js     801346 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801283:	83 ec 0c             	sub    $0xc,%esp
  801286:	ff 75 f4             	pushl  -0xc(%ebp)
  801289:	e8 55 f1 ff ff       	call   8003e3 <fd2data>
  80128e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801290:	83 c4 0c             	add    $0xc,%esp
  801293:	68 07 04 00 00       	push   $0x407
  801298:	50                   	push   %eax
  801299:	6a 00                	push   $0x0
  80129b:	e8 e1 ee ff ff       	call   800181 <sys_page_alloc>
  8012a0:	89 c3                	mov    %eax,%ebx
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	0f 88 89 00 00 00    	js     801336 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8012b3:	e8 2b f1 ff ff       	call   8003e3 <fd2data>
  8012b8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012bf:	50                   	push   %eax
  8012c0:	6a 00                	push   $0x0
  8012c2:	56                   	push   %esi
  8012c3:	6a 00                	push   $0x0
  8012c5:	e8 fa ee ff ff       	call   8001c4 <sys_page_map>
  8012ca:	89 c3                	mov    %eax,%ebx
  8012cc:	83 c4 20             	add    $0x20,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 55                	js     801328 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012d3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012dc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012e8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012fd:	83 ec 0c             	sub    $0xc,%esp
  801300:	ff 75 f4             	pushl  -0xc(%ebp)
  801303:	e8 cb f0 ff ff       	call   8003d3 <fd2num>
  801308:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80130d:	83 c4 04             	add    $0x4,%esp
  801310:	ff 75 f0             	pushl  -0x10(%ebp)
  801313:	e8 bb f0 ff ff       	call   8003d3 <fd2num>
  801318:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	ba 00 00 00 00       	mov    $0x0,%edx
  801326:	eb 30                	jmp    801358 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	56                   	push   %esi
  80132c:	6a 00                	push   $0x0
  80132e:	e8 d3 ee ff ff       	call   800206 <sys_page_unmap>
  801333:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	ff 75 f0             	pushl  -0x10(%ebp)
  80133c:	6a 00                	push   $0x0
  80133e:	e8 c3 ee ff ff       	call   800206 <sys_page_unmap>
  801343:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	ff 75 f4             	pushl  -0xc(%ebp)
  80134c:	6a 00                	push   $0x0
  80134e:	e8 b3 ee ff ff       	call   800206 <sys_page_unmap>
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801358:	89 d0                	mov    %edx,%eax
  80135a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5d                   	pop    %ebp
  801360:	c3                   	ret    

00801361 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136a:	50                   	push   %eax
  80136b:	ff 75 08             	pushl  0x8(%ebp)
  80136e:	e8 d6 f0 ff ff       	call   800449 <fd_lookup>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	78 18                	js     801392 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80137a:	83 ec 0c             	sub    $0xc,%esp
  80137d:	ff 75 f4             	pushl  -0xc(%ebp)
  801380:	e8 5e f0 ff ff       	call   8003e3 <fd2data>
	return _pipeisclosed(fd, p);
  801385:	89 c2                	mov    %eax,%edx
  801387:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138a:	e8 21 fd ff ff       	call   8010b0 <_pipeisclosed>
  80138f:	83 c4 10             	add    $0x10,%esp
}
  801392:	c9                   	leave  
  801393:	c3                   	ret    

00801394 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801397:	b8 00 00 00 00       	mov    $0x0,%eax
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013a4:	68 d3 23 80 00       	push   $0x8023d3
  8013a9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ac:	e8 c4 07 00 00       	call   801b75 <strcpy>
	return 0;
}
  8013b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b6:	c9                   	leave  
  8013b7:	c3                   	ret    

008013b8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	57                   	push   %edi
  8013bc:	56                   	push   %esi
  8013bd:	53                   	push   %ebx
  8013be:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013c9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013cf:	eb 2d                	jmp    8013fe <devcons_write+0x46>
		m = n - tot;
  8013d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013d4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013d6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013d9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013de:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013e1:	83 ec 04             	sub    $0x4,%esp
  8013e4:	53                   	push   %ebx
  8013e5:	03 45 0c             	add    0xc(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	57                   	push   %edi
  8013ea:	e8 18 09 00 00       	call   801d07 <memmove>
		sys_cputs(buf, m);
  8013ef:	83 c4 08             	add    $0x8,%esp
  8013f2:	53                   	push   %ebx
  8013f3:	57                   	push   %edi
  8013f4:	e8 cc ec ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013f9:	01 de                	add    %ebx,%esi
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	89 f0                	mov    %esi,%eax
  801400:	3b 75 10             	cmp    0x10(%ebp),%esi
  801403:	72 cc                	jb     8013d1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801405:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	5f                   	pop    %edi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	83 ec 08             	sub    $0x8,%esp
  801413:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801418:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80141c:	74 2a                	je     801448 <devcons_read+0x3b>
  80141e:	eb 05                	jmp    801425 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801420:	e8 3d ed ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801425:	e8 b9 ec ff ff       	call   8000e3 <sys_cgetc>
  80142a:	85 c0                	test   %eax,%eax
  80142c:	74 f2                	je     801420 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80142e:	85 c0                	test   %eax,%eax
  801430:	78 16                	js     801448 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801432:	83 f8 04             	cmp    $0x4,%eax
  801435:	74 0c                	je     801443 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801437:	8b 55 0c             	mov    0xc(%ebp),%edx
  80143a:	88 02                	mov    %al,(%edx)
	return 1;
  80143c:	b8 01 00 00 00       	mov    $0x1,%eax
  801441:	eb 05                	jmp    801448 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801443:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801450:	8b 45 08             	mov    0x8(%ebp),%eax
  801453:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801456:	6a 01                	push   $0x1
  801458:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80145b:	50                   	push   %eax
  80145c:	e8 64 ec ff ff       	call   8000c5 <sys_cputs>
}
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <getchar>:

int
getchar(void)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80146c:	6a 01                	push   $0x1
  80146e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	6a 00                	push   $0x0
  801474:	e8 36 f2 ff ff       	call   8006af <read>
	if (r < 0)
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 0f                	js     80148f <getchar+0x29>
		return r;
	if (r < 1)
  801480:	85 c0                	test   %eax,%eax
  801482:	7e 06                	jle    80148a <getchar+0x24>
		return -E_EOF;
	return c;
  801484:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801488:	eb 05                	jmp    80148f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80148a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801497:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	ff 75 08             	pushl  0x8(%ebp)
  80149e:	e8 a6 ef ff ff       	call   800449 <fd_lookup>
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 11                	js     8014bb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ad:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014b3:	39 10                	cmp    %edx,(%eax)
  8014b5:	0f 94 c0             	sete   %al
  8014b8:	0f b6 c0             	movzbl %al,%eax
}
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    

008014bd <opencons>:

int
opencons(void)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	e8 2e ef ff ff       	call   8003fa <fd_alloc>
  8014cc:	83 c4 10             	add    $0x10,%esp
		return r;
  8014cf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 3e                	js     801513 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	68 07 04 00 00       	push   $0x407
  8014dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e0:	6a 00                	push   $0x0
  8014e2:	e8 9a ec ff ff       	call   800181 <sys_page_alloc>
  8014e7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ea:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 23                	js     801513 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014f0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	50                   	push   %eax
  801509:	e8 c5 ee ff ff       	call   8003d3 <fd2num>
  80150e:	89 c2                	mov    %eax,%edx
  801510:	83 c4 10             	add    $0x10,%esp
}
  801513:	89 d0                	mov    %edx,%eax
  801515:	c9                   	leave  
  801516:	c3                   	ret    

00801517 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	56                   	push   %esi
  80151b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80151c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80151f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801525:	e8 19 ec ff ff       	call   800143 <sys_getenvid>
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	ff 75 0c             	pushl  0xc(%ebp)
  801530:	ff 75 08             	pushl  0x8(%ebp)
  801533:	56                   	push   %esi
  801534:	50                   	push   %eax
  801535:	68 e0 23 80 00       	push   $0x8023e0
  80153a:	e8 b1 00 00 00       	call   8015f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80153f:	83 c4 18             	add    $0x18,%esp
  801542:	53                   	push   %ebx
  801543:	ff 75 10             	pushl  0x10(%ebp)
  801546:	e8 54 00 00 00       	call   80159f <vcprintf>
	cprintf("\n");
  80154b:	c7 04 24 cc 23 80 00 	movl   $0x8023cc,(%esp)
  801552:	e8 99 00 00 00       	call   8015f0 <cprintf>
  801557:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80155a:	cc                   	int3   
  80155b:	eb fd                	jmp    80155a <_panic+0x43>

0080155d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	53                   	push   %ebx
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801567:	8b 13                	mov    (%ebx),%edx
  801569:	8d 42 01             	lea    0x1(%edx),%eax
  80156c:	89 03                	mov    %eax,(%ebx)
  80156e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801571:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801575:	3d ff 00 00 00       	cmp    $0xff,%eax
  80157a:	75 1a                	jne    801596 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	68 ff 00 00 00       	push   $0xff
  801584:	8d 43 08             	lea    0x8(%ebx),%eax
  801587:	50                   	push   %eax
  801588:	e8 38 eb ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  80158d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801593:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801596:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015af:	00 00 00 
	b.cnt = 0;
  8015b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015bc:	ff 75 0c             	pushl  0xc(%ebp)
  8015bf:	ff 75 08             	pushl  0x8(%ebp)
  8015c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	68 5d 15 80 00       	push   $0x80155d
  8015ce:	e8 54 01 00 00       	call   801727 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015d3:	83 c4 08             	add    $0x8,%esp
  8015d6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	e8 dd ea ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  8015e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015f9:	50                   	push   %eax
  8015fa:	ff 75 08             	pushl  0x8(%ebp)
  8015fd:	e8 9d ff ff ff       	call   80159f <vcprintf>
	va_end(ap);

	return cnt;
}
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	57                   	push   %edi
  801608:	56                   	push   %esi
  801609:	53                   	push   %ebx
  80160a:	83 ec 1c             	sub    $0x1c,%esp
  80160d:	89 c7                	mov    %eax,%edi
  80160f:	89 d6                	mov    %edx,%esi
  801611:	8b 45 08             	mov    0x8(%ebp),%eax
  801614:	8b 55 0c             	mov    0xc(%ebp),%edx
  801617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80161a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80161d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801620:	bb 00 00 00 00       	mov    $0x0,%ebx
  801625:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801628:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80162b:	39 d3                	cmp    %edx,%ebx
  80162d:	72 05                	jb     801634 <printnum+0x30>
  80162f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801632:	77 45                	ja     801679 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801634:	83 ec 0c             	sub    $0xc,%esp
  801637:	ff 75 18             	pushl  0x18(%ebp)
  80163a:	8b 45 14             	mov    0x14(%ebp),%eax
  80163d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801640:	53                   	push   %ebx
  801641:	ff 75 10             	pushl  0x10(%ebp)
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164a:	ff 75 e0             	pushl  -0x20(%ebp)
  80164d:	ff 75 dc             	pushl  -0x24(%ebp)
  801650:	ff 75 d8             	pushl  -0x28(%ebp)
  801653:	e8 98 09 00 00       	call   801ff0 <__udivdi3>
  801658:	83 c4 18             	add    $0x18,%esp
  80165b:	52                   	push   %edx
  80165c:	50                   	push   %eax
  80165d:	89 f2                	mov    %esi,%edx
  80165f:	89 f8                	mov    %edi,%eax
  801661:	e8 9e ff ff ff       	call   801604 <printnum>
  801666:	83 c4 20             	add    $0x20,%esp
  801669:	eb 18                	jmp    801683 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	56                   	push   %esi
  80166f:	ff 75 18             	pushl  0x18(%ebp)
  801672:	ff d7                	call   *%edi
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	eb 03                	jmp    80167c <printnum+0x78>
  801679:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80167c:	83 eb 01             	sub    $0x1,%ebx
  80167f:	85 db                	test   %ebx,%ebx
  801681:	7f e8                	jg     80166b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	56                   	push   %esi
  801687:	83 ec 04             	sub    $0x4,%esp
  80168a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80168d:	ff 75 e0             	pushl  -0x20(%ebp)
  801690:	ff 75 dc             	pushl  -0x24(%ebp)
  801693:	ff 75 d8             	pushl  -0x28(%ebp)
  801696:	e8 85 0a 00 00       	call   802120 <__umoddi3>
  80169b:	83 c4 14             	add    $0x14,%esp
  80169e:	0f be 80 03 24 80 00 	movsbl 0x802403(%eax),%eax
  8016a5:	50                   	push   %eax
  8016a6:	ff d7                	call   *%edi
}
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5f                   	pop    %edi
  8016b1:	5d                   	pop    %ebp
  8016b2:	c3                   	ret    

008016b3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016b6:	83 fa 01             	cmp    $0x1,%edx
  8016b9:	7e 0e                	jle    8016c9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016bb:	8b 10                	mov    (%eax),%edx
  8016bd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016c0:	89 08                	mov    %ecx,(%eax)
  8016c2:	8b 02                	mov    (%edx),%eax
  8016c4:	8b 52 04             	mov    0x4(%edx),%edx
  8016c7:	eb 22                	jmp    8016eb <getuint+0x38>
	else if (lflag)
  8016c9:	85 d2                	test   %edx,%edx
  8016cb:	74 10                	je     8016dd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016cd:	8b 10                	mov    (%eax),%edx
  8016cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016d2:	89 08                	mov    %ecx,(%eax)
  8016d4:	8b 02                	mov    (%edx),%eax
  8016d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016db:	eb 0e                	jmp    8016eb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016dd:	8b 10                	mov    (%eax),%edx
  8016df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016e2:	89 08                	mov    %ecx,(%eax)
  8016e4:	8b 02                	mov    (%edx),%eax
  8016e6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016f3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016f7:	8b 10                	mov    (%eax),%edx
  8016f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8016fc:	73 0a                	jae    801708 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016fe:	8d 4a 01             	lea    0x1(%edx),%ecx
  801701:	89 08                	mov    %ecx,(%eax)
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	88 02                	mov    %al,(%edx)
}
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801710:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801713:	50                   	push   %eax
  801714:	ff 75 10             	pushl  0x10(%ebp)
  801717:	ff 75 0c             	pushl  0xc(%ebp)
  80171a:	ff 75 08             	pushl  0x8(%ebp)
  80171d:	e8 05 00 00 00       	call   801727 <vprintfmt>
	va_end(ap);
}
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	57                   	push   %edi
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 2c             	sub    $0x2c,%esp
  801730:	8b 75 08             	mov    0x8(%ebp),%esi
  801733:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801736:	8b 7d 10             	mov    0x10(%ebp),%edi
  801739:	eb 12                	jmp    80174d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80173b:	85 c0                	test   %eax,%eax
  80173d:	0f 84 89 03 00 00    	je     801acc <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	53                   	push   %ebx
  801747:	50                   	push   %eax
  801748:	ff d6                	call   *%esi
  80174a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80174d:	83 c7 01             	add    $0x1,%edi
  801750:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801754:	83 f8 25             	cmp    $0x25,%eax
  801757:	75 e2                	jne    80173b <vprintfmt+0x14>
  801759:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80175d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801764:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80176b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801772:	ba 00 00 00 00       	mov    $0x0,%edx
  801777:	eb 07                	jmp    801780 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801779:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80177c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801780:	8d 47 01             	lea    0x1(%edi),%eax
  801783:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801786:	0f b6 07             	movzbl (%edi),%eax
  801789:	0f b6 c8             	movzbl %al,%ecx
  80178c:	83 e8 23             	sub    $0x23,%eax
  80178f:	3c 55                	cmp    $0x55,%al
  801791:	0f 87 1a 03 00 00    	ja     801ab1 <vprintfmt+0x38a>
  801797:	0f b6 c0             	movzbl %al,%eax
  80179a:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  8017a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017a4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017a8:	eb d6                	jmp    801780 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017b5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017b8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017bc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017bf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017c2:	83 fa 09             	cmp    $0x9,%edx
  8017c5:	77 39                	ja     801800 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017c7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017ca:	eb e9                	jmp    8017b5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8017cf:	8d 48 04             	lea    0x4(%eax),%ecx
  8017d2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017d5:	8b 00                	mov    (%eax),%eax
  8017d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017dd:	eb 27                	jmp    801806 <vprintfmt+0xdf>
  8017df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017e9:	0f 49 c8             	cmovns %eax,%ecx
  8017ec:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017f2:	eb 8c                	jmp    801780 <vprintfmt+0x59>
  8017f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017f7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017fe:	eb 80                	jmp    801780 <vprintfmt+0x59>
  801800:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801803:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801806:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80180a:	0f 89 70 ff ff ff    	jns    801780 <vprintfmt+0x59>
				width = precision, precision = -1;
  801810:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801813:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801816:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80181d:	e9 5e ff ff ff       	jmp    801780 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801822:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801825:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801828:	e9 53 ff ff ff       	jmp    801780 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80182d:	8b 45 14             	mov    0x14(%ebp),%eax
  801830:	8d 50 04             	lea    0x4(%eax),%edx
  801833:	89 55 14             	mov    %edx,0x14(%ebp)
  801836:	83 ec 08             	sub    $0x8,%esp
  801839:	53                   	push   %ebx
  80183a:	ff 30                	pushl  (%eax)
  80183c:	ff d6                	call   *%esi
			break;
  80183e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801841:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801844:	e9 04 ff ff ff       	jmp    80174d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801849:	8b 45 14             	mov    0x14(%ebp),%eax
  80184c:	8d 50 04             	lea    0x4(%eax),%edx
  80184f:	89 55 14             	mov    %edx,0x14(%ebp)
  801852:	8b 00                	mov    (%eax),%eax
  801854:	99                   	cltd   
  801855:	31 d0                	xor    %edx,%eax
  801857:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801859:	83 f8 0f             	cmp    $0xf,%eax
  80185c:	7f 0b                	jg     801869 <vprintfmt+0x142>
  80185e:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  801865:	85 d2                	test   %edx,%edx
  801867:	75 18                	jne    801881 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801869:	50                   	push   %eax
  80186a:	68 1b 24 80 00       	push   $0x80241b
  80186f:	53                   	push   %ebx
  801870:	56                   	push   %esi
  801871:	e8 94 fe ff ff       	call   80170a <printfmt>
  801876:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801879:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80187c:	e9 cc fe ff ff       	jmp    80174d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801881:	52                   	push   %edx
  801882:	68 61 23 80 00       	push   $0x802361
  801887:	53                   	push   %ebx
  801888:	56                   	push   %esi
  801889:	e8 7c fe ff ff       	call   80170a <printfmt>
  80188e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801891:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801894:	e9 b4 fe ff ff       	jmp    80174d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801899:	8b 45 14             	mov    0x14(%ebp),%eax
  80189c:	8d 50 04             	lea    0x4(%eax),%edx
  80189f:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018a4:	85 ff                	test   %edi,%edi
  8018a6:	b8 14 24 80 00       	mov    $0x802414,%eax
  8018ab:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018b2:	0f 8e 94 00 00 00    	jle    80194c <vprintfmt+0x225>
  8018b8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018bc:	0f 84 98 00 00 00    	je     80195a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	ff 75 d0             	pushl  -0x30(%ebp)
  8018c8:	57                   	push   %edi
  8018c9:	e8 86 02 00 00       	call   801b54 <strnlen>
  8018ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018d1:	29 c1                	sub    %eax,%ecx
  8018d3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018d6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018e5:	eb 0f                	jmp    8018f6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	53                   	push   %ebx
  8018eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018f0:	83 ef 01             	sub    $0x1,%edi
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	85 ff                	test   %edi,%edi
  8018f8:	7f ed                	jg     8018e7 <vprintfmt+0x1c0>
  8018fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018fd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801900:	85 c9                	test   %ecx,%ecx
  801902:	b8 00 00 00 00       	mov    $0x0,%eax
  801907:	0f 49 c1             	cmovns %ecx,%eax
  80190a:	29 c1                	sub    %eax,%ecx
  80190c:	89 75 08             	mov    %esi,0x8(%ebp)
  80190f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801912:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801915:	89 cb                	mov    %ecx,%ebx
  801917:	eb 4d                	jmp    801966 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801919:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80191d:	74 1b                	je     80193a <vprintfmt+0x213>
  80191f:	0f be c0             	movsbl %al,%eax
  801922:	83 e8 20             	sub    $0x20,%eax
  801925:	83 f8 5e             	cmp    $0x5e,%eax
  801928:	76 10                	jbe    80193a <vprintfmt+0x213>
					putch('?', putdat);
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	ff 75 0c             	pushl  0xc(%ebp)
  801930:	6a 3f                	push   $0x3f
  801932:	ff 55 08             	call   *0x8(%ebp)
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	eb 0d                	jmp    801947 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80193a:	83 ec 08             	sub    $0x8,%esp
  80193d:	ff 75 0c             	pushl  0xc(%ebp)
  801940:	52                   	push   %edx
  801941:	ff 55 08             	call   *0x8(%ebp)
  801944:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801947:	83 eb 01             	sub    $0x1,%ebx
  80194a:	eb 1a                	jmp    801966 <vprintfmt+0x23f>
  80194c:	89 75 08             	mov    %esi,0x8(%ebp)
  80194f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801952:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801955:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801958:	eb 0c                	jmp    801966 <vprintfmt+0x23f>
  80195a:	89 75 08             	mov    %esi,0x8(%ebp)
  80195d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801960:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801963:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801966:	83 c7 01             	add    $0x1,%edi
  801969:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80196d:	0f be d0             	movsbl %al,%edx
  801970:	85 d2                	test   %edx,%edx
  801972:	74 23                	je     801997 <vprintfmt+0x270>
  801974:	85 f6                	test   %esi,%esi
  801976:	78 a1                	js     801919 <vprintfmt+0x1f2>
  801978:	83 ee 01             	sub    $0x1,%esi
  80197b:	79 9c                	jns    801919 <vprintfmt+0x1f2>
  80197d:	89 df                	mov    %ebx,%edi
  80197f:	8b 75 08             	mov    0x8(%ebp),%esi
  801982:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801985:	eb 18                	jmp    80199f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801987:	83 ec 08             	sub    $0x8,%esp
  80198a:	53                   	push   %ebx
  80198b:	6a 20                	push   $0x20
  80198d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80198f:	83 ef 01             	sub    $0x1,%edi
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	eb 08                	jmp    80199f <vprintfmt+0x278>
  801997:	89 df                	mov    %ebx,%edi
  801999:	8b 75 08             	mov    0x8(%ebp),%esi
  80199c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80199f:	85 ff                	test   %edi,%edi
  8019a1:	7f e4                	jg     801987 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019a6:	e9 a2 fd ff ff       	jmp    80174d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019ab:	83 fa 01             	cmp    $0x1,%edx
  8019ae:	7e 16                	jle    8019c6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b3:	8d 50 08             	lea    0x8(%eax),%edx
  8019b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b9:	8b 50 04             	mov    0x4(%eax),%edx
  8019bc:	8b 00                	mov    (%eax),%eax
  8019be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019c4:	eb 32                	jmp    8019f8 <vprintfmt+0x2d1>
	else if (lflag)
  8019c6:	85 d2                	test   %edx,%edx
  8019c8:	74 18                	je     8019e2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cd:	8d 50 04             	lea    0x4(%eax),%edx
  8019d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d3:	8b 00                	mov    (%eax),%eax
  8019d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d8:	89 c1                	mov    %eax,%ecx
  8019da:	c1 f9 1f             	sar    $0x1f,%ecx
  8019dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019e0:	eb 16                	jmp    8019f8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e5:	8d 50 04             	lea    0x4(%eax),%edx
  8019e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8019eb:	8b 00                	mov    (%eax),%eax
  8019ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019f0:	89 c1                	mov    %eax,%ecx
  8019f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8019f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a03:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a07:	79 74                	jns    801a7d <vprintfmt+0x356>
				putch('-', putdat);
  801a09:	83 ec 08             	sub    $0x8,%esp
  801a0c:	53                   	push   %ebx
  801a0d:	6a 2d                	push   $0x2d
  801a0f:	ff d6                	call   *%esi
				num = -(long long) num;
  801a11:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a14:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a17:	f7 d8                	neg    %eax
  801a19:	83 d2 00             	adc    $0x0,%edx
  801a1c:	f7 da                	neg    %edx
  801a1e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a21:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a26:	eb 55                	jmp    801a7d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a28:	8d 45 14             	lea    0x14(%ebp),%eax
  801a2b:	e8 83 fc ff ff       	call   8016b3 <getuint>
			base = 10;
  801a30:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a35:	eb 46                	jmp    801a7d <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a37:	8d 45 14             	lea    0x14(%ebp),%eax
  801a3a:	e8 74 fc ff ff       	call   8016b3 <getuint>
			base = 8;
  801a3f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a44:	eb 37                	jmp    801a7d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	53                   	push   %ebx
  801a4a:	6a 30                	push   $0x30
  801a4c:	ff d6                	call   *%esi
			putch('x', putdat);
  801a4e:	83 c4 08             	add    $0x8,%esp
  801a51:	53                   	push   %ebx
  801a52:	6a 78                	push   $0x78
  801a54:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a56:	8b 45 14             	mov    0x14(%ebp),%eax
  801a59:	8d 50 04             	lea    0x4(%eax),%edx
  801a5c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a5f:	8b 00                	mov    (%eax),%eax
  801a61:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a66:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a69:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a6e:	eb 0d                	jmp    801a7d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a70:	8d 45 14             	lea    0x14(%ebp),%eax
  801a73:	e8 3b fc ff ff       	call   8016b3 <getuint>
			base = 16;
  801a78:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a84:	57                   	push   %edi
  801a85:	ff 75 e0             	pushl  -0x20(%ebp)
  801a88:	51                   	push   %ecx
  801a89:	52                   	push   %edx
  801a8a:	50                   	push   %eax
  801a8b:	89 da                	mov    %ebx,%edx
  801a8d:	89 f0                	mov    %esi,%eax
  801a8f:	e8 70 fb ff ff       	call   801604 <printnum>
			break;
  801a94:	83 c4 20             	add    $0x20,%esp
  801a97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a9a:	e9 ae fc ff ff       	jmp    80174d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a9f:	83 ec 08             	sub    $0x8,%esp
  801aa2:	53                   	push   %ebx
  801aa3:	51                   	push   %ecx
  801aa4:	ff d6                	call   *%esi
			break;
  801aa6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aa9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801aac:	e9 9c fc ff ff       	jmp    80174d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ab1:	83 ec 08             	sub    $0x8,%esp
  801ab4:	53                   	push   %ebx
  801ab5:	6a 25                	push   $0x25
  801ab7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	eb 03                	jmp    801ac1 <vprintfmt+0x39a>
  801abe:	83 ef 01             	sub    $0x1,%edi
  801ac1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ac5:	75 f7                	jne    801abe <vprintfmt+0x397>
  801ac7:	e9 81 fc ff ff       	jmp    80174d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801acc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acf:	5b                   	pop    %ebx
  801ad0:	5e                   	pop    %esi
  801ad1:	5f                   	pop    %edi
  801ad2:	5d                   	pop    %ebp
  801ad3:	c3                   	ret    

00801ad4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	83 ec 18             	sub    $0x18,%esp
  801ada:	8b 45 08             	mov    0x8(%ebp),%eax
  801add:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ae0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ae3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ae7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801aea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801af1:	85 c0                	test   %eax,%eax
  801af3:	74 26                	je     801b1b <vsnprintf+0x47>
  801af5:	85 d2                	test   %edx,%edx
  801af7:	7e 22                	jle    801b1b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801af9:	ff 75 14             	pushl  0x14(%ebp)
  801afc:	ff 75 10             	pushl  0x10(%ebp)
  801aff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b02:	50                   	push   %eax
  801b03:	68 ed 16 80 00       	push   $0x8016ed
  801b08:	e8 1a fc ff ff       	call   801727 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b10:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	eb 05                	jmp    801b20 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b28:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b2b:	50                   	push   %eax
  801b2c:	ff 75 10             	pushl  0x10(%ebp)
  801b2f:	ff 75 0c             	pushl  0xc(%ebp)
  801b32:	ff 75 08             	pushl  0x8(%ebp)
  801b35:	e8 9a ff ff ff       	call   801ad4 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
  801b47:	eb 03                	jmp    801b4c <strlen+0x10>
		n++;
  801b49:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b4c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b50:	75 f7                	jne    801b49 <strlen+0xd>
		n++;
	return n;
}
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    

00801b54 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b62:	eb 03                	jmp    801b67 <strnlen+0x13>
		n++;
  801b64:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b67:	39 c2                	cmp    %eax,%edx
  801b69:	74 08                	je     801b73 <strnlen+0x1f>
  801b6b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b6f:	75 f3                	jne    801b64 <strnlen+0x10>
  801b71:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	53                   	push   %ebx
  801b79:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b7f:	89 c2                	mov    %eax,%edx
  801b81:	83 c2 01             	add    $0x1,%edx
  801b84:	83 c1 01             	add    $0x1,%ecx
  801b87:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b8b:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b8e:	84 db                	test   %bl,%bl
  801b90:	75 ef                	jne    801b81 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b92:	5b                   	pop    %ebx
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	53                   	push   %ebx
  801b99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b9c:	53                   	push   %ebx
  801b9d:	e8 9a ff ff ff       	call   801b3c <strlen>
  801ba2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801ba5:	ff 75 0c             	pushl  0xc(%ebp)
  801ba8:	01 d8                	add    %ebx,%eax
  801baa:	50                   	push   %eax
  801bab:	e8 c5 ff ff ff       	call   801b75 <strcpy>
	return dst;
}
  801bb0:	89 d8                	mov    %ebx,%eax
  801bb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	56                   	push   %esi
  801bbb:	53                   	push   %ebx
  801bbc:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc2:	89 f3                	mov    %esi,%ebx
  801bc4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bc7:	89 f2                	mov    %esi,%edx
  801bc9:	eb 0f                	jmp    801bda <strncpy+0x23>
		*dst++ = *src;
  801bcb:	83 c2 01             	add    $0x1,%edx
  801bce:	0f b6 01             	movzbl (%ecx),%eax
  801bd1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bd4:	80 39 01             	cmpb   $0x1,(%ecx)
  801bd7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bda:	39 da                	cmp    %ebx,%edx
  801bdc:	75 ed                	jne    801bcb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bde:	89 f0                	mov    %esi,%eax
  801be0:	5b                   	pop    %ebx
  801be1:	5e                   	pop    %esi
  801be2:	5d                   	pop    %ebp
  801be3:	c3                   	ret    

00801be4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bef:	8b 55 10             	mov    0x10(%ebp),%edx
  801bf2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bf4:	85 d2                	test   %edx,%edx
  801bf6:	74 21                	je     801c19 <strlcpy+0x35>
  801bf8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bfc:	89 f2                	mov    %esi,%edx
  801bfe:	eb 09                	jmp    801c09 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c00:	83 c2 01             	add    $0x1,%edx
  801c03:	83 c1 01             	add    $0x1,%ecx
  801c06:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c09:	39 c2                	cmp    %eax,%edx
  801c0b:	74 09                	je     801c16 <strlcpy+0x32>
  801c0d:	0f b6 19             	movzbl (%ecx),%ebx
  801c10:	84 db                	test   %bl,%bl
  801c12:	75 ec                	jne    801c00 <strlcpy+0x1c>
  801c14:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c16:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c19:	29 f0                	sub    %esi,%eax
}
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    

00801c1f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c25:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c28:	eb 06                	jmp    801c30 <strcmp+0x11>
		p++, q++;
  801c2a:	83 c1 01             	add    $0x1,%ecx
  801c2d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c30:	0f b6 01             	movzbl (%ecx),%eax
  801c33:	84 c0                	test   %al,%al
  801c35:	74 04                	je     801c3b <strcmp+0x1c>
  801c37:	3a 02                	cmp    (%edx),%al
  801c39:	74 ef                	je     801c2a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3b:	0f b6 c0             	movzbl %al,%eax
  801c3e:	0f b6 12             	movzbl (%edx),%edx
  801c41:	29 d0                	sub    %edx,%eax
}
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	53                   	push   %ebx
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c4f:	89 c3                	mov    %eax,%ebx
  801c51:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c54:	eb 06                	jmp    801c5c <strncmp+0x17>
		n--, p++, q++;
  801c56:	83 c0 01             	add    $0x1,%eax
  801c59:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c5c:	39 d8                	cmp    %ebx,%eax
  801c5e:	74 15                	je     801c75 <strncmp+0x30>
  801c60:	0f b6 08             	movzbl (%eax),%ecx
  801c63:	84 c9                	test   %cl,%cl
  801c65:	74 04                	je     801c6b <strncmp+0x26>
  801c67:	3a 0a                	cmp    (%edx),%cl
  801c69:	74 eb                	je     801c56 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c6b:	0f b6 00             	movzbl (%eax),%eax
  801c6e:	0f b6 12             	movzbl (%edx),%edx
  801c71:	29 d0                	sub    %edx,%eax
  801c73:	eb 05                	jmp    801c7a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c75:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c7a:	5b                   	pop    %ebx
  801c7b:	5d                   	pop    %ebp
  801c7c:	c3                   	ret    

00801c7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	8b 45 08             	mov    0x8(%ebp),%eax
  801c83:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c87:	eb 07                	jmp    801c90 <strchr+0x13>
		if (*s == c)
  801c89:	38 ca                	cmp    %cl,%dl
  801c8b:	74 0f                	je     801c9c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c8d:	83 c0 01             	add    $0x1,%eax
  801c90:	0f b6 10             	movzbl (%eax),%edx
  801c93:	84 d2                	test   %dl,%dl
  801c95:	75 f2                	jne    801c89 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ca8:	eb 03                	jmp    801cad <strfind+0xf>
  801caa:	83 c0 01             	add    $0x1,%eax
  801cad:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cb0:	38 ca                	cmp    %cl,%dl
  801cb2:	74 04                	je     801cb8 <strfind+0x1a>
  801cb4:	84 d2                	test   %dl,%dl
  801cb6:	75 f2                	jne    801caa <strfind+0xc>
			break;
	return (char *) s;
}
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    

00801cba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	57                   	push   %edi
  801cbe:	56                   	push   %esi
  801cbf:	53                   	push   %ebx
  801cc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cc6:	85 c9                	test   %ecx,%ecx
  801cc8:	74 36                	je     801d00 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cd0:	75 28                	jne    801cfa <memset+0x40>
  801cd2:	f6 c1 03             	test   $0x3,%cl
  801cd5:	75 23                	jne    801cfa <memset+0x40>
		c &= 0xFF;
  801cd7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cdb:	89 d3                	mov    %edx,%ebx
  801cdd:	c1 e3 08             	shl    $0x8,%ebx
  801ce0:	89 d6                	mov    %edx,%esi
  801ce2:	c1 e6 18             	shl    $0x18,%esi
  801ce5:	89 d0                	mov    %edx,%eax
  801ce7:	c1 e0 10             	shl    $0x10,%eax
  801cea:	09 f0                	or     %esi,%eax
  801cec:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cee:	89 d8                	mov    %ebx,%eax
  801cf0:	09 d0                	or     %edx,%eax
  801cf2:	c1 e9 02             	shr    $0x2,%ecx
  801cf5:	fc                   	cld    
  801cf6:	f3 ab                	rep stos %eax,%es:(%edi)
  801cf8:	eb 06                	jmp    801d00 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfd:	fc                   	cld    
  801cfe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d00:	89 f8                	mov    %edi,%eax
  801d02:	5b                   	pop    %ebx
  801d03:	5e                   	pop    %esi
  801d04:	5f                   	pop    %edi
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    

00801d07 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	57                   	push   %edi
  801d0b:	56                   	push   %esi
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d15:	39 c6                	cmp    %eax,%esi
  801d17:	73 35                	jae    801d4e <memmove+0x47>
  801d19:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d1c:	39 d0                	cmp    %edx,%eax
  801d1e:	73 2e                	jae    801d4e <memmove+0x47>
		s += n;
		d += n;
  801d20:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d23:	89 d6                	mov    %edx,%esi
  801d25:	09 fe                	or     %edi,%esi
  801d27:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d2d:	75 13                	jne    801d42 <memmove+0x3b>
  801d2f:	f6 c1 03             	test   $0x3,%cl
  801d32:	75 0e                	jne    801d42 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d34:	83 ef 04             	sub    $0x4,%edi
  801d37:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d3a:	c1 e9 02             	shr    $0x2,%ecx
  801d3d:	fd                   	std    
  801d3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d40:	eb 09                	jmp    801d4b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d42:	83 ef 01             	sub    $0x1,%edi
  801d45:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d48:	fd                   	std    
  801d49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d4b:	fc                   	cld    
  801d4c:	eb 1d                	jmp    801d6b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d4e:	89 f2                	mov    %esi,%edx
  801d50:	09 c2                	or     %eax,%edx
  801d52:	f6 c2 03             	test   $0x3,%dl
  801d55:	75 0f                	jne    801d66 <memmove+0x5f>
  801d57:	f6 c1 03             	test   $0x3,%cl
  801d5a:	75 0a                	jne    801d66 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d5c:	c1 e9 02             	shr    $0x2,%ecx
  801d5f:	89 c7                	mov    %eax,%edi
  801d61:	fc                   	cld    
  801d62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d64:	eb 05                	jmp    801d6b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d66:	89 c7                	mov    %eax,%edi
  801d68:	fc                   	cld    
  801d69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d6b:	5e                   	pop    %esi
  801d6c:	5f                   	pop    %edi
  801d6d:	5d                   	pop    %ebp
  801d6e:	c3                   	ret    

00801d6f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d72:	ff 75 10             	pushl  0x10(%ebp)
  801d75:	ff 75 0c             	pushl  0xc(%ebp)
  801d78:	ff 75 08             	pushl  0x8(%ebp)
  801d7b:	e8 87 ff ff ff       	call   801d07 <memmove>
}
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    

00801d82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	56                   	push   %esi
  801d86:	53                   	push   %ebx
  801d87:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8d:	89 c6                	mov    %eax,%esi
  801d8f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d92:	eb 1a                	jmp    801dae <memcmp+0x2c>
		if (*s1 != *s2)
  801d94:	0f b6 08             	movzbl (%eax),%ecx
  801d97:	0f b6 1a             	movzbl (%edx),%ebx
  801d9a:	38 d9                	cmp    %bl,%cl
  801d9c:	74 0a                	je     801da8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d9e:	0f b6 c1             	movzbl %cl,%eax
  801da1:	0f b6 db             	movzbl %bl,%ebx
  801da4:	29 d8                	sub    %ebx,%eax
  801da6:	eb 0f                	jmp    801db7 <memcmp+0x35>
		s1++, s2++;
  801da8:	83 c0 01             	add    $0x1,%eax
  801dab:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dae:	39 f0                	cmp    %esi,%eax
  801db0:	75 e2                	jne    801d94 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801db2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	53                   	push   %ebx
  801dbf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dc2:	89 c1                	mov    %eax,%ecx
  801dc4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dcb:	eb 0a                	jmp    801dd7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dcd:	0f b6 10             	movzbl (%eax),%edx
  801dd0:	39 da                	cmp    %ebx,%edx
  801dd2:	74 07                	je     801ddb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dd4:	83 c0 01             	add    $0x1,%eax
  801dd7:	39 c8                	cmp    %ecx,%eax
  801dd9:	72 f2                	jb     801dcd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801ddb:	5b                   	pop    %ebx
  801ddc:	5d                   	pop    %ebp
  801ddd:	c3                   	ret    

00801dde <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	53                   	push   %ebx
  801de4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dea:	eb 03                	jmp    801def <strtol+0x11>
		s++;
  801dec:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801def:	0f b6 01             	movzbl (%ecx),%eax
  801df2:	3c 20                	cmp    $0x20,%al
  801df4:	74 f6                	je     801dec <strtol+0xe>
  801df6:	3c 09                	cmp    $0x9,%al
  801df8:	74 f2                	je     801dec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dfa:	3c 2b                	cmp    $0x2b,%al
  801dfc:	75 0a                	jne    801e08 <strtol+0x2a>
		s++;
  801dfe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e01:	bf 00 00 00 00       	mov    $0x0,%edi
  801e06:	eb 11                	jmp    801e19 <strtol+0x3b>
  801e08:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e0d:	3c 2d                	cmp    $0x2d,%al
  801e0f:	75 08                	jne    801e19 <strtol+0x3b>
		s++, neg = 1;
  801e11:	83 c1 01             	add    $0x1,%ecx
  801e14:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e1f:	75 15                	jne    801e36 <strtol+0x58>
  801e21:	80 39 30             	cmpb   $0x30,(%ecx)
  801e24:	75 10                	jne    801e36 <strtol+0x58>
  801e26:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e2a:	75 7c                	jne    801ea8 <strtol+0xca>
		s += 2, base = 16;
  801e2c:	83 c1 02             	add    $0x2,%ecx
  801e2f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e34:	eb 16                	jmp    801e4c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e36:	85 db                	test   %ebx,%ebx
  801e38:	75 12                	jne    801e4c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e3a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e3f:	80 39 30             	cmpb   $0x30,(%ecx)
  801e42:	75 08                	jne    801e4c <strtol+0x6e>
		s++, base = 8;
  801e44:	83 c1 01             	add    $0x1,%ecx
  801e47:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e51:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e54:	0f b6 11             	movzbl (%ecx),%edx
  801e57:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e5a:	89 f3                	mov    %esi,%ebx
  801e5c:	80 fb 09             	cmp    $0x9,%bl
  801e5f:	77 08                	ja     801e69 <strtol+0x8b>
			dig = *s - '0';
  801e61:	0f be d2             	movsbl %dl,%edx
  801e64:	83 ea 30             	sub    $0x30,%edx
  801e67:	eb 22                	jmp    801e8b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e69:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e6c:	89 f3                	mov    %esi,%ebx
  801e6e:	80 fb 19             	cmp    $0x19,%bl
  801e71:	77 08                	ja     801e7b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e73:	0f be d2             	movsbl %dl,%edx
  801e76:	83 ea 57             	sub    $0x57,%edx
  801e79:	eb 10                	jmp    801e8b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e7b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e7e:	89 f3                	mov    %esi,%ebx
  801e80:	80 fb 19             	cmp    $0x19,%bl
  801e83:	77 16                	ja     801e9b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e85:	0f be d2             	movsbl %dl,%edx
  801e88:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e8b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e8e:	7d 0b                	jge    801e9b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e90:	83 c1 01             	add    $0x1,%ecx
  801e93:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e97:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e99:	eb b9                	jmp    801e54 <strtol+0x76>

	if (endptr)
  801e9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e9f:	74 0d                	je     801eae <strtol+0xd0>
		*endptr = (char *) s;
  801ea1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ea4:	89 0e                	mov    %ecx,(%esi)
  801ea6:	eb 06                	jmp    801eae <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ea8:	85 db                	test   %ebx,%ebx
  801eaa:	74 98                	je     801e44 <strtol+0x66>
  801eac:	eb 9e                	jmp    801e4c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801eae:	89 c2                	mov    %eax,%edx
  801eb0:	f7 da                	neg    %edx
  801eb2:	85 ff                	test   %edi,%edi
  801eb4:	0f 45 c2             	cmovne %edx,%eax
}
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5f                   	pop    %edi
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    

00801ebc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	56                   	push   %esi
  801ec0:	53                   	push   %ebx
  801ec1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801eca:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ecc:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ed1:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ed4:	83 ec 0c             	sub    $0xc,%esp
  801ed7:	50                   	push   %eax
  801ed8:	e8 54 e4 ff ff       	call   800331 <sys_ipc_recv>

	if (from_env_store != NULL)
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 f6                	test   %esi,%esi
  801ee2:	74 14                	je     801ef8 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801ee4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	78 09                	js     801ef6 <ipc_recv+0x3a>
  801eed:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ef3:	8b 52 74             	mov    0x74(%edx),%edx
  801ef6:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ef8:	85 db                	test   %ebx,%ebx
  801efa:	74 14                	je     801f10 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801efc:	ba 00 00 00 00       	mov    $0x0,%edx
  801f01:	85 c0                	test   %eax,%eax
  801f03:	78 09                	js     801f0e <ipc_recv+0x52>
  801f05:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f0b:	8b 52 78             	mov    0x78(%edx),%edx
  801f0e:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 08                	js     801f1c <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f14:	a1 08 40 80 00       	mov    0x804008,%eax
  801f19:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    

00801f23 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	57                   	push   %edi
  801f27:	56                   	push   %esi
  801f28:	53                   	push   %ebx
  801f29:	83 ec 0c             	sub    $0xc,%esp
  801f2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f35:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f37:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f3c:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f3f:	ff 75 14             	pushl  0x14(%ebp)
  801f42:	53                   	push   %ebx
  801f43:	56                   	push   %esi
  801f44:	57                   	push   %edi
  801f45:	e8 c4 e3 ff ff       	call   80030e <sys_ipc_try_send>

		if (err < 0) {
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	79 1e                	jns    801f6f <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f51:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f54:	75 07                	jne    801f5d <ipc_send+0x3a>
				sys_yield();
  801f56:	e8 07 e2 ff ff       	call   800162 <sys_yield>
  801f5b:	eb e2                	jmp    801f3f <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f5d:	50                   	push   %eax
  801f5e:	68 00 27 80 00       	push   $0x802700
  801f63:	6a 49                	push   $0x49
  801f65:	68 0d 27 80 00       	push   $0x80270d
  801f6a:	e8 a8 f5 ff ff       	call   801517 <_panic>
		}

	} while (err < 0);

}
  801f6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f72:	5b                   	pop    %ebx
  801f73:	5e                   	pop    %esi
  801f74:	5f                   	pop    %edi
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f82:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f85:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f8b:	8b 52 50             	mov    0x50(%edx),%edx
  801f8e:	39 ca                	cmp    %ecx,%edx
  801f90:	75 0d                	jne    801f9f <ipc_find_env+0x28>
			return envs[i].env_id;
  801f92:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f95:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f9a:	8b 40 48             	mov    0x48(%eax),%eax
  801f9d:	eb 0f                	jmp    801fae <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f9f:	83 c0 01             	add    $0x1,%eax
  801fa2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa7:	75 d9                	jne    801f82 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    

00801fb0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb6:	89 d0                	mov    %edx,%eax
  801fb8:	c1 e8 16             	shr    $0x16,%eax
  801fbb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fc2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc7:	f6 c1 01             	test   $0x1,%cl
  801fca:	74 1d                	je     801fe9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fcc:	c1 ea 0c             	shr    $0xc,%edx
  801fcf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd6:	f6 c2 01             	test   $0x1,%dl
  801fd9:	74 0e                	je     801fe9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fdb:	c1 ea 0c             	shr    $0xc,%edx
  801fde:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe5:	ef 
  801fe6:	0f b7 c0             	movzwl %ax,%eax
}
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    
  801feb:	66 90                	xchg   %ax,%ax
  801fed:	66 90                	xchg   %ax,%ax
  801fef:	90                   	nop

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
