
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 87 04 00 00       	call   800511 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 aa 1d 80 00       	push   $0x801daa
  800103:	6a 23                	push   $0x23
  800105:	68 c7 1d 80 00       	push   $0x801dc7
  80010a:	e8 14 0f 00 00       	call   801023 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 aa 1d 80 00       	push   $0x801daa
  800184:	6a 23                	push   $0x23
  800186:	68 c7 1d 80 00       	push   $0x801dc7
  80018b:	e8 93 0e 00 00       	call   801023 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 aa 1d 80 00       	push   $0x801daa
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 c7 1d 80 00       	push   $0x801dc7
  8001cd:	e8 51 0e 00 00       	call   801023 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 aa 1d 80 00       	push   $0x801daa
  800208:	6a 23                	push   $0x23
  80020a:	68 c7 1d 80 00       	push   $0x801dc7
  80020f:	e8 0f 0e 00 00       	call   801023 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 aa 1d 80 00       	push   $0x801daa
  80024a:	6a 23                	push   $0x23
  80024c:	68 c7 1d 80 00       	push   $0x801dc7
  800251:	e8 cd 0d 00 00       	call   801023 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 aa 1d 80 00       	push   $0x801daa
  80028c:	6a 23                	push   $0x23
  80028e:	68 c7 1d 80 00       	push   $0x801dc7
  800293:	e8 8b 0d 00 00       	call   801023 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 aa 1d 80 00       	push   $0x801daa
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 c7 1d 80 00       	push   $0x801dc7
  8002d5:	e8 49 0d 00 00       	call   801023 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 aa 1d 80 00       	push   $0x801daa
  800332:	6a 23                	push   $0x23
  800334:	68 c7 1d 80 00       	push   $0x801dc7
  800339:	e8 e5 0c 00 00       	call   801023 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 11                	je     80039a <fd_alloc+0x2d>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	75 09                	jne    8003a3 <fd_alloc+0x36>
			*fd_store = fd;
  80039a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039c:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a1:	eb 17                	jmp    8003ba <fd_alloc+0x4d>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 c9                	jne    800378 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	eb 13                	jmp    800410 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb 0c                	jmp    800410 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb 05                	jmp    800410 <fd_lookup+0x54>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba 54 1e 80 00       	mov    $0x801e54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	eb 13                	jmp    800435 <dev_lookup+0x23>
  800422:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	75 0c                	jne    800435 <dev_lookup+0x23>
			*dev = devtab[i];
  800429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 2e                	jmp    800463 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 e7                	jne    800422 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 04 40 80 00       	mov    0x804004,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 d8 1d 80 00       	push   $0x801dd8
  80044d:	e8 aa 0c 00 00       	call   8010fc <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 10             	sub    $0x10,%esp
  80046d:	8b 75 08             	mov    0x8(%ebp),%esi
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800476:	50                   	push   %eax
  800477:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047d:	c1 e8 0c             	shr    $0xc,%eax
  800480:	50                   	push   %eax
  800481:	e8 36 ff ff ff       	call   8003bc <fd_lookup>
  800486:	83 c4 08             	add    $0x8,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	78 05                	js     800492 <fd_close+0x2d>
	    || fd != fd2)
  80048d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800490:	74 0c                	je     80049e <fd_close+0x39>
		return (must_exist ? r : 0);
  800492:	84 db                	test   %bl,%bl
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
  800499:	0f 44 c2             	cmove  %edx,%eax
  80049c:	eb 41                	jmp    8004df <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a4:	50                   	push   %eax
  8004a5:	ff 36                	pushl  (%esi)
  8004a7:	e8 66 ff ff ff       	call   800412 <dev_lookup>
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 1a                	js     8004cf <fd_close+0x6a>
		if (dev->dev_close)
  8004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	74 0b                	je     8004cf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c4:	83 ec 0c             	sub    $0xc,%esp
  8004c7:	56                   	push   %esi
  8004c8:	ff d0                	call   *%eax
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	56                   	push   %esi
  8004d3:	6a 00                	push   $0x0
  8004d5:	e8 00 fd ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	89 d8                	mov    %ebx,%eax
}
  8004df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e2:	5b                   	pop    %ebx
  8004e3:	5e                   	pop    %esi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 c4 fe ff ff       	call   8003bc <fd_lookup>
  8004f8:	83 c4 08             	add    $0x8,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 10                	js     80050f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	6a 01                	push   $0x1
  800504:	ff 75 f4             	pushl  -0xc(%ebp)
  800507:	e8 59 ff ff ff       	call   800465 <fd_close>
  80050c:	83 c4 10             	add    $0x10,%esp
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <close_all>:

