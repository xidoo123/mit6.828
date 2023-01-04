
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
  800082:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8000b1:	e8 87 04 00 00       	call   80053d <close_all>
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
  80012a:	68 ca 1d 80 00       	push   $0x801dca
  80012f:	6a 23                	push   $0x23
  800131:	68 e7 1d 80 00       	push   $0x801de7
  800136:	e8 14 0f 00 00       	call   80104f <_panic>

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
  8001ab:	68 ca 1d 80 00       	push   $0x801dca
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 e7 1d 80 00       	push   $0x801de7
  8001b7:	e8 93 0e 00 00       	call   80104f <_panic>

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
  8001ed:	68 ca 1d 80 00       	push   $0x801dca
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 e7 1d 80 00       	push   $0x801de7
  8001f9:	e8 51 0e 00 00       	call   80104f <_panic>

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
  80022f:	68 ca 1d 80 00       	push   $0x801dca
  800234:	6a 23                	push   $0x23
  800236:	68 e7 1d 80 00       	push   $0x801de7
  80023b:	e8 0f 0e 00 00       	call   80104f <_panic>

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
  800271:	68 ca 1d 80 00       	push   $0x801dca
  800276:	6a 23                	push   $0x23
  800278:	68 e7 1d 80 00       	push   $0x801de7
  80027d:	e8 cd 0d 00 00       	call   80104f <_panic>

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
  8002b3:	68 ca 1d 80 00       	push   $0x801dca
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 e7 1d 80 00       	push   $0x801de7
  8002bf:	e8 8b 0d 00 00       	call   80104f <_panic>

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
  8002f5:	68 ca 1d 80 00       	push   $0x801dca
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 e7 1d 80 00       	push   $0x801de7
  800301:	e8 49 0d 00 00       	call   80104f <_panic>

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
  800359:	68 ca 1d 80 00       	push   $0x801dca
  80035e:	6a 23                	push   $0x23
  800360:	68 e7 1d 80 00       	push   $0x801de7
  800365:	e8 e5 0c 00 00       	call   80104f <_panic>

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

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 11                	je     8003c6 <fd_alloc+0x2d>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 09                	jne    8003cf <fd_alloc+0x36>
			*fd_store = fd;
  8003c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 17                	jmp    8003e6 <fd_alloc+0x4d>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 c9                	jne    8003a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 13                	jmp    80043c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb 0c                	jmp    80043c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 05                	jmp    80043c <fd_lookup+0x54>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	eb 13                	jmp    800461 <dev_lookup+0x23>
  80044e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	75 0c                	jne    800461 <dev_lookup+0x23>
			*dev = devtab[i];
  800455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800458:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 2e                	jmp    80048f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 e7                	jne    80044e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800467:	a1 04 40 80 00       	mov    0x804004,%eax
  80046c:	8b 40 48             	mov    0x48(%eax),%eax
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	51                   	push   %ecx
  800473:	50                   	push   %eax
  800474:	68 f8 1d 80 00       	push   $0x801df8
  800479:	e8 aa 0c 00 00       	call   801128 <cprintf>
	*dev = 0;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 10             	sub    $0x10,%esp
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a2:	50                   	push   %eax
  8004a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a9:	c1 e8 0c             	shr    $0xc,%eax
  8004ac:	50                   	push   %eax
  8004ad:	e8 36 ff ff ff       	call   8003e8 <fd_lookup>
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	78 05                	js     8004be <fd_close+0x2d>
	    || fd != fd2)
  8004b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bc:	74 0c                	je     8004ca <fd_close+0x39>
		return (must_exist ? r : 0);
  8004be:	84 db                	test   %bl,%bl
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	0f 44 c2             	cmove  %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 66 ff ff ff       	call   80043e <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x6a>
		if (dev->dev_close)
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 00 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c4 fe ff ff       	call   8003e8 <fd_lookup>
  800524:	83 c4 08             	add    $0x8,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 10                	js     80053b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	6a 01                	push   $0x1
  800530:	ff 75 f4             	pushl  -0xc(%ebp)
  800533:	e8 59 ff ff ff       	call   800491 <fd_close>
  800538:	83 c4 10             	add    $0x10,%esp
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <close_all>:

void
close_all(void)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	53                   	push   %ebx
  800541:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800544:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	53                   	push   %ebx
  80054d:	e8 c0 ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800552:	83 c3 01             	add    $0x1,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	83 fb 20             	cmp    $0x20,%ebx
  80055b:	75 ec                	jne    800549 <close_all+0xc>
		close(i);
}
  80055d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 2c             	sub    $0x2c,%esp
  80056b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800571:	50                   	push   %eax
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 6e fe ff ff       	call   8003e8 <fd_lookup>
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	85 c0                	test   %eax,%eax
  80057f:	0f 88 c1 00 00 00    	js     800646 <dup+0xe4>
		return r;
	close(newfdnum);
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	56                   	push   %esi
  800589:	e8 84 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  80058e:	89 f3                	mov    %esi,%ebx
  800590:	c1 e3 0c             	shl    $0xc,%ebx
  800593:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800599:	83 c4 04             	add    $0x4,%esp
  80059c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059f:	e8 de fd ff ff       	call   800382 <fd2data>
  8005a4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a6:	89 1c 24             	mov    %ebx,(%esp)
  8005a9:	e8 d4 fd ff ff       	call   800382 <fd2data>
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b4:	89 f8                	mov    %edi,%eax
  8005b6:	c1 e8 16             	shr    $0x16,%eax
  8005b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c0:	a8 01                	test   $0x1,%al
  8005c2:	74 37                	je     8005fb <dup+0x99>
  8005c4:	89 f8                	mov    %edi,%eax
  8005c6:	c1 e8 0c             	shr    $0xc,%eax
  8005c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d0:	f6 c2 01             	test   $0x1,%dl
  8005d3:	74 26                	je     8005fb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e8:	6a 00                	push   $0x0
  8005ea:	57                   	push   %edi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 d2 fb ff ff       	call   8001c4 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	78 2e                	js     800629 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 d0                	mov    %edx,%eax
  800600:	c1 e8 0c             	shr    $0xc,%eax
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	53                   	push   %ebx
  800614:	6a 00                	push   $0x0
  800616:	52                   	push   %edx
  800617:	6a 00                	push   $0x0
  800619:	e8 a6 fb ff ff       	call   8001c4 <sys_page_map>
  80061e:	89 c7                	mov    %eax,%edi
  800620:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800623:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	85 ff                	test   %edi,%edi
  800627:	79 1d                	jns    800646 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 00                	push   $0x0
  80062f:	e8 d2 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063a:	6a 00                	push   $0x0
  80063c:	e8 c5 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	89 f8                	mov    %edi,%eax
}
  800646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	53                   	push   %ebx
  800652:	83 ec 14             	sub    $0x14,%esp
  800655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	53                   	push   %ebx
  80065d:	e8 86 fd ff ff       	call   8003e8 <fd_lookup>
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	89 c2                	mov    %eax,%edx
  800667:	85 c0                	test   %eax,%eax
  800669:	78 6d                	js     8006d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800675:	ff 30                	pushl  (%eax)
  800677:	e8 c2 fd ff ff       	call   80043e <dev_lookup>
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 4c                	js     8006cf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800683:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800686:	8b 42 08             	mov    0x8(%edx),%eax
  800689:	83 e0 03             	and    $0x3,%eax
  80068c:	83 f8 01             	cmp    $0x1,%eax
  80068f:	75 21                	jne    8006b2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 04 40 80 00       	mov    0x804004,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 39 1e 80 00       	push   $0x801e39
  8006a3:	e8 80 0a 00 00       	call   801128 <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b0:	eb 26                	jmp    8006d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	8b 40 08             	mov    0x8(%eax),%eax
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 17                	je     8006d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	52                   	push   %edx
  8006c6:	ff d0                	call   *%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 09                	jmp    8006d8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	eb 05                	jmp    8006d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d8:	89 d0                	mov    %edx,%eax
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f3:	eb 21                	jmp    800716 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	29 d8                	sub    %ebx,%eax
  8006fc:	50                   	push   %eax
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	03 45 0c             	add    0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	57                   	push   %edi
  800704:	e8 45 ff ff ff       	call   80064e <read>
		if (m < 0)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 10                	js     800720 <readn+0x41>
			return m;
		if (m == 0)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 0a                	je     80071e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800714:	01 c3                	add    %eax,%ebx
  800716:	39 f3                	cmp    %esi,%ebx
  800718:	72 db                	jb     8006f5 <readn+0x16>
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	eb 02                	jmp    800720 <readn+0x41>
  80071e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ac fc ff ff       	call   8003e8 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e8 fc ff ff       	call   80043e <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 55 1e 80 00       	push   $0x801e55
  800778:	e8 ab 09 00 00       	call   801128 <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 22 fc ff ff       	call   8003e8 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f7 fb ff ff       	call   8003e8 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 33 fc ff ff       	call   80043e <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 18 1e 80 00       	push   $0x801e18
  80082d:	e8 f6 08 00 00       	call   801128 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6c fb ff ff       	call   8003e8 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a8 fb ff ff       	call   80043e <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 d6 01 00 00       	call   800acc <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	50                   	push   %eax
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 72 11 00 00       	call   801aaf <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 03 11 00 00       	call   801a5b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 8f 10 00 00       	call   8019f4 <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 2c                	js     800a0c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	68 00 50 80 00       	push   $0x805000
  8009e8:	53                   	push   %ebx
  8009e9:	e8 bf 0c 00 00       	call   8016ad <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1d:	8b 52 0c             	mov    0xc(%edx),%edx
  800a20:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a26:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a2b:	50                   	push   %eax
  800a2c:	ff 75 0c             	pushl  0xc(%ebp)
  800a2f:	68 08 50 80 00       	push   $0x805008
  800a34:	e8 06 0e 00 00       	call   80183f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800a43:	e8 d9 fe ff ff       	call   800921 <fsipc>

}
  800a48:	c9                   	leave  
  800a49:	c3                   	ret    

