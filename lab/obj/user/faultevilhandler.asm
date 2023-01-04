
obj/user/faultevilhandler.debug:     file format elf32-i386


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
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
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
  80012a:	68 aa 1d 80 00       	push   $0x801daa
  80012f:	6a 23                	push   $0x23
  800131:	68 c7 1d 80 00       	push   $0x801dc7
  800136:	e8 f5 0e 00 00       	call   801030 <_panic>

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
  8001ab:	68 aa 1d 80 00       	push   $0x801daa
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 c7 1d 80 00       	push   $0x801dc7
  8001b7:	e8 74 0e 00 00       	call   801030 <_panic>

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
  8001ed:	68 aa 1d 80 00       	push   $0x801daa
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 c7 1d 80 00       	push   $0x801dc7
  8001f9:	e8 32 0e 00 00       	call   801030 <_panic>

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
  80022f:	68 aa 1d 80 00       	push   $0x801daa
  800234:	6a 23                	push   $0x23
  800236:	68 c7 1d 80 00       	push   $0x801dc7
  80023b:	e8 f0 0d 00 00       	call   801030 <_panic>

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
  800271:	68 aa 1d 80 00       	push   $0x801daa
  800276:	6a 23                	push   $0x23
  800278:	68 c7 1d 80 00       	push   $0x801dc7
  80027d:	e8 ae 0d 00 00       	call   801030 <_panic>

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
  8002b3:	68 aa 1d 80 00       	push   $0x801daa
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 c7 1d 80 00       	push   $0x801dc7
  8002bf:	e8 6c 0d 00 00       	call   801030 <_panic>

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
  8002f5:	68 aa 1d 80 00       	push   $0x801daa
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 c7 1d 80 00       	push   $0x801dc7
  800301:	e8 2a 0d 00 00       	call   801030 <_panic>

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
  800359:	68 aa 1d 80 00       	push   $0x801daa
  80035e:	6a 23                	push   $0x23
  800360:	68 c7 1d 80 00       	push   $0x801dc7
  800365:	e8 c6 0c 00 00       	call   801030 <_panic>

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
  800447:	ba 54 1e 80 00       	mov    $0x801e54,%edx
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
  800474:	68 d8 1d 80 00       	push   $0x801dd8
  800479:	e8 8b 0c 00 00       	call   801109 <cprintf>
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
  80069e:	68 19 1e 80 00       	push   $0x801e19
  8006a3:	e8 61 0a 00 00       	call   801109 <cprintf>
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
  800773:	68 35 1e 80 00       	push   $0x801e35
  800778:	e8 8c 09 00 00       	call   801109 <cprintf>
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
  800828:	68 f8 1d 80 00       	push   $0x801df8
  80082d:	e8 d7 08 00 00       	call   801109 <cprintf>
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
  8008f1:	e8 b7 01 00 00       	call   800aad <open>
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
  800938:	e8 53 11 00 00       	call   801a90 <ipc_find_env>
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
  800953:	e8 e4 10 00 00       	call   801a3c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 70 10 00 00       	call   8019d5 <ipc_recv>
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
	panic("devfile_write not implemented");
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
  8009e9:	e8 a0 0c 00 00       	call   80168e <strcpy>
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
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800a17:	68 64 1e 80 00       	push   $0x801e64
  800a1c:	68 90 00 00 00       	push   $0x90
  800a21:	68 82 1e 80 00       	push   $0x801e82
  800a26:	e8 05 06 00 00       	call   801030 <_panic>