void
close_all(void)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	53                   	push   %ebx
  800515:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800518:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	53                   	push   %ebx
  800521:	e8 c0 ff ff ff       	call   8004e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	83 c3 01             	add    $0x1,%ebx
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	83 fb 20             	cmp    $0x20,%ebx
  80052f:	75 ec                	jne    80051d <close_all+0xc>
		close(i);
}
  800531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 2c             	sub    $0x2c,%esp
  80053f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800542:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 6e fe ff ff       	call   8003bc <fd_lookup>
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	0f 88 c1 00 00 00    	js     80061a <dup+0xe4>
		return r;
	close(newfdnum);
  800559:	83 ec 0c             	sub    $0xc,%esp
  80055c:	56                   	push   %esi
  80055d:	e8 84 ff ff ff       	call   8004e6 <close>

	newfd = INDEX2FD(newfdnum);
  800562:	89 f3                	mov    %esi,%ebx
  800564:	c1 e3 0c             	shl    $0xc,%ebx
  800567:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056d:	83 c4 04             	add    $0x4,%esp
  800570:	ff 75 e4             	pushl  -0x1c(%ebp)
  800573:	e8 de fd ff ff       	call   800356 <fd2data>
  800578:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 d4 fd ff ff       	call   800356 <fd2data>
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800588:	89 f8                	mov    %edi,%eax
  80058a:	c1 e8 16             	shr    $0x16,%eax
  80058d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800594:	a8 01                	test   $0x1,%al
  800596:	74 37                	je     8005cf <dup+0x99>
  800598:	89 f8                	mov    %edi,%eax
  80059a:	c1 e8 0c             	shr    $0xc,%eax
  80059d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a4:	f6 c2 01             	test   $0x1,%dl
  8005a7:	74 26                	je     8005cf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b8:	50                   	push   %eax
  8005b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bc:	6a 00                	push   $0x0
  8005be:	57                   	push   %edi
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 d2 fb ff ff       	call   800198 <sys_page_map>
  8005c6:	89 c7                	mov    %eax,%edi
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 2e                	js     8005fd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d2:	89 d0                	mov    %edx,%eax
  8005d4:	c1 e8 0c             	shr    $0xc,%eax
  8005d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e6:	50                   	push   %eax
  8005e7:	53                   	push   %ebx
  8005e8:	6a 00                	push   $0x0
  8005ea:	52                   	push   %edx
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 a6 fb ff ff       	call   800198 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	79 1d                	jns    80061a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 00                	push   $0x0
  800603:	e8 d2 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800608:	83 c4 08             	add    $0x8,%esp
  80060b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060e:	6a 00                	push   $0x0
  800610:	e8 c5 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	89 f8                	mov    %edi,%eax
}
  80061a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	53                   	push   %ebx
  800626:	83 ec 14             	sub    $0x14,%esp
  800629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062f:	50                   	push   %eax
  800630:	53                   	push   %ebx
  800631:	e8 86 fd ff ff       	call   8003bc <fd_lookup>
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	89 c2                	mov    %eax,%edx
  80063b:	85 c0                	test   %eax,%eax
  80063d:	78 6d                	js     8006ac <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800649:	ff 30                	pushl  (%eax)
  80064b:	e8 c2 fd ff ff       	call   800412 <dev_lookup>
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	85 c0                	test   %eax,%eax
  800655:	78 4c                	js     8006a3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800657:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065a:	8b 42 08             	mov    0x8(%edx),%eax
  80065d:	83 e0 03             	and    $0x3,%eax
  800660:	83 f8 01             	cmp    $0x1,%eax
  800663:	75 21                	jne    800686 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800665:	a1 04 40 80 00       	mov    0x804004,%eax
  80066a:	8b 40 48             	mov    0x48(%eax),%eax
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	53                   	push   %ebx
  800671:	50                   	push   %eax
  800672:	68 19 1e 80 00       	push   $0x801e19
  800677:	e8 80 0a 00 00       	call   8010fc <cprintf>
		return -E_INVAL;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800684:	eb 26                	jmp    8006ac <read+0x8a>
	}
	if (!dev->dev_read)
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	8b 40 08             	mov    0x8(%eax),%eax
  80068c:	85 c0                	test   %eax,%eax
  80068e:	74 17                	je     8006a7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800690:	83 ec 04             	sub    $0x4,%esp
  800693:	ff 75 10             	pushl  0x10(%ebp)
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	52                   	push   %edx
  80069a:	ff d0                	call   *%eax
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb 09                	jmp    8006ac <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a3:	89 c2                	mov    %eax,%edx
  8006a5:	eb 05                	jmp    8006ac <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ac:	89 d0                	mov    %edx,%eax
  8006ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	57                   	push   %edi
  8006b7:	56                   	push   %esi
  8006b8:	53                   	push   %ebx
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	eb 21                	jmp    8006ea <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	29 d8                	sub    %ebx,%eax
  8006d0:	50                   	push   %eax
  8006d1:	89 d8                	mov    %ebx,%eax
  8006d3:	03 45 0c             	add    0xc(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	57                   	push   %edi
  8006d8:	e8 45 ff ff ff       	call   800622 <read>
		if (m < 0)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 10                	js     8006f4 <readn+0x41>
			return m;
		if (m == 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 0a                	je     8006f2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e8:	01 c3                	add    %eax,%ebx
  8006ea:	39 f3                	cmp    %esi,%ebx
  8006ec:	72 db                	jb     8006c9 <readn+0x16>
  8006ee:	89 d8                	mov    %ebx,%eax
  8006f0:	eb 02                	jmp    8006f4 <readn+0x41>
  8006f2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ac fc ff ff       	call   8003bc <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	89 c2                	mov    %eax,%edx
  800715:	85 c0                	test   %eax,%eax
  800717:	78 68                	js     800781 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800723:	ff 30                	pushl  (%eax)
  800725:	e8 e8 fc ff ff       	call   800412 <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 47                	js     800778 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800738:	75 21                	jne    80075b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 04 40 80 00       	mov    0x804004,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	53                   	push   %ebx
  800746:	50                   	push   %eax
  800747:	68 35 1e 80 00       	push   $0x801e35
  80074c:	e8 ab 09 00 00       	call   8010fc <cprintf>
		return -E_INVAL;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800759:	eb 26                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075e:	8b 52 0c             	mov    0xc(%edx),%edx
  800761:	85 d2                	test   %edx,%edx
  800763:	74 17                	je     80077c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800765:	83 ec 04             	sub    $0x4,%esp
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	50                   	push   %eax
  80076f:	ff d2                	call   *%edx
  800771:	89 c2                	mov    %eax,%edx
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 09                	jmp    800781 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800778:	89 c2                	mov    %eax,%edx
  80077a:	eb 05                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800781:	89 d0                	mov    %edx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <seek>:

int
seek(int fdnum, off_t offset)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	ff 75 08             	pushl  0x8(%ebp)
  800795:	e8 22 fc ff ff       	call   8003bc <fd_lookup>
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 0e                	js     8007af <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 14             	sub    $0x14,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	53                   	push   %ebx
  8007c0:	e8 f7 fb ff ff       	call   8003bc <fd_lookup>
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 65                	js     800833 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	ff 30                	pushl  (%eax)
  8007da:	e8 33 fc ff ff       	call   800412 <dev_lookup>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 44                	js     80082a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ed:	75 21                	jne    800810 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ef:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 f8 1d 80 00       	push   $0x801df8
  800801:	e8 f6 08 00 00       	call   8010fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080e:	eb 23                	jmp    800833 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800810:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800813:	8b 52 18             	mov    0x18(%edx),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	74 14                	je     80082e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	50                   	push   %eax
  800821:	ff d2                	call   *%edx
  800823:	89 c2                	mov    %eax,%edx
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 09                	jmp    800833 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	eb 05                	jmp    800833 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800833:	89 d0                	mov    %edx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 6c fb ff ff       	call   8003bc <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	89 c2                	mov    %eax,%edx
  800855:	85 c0                	test   %eax,%eax
  800857:	78 58                	js     8008b1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800863:	ff 30                	pushl  (%eax)
  800865:	e8 a8 fb ff ff       	call   800412 <dev_lookup>
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	85 c0                	test   %eax,%eax
  80086f:	78 37                	js     8008a8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800874:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800878:	74 32                	je     8008ac <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800884:	00 00 00 
	stat->st_isdir = 0;
  800887:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088e:	00 00 00 
	stat->st_dev = dev;
  800891:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	ff 75 f0             	pushl  -0x10(%ebp)
  80089e:	ff 50 14             	call   *0x14(%eax)
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 09                	jmp    8008b1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 05                	jmp    8008b1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	6a 00                	push   $0x0
  8008c2:	ff 75 08             	pushl  0x8(%ebp)
  8008c5:	e8 d6 01 00 00       	call   800aa0 <open>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 1b                	js     8008ee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	50                   	push   %eax
  8008da:	e8 5b ff ff ff       	call   80083a <fstat>
  8008df:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 fd fb ff ff       	call   8004e6 <close>
	return r;
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	89 f0                	mov    %esi,%eax
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	89 c6                	mov    %eax,%esi
  8008fc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800905:	75 12                	jne    800919 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 72 11 00 00       	call   801a83 <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800919:	6a 07                	push   $0x7
  80091b:	68 00 50 80 00       	push   $0x805000
  800920:	56                   	push   %esi
  800921:	ff 35 00 40 80 00    	pushl  0x804000
  800927:	e8 03 11 00 00       	call   801a2f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092c:	83 c4 0c             	add    $0xc,%esp
  80092f:	6a 00                	push   $0x0
  800931:	53                   	push   %ebx
  800932:	6a 00                	push   $0x0
  800934:	e8 8f 10 00 00       	call   8019c8 <ipc_recv>
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 40 0c             	mov    0xc(%eax),%eax
  80094c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 02 00 00 00       	mov    $0x2,%eax
  800963:	e8 8d ff ff ff       	call   8008f5 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 40 0c             	mov    0xc(%eax),%eax
  800976:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	b8 06 00 00 00       	mov    $0x6,%eax
  800985:	e8 6b ff ff ff       	call   8008f5 <fsipc>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	83 ec 04             	sub    $0x4,%esp
  800993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ab:	e8 45 ff ff ff       	call   8008f5 <fsipc>
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	78 2c                	js     8009e0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	68 00 50 80 00       	push   $0x805000
  8009bc:	53                   	push   %ebx
  8009bd:	e8 bf 0c 00 00       	call   801681 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cd:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	83 ec 0c             	sub    $0xc,%esp
  8009eb:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009fa:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009ff:	50                   	push   %eax
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	68 08 50 80 00       	push   $0x805008
  800a08:	e8 06 0e 00 00       	call   801813 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a12:	b8 04 00 00 00       	mov    $0x4,%eax
  800a17:	e8 d9 fe ff ff       	call   8008f5 <fsipc>

}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a31:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a37:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a41:	e8 af fe ff ff       	call   8008f5 <fsipc>
  800a46:	89 c3                	mov    %eax,%ebx
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	78 4b                	js     800a97 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a4c:	39 c6                	cmp    %eax,%esi
  800a4e:	73 16                	jae    800a66 <devfile_read+0x48>
  800a50:	68 64 1e 80 00       	push   $0x801e64
  800a55:	68 6b 1e 80 00       	push   $0x801e6b
  800a5a:	6a 7c                	push   $0x7c
  800a5c:	68 80 1e 80 00       	push   $0x801e80
  800a61:	e8 bd 05 00 00       	call   801023 <_panic>
	assert(r <= PGSIZE);
  800a66:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a6b:	7e 16                	jle    800a83 <devfile_read+0x65>
  800a6d:	68 8b 1e 80 00       	push   $0x801e8b
  800a72:	68 6b 1e 80 00       	push   $0x801e6b
  800a77:	6a 7d                	push   $0x7d
  800a79:	68 80 1e 80 00       	push   $0x801e80
  800a7e:	e8 a0 05 00 00       	call   801023 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a83:	83 ec 04             	sub    $0x4,%esp
  800a86:	50                   	push   %eax
  800a87:	68 00 50 80 00       	push   $0x805000
  800a8c:	ff 75 0c             	pushl  0xc(%ebp)
  800a8f:	e8 7f 0d 00 00       	call   801813 <memmove>
	return r;
  800a94:	83 c4 10             	add    $0x10,%esp
}
  800a97:	89 d8                	mov    %ebx,%eax
  800a99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 20             	sub    $0x20,%esp
  800aa7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aaa:	53                   	push   %ebx
  800aab:	e8 98 0b 00 00       	call   801648 <strlen>
  800ab0:	83 c4 10             	add    $0x10,%esp
  800ab3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab8:	7f 67                	jg     800b21 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aba:	83 ec 0c             	sub    $0xc,%esp
  800abd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac0:	50                   	push   %eax
  800ac1:	e8 a7 f8 ff ff       	call   80036d <fd_alloc>
  800ac6:	83 c4 10             	add    $0x10,%esp
		return r;
  800ac9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800acb:	85 c0                	test   %eax,%eax
  800acd:	78 57                	js     800b26 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800acf:	83 ec 08             	sub    $0x8,%esp
  800ad2:	53                   	push   %ebx
  800ad3:	68 00 50 80 00       	push   $0x805000
  800ad8:	e8 a4 0b 00 00       	call   801681 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800add:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae8:	b8 01 00 00 00       	mov    $0x1,%eax
  800aed:	e8 03 fe ff ff       	call   8008f5 <fsipc>
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	83 c4 10             	add    $0x10,%esp
  800af7:	85 c0                	test   %eax,%eax
  800af9:	79 14                	jns    800b0f <open+0x6f>
		fd_close(fd, 0);
  800afb:	83 ec 08             	sub    $0x8,%esp
  800afe:	6a 00                	push   $0x0
  800b00:	ff 75 f4             	pushl  -0xc(%ebp)
  800b03:	e8 5d f9 ff ff       	call   800465 <fd_close>
		return r;
  800b08:	83 c4 10             	add    $0x10,%esp
  800b0b:	89 da                	mov    %ebx,%edx
  800b0d:	eb 17                	jmp    800b26 <open+0x86>
	}

	return fd2num(fd);
  800b0f:	83 ec 0c             	sub    $0xc,%esp
  800b12:	ff 75 f4             	pushl  -0xc(%ebp)
  800b15:	e8 2c f8 ff ff       	call   800346 <fd2num>
  800b1a:	89 c2                	mov    %eax,%edx
  800b1c:	83 c4 10             	add    $0x10,%esp
  800b1f:	eb 05                	jmp    800b26 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b21:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b26:	89 d0                	mov    %edx,%eax
  800b28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b33:	ba 00 00 00 00       	mov    $0x0,%edx
  800b38:	b8 08 00 00 00       	mov    $0x8,%eax
  800b3d:	e8 b3 fd ff ff       	call   8008f5 <fsipc>
}
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b4c:	83 ec 0c             	sub    $0xc,%esp
  800b4f:	ff 75 08             	pushl  0x8(%ebp)
  800b52:	e8 ff f7 ff ff       	call   800356 <fd2data>
  800b57:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b59:	83 c4 08             	add    $0x8,%esp
  800b5c:	68 97 1e 80 00       	push   $0x801e97
  800b61:	53                   	push   %ebx
  800b62:	e8 1a 0b 00 00       	call   801681 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b67:	8b 46 04             	mov    0x4(%esi),%eax
  800b6a:	2b 06                	sub    (%esi),%eax
  800b6c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b72:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b79:	00 00 00 
	stat->st_dev = &devpipe;
  800b7c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b83:	30 80 00 
	return 0;
}
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	53                   	push   %ebx
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b9c:	53                   	push   %ebx
  800b9d:	6a 00                	push   $0x0
  800b9f:	e8 36 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800ba4:	89 1c 24             	mov    %ebx,(%esp)
  800ba7:	e8 aa f7 ff ff       	call   800356 <fd2data>
  800bac:	83 c4 08             	add    $0x8,%esp
  800baf:	50                   	push   %eax
  800bb0:	6a 00                	push   $0x0
  800bb2:	e8 23 f6 ff ff       	call   8001da <sys_page_unmap>
}
  800bb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 1c             	sub    $0x1c,%esp
  800bc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bc8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bca:	a1 04 40 80 00       	mov    0x804004,%eax
  800bcf:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	ff 75 e0             	pushl  -0x20(%ebp)
  800bd8:	e8 df 0e 00 00       	call   801abc <pageref>
  800bdd:	89 c3                	mov    %eax,%ebx
  800bdf:	89 3c 24             	mov    %edi,(%esp)
  800be2:	e8 d5 0e 00 00       	call   801abc <pageref>
  800be7:	83 c4 10             	add    $0x10,%esp
  800bea:	39 c3                	cmp    %eax,%ebx
  800bec:	0f 94 c1             	sete   %cl
  800bef:	0f b6 c9             	movzbl %cl,%ecx
  800bf2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bf5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bfb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bfe:	39 ce                	cmp    %ecx,%esi
  800c00:	74 1b                	je     800c1d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c02:	39 c3                	cmp    %eax,%ebx
  800c04:	75 c4                	jne    800bca <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c06:	8b 42 58             	mov    0x58(%edx),%eax
  800c09:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c0c:	50                   	push   %eax
  800c0d:	56                   	push   %esi
  800c0e:	68 9e 1e 80 00       	push   $0x801e9e
  800c13:	e8 e4 04 00 00       	call   8010fc <cprintf>
  800c18:	83 c4 10             	add    $0x10,%esp
  800c1b:	eb ad                	jmp    800bca <_pipeisclosed+0xe>
	}
}
  800c1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 28             	sub    $0x28,%esp
  800c31:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c34:	56                   	push   %esi
  800c35:	e8 1c f7 ff ff       	call   800356 <fd2data>
  800c3a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c3c:	83 c4 10             	add    $0x10,%esp
  800c3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c44:	eb 4b                	jmp    800c91 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c46:	89 da                	mov    %ebx,%edx
  800c48:	89 f0                	mov    %esi,%eax
  800c4a:	e8 6d ff ff ff       	call   800bbc <_pipeisclosed>
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	75 48                	jne    800c9b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c53:	e8 de f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c58:	8b 43 04             	mov    0x4(%ebx),%eax
  800c5b:	8b 0b                	mov    (%ebx),%ecx
  800c5d:	8d 51 20             	lea    0x20(%ecx),%edx
  800c60:	39 d0                	cmp    %edx,%eax
  800c62:	73 e2                	jae    800c46 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c6b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c6e:	89 c2                	mov    %eax,%edx
  800c70:	c1 fa 1f             	sar    $0x1f,%edx
  800c73:	89 d1                	mov    %edx,%ecx
  800c75:	c1 e9 1b             	shr    $0x1b,%ecx
  800c78:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c7b:	83 e2 1f             	and    $0x1f,%edx
  800c7e:	29 ca                	sub    %ecx,%edx
  800c80:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c84:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c88:	83 c0 01             	add    $0x1,%eax
  800c8b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c8e:	83 c7 01             	add    $0x1,%edi
  800c91:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c94:	75 c2                	jne    800c58 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c96:	8b 45 10             	mov    0x10(%ebp),%eax
  800c99:	eb 05                	jmp    800ca0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 18             	sub    $0x18,%esp
  800cb1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cb4:	57                   	push   %edi
  800cb5:	e8 9c f6 ff ff       	call   800356 <fd2data>
  800cba:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbc:	83 c4 10             	add    $0x10,%esp
  800cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc4:	eb 3d                	jmp    800d03 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cc6:	85 db                	test   %ebx,%ebx
  800cc8:	74 04                	je     800cce <devpipe_read+0x26>
				return i;
  800cca:	89 d8                	mov    %ebx,%eax
  800ccc:	eb 44                	jmp    800d12 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cce:	89 f2                	mov    %esi,%edx
  800cd0:	89 f8                	mov    %edi,%eax
  800cd2:	e8 e5 fe ff ff       	call   800bbc <_pipeisclosed>
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	75 32                	jne    800d0d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cdb:	e8 56 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ce0:	8b 06                	mov    (%esi),%eax
  800ce2:	3b 46 04             	cmp    0x4(%esi),%eax
  800ce5:	74 df                	je     800cc6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ce7:	99                   	cltd   
  800ce8:	c1 ea 1b             	shr    $0x1b,%edx
  800ceb:	01 d0                	add    %edx,%eax
  800ced:	83 e0 1f             	and    $0x1f,%eax
  800cf0:	29 d0                	sub    %edx,%eax
  800cf2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cfd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d00:	83 c3 01             	add    $0x1,%ebx
  800d03:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d06:	75 d8                	jne    800ce0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d08:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0b:	eb 05                	jmp    800d12 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d25:	50                   	push   %eax
  800d26:	e8 42 f6 ff ff       	call   80036d <fd_alloc>
  800d2b:	83 c4 10             	add    $0x10,%esp
  800d2e:	89 c2                	mov    %eax,%edx
  800d30:	85 c0                	test   %eax,%eax
  800d32:	0f 88 2c 01 00 00    	js     800e64 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d38:	83 ec 04             	sub    $0x4,%esp
  800d3b:	68 07 04 00 00       	push   $0x407
  800d40:	ff 75 f4             	pushl  -0xc(%ebp)
  800d43:	6a 00                	push   $0x0
  800d45:	e8 0b f4 ff ff       	call   800155 <sys_page_alloc>
  800d4a:	83 c4 10             	add    $0x10,%esp
  800d4d:	89 c2                	mov    %eax,%edx
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	0f 88 0d 01 00 00    	js     800e64 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d5d:	50                   	push   %eax
  800d5e:	e8 0a f6 ff ff       	call   80036d <fd_alloc>
  800d63:	89 c3                	mov    %eax,%ebx
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	0f 88 e2 00 00 00    	js     800e52 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d70:	83 ec 04             	sub    $0x4,%esp
  800d73:	68 07 04 00 00       	push   $0x407
  800d78:	ff 75 f0             	pushl  -0x10(%ebp)
  800d7b:	6a 00                	push   $0x0
  800d7d:	e8 d3 f3 ff ff       	call   800155 <sys_page_alloc>
  800d82:	89 c3                	mov    %eax,%ebx
  800d84:	83 c4 10             	add    $0x10,%esp
  800d87:	85 c0                	test   %eax,%eax
  800d89:	0f 88 c3 00 00 00    	js     800e52 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	ff 75 f4             	pushl  -0xc(%ebp)
  800d95:	e8 bc f5 ff ff       	call   800356 <fd2data>
  800d9a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9c:	83 c4 0c             	add    $0xc,%esp
  800d9f:	68 07 04 00 00       	push   $0x407
  800da4:	50                   	push   %eax
  800da5:	6a 00                	push   $0x0
  800da7:	e8 a9 f3 ff ff       	call   800155 <sys_page_alloc>
  800dac:	89 c3                	mov    %eax,%ebx
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	85 c0                	test   %eax,%eax
  800db3:	0f 88 89 00 00 00    	js     800e42 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	ff 75 f0             	pushl  -0x10(%ebp)
  800dbf:	e8 92 f5 ff ff       	call   800356 <fd2data>
  800dc4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dcb:	50                   	push   %eax
  800dcc:	6a 00                	push   $0x0
  800dce:	56                   	push   %esi
  800dcf:	6a 00                	push   $0x0
  800dd1:	e8 c2 f3 ff ff       	call   800198 <sys_page_map>
  800dd6:	89 c3                	mov    %eax,%ebx
  800dd8:	83 c4 20             	add    $0x20,%esp
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	78 55                	js     800e34 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800ddf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ded:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800df4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e02:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e0f:	e8 32 f5 ff ff       	call   800346 <fd2num>
  800e14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e17:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e19:	83 c4 04             	add    $0x4,%esp
  800e1c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e1f:	e8 22 f5 ff ff       	call   800346 <fd2num>
  800e24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e27:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e32:	eb 30                	jmp    800e64 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	56                   	push   %esi
  800e38:	6a 00                	push   $0x0
  800e3a:	e8 9b f3 ff ff       	call   8001da <sys_page_unmap>
  800e3f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e42:	83 ec 08             	sub    $0x8,%esp
  800e45:	ff 75 f0             	pushl  -0x10(%ebp)
  800e48:	6a 00                	push   $0x0
  800e4a:	e8 8b f3 ff ff       	call   8001da <sys_page_unmap>
  800e4f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e52:	83 ec 08             	sub    $0x8,%esp
  800e55:	ff 75 f4             	pushl  -0xc(%ebp)
  800e58:	6a 00                	push   $0x0
  800e5a:	e8 7b f3 ff ff       	call   8001da <sys_page_unmap>
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e64:	89 d0                	mov    %edx,%eax
  800e66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e76:	50                   	push   %eax
  800e77:	ff 75 08             	pushl  0x8(%ebp)
  800e7a:	e8 3d f5 ff ff       	call   8003bc <fd_lookup>
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	85 c0                	test   %eax,%eax
  800e84:	78 18                	js     800e9e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e86:	83 ec 0c             	sub    $0xc,%esp
  800e89:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8c:	e8 c5 f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800e91:	89 c2                	mov    %eax,%edx
  800e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e96:	e8 21 fd ff ff       	call   800bbc <_pipeisclosed>
  800e9b:	83 c4 10             	add    $0x10,%esp
}
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eb0:	68 b6 1e 80 00       	push   $0x801eb6
  800eb5:	ff 75 0c             	pushl  0xc(%ebp)
  800eb8:	e8 c4 07 00 00       	call   801681 <strcpy>
	return 0;
}
  800ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
  800eca:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ed0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ed5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800edb:	eb 2d                	jmp    800f0a <devcons_write+0x46>
		m = n - tot;
  800edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ee2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ee5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800eea:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eed:	83 ec 04             	sub    $0x4,%esp
  800ef0:	53                   	push   %ebx
  800ef1:	03 45 0c             	add    0xc(%ebp),%eax
  800ef4:	50                   	push   %eax
  800ef5:	57                   	push   %edi
  800ef6:	e8 18 09 00 00       	call   801813 <memmove>
		sys_cputs(buf, m);
  800efb:	83 c4 08             	add    $0x8,%esp
  800efe:	53                   	push   %ebx
  800eff:	57                   	push   %edi
  800f00:	e8 94 f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f05:	01 de                	add    %ebx,%esi
  800f07:	83 c4 10             	add    $0x10,%esp
  800f0a:	89 f0                	mov    %esi,%eax
  800f0c:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f0f:	72 cc                	jb     800edd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5f                   	pop    %edi
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f28:	74 2a                	je     800f54 <devcons_read+0x3b>
  800f2a:	eb 05                	jmp    800f31 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f2c:	e8 05 f2 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f31:	e8 81 f1 ff ff       	call   8000b7 <sys_cgetc>
  800f36:	85 c0                	test   %eax,%eax
  800f38:	74 f2                	je     800f2c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	78 16                	js     800f54 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f3e:	83 f8 04             	cmp    $0x4,%eax
  800f41:	74 0c                	je     800f4f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f46:	88 02                	mov    %al,(%edx)
	return 1;
  800f48:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4d:	eb 05                	jmp    800f54 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f4f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f54:	c9                   	leave  
  800f55:	c3                   	ret    