00800a4a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 40 0c             	mov    0xc(%eax),%eax
  800a58:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a5d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6d:	e8 af fe ff ff       	call   800921 <fsipc>
  800a72:	89 c3                	mov    %eax,%ebx
  800a74:	85 c0                	test   %eax,%eax
  800a76:	78 4b                	js     800ac3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a78:	39 c6                	cmp    %eax,%esi
  800a7a:	73 16                	jae    800a92 <devfile_read+0x48>
  800a7c:	68 84 1e 80 00       	push   $0x801e84
  800a81:	68 8b 1e 80 00       	push   $0x801e8b
  800a86:	6a 7c                	push   $0x7c
  800a88:	68 a0 1e 80 00       	push   $0x801ea0
  800a8d:	e8 bd 05 00 00       	call   80104f <_panic>
	assert(r <= PGSIZE);
  800a92:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a97:	7e 16                	jle    800aaf <devfile_read+0x65>
  800a99:	68 ab 1e 80 00       	push   $0x801eab
  800a9e:	68 8b 1e 80 00       	push   $0x801e8b
  800aa3:	6a 7d                	push   $0x7d
  800aa5:	68 a0 1e 80 00       	push   $0x801ea0
  800aaa:	e8 a0 05 00 00       	call   80104f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aaf:	83 ec 04             	sub    $0x4,%esp
  800ab2:	50                   	push   %eax
  800ab3:	68 00 50 80 00       	push   $0x805000
  800ab8:	ff 75 0c             	pushl  0xc(%ebp)
  800abb:	e8 7f 0d 00 00       	call   80183f <memmove>
	return r;
  800ac0:	83 c4 10             	add    $0x10,%esp
}
  800ac3:	89 d8                	mov    %ebx,%eax
  800ac5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	53                   	push   %ebx
  800ad0:	83 ec 20             	sub    $0x20,%esp
  800ad3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ad6:	53                   	push   %ebx
  800ad7:	e8 98 0b 00 00       	call   801674 <strlen>
  800adc:	83 c4 10             	add    $0x10,%esp
  800adf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ae4:	7f 67                	jg     800b4d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae6:	83 ec 0c             	sub    $0xc,%esp
  800ae9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aec:	50                   	push   %eax
  800aed:	e8 a7 f8 ff ff       	call   800399 <fd_alloc>
  800af2:	83 c4 10             	add    $0x10,%esp
		return r;
  800af5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af7:	85 c0                	test   %eax,%eax
  800af9:	78 57                	js     800b52 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800afb:	83 ec 08             	sub    $0x8,%esp
  800afe:	53                   	push   %ebx
  800aff:	68 00 50 80 00       	push   $0x805000
  800b04:	e8 a4 0b 00 00       	call   8016ad <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b14:	b8 01 00 00 00       	mov    $0x1,%eax
  800b19:	e8 03 fe ff ff       	call   800921 <fsipc>
  800b1e:	89 c3                	mov    %eax,%ebx
  800b20:	83 c4 10             	add    $0x10,%esp
  800b23:	85 c0                	test   %eax,%eax
  800b25:	79 14                	jns    800b3b <open+0x6f>
		fd_close(fd, 0);
  800b27:	83 ec 08             	sub    $0x8,%esp
  800b2a:	6a 00                	push   $0x0
  800b2c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2f:	e8 5d f9 ff ff       	call   800491 <fd_close>
		return r;
  800b34:	83 c4 10             	add    $0x10,%esp
  800b37:	89 da                	mov    %ebx,%edx
  800b39:	eb 17                	jmp    800b52 <open+0x86>
	}

	return fd2num(fd);
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b41:	e8 2c f8 ff ff       	call   800372 <fd2num>
  800b46:	89 c2                	mov    %eax,%edx
  800b48:	83 c4 10             	add    $0x10,%esp
  800b4b:	eb 05                	jmp    800b52 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b4d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b52:	89 d0                	mov    %edx,%eax
  800b54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b64:	b8 08 00 00 00       	mov    $0x8,%eax
  800b69:	e8 b3 fd ff ff       	call   800921 <fsipc>
}
  800b6e:	c9                   	leave  
  800b6f:	c3                   	ret    

00800b70 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
  800b75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	ff 75 08             	pushl  0x8(%ebp)
  800b7e:	e8 ff f7 ff ff       	call   800382 <fd2data>
  800b83:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b85:	83 c4 08             	add    $0x8,%esp
  800b88:	68 b7 1e 80 00       	push   $0x801eb7
  800b8d:	53                   	push   %ebx
  800b8e:	e8 1a 0b 00 00       	call   8016ad <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b93:	8b 46 04             	mov    0x4(%esi),%eax
  800b96:	2b 06                	sub    (%esi),%eax
  800b98:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b9e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ba5:	00 00 00 
	stat->st_dev = &devpipe;
  800ba8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800baf:	30 80 00 
	return 0;
}
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bc8:	53                   	push   %ebx
  800bc9:	6a 00                	push   $0x0
  800bcb:	e8 36 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd0:	89 1c 24             	mov    %ebx,(%esp)
  800bd3:	e8 aa f7 ff ff       	call   800382 <fd2data>
  800bd8:	83 c4 08             	add    $0x8,%esp
  800bdb:	50                   	push   %eax
  800bdc:	6a 00                	push   $0x0
  800bde:	e8 23 f6 ff ff       	call   800206 <sys_page_unmap>
}
  800be3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 1c             	sub    $0x1c,%esp
  800bf1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bf4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bf6:	a1 04 40 80 00       	mov    0x804004,%eax
  800bfb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	ff 75 e0             	pushl  -0x20(%ebp)
  800c04:	e8 df 0e 00 00       	call   801ae8 <pageref>
  800c09:	89 c3                	mov    %eax,%ebx
  800c0b:	89 3c 24             	mov    %edi,(%esp)
  800c0e:	e8 d5 0e 00 00       	call   801ae8 <pageref>
  800c13:	83 c4 10             	add    $0x10,%esp
  800c16:	39 c3                	cmp    %eax,%ebx
  800c18:	0f 94 c1             	sete   %cl
  800c1b:	0f b6 c9             	movzbl %cl,%ecx
  800c1e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c21:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c27:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c2a:	39 ce                	cmp    %ecx,%esi
  800c2c:	74 1b                	je     800c49 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c2e:	39 c3                	cmp    %eax,%ebx
  800c30:	75 c4                	jne    800bf6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c32:	8b 42 58             	mov    0x58(%edx),%eax
  800c35:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c38:	50                   	push   %eax
  800c39:	56                   	push   %esi
  800c3a:	68 be 1e 80 00       	push   $0x801ebe
  800c3f:	e8 e4 04 00 00       	call   801128 <cprintf>
  800c44:	83 c4 10             	add    $0x10,%esp
  800c47:	eb ad                	jmp    800bf6 <_pipeisclosed+0xe>
	}
}
  800c49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 28             	sub    $0x28,%esp
  800c5d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c60:	56                   	push   %esi
  800c61:	e8 1c f7 ff ff       	call   800382 <fd2data>
  800c66:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c70:	eb 4b                	jmp    800cbd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c72:	89 da                	mov    %ebx,%edx
  800c74:	89 f0                	mov    %esi,%eax
  800c76:	e8 6d ff ff ff       	call   800be8 <_pipeisclosed>
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	75 48                	jne    800cc7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c7f:	e8 de f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c84:	8b 43 04             	mov    0x4(%ebx),%eax
  800c87:	8b 0b                	mov    (%ebx),%ecx
  800c89:	8d 51 20             	lea    0x20(%ecx),%edx
  800c8c:	39 d0                	cmp    %edx,%eax
  800c8e:	73 e2                	jae    800c72 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c97:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c9a:	89 c2                	mov    %eax,%edx
  800c9c:	c1 fa 1f             	sar    $0x1f,%edx
  800c9f:	89 d1                	mov    %edx,%ecx
  800ca1:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ca7:	83 e2 1f             	and    $0x1f,%edx
  800caa:	29 ca                	sub    %ecx,%edx
  800cac:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb4:	83 c0 01             	add    $0x1,%eax
  800cb7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cba:	83 c7 01             	add    $0x1,%edi
  800cbd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc0:	75 c2                	jne    800c84 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc5:	eb 05                	jmp    800ccc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	83 ec 18             	sub    $0x18,%esp
  800cdd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ce0:	57                   	push   %edi
  800ce1:	e8 9c f6 ff ff       	call   800382 <fd2data>
  800ce6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce8:	83 c4 10             	add    $0x10,%esp
  800ceb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf0:	eb 3d                	jmp    800d2f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cf2:	85 db                	test   %ebx,%ebx
  800cf4:	74 04                	je     800cfa <devpipe_read+0x26>
				return i;
  800cf6:	89 d8                	mov    %ebx,%eax
  800cf8:	eb 44                	jmp    800d3e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cfa:	89 f2                	mov    %esi,%edx
  800cfc:	89 f8                	mov    %edi,%eax
  800cfe:	e8 e5 fe ff ff       	call   800be8 <_pipeisclosed>
  800d03:	85 c0                	test   %eax,%eax
  800d05:	75 32                	jne    800d39 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d07:	e8 56 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d0c:	8b 06                	mov    (%esi),%eax
  800d0e:	3b 46 04             	cmp    0x4(%esi),%eax
  800d11:	74 df                	je     800cf2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d13:	99                   	cltd   
  800d14:	c1 ea 1b             	shr    $0x1b,%edx
  800d17:	01 d0                	add    %edx,%eax
  800d19:	83 e0 1f             	and    $0x1f,%eax
  800d1c:	29 d0                	sub    %edx,%eax
  800d1e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d29:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d2c:	83 c3 01             	add    $0x1,%ebx
  800d2f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d32:	75 d8                	jne    800d0c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d34:	8b 45 10             	mov    0x10(%ebp),%eax
  800d37:	eb 05                	jmp    800d3e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d39:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d51:	50                   	push   %eax
  800d52:	e8 42 f6 ff ff       	call   800399 <fd_alloc>
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	89 c2                	mov    %eax,%edx
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	0f 88 2c 01 00 00    	js     800e90 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d64:	83 ec 04             	sub    $0x4,%esp
  800d67:	68 07 04 00 00       	push   $0x407
  800d6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800d6f:	6a 00                	push   $0x0
  800d71:	e8 0b f4 ff ff       	call   800181 <sys_page_alloc>
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	89 c2                	mov    %eax,%edx
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	0f 88 0d 01 00 00    	js     800e90 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d89:	50                   	push   %eax
  800d8a:	e8 0a f6 ff ff       	call   800399 <fd_alloc>
  800d8f:	89 c3                	mov    %eax,%ebx
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	0f 88 e2 00 00 00    	js     800e7e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	68 07 04 00 00       	push   $0x407
  800da4:	ff 75 f0             	pushl  -0x10(%ebp)
  800da7:	6a 00                	push   $0x0
  800da9:	e8 d3 f3 ff ff       	call   800181 <sys_page_alloc>
  800dae:	89 c3                	mov    %eax,%ebx
  800db0:	83 c4 10             	add    $0x10,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	0f 88 c3 00 00 00    	js     800e7e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc1:	e8 bc f5 ff ff       	call   800382 <fd2data>
  800dc6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc8:	83 c4 0c             	add    $0xc,%esp
  800dcb:	68 07 04 00 00       	push   $0x407
  800dd0:	50                   	push   %eax
  800dd1:	6a 00                	push   $0x0
  800dd3:	e8 a9 f3 ff ff       	call   800181 <sys_page_alloc>
  800dd8:	89 c3                	mov    %eax,%ebx
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	0f 88 89 00 00 00    	js     800e6e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	ff 75 f0             	pushl  -0x10(%ebp)
  800deb:	e8 92 f5 ff ff       	call   800382 <fd2data>
  800df0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df7:	50                   	push   %eax
  800df8:	6a 00                	push   $0x0
  800dfa:	56                   	push   %esi
  800dfb:	6a 00                	push   $0x0
  800dfd:	e8 c2 f3 ff ff       	call   8001c4 <sys_page_map>
  800e02:	89 c3                	mov    %eax,%ebx
  800e04:	83 c4 20             	add    $0x20,%esp
  800e07:	85 c0                	test   %eax,%eax
  800e09:	78 55                	js     800e60 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e0b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e14:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e19:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e20:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e29:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3b:	e8 32 f5 ff ff       	call   800372 <fd2num>
  800e40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e43:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e45:	83 c4 04             	add    $0x4,%esp
  800e48:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4b:	e8 22 f5 ff ff       	call   800372 <fd2num>
  800e50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e53:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5e:	eb 30                	jmp    800e90 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e60:	83 ec 08             	sub    $0x8,%esp
  800e63:	56                   	push   %esi
  800e64:	6a 00                	push   $0x0
  800e66:	e8 9b f3 ff ff       	call   800206 <sys_page_unmap>
  800e6b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e6e:	83 ec 08             	sub    $0x8,%esp
  800e71:	ff 75 f0             	pushl  -0x10(%ebp)
  800e74:	6a 00                	push   $0x0
  800e76:	e8 8b f3 ff ff       	call   800206 <sys_page_unmap>
  800e7b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e7e:	83 ec 08             	sub    $0x8,%esp
  800e81:	ff 75 f4             	pushl  -0xc(%ebp)
  800e84:	6a 00                	push   $0x0
  800e86:	e8 7b f3 ff ff       	call   800206 <sys_page_unmap>
  800e8b:	83 c4 10             	add    $0x10,%esp
  800e8e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e90:	89 d0                	mov    %edx,%eax
  800e92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea2:	50                   	push   %eax
  800ea3:	ff 75 08             	pushl  0x8(%ebp)
  800ea6:	e8 3d f5 ff ff       	call   8003e8 <fd_lookup>
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	78 18                	js     800eca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eb2:	83 ec 0c             	sub    $0xc,%esp
  800eb5:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb8:	e8 c5 f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec2:	e8 21 fd ff ff       	call   800be8 <_pipeisclosed>
  800ec7:	83 c4 10             	add    $0x10,%esp
}
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800edc:	68 d6 1e 80 00       	push   $0x801ed6
  800ee1:	ff 75 0c             	pushl  0xc(%ebp)
  800ee4:	e8 c4 07 00 00       	call   8016ad <strcpy>
	return 0;
}
  800ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eee:	c9                   	leave  
  800eef:	c3                   	ret    