00800a2b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 40 0c             	mov    0xc(%eax),%eax
  800a39:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4e:	e8 ce fe ff ff       	call   800921 <fsipc>
  800a53:	89 c3                	mov    %eax,%ebx
  800a55:	85 c0                	test   %eax,%eax
  800a57:	78 4b                	js     800aa4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a59:	39 c6                	cmp    %eax,%esi
  800a5b:	73 16                	jae    800a73 <devfile_read+0x48>
  800a5d:	68 8d 1e 80 00       	push   $0x801e8d
  800a62:	68 94 1e 80 00       	push   $0x801e94
  800a67:	6a 7c                	push   $0x7c
  800a69:	68 82 1e 80 00       	push   $0x801e82
  800a6e:	e8 bd 05 00 00       	call   801030 <_panic>
	assert(r <= PGSIZE);
  800a73:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a78:	7e 16                	jle    800a90 <devfile_read+0x65>
  800a7a:	68 a9 1e 80 00       	push   $0x801ea9
  800a7f:	68 94 1e 80 00       	push   $0x801e94
  800a84:	6a 7d                	push   $0x7d
  800a86:	68 82 1e 80 00       	push   $0x801e82
  800a8b:	e8 a0 05 00 00       	call   801030 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a90:	83 ec 04             	sub    $0x4,%esp
  800a93:	50                   	push   %eax
  800a94:	68 00 50 80 00       	push   $0x805000
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	e8 7f 0d 00 00       	call   801820 <memmove>
	return r;
  800aa1:	83 c4 10             	add    $0x10,%esp
}
  800aa4:	89 d8                	mov    %ebx,%eax
  800aa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 20             	sub    $0x20,%esp
  800ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ab7:	53                   	push   %ebx
  800ab8:	e8 98 0b 00 00       	call   801655 <strlen>
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac5:	7f 67                	jg     800b2e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acd:	50                   	push   %eax
  800ace:	e8 c6 f8 ff ff       	call   800399 <fd_alloc>
  800ad3:	83 c4 10             	add    $0x10,%esp
		return r;
  800ad6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	78 57                	js     800b33 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	53                   	push   %ebx
  800ae0:	68 00 50 80 00       	push   $0x805000
  800ae5:	e8 a4 0b 00 00       	call   80168e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	e8 22 fe ff ff       	call   800921 <fsipc>
  800aff:	89 c3                	mov    %eax,%ebx
  800b01:	83 c4 10             	add    $0x10,%esp
  800b04:	85 c0                	test   %eax,%eax
  800b06:	79 14                	jns    800b1c <open+0x6f>
		fd_close(fd, 0);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	6a 00                	push   $0x0
  800b0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b10:	e8 7c f9 ff ff       	call   800491 <fd_close>
		return r;
  800b15:	83 c4 10             	add    $0x10,%esp
  800b18:	89 da                	mov    %ebx,%edx
  800b1a:	eb 17                	jmp    800b33 <open+0x86>
	}

	return fd2num(fd);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b22:	e8 4b f8 ff ff       	call   800372 <fd2num>
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	83 c4 10             	add    $0x10,%esp
  800b2c:	eb 05                	jmp    800b33 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b2e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b33:	89 d0                	mov    %edx,%eax
  800b35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4a:	e8 d2 fd ff ff       	call   800921 <fsipc>
}
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	ff 75 08             	pushl  0x8(%ebp)
  800b5f:	e8 1e f8 ff ff       	call   800382 <fd2data>
  800b64:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b66:	83 c4 08             	add    $0x8,%esp
  800b69:	68 b5 1e 80 00       	push   $0x801eb5
  800b6e:	53                   	push   %ebx
  800b6f:	e8 1a 0b 00 00       	call   80168e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b74:	8b 46 04             	mov    0x4(%esi),%eax
  800b77:	2b 06                	sub    (%esi),%eax
  800b79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b7f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b86:	00 00 00 
	stat->st_dev = &devpipe;
  800b89:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b90:	30 80 00 
	return 0;
}
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba9:	53                   	push   %ebx
  800baa:	6a 00                	push   $0x0
  800bac:	e8 55 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb1:	89 1c 24             	mov    %ebx,(%esp)
  800bb4:	e8 c9 f7 ff ff       	call   800382 <fd2data>
  800bb9:	83 c4 08             	add    $0x8,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 00                	push   $0x0
  800bbf:	e8 42 f6 ff ff       	call   800206 <sys_page_unmap>
}
  800bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 1c             	sub    $0x1c,%esp
  800bd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bd5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bd7:	a1 04 40 80 00       	mov    0x804004,%eax
  800bdc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	ff 75 e0             	pushl  -0x20(%ebp)
  800be5:	e8 df 0e 00 00       	call   801ac9 <pageref>
  800bea:	89 c3                	mov    %eax,%ebx
  800bec:	89 3c 24             	mov    %edi,(%esp)
  800bef:	e8 d5 0e 00 00       	call   801ac9 <pageref>
  800bf4:	83 c4 10             	add    $0x10,%esp
  800bf7:	39 c3                	cmp    %eax,%ebx
  800bf9:	0f 94 c1             	sete   %cl
  800bfc:	0f b6 c9             	movzbl %cl,%ecx
  800bff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c02:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c08:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0b:	39 ce                	cmp    %ecx,%esi
  800c0d:	74 1b                	je     800c2a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c0f:	39 c3                	cmp    %eax,%ebx
  800c11:	75 c4                	jne    800bd7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c13:	8b 42 58             	mov    0x58(%edx),%eax
  800c16:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c19:	50                   	push   %eax
  800c1a:	56                   	push   %esi
  800c1b:	68 bc 1e 80 00       	push   $0x801ebc
  800c20:	e8 e4 04 00 00       	call   801109 <cprintf>
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	eb ad                	jmp    800bd7 <_pipeisclosed+0xe>
	}
}
  800c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 28             	sub    $0x28,%esp
  800c3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c41:	56                   	push   %esi
  800c42:	e8 3b f7 ff ff       	call   800382 <fd2data>
  800c47:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c51:	eb 4b                	jmp    800c9e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c53:	89 da                	mov    %ebx,%edx
  800c55:	89 f0                	mov    %esi,%eax
  800c57:	e8 6d ff ff ff       	call   800bc9 <_pipeisclosed>
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	75 48                	jne    800ca8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c60:	e8 fd f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c65:	8b 43 04             	mov    0x4(%ebx),%eax
  800c68:	8b 0b                	mov    (%ebx),%ecx
  800c6a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6d:	39 d0                	cmp    %edx,%eax
  800c6f:	73 e2                	jae    800c53 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c78:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	c1 fa 1f             	sar    $0x1f,%edx
  800c80:	89 d1                	mov    %edx,%ecx
  800c82:	c1 e9 1b             	shr    $0x1b,%ecx
  800c85:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c88:	83 e2 1f             	and    $0x1f,%edx
  800c8b:	29 ca                	sub    %ecx,%edx
  800c8d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c95:	83 c0 01             	add    $0x1,%eax
  800c98:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9b:	83 c7 01             	add    $0x1,%edi
  800c9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca1:	75 c2                	jne    800c65 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca6:	eb 05                	jmp    800cad <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 18             	sub    $0x18,%esp
  800cbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc1:	57                   	push   %edi
  800cc2:	e8 bb f6 ff ff       	call   800382 <fd2data>
  800cc7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc9:	83 c4 10             	add    $0x10,%esp
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	eb 3d                	jmp    800d10 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd3:	85 db                	test   %ebx,%ebx
  800cd5:	74 04                	je     800cdb <devpipe_read+0x26>
				return i;
  800cd7:	89 d8                	mov    %ebx,%eax
  800cd9:	eb 44                	jmp    800d1f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	89 f8                	mov    %edi,%eax
  800cdf:	e8 e5 fe ff ff       	call   800bc9 <_pipeisclosed>
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	75 32                	jne    800d1a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ce8:	e8 75 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ced:	8b 06                	mov    (%esi),%eax
  800cef:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf2:	74 df                	je     800cd3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf4:	99                   	cltd   
  800cf5:	c1 ea 1b             	shr    $0x1b,%edx
  800cf8:	01 d0                	add    %edx,%eax
  800cfa:	83 e0 1f             	and    $0x1f,%eax
  800cfd:	29 d0                	sub    %edx,%eax
  800cff:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d0a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0d:	83 c3 01             	add    $0x1,%ebx
  800d10:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d13:	75 d8                	jne    800ced <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d15:	8b 45 10             	mov    0x10(%ebp),%eax
  800d18:	eb 05                	jmp    800d1f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d32:	50                   	push   %eax
  800d33:	e8 61 f6 ff ff       	call   800399 <fd_alloc>
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	0f 88 2c 01 00 00    	js     800e71 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d45:	83 ec 04             	sub    $0x4,%esp
  800d48:	68 07 04 00 00       	push   $0x407
  800d4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d50:	6a 00                	push   $0x0
  800d52:	e8 2a f4 ff ff       	call   800181 <sys_page_alloc>
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	89 c2                	mov    %eax,%edx
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	0f 88 0d 01 00 00    	js     800e71 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6a:	50                   	push   %eax
  800d6b:	e8 29 f6 ff ff       	call   800399 <fd_alloc>
  800d70:	89 c3                	mov    %eax,%ebx
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	85 c0                	test   %eax,%eax
  800d77:	0f 88 e2 00 00 00    	js     800e5f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7d:	83 ec 04             	sub    $0x4,%esp
  800d80:	68 07 04 00 00       	push   $0x407
  800d85:	ff 75 f0             	pushl  -0x10(%ebp)
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 f2 f3 ff ff       	call   800181 <sys_page_alloc>
  800d8f:	89 c3                	mov    %eax,%ebx
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	0f 88 c3 00 00 00    	js     800e5f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800da2:	e8 db f5 ff ff       	call   800382 <fd2data>
  800da7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da9:	83 c4 0c             	add    $0xc,%esp
  800dac:	68 07 04 00 00       	push   $0x407
  800db1:	50                   	push   %eax
  800db2:	6a 00                	push   $0x0
  800db4:	e8 c8 f3 ff ff       	call   800181 <sys_page_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 89 00 00 00    	js     800e4f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcc:	e8 b1 f5 ff ff       	call   800382 <fd2data>
  800dd1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd8:	50                   	push   %eax
  800dd9:	6a 00                	push   $0x0
  800ddb:	56                   	push   %esi
  800ddc:	6a 00                	push   $0x0
  800dde:	e8 e1 f3 ff ff       	call   8001c4 <sys_page_map>
  800de3:	89 c3                	mov    %eax,%ebx
  800de5:	83 c4 20             	add    $0x20,%esp
  800de8:	85 c0                	test   %eax,%eax
  800dea:	78 55                	js     800e41 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e01:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1c:	e8 51 f5 ff ff       	call   800372 <fd2num>
  800e21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e26:	83 c4 04             	add    $0x4,%esp
  800e29:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2c:	e8 41 f5 ff ff       	call   800372 <fd2num>
  800e31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e37:	83 c4 10             	add    $0x10,%esp
  800e3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3f:	eb 30                	jmp    800e71 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	56                   	push   %esi
  800e45:	6a 00                	push   $0x0
  800e47:	e8 ba f3 ff ff       	call   800206 <sys_page_unmap>
  800e4c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	ff 75 f0             	pushl  -0x10(%ebp)
  800e55:	6a 00                	push   $0x0
  800e57:	e8 aa f3 ff ff       	call   800206 <sys_page_unmap>
  800e5c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	ff 75 f4             	pushl  -0xc(%ebp)
  800e65:	6a 00                	push   $0x0
  800e67:	e8 9a f3 ff ff       	call   800206 <sys_page_unmap>
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e71:	89 d0                	mov    %edx,%eax
  800e73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e83:	50                   	push   %eax
  800e84:	ff 75 08             	pushl  0x8(%ebp)
  800e87:	e8 5c f5 ff ff       	call   8003e8 <fd_lookup>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 18                	js     800eab <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	ff 75 f4             	pushl  -0xc(%ebp)
  800e99:	e8 e4 f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800e9e:	89 c2                	mov    %eax,%edx
  800ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea3:	e8 21 fd ff ff       	call   800bc9 <_pipeisclosed>
  800ea8:	83 c4 10             	add    $0x10,%esp
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ebd:	68 d4 1e 80 00       	push   $0x801ed4
  800ec2:	ff 75 0c             	pushl  0xc(%ebp)
  800ec5:	e8 c4 07 00 00       	call   80168e <strcpy>
	return 0;
}
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	57                   	push   %edi
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
  800ed7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800edd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee8:	eb 2d                	jmp    800f17 <devcons_write+0x46>
		m = n - tot;
  800eea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eed:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800eef:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ef7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efa:	83 ec 04             	sub    $0x4,%esp
  800efd:	53                   	push   %ebx
  800efe:	03 45 0c             	add    0xc(%ebp),%eax
  800f01:	50                   	push   %eax
  800f02:	57                   	push   %edi
  800f03:	e8 18 09 00 00       	call   801820 <memmove>
		sys_cputs(buf, m);
  800f08:	83 c4 08             	add    $0x8,%esp
  800f0b:	53                   	push   %ebx
  800f0c:	57                   	push   %edi
  800f0d:	e8 b3 f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f12:	01 de                	add    %ebx,%esi
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	89 f0                	mov    %esi,%eax
  800f19:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1c:	72 cc                	jb     800eea <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 08             	sub    $0x8,%esp
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f35:	74 2a                	je     800f61 <devcons_read+0x3b>
  800f37:	eb 05                	jmp    800f3e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f39:	e8 24 f2 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f3e:	e8 a0 f1 ff ff       	call   8000e3 <sys_cgetc>
  800f43:	85 c0                	test   %eax,%eax
  800f45:	74 f2                	je     800f39 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 16                	js     800f61 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f4b:	83 f8 04             	cmp    $0x4,%eax
  800f4e:	74 0c                	je     800f5c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f53:	88 02                	mov    %al,(%edx)
	return 1;
  800f55:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5a:	eb 05                	jmp    800f61 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f6f:	6a 01                	push   $0x1
  800f71:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	e8 4b f1 ff ff       	call   8000c5 <sys_cputs>
}
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <getchar>:

int
getchar(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f85:	6a 01                	push   $0x1
  800f87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8a:	50                   	push   %eax
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 bc f6 ff ff       	call   80064e <read>
	if (r < 0)
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 0f                	js     800fa8 <getchar+0x29>
		return r;
	if (r < 1)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	7e 06                	jle    800fa3 <getchar+0x24>
		return -E_EOF;
	return c;
  800f9d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa1:	eb 05                	jmp    800fa8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	ff 75 08             	pushl  0x8(%ebp)
  800fb7:	e8 2c f4 ff ff       	call   8003e8 <fd_lookup>
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 11                	js     800fd4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcc:	39 10                	cmp    %edx,(%eax)
  800fce:	0f 94 c0             	sete   %al
  800fd1:	0f b6 c0             	movzbl %al,%eax
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <opencons>:

int
opencons(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	e8 b4 f3 ff ff       	call   800399 <fd_alloc>
  800fe5:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 3e                	js     80102c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 07 04 00 00       	push   $0x407
  800ff6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 81 f1 ff ff       	call   800181 <sys_page_alloc>
  801000:	83 c4 10             	add    $0x10,%esp
		return r;
  801003:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	78 23                	js     80102c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801009:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801012:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801017:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	50                   	push   %eax
  801022:	e8 4b f3 ff ff       	call   800372 <fd2num>
  801027:	89 c2                	mov    %eax,%edx
  801029:	83 c4 10             	add    $0x10,%esp
}
  80102c:	89 d0                	mov    %edx,%eax
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801035:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801038:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103e:	e8 00 f1 ff ff       	call   800143 <sys_getenvid>
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	ff 75 0c             	pushl  0xc(%ebp)
  801049:	ff 75 08             	pushl  0x8(%ebp)
  80104c:	56                   	push   %esi
  80104d:	50                   	push   %eax
  80104e:	68 e0 1e 80 00       	push   $0x801ee0
  801053:	e8 b1 00 00 00       	call   801109 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801058:	83 c4 18             	add    $0x18,%esp
  80105b:	53                   	push   %ebx
  80105c:	ff 75 10             	pushl  0x10(%ebp)
  80105f:	e8 54 00 00 00       	call   8010b8 <vcprintf>
	cprintf("\n");
  801064:	c7 04 24 cd 1e 80 00 	movl   $0x801ecd,(%esp)
  80106b:	e8 99 00 00 00       	call   801109 <cprintf>
  801070:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801073:	cc                   	int3   
  801074:	eb fd                	jmp    801073 <_panic+0x43>

00801076 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	53                   	push   %ebx
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801080:	8b 13                	mov    (%ebx),%edx
  801082:	8d 42 01             	lea    0x1(%edx),%eax
  801085:	89 03                	mov    %eax,(%ebx)
  801087:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801093:	75 1a                	jne    8010af <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	68 ff 00 00 00       	push   $0xff
  80109d:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a0:	50                   	push   %eax
  8010a1:	e8 1f f0 ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ac:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c8:	00 00 00 
	b.cnt = 0;
  8010cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d5:	ff 75 0c             	pushl  0xc(%ebp)
  8010d8:	ff 75 08             	pushl  0x8(%ebp)
  8010db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e1:	50                   	push   %eax
  8010e2:	68 76 10 80 00       	push   $0x801076
  8010e7:	e8 54 01 00 00       	call   801240 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ec:	83 c4 08             	add    $0x8,%esp
  8010ef:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fb:	50                   	push   %eax
  8010fc:	e8 c4 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801101:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80110f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801112:	50                   	push   %eax
  801113:	ff 75 08             	pushl  0x8(%ebp)
  801116:	e8 9d ff ff ff       	call   8010b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    

0080111d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	57                   	push   %edi
  801121:	56                   	push   %esi
  801122:	53                   	push   %ebx
  801123:	83 ec 1c             	sub    $0x1c,%esp
  801126:	89 c7                	mov    %eax,%edi
  801128:	89 d6                	mov    %edx,%esi
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801130:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801133:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801136:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801139:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801141:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801144:	39 d3                	cmp    %edx,%ebx
  801146:	72 05                	jb     80114d <printnum+0x30>
  801148:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114b:	77 45                	ja     801192 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114d:	83 ec 0c             	sub    $0xc,%esp
  801150:	ff 75 18             	pushl  0x18(%ebp)
  801153:	8b 45 14             	mov    0x14(%ebp),%eax
  801156:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801159:	53                   	push   %ebx
  80115a:	ff 75 10             	pushl  0x10(%ebp)
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	ff 75 e4             	pushl  -0x1c(%ebp)
  801163:	ff 75 e0             	pushl  -0x20(%ebp)
  801166:	ff 75 dc             	pushl  -0x24(%ebp)
  801169:	ff 75 d8             	pushl  -0x28(%ebp)
  80116c:	e8 9f 09 00 00       	call   801b10 <__udivdi3>
  801171:	83 c4 18             	add    $0x18,%esp
  801174:	52                   	push   %edx
  801175:	50                   	push   %eax
  801176:	89 f2                	mov    %esi,%edx
  801178:	89 f8                	mov    %edi,%eax
  80117a:	e8 9e ff ff ff       	call   80111d <printnum>
  80117f:	83 c4 20             	add    $0x20,%esp
  801182:	eb 18                	jmp    80119c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	56                   	push   %esi
  801188:	ff 75 18             	pushl  0x18(%ebp)
  80118b:	ff d7                	call   *%edi
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	eb 03                	jmp    801195 <printnum+0x78>
  801192:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801195:	83 eb 01             	sub    $0x1,%ebx
  801198:	85 db                	test   %ebx,%ebx
  80119a:	7f e8                	jg     801184 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	56                   	push   %esi
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8011af:	e8 8c 0a 00 00       	call   801c40 <__umoddi3>
  8011b4:	83 c4 14             	add    $0x14,%esp
  8011b7:	0f be 80 03 1f 80 00 	movsbl 0x801f03(%eax),%eax
  8011be:	50                   	push   %eax
  8011bf:	ff d7                	call   *%edi
}
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5f                   	pop    %edi
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011cf:	83 fa 01             	cmp    $0x1,%edx
  8011d2:	7e 0e                	jle    8011e2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011d4:	8b 10                	mov    (%eax),%edx
  8011d6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011d9:	89 08                	mov    %ecx,(%eax)
  8011db:	8b 02                	mov    (%edx),%eax
  8011dd:	8b 52 04             	mov    0x4(%edx),%edx
  8011e0:	eb 22                	jmp    801204 <getuint+0x38>
	else if (lflag)
  8011e2:	85 d2                	test   %edx,%edx
  8011e4:	74 10                	je     8011f6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011e6:	8b 10                	mov    (%eax),%edx
  8011e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011eb:	89 08                	mov    %ecx,(%eax)
  8011ed:	8b 02                	mov    (%edx),%eax
  8011ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f4:	eb 0e                	jmp    801204 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011f6:	8b 10                	mov    (%eax),%edx
  8011f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011fb:	89 08                	mov    %ecx,(%eax)
  8011fd:	8b 02                	mov    (%edx),%eax
  8011ff:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80120c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801210:	8b 10                	mov    (%eax),%edx
  801212:	3b 50 04             	cmp    0x4(%eax),%edx
  801215:	73 0a                	jae    801221 <sprintputch+0x1b>
		*b->buf++ = ch;
  801217:	8d 4a 01             	lea    0x1(%edx),%ecx
  80121a:	89 08                	mov    %ecx,(%eax)
  80121c:	8b 45 08             	mov    0x8(%ebp),%eax
  80121f:	88 02                	mov    %al,(%edx)
}
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801229:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80122c:	50                   	push   %eax
  80122d:	ff 75 10             	pushl  0x10(%ebp)
  801230:	ff 75 0c             	pushl  0xc(%ebp)
  801233:	ff 75 08             	pushl  0x8(%ebp)
  801236:	e8 05 00 00 00       	call   801240 <vprintfmt>
	va_end(ap);
}
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	c9                   	leave  
  80123f:	c3                   	ret    