00800f56 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f62:	6a 01                	push   $0x1
  800f64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f67:	50                   	push   %eax
  800f68:	e8 2c f1 ff ff       	call   800099 <sys_cputs>
}
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <getchar>:

int
getchar(void)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f78:	6a 01                	push   $0x1
  800f7a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7d:	50                   	push   %eax
  800f7e:	6a 00                	push   $0x0
  800f80:	e8 9d f6 ff ff       	call   800622 <read>
	if (r < 0)
  800f85:	83 c4 10             	add    $0x10,%esp
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	78 0f                	js     800f9b <getchar+0x29>
		return r;
	if (r < 1)
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	7e 06                	jle    800f96 <getchar+0x24>
		return -E_EOF;
	return c;
  800f90:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f94:	eb 05                	jmp    800f9b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f96:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa6:	50                   	push   %eax
  800fa7:	ff 75 08             	pushl  0x8(%ebp)
  800faa:	e8 0d f4 ff ff       	call   8003bc <fd_lookup>
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 11                	js     800fc7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fbf:	39 10                	cmp    %edx,(%eax)
  800fc1:	0f 94 c0             	sete   %al
  800fc4:	0f b6 c0             	movzbl %al,%eax
}
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <opencons>:

int
opencons(void)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd2:	50                   	push   %eax
  800fd3:	e8 95 f3 ff ff       	call   80036d <fd_alloc>
  800fd8:	83 c4 10             	add    $0x10,%esp
		return r;
  800fdb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 3e                	js     80101f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fe1:	83 ec 04             	sub    $0x4,%esp
  800fe4:	68 07 04 00 00       	push   $0x407
  800fe9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fec:	6a 00                	push   $0x0
  800fee:	e8 62 f1 ff ff       	call   800155 <sys_page_alloc>
  800ff3:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 23                	js     80101f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800ffc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801002:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801005:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801007:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	50                   	push   %eax
  801015:	e8 2c f3 ff ff       	call   800346 <fd2num>
  80101a:	89 c2                	mov    %eax,%edx
  80101c:	83 c4 10             	add    $0x10,%esp
}
  80101f:	89 d0                	mov    %edx,%eax
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801028:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80102b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801031:	e8 e1 f0 ff ff       	call   800117 <sys_getenvid>
  801036:	83 ec 0c             	sub    $0xc,%esp
  801039:	ff 75 0c             	pushl  0xc(%ebp)
  80103c:	ff 75 08             	pushl  0x8(%ebp)
  80103f:	56                   	push   %esi
  801040:	50                   	push   %eax
  801041:	68 c4 1e 80 00       	push   $0x801ec4
  801046:	e8 b1 00 00 00       	call   8010fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80104b:	83 c4 18             	add    $0x18,%esp
  80104e:	53                   	push   %ebx
  80104f:	ff 75 10             	pushl  0x10(%ebp)
  801052:	e8 54 00 00 00       	call   8010ab <vcprintf>
	cprintf("\n");
  801057:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  80105e:	e8 99 00 00 00       	call   8010fc <cprintf>
  801063:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801066:	cc                   	int3   
  801067:	eb fd                	jmp    801066 <_panic+0x43>