00800ef0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800efc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f01:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f07:	eb 2d                	jmp    800f36 <devcons_write+0x46>
		m = n - tot;
  800f09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f0e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f11:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f16:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f19:	83 ec 04             	sub    $0x4,%esp
  800f1c:	53                   	push   %ebx
  800f1d:	03 45 0c             	add    0xc(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	57                   	push   %edi
  800f22:	e8 18 09 00 00       	call   80183f <memmove>
		sys_cputs(buf, m);
  800f27:	83 c4 08             	add    $0x8,%esp
  800f2a:	53                   	push   %ebx
  800f2b:	57                   	push   %edi
  800f2c:	e8 94 f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f31:	01 de                	add    %ebx,%esi
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	89 f0                	mov    %esi,%eax
  800f38:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f3b:	72 cc                	jb     800f09 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 08             	sub    $0x8,%esp
  800f4b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f54:	74 2a                	je     800f80 <devcons_read+0x3b>
  800f56:	eb 05                	jmp    800f5d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f58:	e8 05 f2 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f5d:	e8 81 f1 ff ff       	call   8000e3 <sys_cgetc>
  800f62:	85 c0                	test   %eax,%eax
  800f64:	74 f2                	je     800f58 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 16                	js     800f80 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f6a:	83 f8 04             	cmp    $0x4,%eax
  800f6d:	74 0c                	je     800f7b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f72:	88 02                	mov    %al,(%edx)
	return 1;
  800f74:	b8 01 00 00 00       	mov    $0x1,%eax
  800f79:	eb 05                	jmp    800f80 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f8e:	6a 01                	push   $0x1
  800f90:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	e8 2c f1 ff ff       	call   8000c5 <sys_cputs>
}
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <getchar>:

int
getchar(void)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fa4:	6a 01                	push   $0x1
  800fa6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa9:	50                   	push   %eax
  800faa:	6a 00                	push   $0x0
  800fac:	e8 9d f6 ff ff       	call   80064e <read>
	if (r < 0)
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 0f                	js     800fc7 <getchar+0x29>
		return r;
	if (r < 1)
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	7e 06                	jle    800fc2 <getchar+0x24>
		return -E_EOF;
	return c;
  800fbc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fc0:	eb 05                	jmp    800fc7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fc2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd2:	50                   	push   %eax
  800fd3:	ff 75 08             	pushl  0x8(%ebp)
  800fd6:	e8 0d f4 ff ff       	call   8003e8 <fd_lookup>
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 11                	js     800ff3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800feb:	39 10                	cmp    %edx,(%eax)
  800fed:	0f 94 c0             	sete   %al
  800ff0:	0f b6 c0             	movzbl %al,%eax
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <opencons>:

int
opencons(void)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffe:	50                   	push   %eax
  800fff:	e8 95 f3 ff ff       	call   800399 <fd_alloc>
  801004:	83 c4 10             	add    $0x10,%esp
		return r;
  801007:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 3e                	js     80104b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100d:	83 ec 04             	sub    $0x4,%esp
  801010:	68 07 04 00 00       	push   $0x407
  801015:	ff 75 f4             	pushl  -0xc(%ebp)
  801018:	6a 00                	push   $0x0
  80101a:	e8 62 f1 ff ff       	call   800181 <sys_page_alloc>
  80101f:	83 c4 10             	add    $0x10,%esp
		return r;
  801022:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	78 23                	js     80104b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801028:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80102e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801031:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801033:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801036:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	50                   	push   %eax
  801041:	e8 2c f3 ff ff       	call   800372 <fd2num>
  801046:	89 c2                	mov    %eax,%edx
  801048:	83 c4 10             	add    $0x10,%esp
}
  80104b:	89 d0                	mov    %edx,%eax
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801054:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801057:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80105d:	e8 e1 f0 ff ff       	call   800143 <sys_getenvid>
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	ff 75 0c             	pushl  0xc(%ebp)
  801068:	ff 75 08             	pushl  0x8(%ebp)
  80106b:	56                   	push   %esi
  80106c:	50                   	push   %eax
  80106d:	68 e4 1e 80 00       	push   $0x801ee4
  801072:	e8 b1 00 00 00       	call   801128 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801077:	83 c4 18             	add    $0x18,%esp
  80107a:	53                   	push   %ebx
  80107b:	ff 75 10             	pushl  0x10(%ebp)
  80107e:	e8 54 00 00 00       	call   8010d7 <vcprintf>
	cprintf("\n");
  801083:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  80108a:	e8 99 00 00 00       	call   801128 <cprintf>
  80108f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801092:	cc                   	int3   
  801093:	eb fd                	jmp    801092 <_panic+0x43>