00801240 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	53                   	push   %ebx
  801246:	83 ec 2c             	sub    $0x2c,%esp
  801249:	8b 75 08             	mov    0x8(%ebp),%esi
  80124c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80124f:	8b 7d 10             	mov    0x10(%ebp),%edi
  801252:	eb 12                	jmp    801266 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801254:	85 c0                	test   %eax,%eax
  801256:	0f 84 89 03 00 00    	je     8015e5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	53                   	push   %ebx
  801260:	50                   	push   %eax
  801261:	ff d6                	call   *%esi
  801263:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801266:	83 c7 01             	add    $0x1,%edi
  801269:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80126d:	83 f8 25             	cmp    $0x25,%eax
  801270:	75 e2                	jne    801254 <vprintfmt+0x14>
  801272:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801276:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80127d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801284:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80128b:	ba 00 00 00 00       	mov    $0x0,%edx
  801290:	eb 07                	jmp    801299 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801292:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801295:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801299:	8d 47 01             	lea    0x1(%edi),%eax
  80129c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80129f:	0f b6 07             	movzbl (%edi),%eax
  8012a2:	0f b6 c8             	movzbl %al,%ecx
  8012a5:	83 e8 23             	sub    $0x23,%eax
  8012a8:	3c 55                	cmp    $0x55,%al
  8012aa:	0f 87 1a 03 00 00    	ja     8015ca <vprintfmt+0x38a>
  8012b0:	0f b6 c0             	movzbl %al,%eax
  8012b3:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8012ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012bd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012c1:	eb d6                	jmp    801299 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012ce:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012d1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012d5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012d8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012db:	83 fa 09             	cmp    $0x9,%edx
  8012de:	77 39                	ja     801319 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012e0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012e3:	eb e9                	jmp    8012ce <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e8:	8d 48 04             	lea    0x4(%eax),%ecx
  8012eb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012ee:	8b 00                	mov    (%eax),%eax
  8012f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012f6:	eb 27                	jmp    80131f <vprintfmt+0xdf>
  8012f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801302:	0f 49 c8             	cmovns %eax,%ecx
  801305:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80130b:	eb 8c                	jmp    801299 <vprintfmt+0x59>
  80130d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801310:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801317:	eb 80                	jmp    801299 <vprintfmt+0x59>
  801319:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80131c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80131f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801323:	0f 89 70 ff ff ff    	jns    801299 <vprintfmt+0x59>
				width = precision, precision = -1;
  801329:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80132c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80132f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801336:	e9 5e ff ff ff       	jmp    801299 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80133b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801341:	e9 53 ff ff ff       	jmp    801299 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801346:	8b 45 14             	mov    0x14(%ebp),%eax
  801349:	8d 50 04             	lea    0x4(%eax),%edx
  80134c:	89 55 14             	mov    %edx,0x14(%ebp)
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	53                   	push   %ebx
  801353:	ff 30                	pushl  (%eax)
  801355:	ff d6                	call   *%esi
			break;
  801357:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80135d:	e9 04 ff ff ff       	jmp    801266 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801362:	8b 45 14             	mov    0x14(%ebp),%eax
  801365:	8d 50 04             	lea    0x4(%eax),%edx
  801368:	89 55 14             	mov    %edx,0x14(%ebp)
  80136b:	8b 00                	mov    (%eax),%eax
  80136d:	99                   	cltd   
  80136e:	31 d0                	xor    %edx,%eax
  801370:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801372:	83 f8 0f             	cmp    $0xf,%eax
  801375:	7f 0b                	jg     801382 <vprintfmt+0x142>
  801377:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  80137e:	85 d2                	test   %edx,%edx
  801380:	75 18                	jne    80139a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801382:	50                   	push   %eax
  801383:	68 1b 1f 80 00       	push   $0x801f1b
  801388:	53                   	push   %ebx
  801389:	56                   	push   %esi
  80138a:	e8 94 fe ff ff       	call   801223 <printfmt>
  80138f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801395:	e9 cc fe ff ff       	jmp    801266 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80139a:	52                   	push   %edx
  80139b:	68 a6 1e 80 00       	push   $0x801ea6
  8013a0:	53                   	push   %ebx
  8013a1:	56                   	push   %esi
  8013a2:	e8 7c fe ff ff       	call   801223 <printfmt>
  8013a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013ad:	e9 b4 fe ff ff       	jmp    801266 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b5:	8d 50 04             	lea    0x4(%eax),%edx
  8013b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013bb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013bd:	85 ff                	test   %edi,%edi
  8013bf:	b8 14 1f 80 00       	mov    $0x801f14,%eax
  8013c4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013cb:	0f 8e 94 00 00 00    	jle    801465 <vprintfmt+0x225>
  8013d1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013d5:	0f 84 98 00 00 00    	je     801473 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	ff 75 d0             	pushl  -0x30(%ebp)
  8013e1:	57                   	push   %edi
  8013e2:	e8 86 02 00 00       	call   80166d <strnlen>
  8013e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013ea:	29 c1                	sub    %eax,%ecx
  8013ec:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013ef:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013f2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013f9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013fc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013fe:	eb 0f                	jmp    80140f <vprintfmt+0x1cf>
					putch(padc, putdat);
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	53                   	push   %ebx
  801404:	ff 75 e0             	pushl  -0x20(%ebp)
  801407:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801409:	83 ef 01             	sub    $0x1,%edi
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	85 ff                	test   %edi,%edi
  801411:	7f ed                	jg     801400 <vprintfmt+0x1c0>
  801413:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801416:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801419:	85 c9                	test   %ecx,%ecx
  80141b:	b8 00 00 00 00       	mov    $0x0,%eax
  801420:	0f 49 c1             	cmovns %ecx,%eax
  801423:	29 c1                	sub    %eax,%ecx
  801425:	89 75 08             	mov    %esi,0x8(%ebp)
  801428:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80142b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80142e:	89 cb                	mov    %ecx,%ebx
  801430:	eb 4d                	jmp    80147f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801432:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801436:	74 1b                	je     801453 <vprintfmt+0x213>
  801438:	0f be c0             	movsbl %al,%eax
  80143b:	83 e8 20             	sub    $0x20,%eax
  80143e:	83 f8 5e             	cmp    $0x5e,%eax
  801441:	76 10                	jbe    801453 <vprintfmt+0x213>
					putch('?', putdat);
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	ff 75 0c             	pushl  0xc(%ebp)
  801449:	6a 3f                	push   $0x3f
  80144b:	ff 55 08             	call   *0x8(%ebp)
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	eb 0d                	jmp    801460 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	ff 75 0c             	pushl  0xc(%ebp)
  801459:	52                   	push   %edx
  80145a:	ff 55 08             	call   *0x8(%ebp)
  80145d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801460:	83 eb 01             	sub    $0x1,%ebx
  801463:	eb 1a                	jmp    80147f <vprintfmt+0x23f>
  801465:	89 75 08             	mov    %esi,0x8(%ebp)
  801468:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80146b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80146e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801471:	eb 0c                	jmp    80147f <vprintfmt+0x23f>
  801473:	89 75 08             	mov    %esi,0x8(%ebp)
  801476:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801479:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80147f:	83 c7 01             	add    $0x1,%edi
  801482:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801486:	0f be d0             	movsbl %al,%edx
  801489:	85 d2                	test   %edx,%edx
  80148b:	74 23                	je     8014b0 <vprintfmt+0x270>
  80148d:	85 f6                	test   %esi,%esi
  80148f:	78 a1                	js     801432 <vprintfmt+0x1f2>
  801491:	83 ee 01             	sub    $0x1,%esi
  801494:	79 9c                	jns    801432 <vprintfmt+0x1f2>
  801496:	89 df                	mov    %ebx,%edi
  801498:	8b 75 08             	mov    0x8(%ebp),%esi
  80149b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149e:	eb 18                	jmp    8014b8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	53                   	push   %ebx
  8014a4:	6a 20                	push   $0x20
  8014a6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014a8:	83 ef 01             	sub    $0x1,%edi
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb 08                	jmp    8014b8 <vprintfmt+0x278>
  8014b0:	89 df                	mov    %ebx,%edi
  8014b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b8:	85 ff                	test   %edi,%edi
  8014ba:	7f e4                	jg     8014a0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014bf:	e9 a2 fd ff ff       	jmp    801266 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014c4:	83 fa 01             	cmp    $0x1,%edx
  8014c7:	7e 16                	jle    8014df <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cc:	8d 50 08             	lea    0x8(%eax),%edx
  8014cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d2:	8b 50 04             	mov    0x4(%eax),%edx
  8014d5:	8b 00                	mov    (%eax),%eax
  8014d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014da:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014dd:	eb 32                	jmp    801511 <vprintfmt+0x2d1>
	else if (lflag)
  8014df:	85 d2                	test   %edx,%edx
  8014e1:	74 18                	je     8014fb <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e6:	8d 50 04             	lea    0x4(%eax),%edx
  8014e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ec:	8b 00                	mov    (%eax),%eax
  8014ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f1:	89 c1                	mov    %eax,%ecx
  8014f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f9:	eb 16                	jmp    801511 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fe:	8d 50 04             	lea    0x4(%eax),%edx
  801501:	89 55 14             	mov    %edx,0x14(%ebp)
  801504:	8b 00                	mov    (%eax),%eax
  801506:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801509:	89 c1                	mov    %eax,%ecx
  80150b:	c1 f9 1f             	sar    $0x1f,%ecx
  80150e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801511:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801514:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801517:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80151c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801520:	79 74                	jns    801596 <vprintfmt+0x356>
				putch('-', putdat);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	53                   	push   %ebx
  801526:	6a 2d                	push   $0x2d
  801528:	ff d6                	call   *%esi
				num = -(long long) num;
  80152a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80152d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801530:	f7 d8                	neg    %eax
  801532:	83 d2 00             	adc    $0x0,%edx
  801535:	f7 da                	neg    %edx
  801537:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80153a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80153f:	eb 55                	jmp    801596 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801541:	8d 45 14             	lea    0x14(%ebp),%eax
  801544:	e8 83 fc ff ff       	call   8011cc <getuint>
			base = 10;
  801549:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80154e:	eb 46                	jmp    801596 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801550:	8d 45 14             	lea    0x14(%ebp),%eax
  801553:	e8 74 fc ff ff       	call   8011cc <getuint>
			base = 8;
  801558:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80155d:	eb 37                	jmp    801596 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	53                   	push   %ebx
  801563:	6a 30                	push   $0x30
  801565:	ff d6                	call   *%esi
			putch('x', putdat);
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	53                   	push   %ebx
  80156b:	6a 78                	push   $0x78
  80156d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80156f:	8b 45 14             	mov    0x14(%ebp),%eax
  801572:	8d 50 04             	lea    0x4(%eax),%edx
  801575:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801578:	8b 00                	mov    (%eax),%eax
  80157a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80157f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801582:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801587:	eb 0d                	jmp    801596 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801589:	8d 45 14             	lea    0x14(%ebp),%eax
  80158c:	e8 3b fc ff ff       	call   8011cc <getuint>
			base = 16;
  801591:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801596:	83 ec 0c             	sub    $0xc,%esp
  801599:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80159d:	57                   	push   %edi
  80159e:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a1:	51                   	push   %ecx
  8015a2:	52                   	push   %edx
  8015a3:	50                   	push   %eax
  8015a4:	89 da                	mov    %ebx,%edx
  8015a6:	89 f0                	mov    %esi,%eax
  8015a8:	e8 70 fb ff ff       	call   80111d <printnum>
			break;
  8015ad:	83 c4 20             	add    $0x20,%esp
  8015b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015b3:	e9 ae fc ff ff       	jmp    801266 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	51                   	push   %ecx
  8015bd:	ff d6                	call   *%esi
			break;
  8015bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015c5:	e9 9c fc ff ff       	jmp    801266 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	53                   	push   %ebx
  8015ce:	6a 25                	push   $0x25
  8015d0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	eb 03                	jmp    8015da <vprintfmt+0x39a>
  8015d7:	83 ef 01             	sub    $0x1,%edi
  8015da:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015de:	75 f7                	jne    8015d7 <vprintfmt+0x397>
  8015e0:	e9 81 fc ff ff       	jmp    801266 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e8:	5b                   	pop    %ebx
  8015e9:	5e                   	pop    %esi
  8015ea:	5f                   	pop    %edi
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    