00801069 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	53                   	push   %ebx
  80106d:	83 ec 04             	sub    $0x4,%esp
  801070:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801073:	8b 13                	mov    (%ebx),%edx
  801075:	8d 42 01             	lea    0x1(%edx),%eax
  801078:	89 03                	mov    %eax,(%ebx)
  80107a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801081:	3d ff 00 00 00       	cmp    $0xff,%eax
  801086:	75 1a                	jne    8010a2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801088:	83 ec 08             	sub    $0x8,%esp
  80108b:	68 ff 00 00 00       	push   $0xff
  801090:	8d 43 08             	lea    0x8(%ebx),%eax
  801093:	50                   	push   %eax
  801094:	e8 00 f0 ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  801099:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80109f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    

008010ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010bb:	00 00 00 
	b.cnt = 0;
  8010be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010c8:	ff 75 0c             	pushl  0xc(%ebp)
  8010cb:	ff 75 08             	pushl  0x8(%ebp)
  8010ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010d4:	50                   	push   %eax
  8010d5:	68 69 10 80 00       	push   $0x801069
  8010da:	e8 54 01 00 00       	call   801233 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010df:	83 c4 08             	add    $0x8,%esp
  8010e2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010ee:	50                   	push   %eax
  8010ef:	e8 a5 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  8010f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801102:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801105:	50                   	push   %eax
  801106:	ff 75 08             	pushl  0x8(%ebp)
  801109:	e8 9d ff ff ff       	call   8010ab <vcprintf>
	va_end(ap);

	return cnt;
}
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	57                   	push   %edi
  801114:	56                   	push   %esi
  801115:	53                   	push   %ebx
  801116:	83 ec 1c             	sub    $0x1c,%esp
  801119:	89 c7                	mov    %eax,%edi
  80111b:	89 d6                	mov    %edx,%esi
  80111d:	8b 45 08             	mov    0x8(%ebp),%eax
  801120:	8b 55 0c             	mov    0xc(%ebp),%edx
  801123:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801126:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801129:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80112c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801131:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801134:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801137:	39 d3                	cmp    %edx,%ebx
  801139:	72 05                	jb     801140 <printnum+0x30>
  80113b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80113e:	77 45                	ja     801185 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801140:	83 ec 0c             	sub    $0xc,%esp
  801143:	ff 75 18             	pushl  0x18(%ebp)
  801146:	8b 45 14             	mov    0x14(%ebp),%eax
  801149:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80114c:	53                   	push   %ebx
  80114d:	ff 75 10             	pushl  0x10(%ebp)
  801150:	83 ec 08             	sub    $0x8,%esp
  801153:	ff 75 e4             	pushl  -0x1c(%ebp)
  801156:	ff 75 e0             	pushl  -0x20(%ebp)
  801159:	ff 75 dc             	pushl  -0x24(%ebp)
  80115c:	ff 75 d8             	pushl  -0x28(%ebp)
  80115f:	e8 9c 09 00 00       	call   801b00 <__udivdi3>
  801164:	83 c4 18             	add    $0x18,%esp
  801167:	52                   	push   %edx
  801168:	50                   	push   %eax
  801169:	89 f2                	mov    %esi,%edx
  80116b:	89 f8                	mov    %edi,%eax
  80116d:	e8 9e ff ff ff       	call   801110 <printnum>
  801172:	83 c4 20             	add    $0x20,%esp
  801175:	eb 18                	jmp    80118f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801177:	83 ec 08             	sub    $0x8,%esp
  80117a:	56                   	push   %esi
  80117b:	ff 75 18             	pushl  0x18(%ebp)
  80117e:	ff d7                	call   *%edi
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	eb 03                	jmp    801188 <printnum+0x78>
  801185:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801188:	83 eb 01             	sub    $0x1,%ebx
  80118b:	85 db                	test   %ebx,%ebx
  80118d:	7f e8                	jg     801177 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	56                   	push   %esi
  801193:	83 ec 04             	sub    $0x4,%esp
  801196:	ff 75 e4             	pushl  -0x1c(%ebp)
  801199:	ff 75 e0             	pushl  -0x20(%ebp)
  80119c:	ff 75 dc             	pushl  -0x24(%ebp)
  80119f:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a2:	e8 89 0a 00 00       	call   801c30 <__umoddi3>
  8011a7:	83 c4 14             	add    $0x14,%esp
  8011aa:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  8011b1:	50                   	push   %eax
  8011b2:	ff d7                	call   *%edi
}
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ba:	5b                   	pop    %ebx
  8011bb:	5e                   	pop    %esi
  8011bc:	5f                   	pop    %edi
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011c2:	83 fa 01             	cmp    $0x1,%edx
  8011c5:	7e 0e                	jle    8011d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011c7:	8b 10                	mov    (%eax),%edx
  8011c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011cc:	89 08                	mov    %ecx,(%eax)
  8011ce:	8b 02                	mov    (%edx),%eax
  8011d0:	8b 52 04             	mov    0x4(%edx),%edx
  8011d3:	eb 22                	jmp    8011f7 <getuint+0x38>
	else if (lflag)
  8011d5:	85 d2                	test   %edx,%edx
  8011d7:	74 10                	je     8011e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011d9:	8b 10                	mov    (%eax),%edx
  8011db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011de:	89 08                	mov    %ecx,(%eax)
  8011e0:	8b 02                	mov    (%edx),%eax
  8011e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e7:	eb 0e                	jmp    8011f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011e9:	8b 10                	mov    (%eax),%edx
  8011eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ee:	89 08                	mov    %ecx,(%eax)
  8011f0:	8b 02                	mov    (%edx),%eax
  8011f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801203:	8b 10                	mov    (%eax),%edx
  801205:	3b 50 04             	cmp    0x4(%eax),%edx
  801208:	73 0a                	jae    801214 <sprintputch+0x1b>
		*b->buf++ = ch;
  80120a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80120d:	89 08                	mov    %ecx,(%eax)
  80120f:	8b 45 08             	mov    0x8(%ebp),%eax
  801212:	88 02                	mov    %al,(%edx)
}
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80121c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80121f:	50                   	push   %eax
  801220:	ff 75 10             	pushl  0x10(%ebp)
  801223:	ff 75 0c             	pushl  0xc(%ebp)
  801226:	ff 75 08             	pushl  0x8(%ebp)
  801229:	e8 05 00 00 00       	call   801233 <vprintfmt>
	va_end(ap);
}
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	c9                   	leave  
  801232:	c3                   	ret    