00801095 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	53                   	push   %ebx
  801099:	83 ec 04             	sub    $0x4,%esp
  80109c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80109f:	8b 13                	mov    (%ebx),%edx
  8010a1:	8d 42 01             	lea    0x1(%edx),%eax
  8010a4:	89 03                	mov    %eax,(%ebx)
  8010a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010b2:	75 1a                	jne    8010ce <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010b4:	83 ec 08             	sub    $0x8,%esp
  8010b7:	68 ff 00 00 00       	push   $0xff
  8010bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8010bf:	50                   	push   %eax
  8010c0:	e8 00 f0 ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010cb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010ce:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010e7:	00 00 00 
	b.cnt = 0;
  8010ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f4:	ff 75 0c             	pushl  0xc(%ebp)
  8010f7:	ff 75 08             	pushl  0x8(%ebp)
  8010fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801100:	50                   	push   %eax
  801101:	68 95 10 80 00       	push   $0x801095
  801106:	e8 54 01 00 00       	call   80125f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80110b:	83 c4 08             	add    $0x8,%esp
  80110e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801114:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80111a:	50                   	push   %eax
  80111b:	e8 a5 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801120:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801126:	c9                   	leave  
  801127:	c3                   	ret    

00801128 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80112e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801131:	50                   	push   %eax
  801132:	ff 75 08             	pushl  0x8(%ebp)
  801135:	e8 9d ff ff ff       	call   8010d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80113a:	c9                   	leave  
  80113b:	c3                   	ret    