008015ed <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 18             	sub    $0x18,%esp
  8015f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801600:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801603:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80160a:	85 c0                	test   %eax,%eax
  80160c:	74 26                	je     801634 <vsnprintf+0x47>
  80160e:	85 d2                	test   %edx,%edx
  801610:	7e 22                	jle    801634 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801612:	ff 75 14             	pushl  0x14(%ebp)
  801615:	ff 75 10             	pushl  0x10(%ebp)
  801618:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	68 06 12 80 00       	push   $0x801206
  801621:	e8 1a fc ff ff       	call   801240 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801626:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801629:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80162c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 05                	jmp    801639 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801634:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801641:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801644:	50                   	push   %eax
  801645:	ff 75 10             	pushl  0x10(%ebp)
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	ff 75 08             	pushl  0x8(%ebp)
  80164e:	e8 9a ff ff ff       	call   8015ed <vsnprintf>
	va_end(ap);

	return rc;
}
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80165b:	b8 00 00 00 00       	mov    $0x0,%eax
  801660:	eb 03                	jmp    801665 <strlen+0x10>
		n++;
  801662:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801665:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801669:	75 f7                	jne    801662 <strlen+0xd>
		n++;
	return n;
}
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801673:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801676:	ba 00 00 00 00       	mov    $0x0,%edx
  80167b:	eb 03                	jmp    801680 <strnlen+0x13>
		n++;
  80167d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801680:	39 c2                	cmp    %eax,%edx
  801682:	74 08                	je     80168c <strnlen+0x1f>
  801684:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801688:	75 f3                	jne    80167d <strnlen+0x10>
  80168a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	8b 45 08             	mov    0x8(%ebp),%eax
  801695:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801698:	89 c2                	mov    %eax,%edx
  80169a:	83 c2 01             	add    $0x1,%edx
  80169d:	83 c1 01             	add    $0x1,%ecx
  8016a0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016a4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016a7:	84 db                	test   %bl,%bl
  8016a9:	75 ef                	jne    80169a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016ab:	5b                   	pop    %ebx
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	53                   	push   %ebx
  8016b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016b5:	53                   	push   %ebx
  8016b6:	e8 9a ff ff ff       	call   801655 <strlen>
  8016bb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016be:	ff 75 0c             	pushl  0xc(%ebp)
  8016c1:	01 d8                	add    %ebx,%eax
  8016c3:	50                   	push   %eax
  8016c4:	e8 c5 ff ff ff       	call   80168e <strcpy>
	return dst;
}
  8016c9:	89 d8                	mov    %ebx,%eax
  8016cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	56                   	push   %esi
  8016d4:	53                   	push   %ebx
  8016d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8016d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016db:	89 f3                	mov    %esi,%ebx
  8016dd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016e0:	89 f2                	mov    %esi,%edx
  8016e2:	eb 0f                	jmp    8016f3 <strncpy+0x23>
		*dst++ = *src;
  8016e4:	83 c2 01             	add    $0x1,%edx
  8016e7:	0f b6 01             	movzbl (%ecx),%eax
  8016ea:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016ed:	80 39 01             	cmpb   $0x1,(%ecx)
  8016f0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f3:	39 da                	cmp    %ebx,%edx
  8016f5:	75 ed                	jne    8016e4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016f7:	89 f0                	mov    %esi,%eax
  8016f9:	5b                   	pop    %ebx
  8016fa:	5e                   	pop    %esi
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	56                   	push   %esi
  801701:	53                   	push   %ebx
  801702:	8b 75 08             	mov    0x8(%ebp),%esi
  801705:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801708:	8b 55 10             	mov    0x10(%ebp),%edx
  80170b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80170d:	85 d2                	test   %edx,%edx
  80170f:	74 21                	je     801732 <strlcpy+0x35>
  801711:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801715:	89 f2                	mov    %esi,%edx
  801717:	eb 09                	jmp    801722 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801719:	83 c2 01             	add    $0x1,%edx
  80171c:	83 c1 01             	add    $0x1,%ecx
  80171f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801722:	39 c2                	cmp    %eax,%edx
  801724:	74 09                	je     80172f <strlcpy+0x32>
  801726:	0f b6 19             	movzbl (%ecx),%ebx
  801729:	84 db                	test   %bl,%bl
  80172b:	75 ec                	jne    801719 <strlcpy+0x1c>
  80172d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80172f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801732:	29 f0                	sub    %esi,%eax
}
  801734:	5b                   	pop    %ebx
  801735:	5e                   	pop    %esi
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80173e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801741:	eb 06                	jmp    801749 <strcmp+0x11>
		p++, q++;
  801743:	83 c1 01             	add    $0x1,%ecx
  801746:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801749:	0f b6 01             	movzbl (%ecx),%eax
  80174c:	84 c0                	test   %al,%al
  80174e:	74 04                	je     801754 <strcmp+0x1c>
  801750:	3a 02                	cmp    (%edx),%al
  801752:	74 ef                	je     801743 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801754:	0f b6 c0             	movzbl %al,%eax
  801757:	0f b6 12             	movzbl (%edx),%edx
  80175a:	29 d0                	sub    %edx,%eax
}
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	8b 55 0c             	mov    0xc(%ebp),%edx
  801768:	89 c3                	mov    %eax,%ebx
  80176a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80176d:	eb 06                	jmp    801775 <strncmp+0x17>
		n--, p++, q++;
  80176f:	83 c0 01             	add    $0x1,%eax
  801772:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801775:	39 d8                	cmp    %ebx,%eax
  801777:	74 15                	je     80178e <strncmp+0x30>
  801779:	0f b6 08             	movzbl (%eax),%ecx
  80177c:	84 c9                	test   %cl,%cl
  80177e:	74 04                	je     801784 <strncmp+0x26>
  801780:	3a 0a                	cmp    (%edx),%cl
  801782:	74 eb                	je     80176f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801784:	0f b6 00             	movzbl (%eax),%eax
  801787:	0f b6 12             	movzbl (%edx),%edx
  80178a:	29 d0                	sub    %edx,%eax
  80178c:	eb 05                	jmp    801793 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80178e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801793:	5b                   	pop    %ebx
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017a0:	eb 07                	jmp    8017a9 <strchr+0x13>
		if (*s == c)
  8017a2:	38 ca                	cmp    %cl,%dl
  8017a4:	74 0f                	je     8017b5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017a6:	83 c0 01             	add    $0x1,%eax
  8017a9:	0f b6 10             	movzbl (%eax),%edx
  8017ac:	84 d2                	test   %dl,%dl
  8017ae:	75 f2                	jne    8017a2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c1:	eb 03                	jmp    8017c6 <strfind+0xf>
  8017c3:	83 c0 01             	add    $0x1,%eax
  8017c6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017c9:	38 ca                	cmp    %cl,%dl
  8017cb:	74 04                	je     8017d1 <strfind+0x1a>
  8017cd:	84 d2                	test   %dl,%dl
  8017cf:	75 f2                	jne    8017c3 <strfind+0xc>
			break;
	return (char *) s;
}
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	57                   	push   %edi
  8017d7:	56                   	push   %esi
  8017d8:	53                   	push   %ebx
  8017d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017df:	85 c9                	test   %ecx,%ecx
  8017e1:	74 36                	je     801819 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017e3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017e9:	75 28                	jne    801813 <memset+0x40>
  8017eb:	f6 c1 03             	test   $0x3,%cl
  8017ee:	75 23                	jne    801813 <memset+0x40>
		c &= 0xFF;
  8017f0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017f4:	89 d3                	mov    %edx,%ebx
  8017f6:	c1 e3 08             	shl    $0x8,%ebx
  8017f9:	89 d6                	mov    %edx,%esi
  8017fb:	c1 e6 18             	shl    $0x18,%esi
  8017fe:	89 d0                	mov    %edx,%eax
  801800:	c1 e0 10             	shl    $0x10,%eax
  801803:	09 f0                	or     %esi,%eax
  801805:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801807:	89 d8                	mov    %ebx,%eax
  801809:	09 d0                	or     %edx,%eax
  80180b:	c1 e9 02             	shr    $0x2,%ecx
  80180e:	fc                   	cld    
  80180f:	f3 ab                	rep stos %eax,%es:(%edi)
  801811:	eb 06                	jmp    801819 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801813:	8b 45 0c             	mov    0xc(%ebp),%eax
  801816:	fc                   	cld    
  801817:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801819:	89 f8                	mov    %edi,%eax
  80181b:	5b                   	pop    %ebx
  80181c:	5e                   	pop    %esi
  80181d:	5f                   	pop    %edi
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	57                   	push   %edi
  801824:	56                   	push   %esi
  801825:	8b 45 08             	mov    0x8(%ebp),%eax
  801828:	8b 75 0c             	mov    0xc(%ebp),%esi
  80182b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80182e:	39 c6                	cmp    %eax,%esi
  801830:	73 35                	jae    801867 <memmove+0x47>
  801832:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801835:	39 d0                	cmp    %edx,%eax
  801837:	73 2e                	jae    801867 <memmove+0x47>
		s += n;
		d += n;
  801839:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80183c:	89 d6                	mov    %edx,%esi
  80183e:	09 fe                	or     %edi,%esi
  801840:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801846:	75 13                	jne    80185b <memmove+0x3b>
  801848:	f6 c1 03             	test   $0x3,%cl
  80184b:	75 0e                	jne    80185b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80184d:	83 ef 04             	sub    $0x4,%edi
  801850:	8d 72 fc             	lea    -0x4(%edx),%esi
  801853:	c1 e9 02             	shr    $0x2,%ecx
  801856:	fd                   	std    
  801857:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801859:	eb 09                	jmp    801864 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80185b:	83 ef 01             	sub    $0x1,%edi
  80185e:	8d 72 ff             	lea    -0x1(%edx),%esi
  801861:	fd                   	std    
  801862:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801864:	fc                   	cld    
  801865:	eb 1d                	jmp    801884 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801867:	89 f2                	mov    %esi,%edx
  801869:	09 c2                	or     %eax,%edx
  80186b:	f6 c2 03             	test   $0x3,%dl
  80186e:	75 0f                	jne    80187f <memmove+0x5f>
  801870:	f6 c1 03             	test   $0x3,%cl
  801873:	75 0a                	jne    80187f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801875:	c1 e9 02             	shr    $0x2,%ecx
  801878:	89 c7                	mov    %eax,%edi
  80187a:	fc                   	cld    
  80187b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187d:	eb 05                	jmp    801884 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80187f:	89 c7                	mov    %eax,%edi
  801881:	fc                   	cld    
  801882:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801884:	5e                   	pop    %esi
  801885:	5f                   	pop    %edi
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    