00801233 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
  801239:	83 ec 2c             	sub    $0x2c,%esp
  80123c:	8b 75 08             	mov    0x8(%ebp),%esi
  80123f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801242:	8b 7d 10             	mov    0x10(%ebp),%edi
  801245:	eb 12                	jmp    801259 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801247:	85 c0                	test   %eax,%eax
  801249:	0f 84 89 03 00 00    	je     8015d8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80124f:	83 ec 08             	sub    $0x8,%esp
  801252:	53                   	push   %ebx
  801253:	50                   	push   %eax
  801254:	ff d6                	call   *%esi
  801256:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801259:	83 c7 01             	add    $0x1,%edi
  80125c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801260:	83 f8 25             	cmp    $0x25,%eax
  801263:	75 e2                	jne    801247 <vprintfmt+0x14>
  801265:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801269:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801270:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801277:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80127e:	ba 00 00 00 00       	mov    $0x0,%edx
  801283:	eb 07                	jmp    80128c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801285:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801288:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128c:	8d 47 01             	lea    0x1(%edi),%eax
  80128f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801292:	0f b6 07             	movzbl (%edi),%eax
  801295:	0f b6 c8             	movzbl %al,%ecx
  801298:	83 e8 23             	sub    $0x23,%eax
  80129b:	3c 55                	cmp    $0x55,%al
  80129d:	0f 87 1a 03 00 00    	ja     8015bd <vprintfmt+0x38a>
  8012a3:	0f b6 c0             	movzbl %al,%eax
  8012a6:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  8012ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012b0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012b4:	eb d6                	jmp    80128c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012c1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012c4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012c8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012cb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012ce:	83 fa 09             	cmp    $0x9,%edx
  8012d1:	77 39                	ja     80130c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012d3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012d6:	eb e9                	jmp    8012c1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8012db:	8d 48 04             	lea    0x4(%eax),%ecx
  8012de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012e1:	8b 00                	mov    (%eax),%eax
  8012e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012e9:	eb 27                	jmp    801312 <vprintfmt+0xdf>
  8012eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f5:	0f 49 c8             	cmovns %eax,%ecx
  8012f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012fe:	eb 8c                	jmp    80128c <vprintfmt+0x59>
  801300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801303:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80130a:	eb 80                	jmp    80128c <vprintfmt+0x59>
  80130c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80130f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801312:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801316:	0f 89 70 ff ff ff    	jns    80128c <vprintfmt+0x59>
				width = precision, precision = -1;
  80131c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80131f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801322:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801329:	e9 5e ff ff ff       	jmp    80128c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80132e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801334:	e9 53 ff ff ff       	jmp    80128c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801339:	8b 45 14             	mov    0x14(%ebp),%eax
  80133c:	8d 50 04             	lea    0x4(%eax),%edx
  80133f:	89 55 14             	mov    %edx,0x14(%ebp)
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	53                   	push   %ebx
  801346:	ff 30                	pushl  (%eax)
  801348:	ff d6                	call   *%esi
			break;
  80134a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801350:	e9 04 ff ff ff       	jmp    801259 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801355:	8b 45 14             	mov    0x14(%ebp),%eax
  801358:	8d 50 04             	lea    0x4(%eax),%edx
  80135b:	89 55 14             	mov    %edx,0x14(%ebp)
  80135e:	8b 00                	mov    (%eax),%eax
  801360:	99                   	cltd   
  801361:	31 d0                	xor    %edx,%eax
  801363:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801365:	83 f8 0f             	cmp    $0xf,%eax
  801368:	7f 0b                	jg     801375 <vprintfmt+0x142>
  80136a:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  801371:	85 d2                	test   %edx,%edx
  801373:	75 18                	jne    80138d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801375:	50                   	push   %eax
  801376:	68 ff 1e 80 00       	push   $0x801eff
  80137b:	53                   	push   %ebx
  80137c:	56                   	push   %esi
  80137d:	e8 94 fe ff ff       	call   801216 <printfmt>
  801382:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801388:	e9 cc fe ff ff       	jmp    801259 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80138d:	52                   	push   %edx
  80138e:	68 7d 1e 80 00       	push   $0x801e7d
  801393:	53                   	push   %ebx
  801394:	56                   	push   %esi
  801395:	e8 7c fe ff ff       	call   801216 <printfmt>
  80139a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013a0:	e9 b4 fe ff ff       	jmp    801259 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a8:	8d 50 04             	lea    0x4(%eax),%edx
  8013ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ae:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013b0:	85 ff                	test   %edi,%edi
  8013b2:	b8 f8 1e 80 00       	mov    $0x801ef8,%eax
  8013b7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013be:	0f 8e 94 00 00 00    	jle    801458 <vprintfmt+0x225>
  8013c4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013c8:	0f 84 98 00 00 00    	je     801466 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ce:	83 ec 08             	sub    $0x8,%esp
  8013d1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013d4:	57                   	push   %edi
  8013d5:	e8 86 02 00 00       	call   801660 <strnlen>
  8013da:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013dd:	29 c1                	sub    %eax,%ecx
  8013df:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013e2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013e5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013ef:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f1:	eb 0f                	jmp    801402 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	53                   	push   %ebx
  8013f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8013fa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013fc:	83 ef 01             	sub    $0x1,%edi
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	85 ff                	test   %edi,%edi
  801404:	7f ed                	jg     8013f3 <vprintfmt+0x1c0>
  801406:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801409:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80140c:	85 c9                	test   %ecx,%ecx
  80140e:	b8 00 00 00 00       	mov    $0x0,%eax
  801413:	0f 49 c1             	cmovns %ecx,%eax
  801416:	29 c1                	sub    %eax,%ecx
  801418:	89 75 08             	mov    %esi,0x8(%ebp)
  80141b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80141e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801421:	89 cb                	mov    %ecx,%ebx
  801423:	eb 4d                	jmp    801472 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801425:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801429:	74 1b                	je     801446 <vprintfmt+0x213>
  80142b:	0f be c0             	movsbl %al,%eax
  80142e:	83 e8 20             	sub    $0x20,%eax
  801431:	83 f8 5e             	cmp    $0x5e,%eax
  801434:	76 10                	jbe    801446 <vprintfmt+0x213>
					putch('?', putdat);
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	ff 75 0c             	pushl  0xc(%ebp)
  80143c:	6a 3f                	push   $0x3f
  80143e:	ff 55 08             	call   *0x8(%ebp)
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	eb 0d                	jmp    801453 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	ff 75 0c             	pushl  0xc(%ebp)
  80144c:	52                   	push   %edx
  80144d:	ff 55 08             	call   *0x8(%ebp)
  801450:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801453:	83 eb 01             	sub    $0x1,%ebx
  801456:	eb 1a                	jmp    801472 <vprintfmt+0x23f>
  801458:	89 75 08             	mov    %esi,0x8(%ebp)
  80145b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80145e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801461:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801464:	eb 0c                	jmp    801472 <vprintfmt+0x23f>
  801466:	89 75 08             	mov    %esi,0x8(%ebp)
  801469:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80146c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80146f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801472:	83 c7 01             	add    $0x1,%edi
  801475:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801479:	0f be d0             	movsbl %al,%edx
  80147c:	85 d2                	test   %edx,%edx
  80147e:	74 23                	je     8014a3 <vprintfmt+0x270>
  801480:	85 f6                	test   %esi,%esi
  801482:	78 a1                	js     801425 <vprintfmt+0x1f2>
  801484:	83 ee 01             	sub    $0x1,%esi
  801487:	79 9c                	jns    801425 <vprintfmt+0x1f2>
  801489:	89 df                	mov    %ebx,%edi
  80148b:	8b 75 08             	mov    0x8(%ebp),%esi
  80148e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801491:	eb 18                	jmp    8014ab <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	53                   	push   %ebx
  801497:	6a 20                	push   $0x20
  801499:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80149b:	83 ef 01             	sub    $0x1,%edi
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	eb 08                	jmp    8014ab <vprintfmt+0x278>
  8014a3:	89 df                	mov    %ebx,%edi
  8014a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ab:	85 ff                	test   %edi,%edi
  8014ad:	7f e4                	jg     801493 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014b2:	e9 a2 fd ff ff       	jmp    801259 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014b7:	83 fa 01             	cmp    $0x1,%edx
  8014ba:	7e 16                	jle    8014d2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bf:	8d 50 08             	lea    0x8(%eax),%edx
  8014c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c5:	8b 50 04             	mov    0x4(%eax),%edx
  8014c8:	8b 00                	mov    (%eax),%eax
  8014ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014d0:	eb 32                	jmp    801504 <vprintfmt+0x2d1>
	else if (lflag)
  8014d2:	85 d2                	test   %edx,%edx
  8014d4:	74 18                	je     8014ee <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d9:	8d 50 04             	lea    0x4(%eax),%edx
  8014dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8014df:	8b 00                	mov    (%eax),%eax
  8014e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e4:	89 c1                	mov    %eax,%ecx
  8014e6:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ec:	eb 16                	jmp    801504 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f1:	8d 50 04             	lea    0x4(%eax),%edx
  8014f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f7:	8b 00                	mov    (%eax),%eax
  8014f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014fc:	89 c1                	mov    %eax,%ecx
  8014fe:	c1 f9 1f             	sar    $0x1f,%ecx
  801501:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801504:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801507:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80150a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80150f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801513:	79 74                	jns    801589 <vprintfmt+0x356>
				putch('-', putdat);
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	53                   	push   %ebx
  801519:	6a 2d                	push   $0x2d
  80151b:	ff d6                	call   *%esi
				num = -(long long) num;
  80151d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801520:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801523:	f7 d8                	neg    %eax
  801525:	83 d2 00             	adc    $0x0,%edx
  801528:	f7 da                	neg    %edx
  80152a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80152d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801532:	eb 55                	jmp    801589 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801534:	8d 45 14             	lea    0x14(%ebp),%eax
  801537:	e8 83 fc ff ff       	call   8011bf <getuint>
			base = 10;
  80153c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801541:	eb 46                	jmp    801589 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801543:	8d 45 14             	lea    0x14(%ebp),%eax
  801546:	e8 74 fc ff ff       	call   8011bf <getuint>
			base = 8;
  80154b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801550:	eb 37                	jmp    801589 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	53                   	push   %ebx
  801556:	6a 30                	push   $0x30
  801558:	ff d6                	call   *%esi
			putch('x', putdat);
  80155a:	83 c4 08             	add    $0x8,%esp
  80155d:	53                   	push   %ebx
  80155e:	6a 78                	push   $0x78
  801560:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801562:	8b 45 14             	mov    0x14(%ebp),%eax
  801565:	8d 50 04             	lea    0x4(%eax),%edx
  801568:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80156b:	8b 00                	mov    (%eax),%eax
  80156d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801572:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801575:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80157a:	eb 0d                	jmp    801589 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80157c:	8d 45 14             	lea    0x14(%ebp),%eax
  80157f:	e8 3b fc ff ff       	call   8011bf <getuint>
			base = 16;
  801584:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801589:	83 ec 0c             	sub    $0xc,%esp
  80158c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801590:	57                   	push   %edi
  801591:	ff 75 e0             	pushl  -0x20(%ebp)
  801594:	51                   	push   %ecx
  801595:	52                   	push   %edx
  801596:	50                   	push   %eax
  801597:	89 da                	mov    %ebx,%edx
  801599:	89 f0                	mov    %esi,%eax
  80159b:	e8 70 fb ff ff       	call   801110 <printnum>
			break;
  8015a0:	83 c4 20             	add    $0x20,%esp
  8015a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015a6:	e9 ae fc ff ff       	jmp    801259 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	53                   	push   %ebx
  8015af:	51                   	push   %ecx
  8015b0:	ff d6                	call   *%esi
			break;
  8015b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015b8:	e9 9c fc ff ff       	jmp    801259 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	53                   	push   %ebx
  8015c1:	6a 25                	push   $0x25
  8015c3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	eb 03                	jmp    8015cd <vprintfmt+0x39a>
  8015ca:	83 ef 01             	sub    $0x1,%edi
  8015cd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015d1:	75 f7                	jne    8015ca <vprintfmt+0x397>
  8015d3:	e9 81 fc ff ff       	jmp    801259 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5e                   	pop    %esi
  8015dd:	5f                   	pop    %edi
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    