0080113c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	57                   	push   %edi
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	83 ec 1c             	sub    $0x1c,%esp
  801145:	89 c7                	mov    %eax,%edi
  801147:	89 d6                	mov    %edx,%esi
  801149:	8b 45 08             	mov    0x8(%ebp),%eax
  80114c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801152:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801155:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801158:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801160:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801163:	39 d3                	cmp    %edx,%ebx
  801165:	72 05                	jb     80116c <printnum+0x30>
  801167:	39 45 10             	cmp    %eax,0x10(%ebp)
  80116a:	77 45                	ja     8011b1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	ff 75 18             	pushl  0x18(%ebp)
  801172:	8b 45 14             	mov    0x14(%ebp),%eax
  801175:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801178:	53                   	push   %ebx
  801179:	ff 75 10             	pushl  0x10(%ebp)
  80117c:	83 ec 08             	sub    $0x8,%esp
  80117f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801182:	ff 75 e0             	pushl  -0x20(%ebp)
  801185:	ff 75 dc             	pushl  -0x24(%ebp)
  801188:	ff 75 d8             	pushl  -0x28(%ebp)
  80118b:	e8 a0 09 00 00       	call   801b30 <__udivdi3>
  801190:	83 c4 18             	add    $0x18,%esp
  801193:	52                   	push   %edx
  801194:	50                   	push   %eax
  801195:	89 f2                	mov    %esi,%edx
  801197:	89 f8                	mov    %edi,%eax
  801199:	e8 9e ff ff ff       	call   80113c <printnum>
  80119e:	83 c4 20             	add    $0x20,%esp
  8011a1:	eb 18                	jmp    8011bb <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	56                   	push   %esi
  8011a7:	ff 75 18             	pushl  0x18(%ebp)
  8011aa:	ff d7                	call   *%edi
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	eb 03                	jmp    8011b4 <printnum+0x78>
  8011b1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011b4:	83 eb 01             	sub    $0x1,%ebx
  8011b7:	85 db                	test   %ebx,%ebx
  8011b9:	7f e8                	jg     8011a3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	56                   	push   %esi
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8011cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ce:	e8 8d 0a 00 00       	call   801c60 <__umoddi3>
  8011d3:	83 c4 14             	add    $0x14,%esp
  8011d6:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  8011dd:	50                   	push   %eax
  8011de:	ff d7                	call   *%edi
}
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011ee:	83 fa 01             	cmp    $0x1,%edx
  8011f1:	7e 0e                	jle    801201 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011f3:	8b 10                	mov    (%eax),%edx
  8011f5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011f8:	89 08                	mov    %ecx,(%eax)
  8011fa:	8b 02                	mov    (%edx),%eax
  8011fc:	8b 52 04             	mov    0x4(%edx),%edx
  8011ff:	eb 22                	jmp    801223 <getuint+0x38>
	else if (lflag)
  801201:	85 d2                	test   %edx,%edx
  801203:	74 10                	je     801215 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801205:	8b 10                	mov    (%eax),%edx
  801207:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120a:	89 08                	mov    %ecx,(%eax)
  80120c:	8b 02                	mov    (%edx),%eax
  80120e:	ba 00 00 00 00       	mov    $0x0,%edx
  801213:	eb 0e                	jmp    801223 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801215:	8b 10                	mov    (%eax),%edx
  801217:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121a:	89 08                	mov    %ecx,(%eax)
  80121c:	8b 02                	mov    (%edx),%eax
  80121e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80122b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80122f:	8b 10                	mov    (%eax),%edx
  801231:	3b 50 04             	cmp    0x4(%eax),%edx
  801234:	73 0a                	jae    801240 <sprintputch+0x1b>
		*b->buf++ = ch;
  801236:	8d 4a 01             	lea    0x1(%edx),%ecx
  801239:	89 08                	mov    %ecx,(%eax)
  80123b:	8b 45 08             	mov    0x8(%ebp),%eax
  80123e:	88 02                	mov    %al,(%edx)
}
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801248:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80124b:	50                   	push   %eax
  80124c:	ff 75 10             	pushl  0x10(%ebp)
  80124f:	ff 75 0c             	pushl  0xc(%ebp)
  801252:	ff 75 08             	pushl  0x8(%ebp)
  801255:	e8 05 00 00 00       	call   80125f <vprintfmt>
	va_end(ap);
}
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	57                   	push   %edi
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 2c             	sub    $0x2c,%esp
  801268:	8b 75 08             	mov    0x8(%ebp),%esi
  80126b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80126e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801271:	eb 12                	jmp    801285 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801273:	85 c0                	test   %eax,%eax
  801275:	0f 84 89 03 00 00    	je     801604 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	53                   	push   %ebx
  80127f:	50                   	push   %eax
  801280:	ff d6                	call   *%esi
  801282:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801285:	83 c7 01             	add    $0x1,%edi
  801288:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80128c:	83 f8 25             	cmp    $0x25,%eax
  80128f:	75 e2                	jne    801273 <vprintfmt+0x14>
  801291:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801295:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80129c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012a3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8012af:	eb 07                	jmp    8012b8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012b4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b8:	8d 47 01             	lea    0x1(%edi),%eax
  8012bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012be:	0f b6 07             	movzbl (%edi),%eax
  8012c1:	0f b6 c8             	movzbl %al,%ecx
  8012c4:	83 e8 23             	sub    $0x23,%eax
  8012c7:	3c 55                	cmp    $0x55,%al
  8012c9:	0f 87 1a 03 00 00    	ja     8015e9 <vprintfmt+0x38a>
  8012cf:	0f b6 c0             	movzbl %al,%eax
  8012d2:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8012d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012dc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012e0:	eb d6                	jmp    8012b8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012ed:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012f0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012f4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012f7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012fa:	83 fa 09             	cmp    $0x9,%edx
  8012fd:	77 39                	ja     801338 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ff:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801302:	eb e9                	jmp    8012ed <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801304:	8b 45 14             	mov    0x14(%ebp),%eax
  801307:	8d 48 04             	lea    0x4(%eax),%ecx
  80130a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80130d:	8b 00                	mov    (%eax),%eax
  80130f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801315:	eb 27                	jmp    80133e <vprintfmt+0xdf>
  801317:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80131a:	85 c0                	test   %eax,%eax
  80131c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801321:	0f 49 c8             	cmovns %eax,%ecx
  801324:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80132a:	eb 8c                	jmp    8012b8 <vprintfmt+0x59>
  80132c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80132f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801336:	eb 80                	jmp    8012b8 <vprintfmt+0x59>
  801338:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80133b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80133e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801342:	0f 89 70 ff ff ff    	jns    8012b8 <vprintfmt+0x59>
				width = precision, precision = -1;
  801348:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80134b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80134e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801355:	e9 5e ff ff ff       	jmp    8012b8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80135a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801360:	e9 53 ff ff ff       	jmp    8012b8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801365:	8b 45 14             	mov    0x14(%ebp),%eax
  801368:	8d 50 04             	lea    0x4(%eax),%edx
  80136b:	89 55 14             	mov    %edx,0x14(%ebp)
  80136e:	83 ec 08             	sub    $0x8,%esp
  801371:	53                   	push   %ebx
  801372:	ff 30                	pushl  (%eax)
  801374:	ff d6                	call   *%esi
			break;
  801376:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80137c:	e9 04 ff ff ff       	jmp    801285 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801381:	8b 45 14             	mov    0x14(%ebp),%eax
  801384:	8d 50 04             	lea    0x4(%eax),%edx
  801387:	89 55 14             	mov    %edx,0x14(%ebp)
  80138a:	8b 00                	mov    (%eax),%eax
  80138c:	99                   	cltd   
  80138d:	31 d0                	xor    %edx,%eax
  80138f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801391:	83 f8 0f             	cmp    $0xf,%eax
  801394:	7f 0b                	jg     8013a1 <vprintfmt+0x142>
  801396:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  80139d:	85 d2                	test   %edx,%edx
  80139f:	75 18                	jne    8013b9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013a1:	50                   	push   %eax
  8013a2:	68 1f 1f 80 00       	push   $0x801f1f
  8013a7:	53                   	push   %ebx
  8013a8:	56                   	push   %esi
  8013a9:	e8 94 fe ff ff       	call   801242 <printfmt>
  8013ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013b4:	e9 cc fe ff ff       	jmp    801285 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013b9:	52                   	push   %edx
  8013ba:	68 9d 1e 80 00       	push   $0x801e9d
  8013bf:	53                   	push   %ebx
  8013c0:	56                   	push   %esi
  8013c1:	e8 7c fe ff ff       	call   801242 <printfmt>
  8013c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013cc:	e9 b4 fe ff ff       	jmp    801285 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d4:	8d 50 04             	lea    0x4(%eax),%edx
  8013d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8013da:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013dc:	85 ff                	test   %edi,%edi
  8013de:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  8013e3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013ea:	0f 8e 94 00 00 00    	jle    801484 <vprintfmt+0x225>
  8013f0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013f4:	0f 84 98 00 00 00    	je     801492 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	ff 75 d0             	pushl  -0x30(%ebp)
  801400:	57                   	push   %edi
  801401:	e8 86 02 00 00       	call   80168c <strnlen>
  801406:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801409:	29 c1                	sub    %eax,%ecx
  80140b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80140e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801411:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801415:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801418:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80141b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80141d:	eb 0f                	jmp    80142e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	53                   	push   %ebx
  801423:	ff 75 e0             	pushl  -0x20(%ebp)
  801426:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801428:	83 ef 01             	sub    $0x1,%edi
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	85 ff                	test   %edi,%edi
  801430:	7f ed                	jg     80141f <vprintfmt+0x1c0>
  801432:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801435:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801438:	85 c9                	test   %ecx,%ecx
  80143a:	b8 00 00 00 00       	mov    $0x0,%eax
  80143f:	0f 49 c1             	cmovns %ecx,%eax
  801442:	29 c1                	sub    %eax,%ecx
  801444:	89 75 08             	mov    %esi,0x8(%ebp)
  801447:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80144d:	89 cb                	mov    %ecx,%ebx
  80144f:	eb 4d                	jmp    80149e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801451:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801455:	74 1b                	je     801472 <vprintfmt+0x213>
  801457:	0f be c0             	movsbl %al,%eax
  80145a:	83 e8 20             	sub    $0x20,%eax
  80145d:	83 f8 5e             	cmp    $0x5e,%eax
  801460:	76 10                	jbe    801472 <vprintfmt+0x213>
					putch('?', putdat);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	ff 75 0c             	pushl  0xc(%ebp)
  801468:	6a 3f                	push   $0x3f
  80146a:	ff 55 08             	call   *0x8(%ebp)
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	eb 0d                	jmp    80147f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	ff 75 0c             	pushl  0xc(%ebp)
  801478:	52                   	push   %edx
  801479:	ff 55 08             	call   *0x8(%ebp)
  80147c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147f:	83 eb 01             	sub    $0x1,%ebx
  801482:	eb 1a                	jmp    80149e <vprintfmt+0x23f>
  801484:	89 75 08             	mov    %esi,0x8(%ebp)
  801487:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80148a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80148d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801490:	eb 0c                	jmp    80149e <vprintfmt+0x23f>
  801492:	89 75 08             	mov    %esi,0x8(%ebp)
  801495:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801498:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80149b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80149e:	83 c7 01             	add    $0x1,%edi
  8014a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014a5:	0f be d0             	movsbl %al,%edx
  8014a8:	85 d2                	test   %edx,%edx
  8014aa:	74 23                	je     8014cf <vprintfmt+0x270>
  8014ac:	85 f6                	test   %esi,%esi
  8014ae:	78 a1                	js     801451 <vprintfmt+0x1f2>
  8014b0:	83 ee 01             	sub    $0x1,%esi
  8014b3:	79 9c                	jns    801451 <vprintfmt+0x1f2>
  8014b5:	89 df                	mov    %ebx,%edi
  8014b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014bd:	eb 18                	jmp    8014d7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	53                   	push   %ebx
  8014c3:	6a 20                	push   $0x20
  8014c5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014c7:	83 ef 01             	sub    $0x1,%edi
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	eb 08                	jmp    8014d7 <vprintfmt+0x278>
  8014cf:	89 df                	mov    %ebx,%edi
  8014d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d7:	85 ff                	test   %edi,%edi
  8014d9:	7f e4                	jg     8014bf <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014de:	e9 a2 fd ff ff       	jmp    801285 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014e3:	83 fa 01             	cmp    $0x1,%edx
  8014e6:	7e 16                	jle    8014fe <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014eb:	8d 50 08             	lea    0x8(%eax),%edx
  8014ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f1:	8b 50 04             	mov    0x4(%eax),%edx
  8014f4:	8b 00                	mov    (%eax),%eax
  8014f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014fc:	eb 32                	jmp    801530 <vprintfmt+0x2d1>
	else if (lflag)
  8014fe:	85 d2                	test   %edx,%edx
  801500:	74 18                	je     80151a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801502:	8b 45 14             	mov    0x14(%ebp),%eax
  801505:	8d 50 04             	lea    0x4(%eax),%edx
  801508:	89 55 14             	mov    %edx,0x14(%ebp)
  80150b:	8b 00                	mov    (%eax),%eax
  80150d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801510:	89 c1                	mov    %eax,%ecx
  801512:	c1 f9 1f             	sar    $0x1f,%ecx
  801515:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801518:	eb 16                	jmp    801530 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80151a:	8b 45 14             	mov    0x14(%ebp),%eax
  80151d:	8d 50 04             	lea    0x4(%eax),%edx
  801520:	89 55 14             	mov    %edx,0x14(%ebp)
  801523:	8b 00                	mov    (%eax),%eax
  801525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801528:	89 c1                	mov    %eax,%ecx
  80152a:	c1 f9 1f             	sar    $0x1f,%ecx
  80152d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801530:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801533:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801536:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80153b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80153f:	79 74                	jns    8015b5 <vprintfmt+0x356>
				putch('-', putdat);
  801541:	83 ec 08             	sub    $0x8,%esp
  801544:	53                   	push   %ebx
  801545:	6a 2d                	push   $0x2d
  801547:	ff d6                	call   *%esi
				num = -(long long) num;
  801549:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80154c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80154f:	f7 d8                	neg    %eax
  801551:	83 d2 00             	adc    $0x0,%edx
  801554:	f7 da                	neg    %edx
  801556:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801559:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80155e:	eb 55                	jmp    8015b5 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801560:	8d 45 14             	lea    0x14(%ebp),%eax
  801563:	e8 83 fc ff ff       	call   8011eb <getuint>
			base = 10;
  801568:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80156d:	eb 46                	jmp    8015b5 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80156f:	8d 45 14             	lea    0x14(%ebp),%eax
  801572:	e8 74 fc ff ff       	call   8011eb <getuint>
			base = 8;
  801577:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80157c:	eb 37                	jmp    8015b5 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	53                   	push   %ebx
  801582:	6a 30                	push   $0x30
  801584:	ff d6                	call   *%esi
			putch('x', putdat);
  801586:	83 c4 08             	add    $0x8,%esp
  801589:	53                   	push   %ebx
  80158a:	6a 78                	push   $0x78
  80158c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80158e:	8b 45 14             	mov    0x14(%ebp),%eax
  801591:	8d 50 04             	lea    0x4(%eax),%edx
  801594:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801597:	8b 00                	mov    (%eax),%eax
  801599:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80159e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015a1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015a6:	eb 0d                	jmp    8015b5 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ab:	e8 3b fc ff ff       	call   8011eb <getuint>
			base = 16;
  8015b0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015bc:	57                   	push   %edi
  8015bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c0:	51                   	push   %ecx
  8015c1:	52                   	push   %edx
  8015c2:	50                   	push   %eax
  8015c3:	89 da                	mov    %ebx,%edx
  8015c5:	89 f0                	mov    %esi,%eax
  8015c7:	e8 70 fb ff ff       	call   80113c <printnum>
			break;
  8015cc:	83 c4 20             	add    $0x20,%esp
  8015cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015d2:	e9 ae fc ff ff       	jmp    801285 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	53                   	push   %ebx
  8015db:	51                   	push   %ecx
  8015dc:	ff d6                	call   *%esi
			break;
  8015de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015e4:	e9 9c fc ff ff       	jmp    801285 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	53                   	push   %ebx
  8015ed:	6a 25                	push   $0x25
  8015ef:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	eb 03                	jmp    8015f9 <vprintfmt+0x39a>
  8015f6:	83 ef 01             	sub    $0x1,%edi
  8015f9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015fd:	75 f7                	jne    8015f6 <vprintfmt+0x397>
  8015ff:	e9 81 fc ff ff       	jmp    801285 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801604:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5f                   	pop    %edi
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	83 ec 18             	sub    $0x18,%esp
  801612:	8b 45 08             	mov    0x8(%ebp),%eax
  801615:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801618:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80161b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80161f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801622:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801629:	85 c0                	test   %eax,%eax
  80162b:	74 26                	je     801653 <vsnprintf+0x47>
  80162d:	85 d2                	test   %edx,%edx
  80162f:	7e 22                	jle    801653 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801631:	ff 75 14             	pushl  0x14(%ebp)
  801634:	ff 75 10             	pushl  0x10(%ebp)
  801637:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	68 25 12 80 00       	push   $0x801225
  801640:	e8 1a fc ff ff       	call   80125f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801645:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801648:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80164b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	eb 05                	jmp    801658 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801653:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801660:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801663:	50                   	push   %eax
  801664:	ff 75 10             	pushl  0x10(%ebp)
  801667:	ff 75 0c             	pushl  0xc(%ebp)
  80166a:	ff 75 08             	pushl  0x8(%ebp)
  80166d:	e8 9a ff ff ff       	call   80160c <vsnprintf>
	va_end(ap);

	return rc;
}
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80167a:	b8 00 00 00 00       	mov    $0x0,%eax
  80167f:	eb 03                	jmp    801684 <strlen+0x10>
		n++;
  801681:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801684:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801688:	75 f7                	jne    801681 <strlen+0xd>
		n++;
	return n;
}
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801692:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801695:	ba 00 00 00 00       	mov    $0x0,%edx
  80169a:	eb 03                	jmp    80169f <strnlen+0x13>
		n++;
  80169c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169f:	39 c2                	cmp    %eax,%edx
  8016a1:	74 08                	je     8016ab <strnlen+0x1f>
  8016a3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016a7:	75 f3                	jne    80169c <strnlen+0x10>
  8016a9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	53                   	push   %ebx
  8016b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	83 c2 01             	add    $0x1,%edx
  8016bc:	83 c1 01             	add    $0x1,%ecx
  8016bf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016c3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016c6:	84 db                	test   %bl,%bl
  8016c8:	75 ef                	jne    8016b9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016ca:	5b                   	pop    %ebx
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	53                   	push   %ebx
  8016d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016d4:	53                   	push   %ebx
  8016d5:	e8 9a ff ff ff       	call   801674 <strlen>
  8016da:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016dd:	ff 75 0c             	pushl  0xc(%ebp)
  8016e0:	01 d8                	add    %ebx,%eax
  8016e2:	50                   	push   %eax
  8016e3:	e8 c5 ff ff ff       	call   8016ad <strcpy>
	return dst;
}
  8016e8:	89 d8                	mov    %ebx,%eax
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
  8016f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fa:	89 f3                	mov    %esi,%ebx
  8016fc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016ff:	89 f2                	mov    %esi,%edx
  801701:	eb 0f                	jmp    801712 <strncpy+0x23>
		*dst++ = *src;
  801703:	83 c2 01             	add    $0x1,%edx
  801706:	0f b6 01             	movzbl (%ecx),%eax
  801709:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80170c:	80 39 01             	cmpb   $0x1,(%ecx)
  80170f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801712:	39 da                	cmp    %ebx,%edx
  801714:	75 ed                	jne    801703 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801716:	89 f0                	mov    %esi,%eax
  801718:	5b                   	pop    %ebx
  801719:	5e                   	pop    %esi
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	8b 75 08             	mov    0x8(%ebp),%esi
  801724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801727:	8b 55 10             	mov    0x10(%ebp),%edx
  80172a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80172c:	85 d2                	test   %edx,%edx
  80172e:	74 21                	je     801751 <strlcpy+0x35>
  801730:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801734:	89 f2                	mov    %esi,%edx
  801736:	eb 09                	jmp    801741 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801738:	83 c2 01             	add    $0x1,%edx
  80173b:	83 c1 01             	add    $0x1,%ecx
  80173e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801741:	39 c2                	cmp    %eax,%edx
  801743:	74 09                	je     80174e <strlcpy+0x32>
  801745:	0f b6 19             	movzbl (%ecx),%ebx
  801748:	84 db                	test   %bl,%bl
  80174a:	75 ec                	jne    801738 <strlcpy+0x1c>
  80174c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80174e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801751:	29 f0                	sub    %esi,%eax
}
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801760:	eb 06                	jmp    801768 <strcmp+0x11>
		p++, q++;
  801762:	83 c1 01             	add    $0x1,%ecx
  801765:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801768:	0f b6 01             	movzbl (%ecx),%eax
  80176b:	84 c0                	test   %al,%al
  80176d:	74 04                	je     801773 <strcmp+0x1c>
  80176f:	3a 02                	cmp    (%edx),%al
  801771:	74 ef                	je     801762 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801773:	0f b6 c0             	movzbl %al,%eax
  801776:	0f b6 12             	movzbl (%edx),%edx
  801779:	29 d0                	sub    %edx,%eax
}
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	53                   	push   %ebx
  801781:	8b 45 08             	mov    0x8(%ebp),%eax
  801784:	8b 55 0c             	mov    0xc(%ebp),%edx
  801787:	89 c3                	mov    %eax,%ebx
  801789:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80178c:	eb 06                	jmp    801794 <strncmp+0x17>
		n--, p++, q++;
  80178e:	83 c0 01             	add    $0x1,%eax
  801791:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801794:	39 d8                	cmp    %ebx,%eax
  801796:	74 15                	je     8017ad <strncmp+0x30>
  801798:	0f b6 08             	movzbl (%eax),%ecx
  80179b:	84 c9                	test   %cl,%cl
  80179d:	74 04                	je     8017a3 <strncmp+0x26>
  80179f:	3a 0a                	cmp    (%edx),%cl
  8017a1:	74 eb                	je     80178e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a3:	0f b6 00             	movzbl (%eax),%eax
  8017a6:	0f b6 12             	movzbl (%edx),%edx
  8017a9:	29 d0                	sub    %edx,%eax
  8017ab:	eb 05                	jmp    8017b2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017ad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017b2:	5b                   	pop    %ebx
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017bf:	eb 07                	jmp    8017c8 <strchr+0x13>
		if (*s == c)
  8017c1:	38 ca                	cmp    %cl,%dl
  8017c3:	74 0f                	je     8017d4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017c5:	83 c0 01             	add    $0x1,%eax
  8017c8:	0f b6 10             	movzbl (%eax),%edx
  8017cb:	84 d2                	test   %dl,%dl
  8017cd:	75 f2                	jne    8017c1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e0:	eb 03                	jmp    8017e5 <strfind+0xf>
  8017e2:	83 c0 01             	add    $0x1,%eax
  8017e5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017e8:	38 ca                	cmp    %cl,%dl
  8017ea:	74 04                	je     8017f0 <strfind+0x1a>
  8017ec:	84 d2                	test   %dl,%dl
  8017ee:	75 f2                	jne    8017e2 <strfind+0xc>
			break;
	return (char *) s;
}
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	57                   	push   %edi
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017fe:	85 c9                	test   %ecx,%ecx
  801800:	74 36                	je     801838 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801802:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801808:	75 28                	jne    801832 <memset+0x40>
  80180a:	f6 c1 03             	test   $0x3,%cl
  80180d:	75 23                	jne    801832 <memset+0x40>
		c &= 0xFF;
  80180f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801813:	89 d3                	mov    %edx,%ebx
  801815:	c1 e3 08             	shl    $0x8,%ebx
  801818:	89 d6                	mov    %edx,%esi
  80181a:	c1 e6 18             	shl    $0x18,%esi
  80181d:	89 d0                	mov    %edx,%eax
  80181f:	c1 e0 10             	shl    $0x10,%eax
  801822:	09 f0                	or     %esi,%eax
  801824:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801826:	89 d8                	mov    %ebx,%eax
  801828:	09 d0                	or     %edx,%eax
  80182a:	c1 e9 02             	shr    $0x2,%ecx
  80182d:	fc                   	cld    
  80182e:	f3 ab                	rep stos %eax,%es:(%edi)
  801830:	eb 06                	jmp    801838 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801832:	8b 45 0c             	mov    0xc(%ebp),%eax
  801835:	fc                   	cld    
  801836:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801838:	89 f8                	mov    %edi,%eax
  80183a:	5b                   	pop    %ebx
  80183b:	5e                   	pop    %esi
  80183c:	5f                   	pop    %edi
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    