00801888 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80188b:	ff 75 10             	pushl  0x10(%ebp)
  80188e:	ff 75 0c             	pushl  0xc(%ebp)
  801891:	ff 75 08             	pushl  0x8(%ebp)
  801894:	e8 87 ff ff ff       	call   801820 <memmove>
}
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	56                   	push   %esi
  80189f:	53                   	push   %ebx
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a6:	89 c6                	mov    %eax,%esi
  8018a8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ab:	eb 1a                	jmp    8018c7 <memcmp+0x2c>
		if (*s1 != *s2)
  8018ad:	0f b6 08             	movzbl (%eax),%ecx
  8018b0:	0f b6 1a             	movzbl (%edx),%ebx
  8018b3:	38 d9                	cmp    %bl,%cl
  8018b5:	74 0a                	je     8018c1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018b7:	0f b6 c1             	movzbl %cl,%eax
  8018ba:	0f b6 db             	movzbl %bl,%ebx
  8018bd:	29 d8                	sub    %ebx,%eax
  8018bf:	eb 0f                	jmp    8018d0 <memcmp+0x35>
		s1++, s2++;
  8018c1:	83 c0 01             	add    $0x1,%eax
  8018c4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c7:	39 f0                	cmp    %esi,%eax
  8018c9:	75 e2                	jne    8018ad <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d0:	5b                   	pop    %ebx
  8018d1:	5e                   	pop    %esi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	53                   	push   %ebx
  8018d8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018db:	89 c1                	mov    %eax,%ecx
  8018dd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018e0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018e4:	eb 0a                	jmp    8018f0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018e6:	0f b6 10             	movzbl (%eax),%edx
  8018e9:	39 da                	cmp    %ebx,%edx
  8018eb:	74 07                	je     8018f4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018ed:	83 c0 01             	add    $0x1,%eax
  8018f0:	39 c8                	cmp    %ecx,%eax
  8018f2:	72 f2                	jb     8018e6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018f4:	5b                   	pop    %ebx
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	57                   	push   %edi
  8018fb:	56                   	push   %esi
  8018fc:	53                   	push   %ebx
  8018fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801900:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801903:	eb 03                	jmp    801908 <strtol+0x11>
		s++;
  801905:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801908:	0f b6 01             	movzbl (%ecx),%eax
  80190b:	3c 20                	cmp    $0x20,%al
  80190d:	74 f6                	je     801905 <strtol+0xe>
  80190f:	3c 09                	cmp    $0x9,%al
  801911:	74 f2                	je     801905 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801913:	3c 2b                	cmp    $0x2b,%al
  801915:	75 0a                	jne    801921 <strtol+0x2a>
		s++;
  801917:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80191a:	bf 00 00 00 00       	mov    $0x0,%edi
  80191f:	eb 11                	jmp    801932 <strtol+0x3b>
  801921:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801926:	3c 2d                	cmp    $0x2d,%al
  801928:	75 08                	jne    801932 <strtol+0x3b>
		s++, neg = 1;
  80192a:	83 c1 01             	add    $0x1,%ecx
  80192d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801932:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801938:	75 15                	jne    80194f <strtol+0x58>
  80193a:	80 39 30             	cmpb   $0x30,(%ecx)
  80193d:	75 10                	jne    80194f <strtol+0x58>
  80193f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801943:	75 7c                	jne    8019c1 <strtol+0xca>
		s += 2, base = 16;
  801945:	83 c1 02             	add    $0x2,%ecx
  801948:	bb 10 00 00 00       	mov    $0x10,%ebx
  80194d:	eb 16                	jmp    801965 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80194f:	85 db                	test   %ebx,%ebx
  801951:	75 12                	jne    801965 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801953:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801958:	80 39 30             	cmpb   $0x30,(%ecx)
  80195b:	75 08                	jne    801965 <strtol+0x6e>
		s++, base = 8;
  80195d:	83 c1 01             	add    $0x1,%ecx
  801960:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801965:	b8 00 00 00 00       	mov    $0x0,%eax
  80196a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80196d:	0f b6 11             	movzbl (%ecx),%edx
  801970:	8d 72 d0             	lea    -0x30(%edx),%esi
  801973:	89 f3                	mov    %esi,%ebx
  801975:	80 fb 09             	cmp    $0x9,%bl
  801978:	77 08                	ja     801982 <strtol+0x8b>
			dig = *s - '0';
  80197a:	0f be d2             	movsbl %dl,%edx
  80197d:	83 ea 30             	sub    $0x30,%edx
  801980:	eb 22                	jmp    8019a4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801982:	8d 72 9f             	lea    -0x61(%edx),%esi
  801985:	89 f3                	mov    %esi,%ebx
  801987:	80 fb 19             	cmp    $0x19,%bl
  80198a:	77 08                	ja     801994 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80198c:	0f be d2             	movsbl %dl,%edx
  80198f:	83 ea 57             	sub    $0x57,%edx
  801992:	eb 10                	jmp    8019a4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801994:	8d 72 bf             	lea    -0x41(%edx),%esi
  801997:	89 f3                	mov    %esi,%ebx
  801999:	80 fb 19             	cmp    $0x19,%bl
  80199c:	77 16                	ja     8019b4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80199e:	0f be d2             	movsbl %dl,%edx
  8019a1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019a4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019a7:	7d 0b                	jge    8019b4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019a9:	83 c1 01             	add    $0x1,%ecx
  8019ac:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019b0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019b2:	eb b9                	jmp    80196d <strtol+0x76>

	if (endptr)
  8019b4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019b8:	74 0d                	je     8019c7 <strtol+0xd0>
		*endptr = (char *) s;
  8019ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019bd:	89 0e                	mov    %ecx,(%esi)
  8019bf:	eb 06                	jmp    8019c7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019c1:	85 db                	test   %ebx,%ebx
  8019c3:	74 98                	je     80195d <strtol+0x66>
  8019c5:	eb 9e                	jmp    801965 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019c7:	89 c2                	mov    %eax,%edx
  8019c9:	f7 da                	neg    %edx
  8019cb:	85 ff                	test   %edi,%edi
  8019cd:	0f 45 c2             	cmovne %edx,%eax
}
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5f                   	pop    %edi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	56                   	push   %esi
  8019d9:	53                   	push   %ebx
  8019da:	8b 75 08             	mov    0x8(%ebp),%esi
  8019dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019e3:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019e5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019ea:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019ed:	83 ec 0c             	sub    $0xc,%esp
  8019f0:	50                   	push   %eax
  8019f1:	e8 3b e9 ff ff       	call   800331 <sys_ipc_recv>

	if (from_env_store != NULL)
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	85 f6                	test   %esi,%esi
  8019fb:	74 14                	je     801a11 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801a02:	85 c0                	test   %eax,%eax
  801a04:	78 09                	js     801a0f <ipc_recv+0x3a>
  801a06:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a0c:	8b 52 74             	mov    0x74(%edx),%edx
  801a0f:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a11:	85 db                	test   %ebx,%ebx
  801a13:	74 14                	je     801a29 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a15:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 09                	js     801a27 <ipc_recv+0x52>
  801a1e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a24:	8b 52 78             	mov    0x78(%edx),%edx
  801a27:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 08                	js     801a35 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a2d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a32:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	57                   	push   %edi
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a48:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a4e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a50:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a55:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a58:	ff 75 14             	pushl  0x14(%ebp)
  801a5b:	53                   	push   %ebx
  801a5c:	56                   	push   %esi
  801a5d:	57                   	push   %edi
  801a5e:	e8 ab e8 ff ff       	call   80030e <sys_ipc_try_send>

		if (err < 0) {
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	85 c0                	test   %eax,%eax
  801a68:	79 1e                	jns    801a88 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a6a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a6d:	75 07                	jne    801a76 <ipc_send+0x3a>
				sys_yield();
  801a6f:	e8 ee e6 ff ff       	call   800162 <sys_yield>
  801a74:	eb e2                	jmp    801a58 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a76:	50                   	push   %eax
  801a77:	68 00 22 80 00       	push   $0x802200
  801a7c:	6a 49                	push   $0x49
  801a7e:	68 0d 22 80 00       	push   $0x80220d
  801a83:	e8 a8 f5 ff ff       	call   801030 <_panic>
		}

	} while (err < 0);

}
  801a88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5e                   	pop    %esi
  801a8d:	5f                   	pop    %edi
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a96:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a9b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a9e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aa4:	8b 52 50             	mov    0x50(%edx),%edx
  801aa7:	39 ca                	cmp    %ecx,%edx
  801aa9:	75 0d                	jne    801ab8 <ipc_find_env+0x28>
			return envs[i].env_id;
  801aab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ab3:	8b 40 48             	mov    0x48(%eax),%eax
  801ab6:	eb 0f                	jmp    801ac7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab8:	83 c0 01             	add    $0x1,%eax
  801abb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ac0:	75 d9                	jne    801a9b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ac2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801acf:	89 d0                	mov    %edx,%eax
  801ad1:	c1 e8 16             	shr    $0x16,%eax
  801ad4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801adb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae0:	f6 c1 01             	test   $0x1,%cl
  801ae3:	74 1d                	je     801b02 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ae5:	c1 ea 0c             	shr    $0xc,%edx
  801ae8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801aef:	f6 c2 01             	test   $0x1,%dl
  801af2:	74 0e                	je     801b02 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801af4:	c1 ea 0c             	shr    $0xc,%edx
  801af7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801afe:	ef 
  801aff:	0f b7 c0             	movzwl %ax,%eax
}
  801b02:	5d                   	pop    %ebp
  801b03:	c3                   	ret    
  801b04:	66 90                	xchg   %ax,%ax
  801b06:	66 90                	xchg   %ax,%ax
  801b08:	66 90                	xchg   %ax,%ax
  801b0a:	66 90                	xchg   %ax,%ax
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