008015e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	83 ec 18             	sub    $0x18,%esp
  8015e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	74 26                	je     801627 <vsnprintf+0x47>
  801601:	85 d2                	test   %edx,%edx
  801603:	7e 22                	jle    801627 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801605:	ff 75 14             	pushl  0x14(%ebp)
  801608:	ff 75 10             	pushl  0x10(%ebp)
  80160b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	68 f9 11 80 00       	push   $0x8011f9
  801614:	e8 1a fc ff ff       	call   801233 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801619:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80161c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80161f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	eb 05                	jmp    80162c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801627:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801634:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801637:	50                   	push   %eax
  801638:	ff 75 10             	pushl  0x10(%ebp)
  80163b:	ff 75 0c             	pushl  0xc(%ebp)
  80163e:	ff 75 08             	pushl  0x8(%ebp)
  801641:	e8 9a ff ff ff       	call   8015e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80164e:	b8 00 00 00 00       	mov    $0x0,%eax
  801653:	eb 03                	jmp    801658 <strlen+0x10>
		n++;
  801655:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801658:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80165c:	75 f7                	jne    801655 <strlen+0xd>
		n++;
	return n;
}
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    

00801660 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801666:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801669:	ba 00 00 00 00       	mov    $0x0,%edx
  80166e:	eb 03                	jmp    801673 <strnlen+0x13>
		n++;
  801670:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801673:	39 c2                	cmp    %eax,%edx
  801675:	74 08                	je     80167f <strnlen+0x1f>
  801677:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80167b:	75 f3                	jne    801670 <strnlen+0x10>
  80167d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	53                   	push   %ebx
  801685:	8b 45 08             	mov    0x8(%ebp),%eax
  801688:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80168b:	89 c2                	mov    %eax,%edx
  80168d:	83 c2 01             	add    $0x1,%edx
  801690:	83 c1 01             	add    $0x1,%ecx
  801693:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801697:	88 5a ff             	mov    %bl,-0x1(%edx)
  80169a:	84 db                	test   %bl,%bl
  80169c:	75 ef                	jne    80168d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80169e:	5b                   	pop    %ebx
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	53                   	push   %ebx
  8016a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016a8:	53                   	push   %ebx
  8016a9:	e8 9a ff ff ff       	call   801648 <strlen>
  8016ae:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016b1:	ff 75 0c             	pushl  0xc(%ebp)
  8016b4:	01 d8                	add    %ebx,%eax
  8016b6:	50                   	push   %eax
  8016b7:	e8 c5 ff ff ff       	call   801681 <strcpy>
	return dst;
}
  8016bc:	89 d8                	mov    %ebx,%eax
  8016be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
  8016c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ce:	89 f3                	mov    %esi,%ebx
  8016d0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016d3:	89 f2                	mov    %esi,%edx
  8016d5:	eb 0f                	jmp    8016e6 <strncpy+0x23>
		*dst++ = *src;
  8016d7:	83 c2 01             	add    $0x1,%edx
  8016da:	0f b6 01             	movzbl (%ecx),%eax
  8016dd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016e0:	80 39 01             	cmpb   $0x1,(%ecx)
  8016e3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016e6:	39 da                	cmp    %ebx,%edx
  8016e8:	75 ed                	jne    8016d7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016ea:	89 f0                	mov    %esi,%eax
  8016ec:	5b                   	pop    %ebx
  8016ed:	5e                   	pop    %esi
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fb:	8b 55 10             	mov    0x10(%ebp),%edx
  8016fe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801700:	85 d2                	test   %edx,%edx
  801702:	74 21                	je     801725 <strlcpy+0x35>
  801704:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801708:	89 f2                	mov    %esi,%edx
  80170a:	eb 09                	jmp    801715 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80170c:	83 c2 01             	add    $0x1,%edx
  80170f:	83 c1 01             	add    $0x1,%ecx
  801712:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801715:	39 c2                	cmp    %eax,%edx
  801717:	74 09                	je     801722 <strlcpy+0x32>
  801719:	0f b6 19             	movzbl (%ecx),%ebx
  80171c:	84 db                	test   %bl,%bl
  80171e:	75 ec                	jne    80170c <strlcpy+0x1c>
  801720:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801722:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801725:	29 f0                	sub    %esi,%eax
}
  801727:	5b                   	pop    %ebx
  801728:	5e                   	pop    %esi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801731:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801734:	eb 06                	jmp    80173c <strcmp+0x11>
		p++, q++;
  801736:	83 c1 01             	add    $0x1,%ecx
  801739:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80173c:	0f b6 01             	movzbl (%ecx),%eax
  80173f:	84 c0                	test   %al,%al
  801741:	74 04                	je     801747 <strcmp+0x1c>
  801743:	3a 02                	cmp    (%edx),%al
  801745:	74 ef                	je     801736 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801747:	0f b6 c0             	movzbl %al,%eax
  80174a:	0f b6 12             	movzbl (%edx),%edx
  80174d:	29 d0                	sub    %edx,%eax
}
  80174f:	5d                   	pop    %ebp
  801750:	c3                   	ret    

00801751 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	53                   	push   %ebx
  801755:	8b 45 08             	mov    0x8(%ebp),%eax
  801758:	8b 55 0c             	mov    0xc(%ebp),%edx
  80175b:	89 c3                	mov    %eax,%ebx
  80175d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801760:	eb 06                	jmp    801768 <strncmp+0x17>
		n--, p++, q++;
  801762:	83 c0 01             	add    $0x1,%eax
  801765:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801768:	39 d8                	cmp    %ebx,%eax
  80176a:	74 15                	je     801781 <strncmp+0x30>
  80176c:	0f b6 08             	movzbl (%eax),%ecx
  80176f:	84 c9                	test   %cl,%cl
  801771:	74 04                	je     801777 <strncmp+0x26>
  801773:	3a 0a                	cmp    (%edx),%cl
  801775:	74 eb                	je     801762 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801777:	0f b6 00             	movzbl (%eax),%eax
  80177a:	0f b6 12             	movzbl (%edx),%edx
  80177d:	29 d0                	sub    %edx,%eax
  80177f:	eb 05                	jmp    801786 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801781:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801786:	5b                   	pop    %ebx
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801793:	eb 07                	jmp    80179c <strchr+0x13>
		if (*s == c)
  801795:	38 ca                	cmp    %cl,%dl
  801797:	74 0f                	je     8017a8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801799:	83 c0 01             	add    $0x1,%eax
  80179c:	0f b6 10             	movzbl (%eax),%edx
  80179f:	84 d2                	test   %dl,%dl
  8017a1:	75 f2                	jne    801795 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017b4:	eb 03                	jmp    8017b9 <strfind+0xf>
  8017b6:	83 c0 01             	add    $0x1,%eax
  8017b9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017bc:	38 ca                	cmp    %cl,%dl
  8017be:	74 04                	je     8017c4 <strfind+0x1a>
  8017c0:	84 d2                	test   %dl,%dl
  8017c2:	75 f2                	jne    8017b6 <strfind+0xc>
			break;
	return (char *) s;
}
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	57                   	push   %edi
  8017ca:	56                   	push   %esi
  8017cb:	53                   	push   %ebx
  8017cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017d2:	85 c9                	test   %ecx,%ecx
  8017d4:	74 36                	je     80180c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017d6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017dc:	75 28                	jne    801806 <memset+0x40>
  8017de:	f6 c1 03             	test   $0x3,%cl
  8017e1:	75 23                	jne    801806 <memset+0x40>
		c &= 0xFF;
  8017e3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017e7:	89 d3                	mov    %edx,%ebx
  8017e9:	c1 e3 08             	shl    $0x8,%ebx
  8017ec:	89 d6                	mov    %edx,%esi
  8017ee:	c1 e6 18             	shl    $0x18,%esi
  8017f1:	89 d0                	mov    %edx,%eax
  8017f3:	c1 e0 10             	shl    $0x10,%eax
  8017f6:	09 f0                	or     %esi,%eax
  8017f8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8017fa:	89 d8                	mov    %ebx,%eax
  8017fc:	09 d0                	or     %edx,%eax
  8017fe:	c1 e9 02             	shr    $0x2,%ecx
  801801:	fc                   	cld    
  801802:	f3 ab                	rep stos %eax,%es:(%edi)
  801804:	eb 06                	jmp    80180c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801806:	8b 45 0c             	mov    0xc(%ebp),%eax
  801809:	fc                   	cld    
  80180a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80180c:	89 f8                	mov    %edi,%eax
  80180e:	5b                   	pop    %ebx
  80180f:	5e                   	pop    %esi
  801810:	5f                   	pop    %edi
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	57                   	push   %edi
  801817:	56                   	push   %esi
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80181e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801821:	39 c6                	cmp    %eax,%esi
  801823:	73 35                	jae    80185a <memmove+0x47>
  801825:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801828:	39 d0                	cmp    %edx,%eax
  80182a:	73 2e                	jae    80185a <memmove+0x47>
		s += n;
		d += n;
  80182c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80182f:	89 d6                	mov    %edx,%esi
  801831:	09 fe                	or     %edi,%esi
  801833:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801839:	75 13                	jne    80184e <memmove+0x3b>
  80183b:	f6 c1 03             	test   $0x3,%cl
  80183e:	75 0e                	jne    80184e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801840:	83 ef 04             	sub    $0x4,%edi
  801843:	8d 72 fc             	lea    -0x4(%edx),%esi
  801846:	c1 e9 02             	shr    $0x2,%ecx
  801849:	fd                   	std    
  80184a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80184c:	eb 09                	jmp    801857 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80184e:	83 ef 01             	sub    $0x1,%edi
  801851:	8d 72 ff             	lea    -0x1(%edx),%esi
  801854:	fd                   	std    
  801855:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801857:	fc                   	cld    
  801858:	eb 1d                	jmp    801877 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185a:	89 f2                	mov    %esi,%edx
  80185c:	09 c2                	or     %eax,%edx
  80185e:	f6 c2 03             	test   $0x3,%dl
  801861:	75 0f                	jne    801872 <memmove+0x5f>
  801863:	f6 c1 03             	test   $0x3,%cl
  801866:	75 0a                	jne    801872 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801868:	c1 e9 02             	shr    $0x2,%ecx
  80186b:	89 c7                	mov    %eax,%edi
  80186d:	fc                   	cld    
  80186e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801870:	eb 05                	jmp    801877 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801872:	89 c7                	mov    %eax,%edi
  801874:	fc                   	cld    
  801875:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801877:	5e                   	pop    %esi
  801878:	5f                   	pop    %edi
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80187e:	ff 75 10             	pushl  0x10(%ebp)
  801881:	ff 75 0c             	pushl  0xc(%ebp)
  801884:	ff 75 08             	pushl  0x8(%ebp)
  801887:	e8 87 ff ff ff       	call   801813 <memmove>
}
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	56                   	push   %esi
  801892:	53                   	push   %ebx
  801893:	8b 45 08             	mov    0x8(%ebp),%eax
  801896:	8b 55 0c             	mov    0xc(%ebp),%edx
  801899:	89 c6                	mov    %eax,%esi
  80189b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80189e:	eb 1a                	jmp    8018ba <memcmp+0x2c>
		if (*s1 != *s2)
  8018a0:	0f b6 08             	movzbl (%eax),%ecx
  8018a3:	0f b6 1a             	movzbl (%edx),%ebx
  8018a6:	38 d9                	cmp    %bl,%cl
  8018a8:	74 0a                	je     8018b4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018aa:	0f b6 c1             	movzbl %cl,%eax
  8018ad:	0f b6 db             	movzbl %bl,%ebx
  8018b0:	29 d8                	sub    %ebx,%eax
  8018b2:	eb 0f                	jmp    8018c3 <memcmp+0x35>
		s1++, s2++;
  8018b4:	83 c0 01             	add    $0x1,%eax
  8018b7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ba:	39 f0                	cmp    %esi,%eax
  8018bc:	75 e2                	jne    8018a0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	53                   	push   %ebx
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018ce:	89 c1                	mov    %eax,%ecx
  8018d0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018d3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018d7:	eb 0a                	jmp    8018e3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018d9:	0f b6 10             	movzbl (%eax),%edx
  8018dc:	39 da                	cmp    %ebx,%edx
  8018de:	74 07                	je     8018e7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018e0:	83 c0 01             	add    $0x1,%eax
  8018e3:	39 c8                	cmp    %ecx,%eax
  8018e5:	72 f2                	jb     8018d9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018e7:	5b                   	pop    %ebx
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    