0080183f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	57                   	push   %edi
  801843:	56                   	push   %esi
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	8b 75 0c             	mov    0xc(%ebp),%esi
  80184a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80184d:	39 c6                	cmp    %eax,%esi
  80184f:	73 35                	jae    801886 <memmove+0x47>
  801851:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801854:	39 d0                	cmp    %edx,%eax
  801856:	73 2e                	jae    801886 <memmove+0x47>
		s += n;
		d += n;
  801858:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185b:	89 d6                	mov    %edx,%esi
  80185d:	09 fe                	or     %edi,%esi
  80185f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801865:	75 13                	jne    80187a <memmove+0x3b>
  801867:	f6 c1 03             	test   $0x3,%cl
  80186a:	75 0e                	jne    80187a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80186c:	83 ef 04             	sub    $0x4,%edi
  80186f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801872:	c1 e9 02             	shr    $0x2,%ecx
  801875:	fd                   	std    
  801876:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801878:	eb 09                	jmp    801883 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80187a:	83 ef 01             	sub    $0x1,%edi
  80187d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801880:	fd                   	std    
  801881:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801883:	fc                   	cld    
  801884:	eb 1d                	jmp    8018a3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801886:	89 f2                	mov    %esi,%edx
  801888:	09 c2                	or     %eax,%edx
  80188a:	f6 c2 03             	test   $0x3,%dl
  80188d:	75 0f                	jne    80189e <memmove+0x5f>
  80188f:	f6 c1 03             	test   $0x3,%cl
  801892:	75 0a                	jne    80189e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801894:	c1 e9 02             	shr    $0x2,%ecx
  801897:	89 c7                	mov    %eax,%edi
  801899:	fc                   	cld    
  80189a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80189c:	eb 05                	jmp    8018a3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80189e:	89 c7                	mov    %eax,%edi
  8018a0:	fc                   	cld    
  8018a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018a3:	5e                   	pop    %esi
  8018a4:	5f                   	pop    %edi
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018aa:	ff 75 10             	pushl  0x10(%ebp)
  8018ad:	ff 75 0c             	pushl  0xc(%ebp)
  8018b0:	ff 75 08             	pushl  0x8(%ebp)
  8018b3:	e8 87 ff ff ff       	call   80183f <memmove>
}
  8018b8:	c9                   	leave  
  8018b9:	c3                   	ret    