008018ea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	57                   	push   %edi
  8018ee:	56                   	push   %esi
  8018ef:	53                   	push   %ebx
  8018f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018f6:	eb 03                	jmp    8018fb <strtol+0x11>
		s++;
  8018f8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018fb:	0f b6 01             	movzbl (%ecx),%eax
  8018fe:	3c 20                	cmp    $0x20,%al
  801900:	74 f6                	je     8018f8 <strtol+0xe>
  801902:	3c 09                	cmp    $0x9,%al
  801904:	74 f2                	je     8018f8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801906:	3c 2b                	cmp    $0x2b,%al
  801908:	75 0a                	jne    801914 <strtol+0x2a>
		s++;
  80190a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80190d:	bf 00 00 00 00       	mov    $0x0,%edi
  801912:	eb 11                	jmp    801925 <strtol+0x3b>
  801914:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801919:	3c 2d                	cmp    $0x2d,%al
  80191b:	75 08                	jne    801925 <strtol+0x3b>
		s++, neg = 1;
  80191d:	83 c1 01             	add    $0x1,%ecx
  801920:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801925:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80192b:	75 15                	jne    801942 <strtol+0x58>
  80192d:	80 39 30             	cmpb   $0x30,(%ecx)
  801930:	75 10                	jne    801942 <strtol+0x58>
  801932:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801936:	75 7c                	jne    8019b4 <strtol+0xca>
		s += 2, base = 16;
  801938:	83 c1 02             	add    $0x2,%ecx
  80193b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801940:	eb 16                	jmp    801958 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801942:	85 db                	test   %ebx,%ebx
  801944:	75 12                	jne    801958 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801946:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80194b:	80 39 30             	cmpb   $0x30,(%ecx)
  80194e:	75 08                	jne    801958 <strtol+0x6e>
		s++, base = 8;
  801950:	83 c1 01             	add    $0x1,%ecx
  801953:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801958:	b8 00 00 00 00       	mov    $0x0,%eax
  80195d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801960:	0f b6 11             	movzbl (%ecx),%edx
  801963:	8d 72 d0             	lea    -0x30(%edx),%esi
  801966:	89 f3                	mov    %esi,%ebx
  801968:	80 fb 09             	cmp    $0x9,%bl
  80196b:	77 08                	ja     801975 <strtol+0x8b>
			dig = *s - '0';
  80196d:	0f be d2             	movsbl %dl,%edx
  801970:	83 ea 30             	sub    $0x30,%edx
  801973:	eb 22                	jmp    801997 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801975:	8d 72 9f             	lea    -0x61(%edx),%esi
  801978:	89 f3                	mov    %esi,%ebx
  80197a:	80 fb 19             	cmp    $0x19,%bl
  80197d:	77 08                	ja     801987 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80197f:	0f be d2             	movsbl %dl,%edx
  801982:	83 ea 57             	sub    $0x57,%edx
  801985:	eb 10                	jmp    801997 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801987:	8d 72 bf             	lea    -0x41(%edx),%esi
  80198a:	89 f3                	mov    %esi,%ebx
  80198c:	80 fb 19             	cmp    $0x19,%bl
  80198f:	77 16                	ja     8019a7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801991:	0f be d2             	movsbl %dl,%edx
  801994:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801997:	3b 55 10             	cmp    0x10(%ebp),%edx
  80199a:	7d 0b                	jge    8019a7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80199c:	83 c1 01             	add    $0x1,%ecx
  80199f:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019a3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019a5:	eb b9                	jmp    801960 <strtol+0x76>

	if (endptr)
  8019a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019ab:	74 0d                	je     8019ba <strtol+0xd0>
		*endptr = (char *) s;
  8019ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019b0:	89 0e                	mov    %ecx,(%esi)
  8019b2:	eb 06                	jmp    8019ba <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019b4:	85 db                	test   %ebx,%ebx
  8019b6:	74 98                	je     801950 <strtol+0x66>
  8019b8:	eb 9e                	jmp    801958 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019ba:	89 c2                	mov    %eax,%edx
  8019bc:	f7 da                	neg    %edx
  8019be:	85 ff                	test   %edi,%edi
  8019c0:	0f 45 c2             	cmovne %edx,%eax
}
  8019c3:	5b                   	pop    %ebx
  8019c4:	5e                   	pop    %esi
  8019c5:	5f                   	pop    %edi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	56                   	push   %esi
  8019cc:	53                   	push   %ebx
  8019cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019d6:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019d8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019dd:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	50                   	push   %eax
  8019e4:	e8 1c e9 ff ff       	call   800305 <sys_ipc_recv>

	if (from_env_store != NULL)
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	85 f6                	test   %esi,%esi
  8019ee:	74 14                	je     801a04 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 09                	js     801a02 <ipc_recv+0x3a>
  8019f9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019ff:	8b 52 74             	mov    0x74(%edx),%edx
  801a02:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a04:	85 db                	test   %ebx,%ebx
  801a06:	74 14                	je     801a1c <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a08:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	78 09                	js     801a1a <ipc_recv+0x52>
  801a11:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a17:	8b 52 78             	mov    0x78(%edx),%edx
  801a1a:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	78 08                	js     801a28 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a20:	a1 04 40 80 00       	mov    0x804004,%eax
  801a25:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	57                   	push   %edi
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a41:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a43:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a48:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a4b:	ff 75 14             	pushl  0x14(%ebp)
  801a4e:	53                   	push   %ebx
  801a4f:	56                   	push   %esi
  801a50:	57                   	push   %edi
  801a51:	e8 8c e8 ff ff       	call   8002e2 <sys_ipc_try_send>

		if (err < 0) {
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	79 1e                	jns    801a7b <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a5d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a60:	75 07                	jne    801a69 <ipc_send+0x3a>
				sys_yield();
  801a62:	e8 cf e6 ff ff       	call   800136 <sys_yield>
  801a67:	eb e2                	jmp    801a4b <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a69:	50                   	push   %eax
  801a6a:	68 e0 21 80 00       	push   $0x8021e0
  801a6f:	6a 49                	push   $0x49
  801a71:	68 ed 21 80 00       	push   $0x8021ed
  801a76:	e8 a8 f5 ff ff       	call   801023 <_panic>
		}

	} while (err < 0);

}
  801a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5f                   	pop    %edi
  801a81:	5d                   	pop    %ebp
  801a82:	c3                   	ret    

00801a83 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a89:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a8e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a91:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a97:	8b 52 50             	mov    0x50(%edx),%edx
  801a9a:	39 ca                	cmp    %ecx,%edx
  801a9c:	75 0d                	jne    801aab <ipc_find_env+0x28>
			return envs[i].env_id;
  801a9e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aa1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aa6:	8b 40 48             	mov    0x48(%eax),%eax
  801aa9:	eb 0f                	jmp    801aba <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aab:	83 c0 01             	add    $0x1,%eax
  801aae:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ab3:	75 d9                	jne    801a8e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ab5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ac2:	89 d0                	mov    %edx,%eax
  801ac4:	c1 e8 16             	shr    $0x16,%eax
  801ac7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ace:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad3:	f6 c1 01             	test   $0x1,%cl
  801ad6:	74 1d                	je     801af5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ad8:	c1 ea 0c             	shr    $0xc,%edx
  801adb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ae2:	f6 c2 01             	test   $0x1,%dl
  801ae5:	74 0e                	je     801af5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ae7:	c1 ea 0c             	shr    $0xc,%edx
  801aea:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801af1:	ef 
  801af2:	0f b7 c0             	movzwl %ax,%eax
}
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    
  801af7:	66 90                	xchg   %ax,%ax
  801af9:	66 90                	xchg   %ax,%ax
  801afb:	66 90                	xchg   %ax,%ax
  801afd:	66 90                	xchg   %ax,%ax
  801aff:	90                   	nop

00801b00 <__udivdi3>:
  801b00:	55                   	push   %ebp
  801b01:	57                   	push   %edi
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 1c             	sub    $0x1c,%esp
  801b07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b17:	85 f6                	test   %esi,%esi
  801b19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b1d:	89 ca                	mov    %ecx,%edx
  801b1f:	89 f8                	mov    %edi,%eax
  801b21:	75 3d                	jne    801b60 <__udivdi3+0x60>
  801b23:	39 cf                	cmp    %ecx,%edi
  801b25:	0f 87 c5 00 00 00    	ja     801bf0 <__udivdi3+0xf0>
  801b2b:	85 ff                	test   %edi,%edi
  801b2d:	89 fd                	mov    %edi,%ebp
  801b2f:	75 0b                	jne    801b3c <__udivdi3+0x3c>
  801b31:	b8 01 00 00 00       	mov    $0x1,%eax
  801b36:	31 d2                	xor    %edx,%edx
  801b38:	f7 f7                	div    %edi
  801b3a:	89 c5                	mov    %eax,%ebp
  801b3c:	89 c8                	mov    %ecx,%eax
  801b3e:	31 d2                	xor    %edx,%edx
  801b40:	f7 f5                	div    %ebp
  801b42:	89 c1                	mov    %eax,%ecx
  801b44:	89 d8                	mov    %ebx,%eax
  801b46:	89 cf                	mov    %ecx,%edi
  801b48:	f7 f5                	div    %ebp
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	89 d8                	mov    %ebx,%eax
  801b4e:	89 fa                	mov    %edi,%edx
  801b50:	83 c4 1c             	add    $0x1c,%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
  801b58:	90                   	nop
  801b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b60:	39 ce                	cmp    %ecx,%esi
  801b62:	77 74                	ja     801bd8 <__udivdi3+0xd8>
  801b64:	0f bd fe             	bsr    %esi,%edi
  801b67:	83 f7 1f             	xor    $0x1f,%edi
  801b6a:	0f 84 98 00 00 00    	je     801c08 <__udivdi3+0x108>
  801b70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b75:	89 f9                	mov    %edi,%ecx
  801b77:	89 c5                	mov    %eax,%ebp
  801b79:	29 fb                	sub    %edi,%ebx
  801b7b:	d3 e6                	shl    %cl,%esi
  801b7d:	89 d9                	mov    %ebx,%ecx
  801b7f:	d3 ed                	shr    %cl,%ebp
  801b81:	89 f9                	mov    %edi,%ecx
  801b83:	d3 e0                	shl    %cl,%eax
  801b85:	09 ee                	or     %ebp,%esi
  801b87:	89 d9                	mov    %ebx,%ecx
  801b89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b8d:	89 d5                	mov    %edx,%ebp
  801b8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b93:	d3 ed                	shr    %cl,%ebp
  801b95:	89 f9                	mov    %edi,%ecx
  801b97:	d3 e2                	shl    %cl,%edx
  801b99:	89 d9                	mov    %ebx,%ecx
  801b9b:	d3 e8                	shr    %cl,%eax
  801b9d:	09 c2                	or     %eax,%edx
  801b9f:	89 d0                	mov    %edx,%eax
  801ba1:	89 ea                	mov    %ebp,%edx
  801ba3:	f7 f6                	div    %esi
  801ba5:	89 d5                	mov    %edx,%ebp
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	f7 64 24 0c          	mull   0xc(%esp)
  801bad:	39 d5                	cmp    %edx,%ebp
  801baf:	72 10                	jb     801bc1 <__udivdi3+0xc1>
  801bb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	d3 e6                	shl    %cl,%esi
  801bb9:	39 c6                	cmp    %eax,%esi
  801bbb:	73 07                	jae    801bc4 <__udivdi3+0xc4>
  801bbd:	39 d5                	cmp    %edx,%ebp
  801bbf:	75 03                	jne    801bc4 <__udivdi3+0xc4>
  801bc1:	83 eb 01             	sub    $0x1,%ebx
  801bc4:	31 ff                	xor    %edi,%edi
  801bc6:	89 d8                	mov    %ebx,%eax
  801bc8:	89 fa                	mov    %edi,%edx
  801bca:	83 c4 1c             	add    $0x1c,%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    
  801bd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bd8:	31 ff                	xor    %edi,%edi
  801bda:	31 db                	xor    %ebx,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	89 d8                	mov    %ebx,%eax
  801bf2:	f7 f7                	div    %edi
  801bf4:	31 ff                	xor    %edi,%edi
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	89 d8                	mov    %ebx,%eax
  801bfa:	89 fa                	mov    %edi,%edx
  801bfc:	83 c4 1c             	add    $0x1c,%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5f                   	pop    %edi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    
  801c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c08:	39 ce                	cmp    %ecx,%esi
  801c0a:	72 0c                	jb     801c18 <__udivdi3+0x118>
  801c0c:	31 db                	xor    %ebx,%ebx
  801c0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c12:	0f 87 34 ff ff ff    	ja     801b4c <__udivdi3+0x4c>
  801c18:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c1d:	e9 2a ff ff ff       	jmp    801b4c <__udivdi3+0x4c>
  801c22:	66 90                	xchg   %ax,%ax
  801c24:	66 90                	xchg   %ax,%ax
  801c26:	66 90                	xchg   %ax,%ax
  801c28:	66 90                	xchg   %ax,%ax
  801c2a:	66 90                	xchg   %ax,%ax
  801c2c:	66 90                	xchg   %ax,%ax
  801c2e:	66 90                	xchg   %ax,%ax

00801c30 <__umoddi3>:
  801c30:	55                   	push   %ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 1c             	sub    $0x1c,%esp
  801c37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c47:	85 d2                	test   %edx,%edx
  801c49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c51:	89 f3                	mov    %esi,%ebx
  801c53:	89 3c 24             	mov    %edi,(%esp)
  801c56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c5a:	75 1c                	jne    801c78 <__umoddi3+0x48>
  801c5c:	39 f7                	cmp    %esi,%edi
  801c5e:	76 50                	jbe    801cb0 <__umoddi3+0x80>
  801c60:	89 c8                	mov    %ecx,%eax
  801c62:	89 f2                	mov    %esi,%edx
  801c64:	f7 f7                	div    %edi
  801c66:	89 d0                	mov    %edx,%eax
  801c68:	31 d2                	xor    %edx,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	39 f2                	cmp    %esi,%edx
  801c7a:	89 d0                	mov    %edx,%eax
  801c7c:	77 52                	ja     801cd0 <__umoddi3+0xa0>
  801c7e:	0f bd ea             	bsr    %edx,%ebp
  801c81:	83 f5 1f             	xor    $0x1f,%ebp
  801c84:	75 5a                	jne    801ce0 <__umoddi3+0xb0>
  801c86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c8a:	0f 82 e0 00 00 00    	jb     801d70 <__umoddi3+0x140>
  801c90:	39 0c 24             	cmp    %ecx,(%esp)
  801c93:	0f 86 d7 00 00 00    	jbe    801d70 <__umoddi3+0x140>
  801c99:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ca1:	83 c4 1c             	add    $0x1c,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5f                   	pop    %edi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	85 ff                	test   %edi,%edi
  801cb2:	89 fd                	mov    %edi,%ebp
  801cb4:	75 0b                	jne    801cc1 <__umoddi3+0x91>
  801cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	f7 f7                	div    %edi
  801cbf:	89 c5                	mov    %eax,%ebp
  801cc1:	89 f0                	mov    %esi,%eax
  801cc3:	31 d2                	xor    %edx,%edx
  801cc5:	f7 f5                	div    %ebp
  801cc7:	89 c8                	mov    %ecx,%eax
  801cc9:	f7 f5                	div    %ebp
  801ccb:	89 d0                	mov    %edx,%eax
  801ccd:	eb 99                	jmp    801c68 <__umoddi3+0x38>
  801ccf:	90                   	nop
  801cd0:	89 c8                	mov    %ecx,%eax
  801cd2:	89 f2                	mov    %esi,%edx
  801cd4:	83 c4 1c             	add    $0x1c,%esp
  801cd7:	5b                   	pop    %ebx
  801cd8:	5e                   	pop    %esi
  801cd9:	5f                   	pop    %edi
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    
  801cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	8b 34 24             	mov    (%esp),%esi
  801ce3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ce8:	89 e9                	mov    %ebp,%ecx
  801cea:	29 ef                	sub    %ebp,%edi
  801cec:	d3 e0                	shl    %cl,%eax
  801cee:	89 f9                	mov    %edi,%ecx
  801cf0:	89 f2                	mov    %esi,%edx
  801cf2:	d3 ea                	shr    %cl,%edx
  801cf4:	89 e9                	mov    %ebp,%ecx
  801cf6:	09 c2                	or     %eax,%edx
  801cf8:	89 d8                	mov    %ebx,%eax
  801cfa:	89 14 24             	mov    %edx,(%esp)
  801cfd:	89 f2                	mov    %esi,%edx
  801cff:	d3 e2                	shl    %cl,%edx
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d0b:	d3 e8                	shr    %cl,%eax
  801d0d:	89 e9                	mov    %ebp,%ecx
  801d0f:	89 c6                	mov    %eax,%esi
  801d11:	d3 e3                	shl    %cl,%ebx
  801d13:	89 f9                	mov    %edi,%ecx
  801d15:	89 d0                	mov    %edx,%eax
  801d17:	d3 e8                	shr    %cl,%eax
  801d19:	89 e9                	mov    %ebp,%ecx
  801d1b:	09 d8                	or     %ebx,%eax
  801d1d:	89 d3                	mov    %edx,%ebx
  801d1f:	89 f2                	mov    %esi,%edx
  801d21:	f7 34 24             	divl   (%esp)
  801d24:	89 d6                	mov    %edx,%esi
  801d26:	d3 e3                	shl    %cl,%ebx
  801d28:	f7 64 24 04          	mull   0x4(%esp)
  801d2c:	39 d6                	cmp    %edx,%esi
  801d2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d32:	89 d1                	mov    %edx,%ecx
  801d34:	89 c3                	mov    %eax,%ebx
  801d36:	72 08                	jb     801d40 <__umoddi3+0x110>
  801d38:	75 11                	jne    801d4b <__umoddi3+0x11b>
  801d3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d3e:	73 0b                	jae    801d4b <__umoddi3+0x11b>
  801d40:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d44:	1b 14 24             	sbb    (%esp),%edx
  801d47:	89 d1                	mov    %edx,%ecx
  801d49:	89 c3                	mov    %eax,%ebx
  801d4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d4f:	29 da                	sub    %ebx,%edx
  801d51:	19 ce                	sbb    %ecx,%esi
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 f0                	mov    %esi,%eax
  801d57:	d3 e0                	shl    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	d3 ea                	shr    %cl,%edx
  801d5d:	89 e9                	mov    %ebp,%ecx
  801d5f:	d3 ee                	shr    %cl,%esi
  801d61:	09 d0                	or     %edx,%eax
  801d63:	89 f2                	mov    %esi,%edx
  801d65:	83 c4 1c             	add    $0x1c,%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    
  801d6d:	8d 76 00             	lea    0x0(%esi),%esi
  801d70:	29 f9                	sub    %edi,%ecx
  801d72:	19 d6                	sbb    %edx,%esi
  801d74:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d7c:	e9 18 ff ff ff       	jmp    801c99 <__umoddi3+0x69>