008018ba <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	56                   	push   %esi
  8018be:	53                   	push   %ebx
  8018bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c5:	89 c6                	mov    %eax,%esi
  8018c7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ca:	eb 1a                	jmp    8018e6 <memcmp+0x2c>
		if (*s1 != *s2)
  8018cc:	0f b6 08             	movzbl (%eax),%ecx
  8018cf:	0f b6 1a             	movzbl (%edx),%ebx
  8018d2:	38 d9                	cmp    %bl,%cl
  8018d4:	74 0a                	je     8018e0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018d6:	0f b6 c1             	movzbl %cl,%eax
  8018d9:	0f b6 db             	movzbl %bl,%ebx
  8018dc:	29 d8                	sub    %ebx,%eax
  8018de:	eb 0f                	jmp    8018ef <memcmp+0x35>
		s1++, s2++;
  8018e0:	83 c0 01             	add    $0x1,%eax
  8018e3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e6:	39 f0                	cmp    %esi,%eax
  8018e8:	75 e2                	jne    8018cc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ef:	5b                   	pop    %ebx
  8018f0:	5e                   	pop    %esi
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    

008018f3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	53                   	push   %ebx
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018fa:	89 c1                	mov    %eax,%ecx
  8018fc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018ff:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801903:	eb 0a                	jmp    80190f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801905:	0f b6 10             	movzbl (%eax),%edx
  801908:	39 da                	cmp    %ebx,%edx
  80190a:	74 07                	je     801913 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190c:	83 c0 01             	add    $0x1,%eax
  80190f:	39 c8                	cmp    %ecx,%eax
  801911:	72 f2                	jb     801905 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801913:	5b                   	pop    %ebx
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	57                   	push   %edi
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80191f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801922:	eb 03                	jmp    801927 <strtol+0x11>
		s++;
  801924:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801927:	0f b6 01             	movzbl (%ecx),%eax
  80192a:	3c 20                	cmp    $0x20,%al
  80192c:	74 f6                	je     801924 <strtol+0xe>
  80192e:	3c 09                	cmp    $0x9,%al
  801930:	74 f2                	je     801924 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801932:	3c 2b                	cmp    $0x2b,%al
  801934:	75 0a                	jne    801940 <strtol+0x2a>
		s++;
  801936:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801939:	bf 00 00 00 00       	mov    $0x0,%edi
  80193e:	eb 11                	jmp    801951 <strtol+0x3b>
  801940:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801945:	3c 2d                	cmp    $0x2d,%al
  801947:	75 08                	jne    801951 <strtol+0x3b>
		s++, neg = 1;
  801949:	83 c1 01             	add    $0x1,%ecx
  80194c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801951:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801957:	75 15                	jne    80196e <strtol+0x58>
  801959:	80 39 30             	cmpb   $0x30,(%ecx)
  80195c:	75 10                	jne    80196e <strtol+0x58>
  80195e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801962:	75 7c                	jne    8019e0 <strtol+0xca>
		s += 2, base = 16;
  801964:	83 c1 02             	add    $0x2,%ecx
  801967:	bb 10 00 00 00       	mov    $0x10,%ebx
  80196c:	eb 16                	jmp    801984 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80196e:	85 db                	test   %ebx,%ebx
  801970:	75 12                	jne    801984 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801972:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801977:	80 39 30             	cmpb   $0x30,(%ecx)
  80197a:	75 08                	jne    801984 <strtol+0x6e>
		s++, base = 8;
  80197c:	83 c1 01             	add    $0x1,%ecx
  80197f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801984:	b8 00 00 00 00       	mov    $0x0,%eax
  801989:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80198c:	0f b6 11             	movzbl (%ecx),%edx
  80198f:	8d 72 d0             	lea    -0x30(%edx),%esi
  801992:	89 f3                	mov    %esi,%ebx
  801994:	80 fb 09             	cmp    $0x9,%bl
  801997:	77 08                	ja     8019a1 <strtol+0x8b>
			dig = *s - '0';
  801999:	0f be d2             	movsbl %dl,%edx
  80199c:	83 ea 30             	sub    $0x30,%edx
  80199f:	eb 22                	jmp    8019c3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019a1:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019a4:	89 f3                	mov    %esi,%ebx
  8019a6:	80 fb 19             	cmp    $0x19,%bl
  8019a9:	77 08                	ja     8019b3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019ab:	0f be d2             	movsbl %dl,%edx
  8019ae:	83 ea 57             	sub    $0x57,%edx
  8019b1:	eb 10                	jmp    8019c3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019b3:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019b6:	89 f3                	mov    %esi,%ebx
  8019b8:	80 fb 19             	cmp    $0x19,%bl
  8019bb:	77 16                	ja     8019d3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019bd:	0f be d2             	movsbl %dl,%edx
  8019c0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019c3:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019c6:	7d 0b                	jge    8019d3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019c8:	83 c1 01             	add    $0x1,%ecx
  8019cb:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019cf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019d1:	eb b9                	jmp    80198c <strtol+0x76>

	if (endptr)
  8019d3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019d7:	74 0d                	je     8019e6 <strtol+0xd0>
		*endptr = (char *) s;
  8019d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019dc:	89 0e                	mov    %ecx,(%esi)
  8019de:	eb 06                	jmp    8019e6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e0:	85 db                	test   %ebx,%ebx
  8019e2:	74 98                	je     80197c <strtol+0x66>
  8019e4:	eb 9e                	jmp    801984 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019e6:	89 c2                	mov    %eax,%edx
  8019e8:	f7 da                	neg    %edx
  8019ea:	85 ff                	test   %edi,%edi
  8019ec:	0f 45 c2             	cmovne %edx,%eax
}
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5f                   	pop    %edi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    

008019f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
  8019f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801a02:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801a04:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a09:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801a0c:	83 ec 0c             	sub    $0xc,%esp
  801a0f:	50                   	push   %eax
  801a10:	e8 1c e9 ff ff       	call   800331 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	85 f6                	test   %esi,%esi
  801a1a:	74 14                	je     801a30 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801a1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a21:	85 c0                	test   %eax,%eax
  801a23:	78 09                	js     801a2e <ipc_recv+0x3a>
  801a25:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a2b:	8b 52 74             	mov    0x74(%edx),%edx
  801a2e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a30:	85 db                	test   %ebx,%ebx
  801a32:	74 14                	je     801a48 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a34:	ba 00 00 00 00       	mov    $0x0,%edx
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	78 09                	js     801a46 <ipc_recv+0x52>
  801a3d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a43:	8b 52 78             	mov    0x78(%edx),%edx
  801a46:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	78 08                	js     801a54 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a51:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	57                   	push   %edi
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	83 ec 0c             	sub    $0xc,%esp
  801a64:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a67:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a6d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a6f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a74:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a77:	ff 75 14             	pushl  0x14(%ebp)
  801a7a:	53                   	push   %ebx
  801a7b:	56                   	push   %esi
  801a7c:	57                   	push   %edi
  801a7d:	e8 8c e8 ff ff       	call   80030e <sys_ipc_try_send>

		if (err < 0) {
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	85 c0                	test   %eax,%eax
  801a87:	79 1e                	jns    801aa7 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a89:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8c:	75 07                	jne    801a95 <ipc_send+0x3a>
				sys_yield();
  801a8e:	e8 cf e6 ff ff       	call   800162 <sys_yield>
  801a93:	eb e2                	jmp    801a77 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a95:	50                   	push   %eax
  801a96:	68 00 22 80 00       	push   $0x802200
  801a9b:	6a 49                	push   $0x49
  801a9d:	68 0d 22 80 00       	push   $0x80220d
  801aa2:	e8 a8 f5 ff ff       	call   80104f <_panic>
		}

	} while (err < 0);

}
  801aa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5f                   	pop    %edi
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    

00801aaf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ab5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801abd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ac3:	8b 52 50             	mov    0x50(%edx),%edx
  801ac6:	39 ca                	cmp    %ecx,%edx
  801ac8:	75 0d                	jne    801ad7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801aca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801acd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ad2:	8b 40 48             	mov    0x48(%eax),%eax
  801ad5:	eb 0f                	jmp    801ae6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad7:	83 c0 01             	add    $0x1,%eax
  801ada:	3d 00 04 00 00       	cmp    $0x400,%eax
  801adf:	75 d9                	jne    801aba <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ae1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae6:	5d                   	pop    %ebp
  801ae7:	c3                   	ret    

00801ae8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aee:	89 d0                	mov    %edx,%eax
  801af0:	c1 e8 16             	shr    $0x16,%eax
  801af3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aff:	f6 c1 01             	test   $0x1,%cl
  801b02:	74 1d                	je     801b21 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b04:	c1 ea 0c             	shr    $0xc,%edx
  801b07:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b0e:	f6 c2 01             	test   $0x1,%dl
  801b11:	74 0e                	je     801b21 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b13:	c1 ea 0c             	shr    $0xc,%edx
  801b16:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b1d:	ef 
  801b1e:	0f b7 c0             	movzwl %ax,%eax
}
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    
  801b23:	66 90                	xchg   %ax,%ax
  801b25:	66 90                	xchg   %ax,%ax
  801b27:	66 90                	xchg   %ax,%ax
  801b29:	66 90                	xchg   %ax,%ax
  801b2b:	66 90                	xchg   %ax,%ax
  801b2d:	66 90                	xchg   %ax,%ax
  801b2f:	90                   	nop

00801b30 <__udivdi3>:
  801b30:	55                   	push   %ebp
  801b31:	57                   	push   %edi
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	83 ec 1c             	sub    $0x1c,%esp
  801b37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b47:	85 f6                	test   %esi,%esi
  801b49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b4d:	89 ca                	mov    %ecx,%edx
  801b4f:	89 f8                	mov    %edi,%eax
  801b51:	75 3d                	jne    801b90 <__udivdi3+0x60>
  801b53:	39 cf                	cmp    %ecx,%edi
  801b55:	0f 87 c5 00 00 00    	ja     801c20 <__udivdi3+0xf0>
  801b5b:	85 ff                	test   %edi,%edi
  801b5d:	89 fd                	mov    %edi,%ebp
  801b5f:	75 0b                	jne    801b6c <__udivdi3+0x3c>
  801b61:	b8 01 00 00 00       	mov    $0x1,%eax
  801b66:	31 d2                	xor    %edx,%edx
  801b68:	f7 f7                	div    %edi
  801b6a:	89 c5                	mov    %eax,%ebp
  801b6c:	89 c8                	mov    %ecx,%eax
  801b6e:	31 d2                	xor    %edx,%edx
  801b70:	f7 f5                	div    %ebp
  801b72:	89 c1                	mov    %eax,%ecx
  801b74:	89 d8                	mov    %ebx,%eax
  801b76:	89 cf                	mov    %ecx,%edi
  801b78:	f7 f5                	div    %ebp
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	89 d8                	mov    %ebx,%eax
  801b7e:	89 fa                	mov    %edi,%edx
  801b80:	83 c4 1c             	add    $0x1c,%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5f                   	pop    %edi
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    
  801b88:	90                   	nop
  801b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b90:	39 ce                	cmp    %ecx,%esi
  801b92:	77 74                	ja     801c08 <__udivdi3+0xd8>
  801b94:	0f bd fe             	bsr    %esi,%edi
  801b97:	83 f7 1f             	xor    $0x1f,%edi
  801b9a:	0f 84 98 00 00 00    	je     801c38 <__udivdi3+0x108>
  801ba0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	89 c5                	mov    %eax,%ebp
  801ba9:	29 fb                	sub    %edi,%ebx
  801bab:	d3 e6                	shl    %cl,%esi
  801bad:	89 d9                	mov    %ebx,%ecx
  801baf:	d3 ed                	shr    %cl,%ebp
  801bb1:	89 f9                	mov    %edi,%ecx
  801bb3:	d3 e0                	shl    %cl,%eax
  801bb5:	09 ee                	or     %ebp,%esi
  801bb7:	89 d9                	mov    %ebx,%ecx
  801bb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bbd:	89 d5                	mov    %edx,%ebp
  801bbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bc3:	d3 ed                	shr    %cl,%ebp
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	d3 e2                	shl    %cl,%edx
  801bc9:	89 d9                	mov    %ebx,%ecx
  801bcb:	d3 e8                	shr    %cl,%eax
  801bcd:	09 c2                	or     %eax,%edx
  801bcf:	89 d0                	mov    %edx,%eax
  801bd1:	89 ea                	mov    %ebp,%edx
  801bd3:	f7 f6                	div    %esi
  801bd5:	89 d5                	mov    %edx,%ebp
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	f7 64 24 0c          	mull   0xc(%esp)
  801bdd:	39 d5                	cmp    %edx,%ebp
  801bdf:	72 10                	jb     801bf1 <__udivdi3+0xc1>
  801be1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	d3 e6                	shl    %cl,%esi
  801be9:	39 c6                	cmp    %eax,%esi
  801beb:	73 07                	jae    801bf4 <__udivdi3+0xc4>
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	75 03                	jne    801bf4 <__udivdi3+0xc4>
  801bf1:	83 eb 01             	sub    $0x1,%ebx
  801bf4:	31 ff                	xor    %edi,%edi
  801bf6:	89 d8                	mov    %ebx,%eax
  801bf8:	89 fa                	mov    %edi,%edx
  801bfa:	83 c4 1c             	add    $0x1c,%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    
  801c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c08:	31 ff                	xor    %edi,%edi
  801c0a:	31 db                	xor    %ebx,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	f7 f7                	div    %edi
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 c3                	mov    %eax,%ebx
  801c28:	89 d8                	mov    %ebx,%eax
  801c2a:	89 fa                	mov    %edi,%edx
  801c2c:	83 c4 1c             	add    $0x1c,%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	39 ce                	cmp    %ecx,%esi
  801c3a:	72 0c                	jb     801c48 <__udivdi3+0x118>
  801c3c:	31 db                	xor    %ebx,%ebx
  801c3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c42:	0f 87 34 ff ff ff    	ja     801b7c <__udivdi3+0x4c>
  801c48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c4d:	e9 2a ff ff ff       	jmp    801b7c <__udivdi3+0x4c>
  801c52:	66 90                	xchg   %ax,%ax
  801c54:	66 90                	xchg   %ax,%ax
  801c56:	66 90                	xchg   %ax,%ax
  801c58:	66 90                	xchg   %ax,%ax
  801c5a:	66 90                	xchg   %ax,%ax
  801c5c:	66 90                	xchg   %ax,%ax
  801c5e:	66 90                	xchg   %ax,%ax

00801c60 <__umoddi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 1c             	sub    $0x1c,%esp
  801c67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c77:	85 d2                	test   %edx,%edx
  801c79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c81:	89 f3                	mov    %esi,%ebx
  801c83:	89 3c 24             	mov    %edi,(%esp)
  801c86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c8a:	75 1c                	jne    801ca8 <__umoddi3+0x48>
  801c8c:	39 f7                	cmp    %esi,%edi
  801c8e:	76 50                	jbe    801ce0 <__umoddi3+0x80>
  801c90:	89 c8                	mov    %ecx,%eax
  801c92:	89 f2                	mov    %esi,%edx
  801c94:	f7 f7                	div    %edi
  801c96:	89 d0                	mov    %edx,%eax
  801c98:	31 d2                	xor    %edx,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	89 d0                	mov    %edx,%eax
  801cac:	77 52                	ja     801d00 <__umoddi3+0xa0>
  801cae:	0f bd ea             	bsr    %edx,%ebp
  801cb1:	83 f5 1f             	xor    $0x1f,%ebp
  801cb4:	75 5a                	jne    801d10 <__umoddi3+0xb0>
  801cb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cba:	0f 82 e0 00 00 00    	jb     801da0 <__umoddi3+0x140>
  801cc0:	39 0c 24             	cmp    %ecx,(%esp)
  801cc3:	0f 86 d7 00 00 00    	jbe    801da0 <__umoddi3+0x140>
  801cc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ccd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cd1:	83 c4 1c             	add    $0x1c,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	85 ff                	test   %edi,%edi
  801ce2:	89 fd                	mov    %edi,%ebp
  801ce4:	75 0b                	jne    801cf1 <__umoddi3+0x91>
  801ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	f7 f7                	div    %edi
  801cef:	89 c5                	mov    %eax,%ebp
  801cf1:	89 f0                	mov    %esi,%eax
  801cf3:	31 d2                	xor    %edx,%edx
  801cf5:	f7 f5                	div    %ebp
  801cf7:	89 c8                	mov    %ecx,%eax
  801cf9:	f7 f5                	div    %ebp
  801cfb:	89 d0                	mov    %edx,%eax
  801cfd:	eb 99                	jmp    801c98 <__umoddi3+0x38>
  801cff:	90                   	nop
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	83 c4 1c             	add    $0x1c,%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5f                   	pop    %edi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    
  801d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d10:	8b 34 24             	mov    (%esp),%esi
  801d13:	bf 20 00 00 00       	mov    $0x20,%edi
  801d18:	89 e9                	mov    %ebp,%ecx
  801d1a:	29 ef                	sub    %ebp,%edi
  801d1c:	d3 e0                	shl    %cl,%eax
  801d1e:	89 f9                	mov    %edi,%ecx
  801d20:	89 f2                	mov    %esi,%edx
  801d22:	d3 ea                	shr    %cl,%edx
  801d24:	89 e9                	mov    %ebp,%ecx
  801d26:	09 c2                	or     %eax,%edx
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	89 14 24             	mov    %edx,(%esp)
  801d2d:	89 f2                	mov    %esi,%edx
  801d2f:	d3 e2                	shl    %cl,%edx
  801d31:	89 f9                	mov    %edi,%ecx
  801d33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	89 e9                	mov    %ebp,%ecx
  801d3f:	89 c6                	mov    %eax,%esi
  801d41:	d3 e3                	shl    %cl,%ebx
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	89 d0                	mov    %edx,%eax
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	09 d8                	or     %ebx,%eax
  801d4d:	89 d3                	mov    %edx,%ebx
  801d4f:	89 f2                	mov    %esi,%edx
  801d51:	f7 34 24             	divl   (%esp)
  801d54:	89 d6                	mov    %edx,%esi
  801d56:	d3 e3                	shl    %cl,%ebx
  801d58:	f7 64 24 04          	mull   0x4(%esp)
  801d5c:	39 d6                	cmp    %edx,%esi
  801d5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d62:	89 d1                	mov    %edx,%ecx
  801d64:	89 c3                	mov    %eax,%ebx
  801d66:	72 08                	jb     801d70 <__umoddi3+0x110>
  801d68:	75 11                	jne    801d7b <__umoddi3+0x11b>
  801d6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d6e:	73 0b                	jae    801d7b <__umoddi3+0x11b>
  801d70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d74:	1b 14 24             	sbb    (%esp),%edx
  801d77:	89 d1                	mov    %edx,%ecx
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d7f:	29 da                	sub    %ebx,%edx
  801d81:	19 ce                	sbb    %ecx,%esi
  801d83:	89 f9                	mov    %edi,%ecx
  801d85:	89 f0                	mov    %esi,%eax
  801d87:	d3 e0                	shl    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	d3 ea                	shr    %cl,%edx
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	d3 ee                	shr    %cl,%esi
  801d91:	09 d0                	or     %edx,%eax
  801d93:	89 f2                	mov    %esi,%edx
  801d95:	83 c4 1c             	add    $0x1c,%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5e                   	pop    %esi
  801d9a:	5f                   	pop    %edi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    
  801d9d:	8d 76 00             	lea    0x0(%esi),%esi
  801da0:	29 f9                	sub    %edi,%ecx
  801da2:	19 d6                	sbb    %edx,%esi
  801da4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801da8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dac:	e9 18 ff ff ff       	jmp    801cc9 <__umoddi3+0x69>
