
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
  8000fe:	68 8a 1d 80 00       	push   $0x801d8a
  800103:	6a 23                	push   $0x23
  800105:	68 a7 1d 80 00       	push   $0x801da7
  80010a:	e8 f5 0e 00 00       	call   801004 <_panic>

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
  80017f:	68 8a 1d 80 00       	push   $0x801d8a
  800184:	6a 23                	push   $0x23
  800186:	68 a7 1d 80 00       	push   $0x801da7
  80018b:	e8 74 0e 00 00       	call   801004 <_panic>

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
  8001c1:	68 8a 1d 80 00       	push   $0x801d8a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 a7 1d 80 00       	push   $0x801da7
  8001cd:	e8 32 0e 00 00       	call   801004 <_panic>

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
  800203:	68 8a 1d 80 00       	push   $0x801d8a
  800208:	6a 23                	push   $0x23
  80020a:	68 a7 1d 80 00       	push   $0x801da7
  80020f:	e8 f0 0d 00 00       	call   801004 <_panic>

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
  800245:	68 8a 1d 80 00       	push   $0x801d8a
  80024a:	6a 23                	push   $0x23
  80024c:	68 a7 1d 80 00       	push   $0x801da7
  800251:	e8 ae 0d 00 00       	call   801004 <_panic>

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
  800287:	68 8a 1d 80 00       	push   $0x801d8a
  80028c:	6a 23                	push   $0x23
  80028e:	68 a7 1d 80 00       	push   $0x801da7
  800293:	e8 6c 0d 00 00       	call   801004 <_panic>

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
  8002c9:	68 8a 1d 80 00       	push   $0x801d8a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 a7 1d 80 00       	push   $0x801da7
  8002d5:	e8 2a 0d 00 00       	call   801004 <_panic>

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
  80032d:	68 8a 1d 80 00       	push   $0x801d8a
  800332:	6a 23                	push   $0x23
  800334:	68 a7 1d 80 00       	push   $0x801da7
  800339:	e8 c6 0c 00 00       	call   801004 <_panic>

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
  80041b:	ba 34 1e 80 00       	mov    $0x801e34,%edx
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
  800448:	68 b8 1d 80 00       	push   $0x801db8
  80044d:	e8 8b 0c 00 00       	call   8010dd <cprintf>
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
  800672:	68 f9 1d 80 00       	push   $0x801df9
  800677:	e8 61 0a 00 00       	call   8010dd <cprintf>
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
  800747:	68 15 1e 80 00       	push   $0x801e15
  80074c:	e8 8c 09 00 00       	call   8010dd <cprintf>
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
  8007fc:	68 d8 1d 80 00       	push   $0x801dd8
  800801:	e8 d7 08 00 00       	call   8010dd <cprintf>
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
  8008c5:	e8 b7 01 00 00       	call   800a81 <open>
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
  80090c:	e8 53 11 00 00       	call   801a64 <ipc_find_env>
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
  800927:	e8 e4 10 00 00       	call   801a10 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092c:	83 c4 0c             	add    $0xc,%esp
  80092f:	6a 00                	push   $0x0
  800931:	53                   	push   %ebx
  800932:	6a 00                	push   $0x0
  800934:	e8 70 10 00 00       	call   8019a9 <ipc_recv>
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
	panic("devfile_write not implemented");
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
  8009bd:	e8 a0 0c 00 00       	call   801662 <strcpy>
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
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009eb:	68 44 1e 80 00       	push   $0x801e44
  8009f0:	68 90 00 00 00       	push   $0x90
  8009f5:	68 62 1e 80 00       	push   $0x801e62
  8009fa:	e8 05 06 00 00       	call   801004 <_panic>

008009ff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a12:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a18:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a22:	e8 ce fe ff ff       	call   8008f5 <fsipc>
  800a27:	89 c3                	mov    %eax,%ebx
  800a29:	85 c0                	test   %eax,%eax
  800a2b:	78 4b                	js     800a78 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a2d:	39 c6                	cmp    %eax,%esi
  800a2f:	73 16                	jae    800a47 <devfile_read+0x48>
  800a31:	68 6d 1e 80 00       	push   $0x801e6d
  800a36:	68 74 1e 80 00       	push   $0x801e74
  800a3b:	6a 7c                	push   $0x7c
  800a3d:	68 62 1e 80 00       	push   $0x801e62
  800a42:	e8 bd 05 00 00       	call   801004 <_panic>
	assert(r <= PGSIZE);
  800a47:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4c:	7e 16                	jle    800a64 <devfile_read+0x65>
  800a4e:	68 89 1e 80 00       	push   $0x801e89
  800a53:	68 74 1e 80 00       	push   $0x801e74
  800a58:	6a 7d                	push   $0x7d
  800a5a:	68 62 1e 80 00       	push   $0x801e62
  800a5f:	e8 a0 05 00 00       	call   801004 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a64:	83 ec 04             	sub    $0x4,%esp
  800a67:	50                   	push   %eax
  800a68:	68 00 50 80 00       	push   $0x805000
  800a6d:	ff 75 0c             	pushl  0xc(%ebp)
  800a70:	e8 7f 0d 00 00       	call   8017f4 <memmove>
	return r;
  800a75:	83 c4 10             	add    $0x10,%esp
}
  800a78:	89 d8                	mov    %ebx,%eax
  800a7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	83 ec 20             	sub    $0x20,%esp
  800a88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a8b:	53                   	push   %ebx
  800a8c:	e8 98 0b 00 00       	call   801629 <strlen>
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a99:	7f 67                	jg     800b02 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a9b:	83 ec 0c             	sub    $0xc,%esp
  800a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa1:	50                   	push   %eax
  800aa2:	e8 c6 f8 ff ff       	call   80036d <fd_alloc>
  800aa7:	83 c4 10             	add    $0x10,%esp
		return r;
  800aaa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aac:	85 c0                	test   %eax,%eax
  800aae:	78 57                	js     800b07 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ab0:	83 ec 08             	sub    $0x8,%esp
  800ab3:	53                   	push   %ebx
  800ab4:	68 00 50 80 00       	push   $0x805000
  800ab9:	e8 a4 0b 00 00       	call   801662 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	e8 22 fe ff ff       	call   8008f5 <fsipc>
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	79 14                	jns    800af0 <open+0x6f>
		fd_close(fd, 0);
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	6a 00                	push   $0x0
  800ae1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae4:	e8 7c f9 ff ff       	call   800465 <fd_close>
		return r;
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	89 da                	mov    %ebx,%edx
  800aee:	eb 17                	jmp    800b07 <open+0x86>
	}

	return fd2num(fd);
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	ff 75 f4             	pushl  -0xc(%ebp)
  800af6:	e8 4b f8 ff ff       	call   800346 <fd2num>
  800afb:	89 c2                	mov    %eax,%edx
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	eb 05                	jmp    800b07 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b02:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b07:	89 d0                	mov    %edx,%eax
  800b09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b0c:	c9                   	leave  
  800b0d:	c3                   	ret    

00800b0e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 08 00 00 00       	mov    $0x8,%eax
  800b1e:	e8 d2 fd ff ff       	call   8008f5 <fsipc>
}
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b2d:	83 ec 0c             	sub    $0xc,%esp
  800b30:	ff 75 08             	pushl  0x8(%ebp)
  800b33:	e8 1e f8 ff ff       	call   800356 <fd2data>
  800b38:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b3a:	83 c4 08             	add    $0x8,%esp
  800b3d:	68 95 1e 80 00       	push   $0x801e95
  800b42:	53                   	push   %ebx
  800b43:	e8 1a 0b 00 00       	call   801662 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b48:	8b 46 04             	mov    0x4(%esi),%eax
  800b4b:	2b 06                	sub    (%esi),%eax
  800b4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b53:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b5a:	00 00 00 
	stat->st_dev = &devpipe;
  800b5d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b64:	30 80 00 
	return 0;
}
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b7d:	53                   	push   %ebx
  800b7e:	6a 00                	push   $0x0
  800b80:	e8 55 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b85:	89 1c 24             	mov    %ebx,(%esp)
  800b88:	e8 c9 f7 ff ff       	call   800356 <fd2data>
  800b8d:	83 c4 08             	add    $0x8,%esp
  800b90:	50                   	push   %eax
  800b91:	6a 00                	push   $0x0
  800b93:	e8 42 f6 ff ff       	call   8001da <sys_page_unmap>
}
  800b98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 1c             	sub    $0x1c,%esp
  800ba6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ba9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bab:	a1 04 40 80 00       	mov    0x804004,%eax
  800bb0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	ff 75 e0             	pushl  -0x20(%ebp)
  800bb9:	e8 df 0e 00 00       	call   801a9d <pageref>
  800bbe:	89 c3                	mov    %eax,%ebx
  800bc0:	89 3c 24             	mov    %edi,(%esp)
  800bc3:	e8 d5 0e 00 00       	call   801a9d <pageref>
  800bc8:	83 c4 10             	add    $0x10,%esp
  800bcb:	39 c3                	cmp    %eax,%ebx
  800bcd:	0f 94 c1             	sete   %cl
  800bd0:	0f b6 c9             	movzbl %cl,%ecx
  800bd3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bd6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bdc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bdf:	39 ce                	cmp    %ecx,%esi
  800be1:	74 1b                	je     800bfe <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800be3:	39 c3                	cmp    %eax,%ebx
  800be5:	75 c4                	jne    800bab <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be7:	8b 42 58             	mov    0x58(%edx),%eax
  800bea:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bed:	50                   	push   %eax
  800bee:	56                   	push   %esi
  800bef:	68 9c 1e 80 00       	push   $0x801e9c
  800bf4:	e8 e4 04 00 00       	call   8010dd <cprintf>
  800bf9:	83 c4 10             	add    $0x10,%esp
  800bfc:	eb ad                	jmp    800bab <_pipeisclosed+0xe>
	}
}
  800bfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 28             	sub    $0x28,%esp
  800c12:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c15:	56                   	push   %esi
  800c16:	e8 3b f7 ff ff       	call   800356 <fd2data>
  800c1b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c1d:	83 c4 10             	add    $0x10,%esp
  800c20:	bf 00 00 00 00       	mov    $0x0,%edi
  800c25:	eb 4b                	jmp    800c72 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c27:	89 da                	mov    %ebx,%edx
  800c29:	89 f0                	mov    %esi,%eax
  800c2b:	e8 6d ff ff ff       	call   800b9d <_pipeisclosed>
  800c30:	85 c0                	test   %eax,%eax
  800c32:	75 48                	jne    800c7c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c34:	e8 fd f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c39:	8b 43 04             	mov    0x4(%ebx),%eax
  800c3c:	8b 0b                	mov    (%ebx),%ecx
  800c3e:	8d 51 20             	lea    0x20(%ecx),%edx
  800c41:	39 d0                	cmp    %edx,%eax
  800c43:	73 e2                	jae    800c27 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c4c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c4f:	89 c2                	mov    %eax,%edx
  800c51:	c1 fa 1f             	sar    $0x1f,%edx
  800c54:	89 d1                	mov    %edx,%ecx
  800c56:	c1 e9 1b             	shr    $0x1b,%ecx
  800c59:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c5c:	83 e2 1f             	and    $0x1f,%edx
  800c5f:	29 ca                	sub    %ecx,%edx
  800c61:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c65:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c69:	83 c0 01             	add    $0x1,%eax
  800c6c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6f:	83 c7 01             	add    $0x1,%edi
  800c72:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c75:	75 c2                	jne    800c39 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c77:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7a:	eb 05                	jmp    800c81 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 18             	sub    $0x18,%esp
  800c92:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c95:	57                   	push   %edi
  800c96:	e8 bb f6 ff ff       	call   800356 <fd2data>
  800c9b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9d:	83 c4 10             	add    $0x10,%esp
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	eb 3d                	jmp    800ce4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ca7:	85 db                	test   %ebx,%ebx
  800ca9:	74 04                	je     800caf <devpipe_read+0x26>
				return i;
  800cab:	89 d8                	mov    %ebx,%eax
  800cad:	eb 44                	jmp    800cf3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800caf:	89 f2                	mov    %esi,%edx
  800cb1:	89 f8                	mov    %edi,%eax
  800cb3:	e8 e5 fe ff ff       	call   800b9d <_pipeisclosed>
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	75 32                	jne    800cee <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cbc:	e8 75 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cc1:	8b 06                	mov    (%esi),%eax
  800cc3:	3b 46 04             	cmp    0x4(%esi),%eax
  800cc6:	74 df                	je     800ca7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cc8:	99                   	cltd   
  800cc9:	c1 ea 1b             	shr    $0x1b,%edx
  800ccc:	01 d0                	add    %edx,%eax
  800cce:	83 e0 1f             	and    $0x1f,%eax
  800cd1:	29 d0                	sub    %edx,%eax
  800cd3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cde:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce1:	83 c3 01             	add    $0x1,%ebx
  800ce4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800ce7:	75 d8                	jne    800cc1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ce9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cec:	eb 05                	jmp    800cf3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cee:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d06:	50                   	push   %eax
  800d07:	e8 61 f6 ff ff       	call   80036d <fd_alloc>
  800d0c:	83 c4 10             	add    $0x10,%esp
  800d0f:	89 c2                	mov    %eax,%edx
  800d11:	85 c0                	test   %eax,%eax
  800d13:	0f 88 2c 01 00 00    	js     800e45 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d19:	83 ec 04             	sub    $0x4,%esp
  800d1c:	68 07 04 00 00       	push   $0x407
  800d21:	ff 75 f4             	pushl  -0xc(%ebp)
  800d24:	6a 00                	push   $0x0
  800d26:	e8 2a f4 ff ff       	call   800155 <sys_page_alloc>
  800d2b:	83 c4 10             	add    $0x10,%esp
  800d2e:	89 c2                	mov    %eax,%edx
  800d30:	85 c0                	test   %eax,%eax
  800d32:	0f 88 0d 01 00 00    	js     800e45 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d3e:	50                   	push   %eax
  800d3f:	e8 29 f6 ff ff       	call   80036d <fd_alloc>
  800d44:	89 c3                	mov    %eax,%ebx
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	0f 88 e2 00 00 00    	js     800e33 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	68 07 04 00 00       	push   $0x407
  800d59:	ff 75 f0             	pushl  -0x10(%ebp)
  800d5c:	6a 00                	push   $0x0
  800d5e:	e8 f2 f3 ff ff       	call   800155 <sys_page_alloc>
  800d63:	89 c3                	mov    %eax,%ebx
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	0f 88 c3 00 00 00    	js     800e33 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	ff 75 f4             	pushl  -0xc(%ebp)
  800d76:	e8 db f5 ff ff       	call   800356 <fd2data>
  800d7b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7d:	83 c4 0c             	add    $0xc,%esp
  800d80:	68 07 04 00 00       	push   $0x407
  800d85:	50                   	push   %eax
  800d86:	6a 00                	push   $0x0
  800d88:	e8 c8 f3 ff ff       	call   800155 <sys_page_alloc>
  800d8d:	89 c3                	mov    %eax,%ebx
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	85 c0                	test   %eax,%eax
  800d94:	0f 88 89 00 00 00    	js     800e23 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9a:	83 ec 0c             	sub    $0xc,%esp
  800d9d:	ff 75 f0             	pushl  -0x10(%ebp)
  800da0:	e8 b1 f5 ff ff       	call   800356 <fd2data>
  800da5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dac:	50                   	push   %eax
  800dad:	6a 00                	push   $0x0
  800daf:	56                   	push   %esi
  800db0:	6a 00                	push   $0x0
  800db2:	e8 e1 f3 ff ff       	call   800198 <sys_page_map>
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	83 c4 20             	add    $0x20,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	78 55                	js     800e15 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dc0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dc9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dd5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dde:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	ff 75 f4             	pushl  -0xc(%ebp)
  800df0:	e8 51 f5 ff ff       	call   800346 <fd2num>
  800df5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dfa:	83 c4 04             	add    $0x4,%esp
  800dfd:	ff 75 f0             	pushl  -0x10(%ebp)
  800e00:	e8 41 f5 ff ff       	call   800346 <fd2num>
  800e05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e08:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e0b:	83 c4 10             	add    $0x10,%esp
  800e0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e13:	eb 30                	jmp    800e45 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e15:	83 ec 08             	sub    $0x8,%esp
  800e18:	56                   	push   %esi
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 ba f3 ff ff       	call   8001da <sys_page_unmap>
  800e20:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e23:	83 ec 08             	sub    $0x8,%esp
  800e26:	ff 75 f0             	pushl  -0x10(%ebp)
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 aa f3 ff ff       	call   8001da <sys_page_unmap>
  800e30:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e33:	83 ec 08             	sub    $0x8,%esp
  800e36:	ff 75 f4             	pushl  -0xc(%ebp)
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 9a f3 ff ff       	call   8001da <sys_page_unmap>
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e45:	89 d0                	mov    %edx,%eax
  800e47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e57:	50                   	push   %eax
  800e58:	ff 75 08             	pushl  0x8(%ebp)
  800e5b:	e8 5c f5 ff ff       	call   8003bc <fd_lookup>
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	78 18                	js     800e7f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6d:	e8 e4 f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800e72:	89 c2                	mov    %eax,%edx
  800e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e77:	e8 21 fd ff ff       	call   800b9d <_pipeisclosed>
  800e7c:	83 c4 10             	add    $0x10,%esp
}
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    

00800e81 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e91:	68 b4 1e 80 00       	push   $0x801eb4
  800e96:	ff 75 0c             	pushl  0xc(%ebp)
  800e99:	e8 c4 07 00 00       	call   801662 <strcpy>
	return 0;
}
  800e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
  800eab:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eb6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ebc:	eb 2d                	jmp    800eeb <devcons_write+0x46>
		m = n - tot;
  800ebe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ec3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ec6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ecb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ece:	83 ec 04             	sub    $0x4,%esp
  800ed1:	53                   	push   %ebx
  800ed2:	03 45 0c             	add    0xc(%ebp),%eax
  800ed5:	50                   	push   %eax
  800ed6:	57                   	push   %edi
  800ed7:	e8 18 09 00 00       	call   8017f4 <memmove>
		sys_cputs(buf, m);
  800edc:	83 c4 08             	add    $0x8,%esp
  800edf:	53                   	push   %ebx
  800ee0:	57                   	push   %edi
  800ee1:	e8 b3 f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee6:	01 de                	add    %ebx,%esi
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	89 f0                	mov    %esi,%eax
  800eed:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef0:	72 cc                	jb     800ebe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ef2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	83 ec 08             	sub    $0x8,%esp
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f09:	74 2a                	je     800f35 <devcons_read+0x3b>
  800f0b:	eb 05                	jmp    800f12 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f0d:	e8 24 f2 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f12:	e8 a0 f1 ff ff       	call   8000b7 <sys_cgetc>
  800f17:	85 c0                	test   %eax,%eax
  800f19:	74 f2                	je     800f0d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	78 16                	js     800f35 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f1f:	83 f8 04             	cmp    $0x4,%eax
  800f22:	74 0c                	je     800f30 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f27:	88 02                	mov    %al,(%edx)
	return 1;
  800f29:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2e:	eb 05                	jmp    800f35 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f30:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    

00800f37 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f40:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f43:	6a 01                	push   $0x1
  800f45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f48:	50                   	push   %eax
  800f49:	e8 4b f1 ff ff       	call   800099 <sys_cputs>
}
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <getchar>:

int
getchar(void)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f59:	6a 01                	push   $0x1
  800f5b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5e:	50                   	push   %eax
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 bc f6 ff ff       	call   800622 <read>
	if (r < 0)
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 0f                	js     800f7c <getchar+0x29>
		return r;
	if (r < 1)
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	7e 06                	jle    800f77 <getchar+0x24>
		return -E_EOF;
	return c;
  800f71:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f75:	eb 05                	jmp    800f7c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f77:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f87:	50                   	push   %eax
  800f88:	ff 75 08             	pushl  0x8(%ebp)
  800f8b:	e8 2c f4 ff ff       	call   8003bc <fd_lookup>
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	78 11                	js     800fa8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa0:	39 10                	cmp    %edx,(%eax)
  800fa2:	0f 94 c0             	sete   %al
  800fa5:	0f b6 c0             	movzbl %al,%eax
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <opencons>:

int
opencons(void)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	e8 b4 f3 ff ff       	call   80036d <fd_alloc>
  800fb9:	83 c4 10             	add    $0x10,%esp
		return r;
  800fbc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 3e                	js     801000 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc2:	83 ec 04             	sub    $0x4,%esp
  800fc5:	68 07 04 00 00       	push   $0x407
  800fca:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcd:	6a 00                	push   $0x0
  800fcf:	e8 81 f1 ff ff       	call   800155 <sys_page_alloc>
  800fd4:	83 c4 10             	add    $0x10,%esp
		return r;
  800fd7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	78 23                	js     801000 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fdd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800feb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	50                   	push   %eax
  800ff6:	e8 4b f3 ff ff       	call   800346 <fd2num>
  800ffb:	89 c2                	mov    %eax,%edx
  800ffd:	83 c4 10             	add    $0x10,%esp
}
  801000:	89 d0                	mov    %edx,%eax
  801002:	c9                   	leave  
  801003:	c3                   	ret    

00801004 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801009:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80100c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801012:	e8 00 f1 ff ff       	call   800117 <sys_getenvid>
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	ff 75 0c             	pushl  0xc(%ebp)
  80101d:	ff 75 08             	pushl  0x8(%ebp)
  801020:	56                   	push   %esi
  801021:	50                   	push   %eax
  801022:	68 c0 1e 80 00       	push   $0x801ec0
  801027:	e8 b1 00 00 00       	call   8010dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80102c:	83 c4 18             	add    $0x18,%esp
  80102f:	53                   	push   %ebx
  801030:	ff 75 10             	pushl  0x10(%ebp)
  801033:	e8 54 00 00 00       	call   80108c <vcprintf>
	cprintf("\n");
  801038:	c7 04 24 ad 1e 80 00 	movl   $0x801ead,(%esp)
  80103f:	e8 99 00 00 00       	call   8010dd <cprintf>
  801044:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801047:	cc                   	int3   
  801048:	eb fd                	jmp    801047 <_panic+0x43>

0080104a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	53                   	push   %ebx
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801054:	8b 13                	mov    (%ebx),%edx
  801056:	8d 42 01             	lea    0x1(%edx),%eax
  801059:	89 03                	mov    %eax,(%ebx)
  80105b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801062:	3d ff 00 00 00       	cmp    $0xff,%eax
  801067:	75 1a                	jne    801083 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801069:	83 ec 08             	sub    $0x8,%esp
  80106c:	68 ff 00 00 00       	push   $0xff
  801071:	8d 43 08             	lea    0x8(%ebx),%eax
  801074:	50                   	push   %eax
  801075:	e8 1f f0 ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  80107a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801080:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801083:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801087:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801095:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80109c:	00 00 00 
	b.cnt = 0;
  80109f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010a9:	ff 75 0c             	pushl  0xc(%ebp)
  8010ac:	ff 75 08             	pushl  0x8(%ebp)
  8010af:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	68 4a 10 80 00       	push   $0x80104a
  8010bb:	e8 54 01 00 00       	call   801214 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c0:	83 c4 08             	add    $0x8,%esp
  8010c3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010c9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010cf:	50                   	push   %eax
  8010d0:	e8 c4 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  8010d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010db:	c9                   	leave  
  8010dc:	c3                   	ret    

008010dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e6:	50                   	push   %eax
  8010e7:	ff 75 08             	pushl  0x8(%ebp)
  8010ea:	e8 9d ff ff ff       	call   80108c <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 1c             	sub    $0x1c,%esp
  8010fa:	89 c7                	mov    %eax,%edi
  8010fc:	89 d6                	mov    %edx,%esi
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801101:	8b 55 0c             	mov    0xc(%ebp),%edx
  801104:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801107:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80110d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801112:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801115:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801118:	39 d3                	cmp    %edx,%ebx
  80111a:	72 05                	jb     801121 <printnum+0x30>
  80111c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80111f:	77 45                	ja     801166 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	ff 75 18             	pushl  0x18(%ebp)
  801127:	8b 45 14             	mov    0x14(%ebp),%eax
  80112a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80112d:	53                   	push   %ebx
  80112e:	ff 75 10             	pushl  0x10(%ebp)
  801131:	83 ec 08             	sub    $0x8,%esp
  801134:	ff 75 e4             	pushl  -0x1c(%ebp)
  801137:	ff 75 e0             	pushl  -0x20(%ebp)
  80113a:	ff 75 dc             	pushl  -0x24(%ebp)
  80113d:	ff 75 d8             	pushl  -0x28(%ebp)
  801140:	e8 9b 09 00 00       	call   801ae0 <__udivdi3>
  801145:	83 c4 18             	add    $0x18,%esp
  801148:	52                   	push   %edx
  801149:	50                   	push   %eax
  80114a:	89 f2                	mov    %esi,%edx
  80114c:	89 f8                	mov    %edi,%eax
  80114e:	e8 9e ff ff ff       	call   8010f1 <printnum>
  801153:	83 c4 20             	add    $0x20,%esp
  801156:	eb 18                	jmp    801170 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	56                   	push   %esi
  80115c:	ff 75 18             	pushl  0x18(%ebp)
  80115f:	ff d7                	call   *%edi
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	eb 03                	jmp    801169 <printnum+0x78>
  801166:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801169:	83 eb 01             	sub    $0x1,%ebx
  80116c:	85 db                	test   %ebx,%ebx
  80116e:	7f e8                	jg     801158 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	56                   	push   %esi
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117a:	ff 75 e0             	pushl  -0x20(%ebp)
  80117d:	ff 75 dc             	pushl  -0x24(%ebp)
  801180:	ff 75 d8             	pushl  -0x28(%ebp)
  801183:	e8 88 0a 00 00       	call   801c10 <__umoddi3>
  801188:	83 c4 14             	add    $0x14,%esp
  80118b:	0f be 80 e3 1e 80 00 	movsbl 0x801ee3(%eax),%eax
  801192:	50                   	push   %eax
  801193:	ff d7                	call   *%edi
}
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119b:	5b                   	pop    %ebx
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011a3:	83 fa 01             	cmp    $0x1,%edx
  8011a6:	7e 0e                	jle    8011b6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011a8:	8b 10                	mov    (%eax),%edx
  8011aa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ad:	89 08                	mov    %ecx,(%eax)
  8011af:	8b 02                	mov    (%edx),%eax
  8011b1:	8b 52 04             	mov    0x4(%edx),%edx
  8011b4:	eb 22                	jmp    8011d8 <getuint+0x38>
	else if (lflag)
  8011b6:	85 d2                	test   %edx,%edx
  8011b8:	74 10                	je     8011ca <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011ba:	8b 10                	mov    (%eax),%edx
  8011bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011bf:	89 08                	mov    %ecx,(%eax)
  8011c1:	8b 02                	mov    (%edx),%eax
  8011c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c8:	eb 0e                	jmp    8011d8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011ca:	8b 10                	mov    (%eax),%edx
  8011cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011cf:	89 08                	mov    %ecx,(%eax)
  8011d1:	8b 02                	mov    (%edx),%eax
  8011d3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e4:	8b 10                	mov    (%eax),%edx
  8011e6:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e9:	73 0a                	jae    8011f5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011eb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011ee:	89 08                	mov    %ecx,(%eax)
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f3:	88 02                	mov    %al,(%edx)
}
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801200:	50                   	push   %eax
  801201:	ff 75 10             	pushl  0x10(%ebp)
  801204:	ff 75 0c             	pushl  0xc(%ebp)
  801207:	ff 75 08             	pushl  0x8(%ebp)
  80120a:	e8 05 00 00 00       	call   801214 <vprintfmt>
	va_end(ap);
}
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	c9                   	leave  
  801213:	c3                   	ret    

00801214 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	57                   	push   %edi
  801218:	56                   	push   %esi
  801219:	53                   	push   %ebx
  80121a:	83 ec 2c             	sub    $0x2c,%esp
  80121d:	8b 75 08             	mov    0x8(%ebp),%esi
  801220:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801223:	8b 7d 10             	mov    0x10(%ebp),%edi
  801226:	eb 12                	jmp    80123a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801228:	85 c0                	test   %eax,%eax
  80122a:	0f 84 89 03 00 00    	je     8015b9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	53                   	push   %ebx
  801234:	50                   	push   %eax
  801235:	ff d6                	call   *%esi
  801237:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80123a:	83 c7 01             	add    $0x1,%edi
  80123d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801241:	83 f8 25             	cmp    $0x25,%eax
  801244:	75 e2                	jne    801228 <vprintfmt+0x14>
  801246:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80124a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801251:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801258:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80125f:	ba 00 00 00 00       	mov    $0x0,%edx
  801264:	eb 07                	jmp    80126d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801266:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801269:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126d:	8d 47 01             	lea    0x1(%edi),%eax
  801270:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801273:	0f b6 07             	movzbl (%edi),%eax
  801276:	0f b6 c8             	movzbl %al,%ecx
  801279:	83 e8 23             	sub    $0x23,%eax
  80127c:	3c 55                	cmp    $0x55,%al
  80127e:	0f 87 1a 03 00 00    	ja     80159e <vprintfmt+0x38a>
  801284:	0f b6 c0             	movzbl %al,%eax
  801287:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  80128e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801291:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801295:	eb d6                	jmp    80126d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801297:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80129a:	b8 00 00 00 00       	mov    $0x0,%eax
  80129f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012a5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012a9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012ac:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012af:	83 fa 09             	cmp    $0x9,%edx
  8012b2:	77 39                	ja     8012ed <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012b7:	eb e9                	jmp    8012a2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bc:	8d 48 04             	lea    0x4(%eax),%ecx
  8012bf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012c2:	8b 00                	mov    (%eax),%eax
  8012c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012ca:	eb 27                	jmp    8012f3 <vprintfmt+0xdf>
  8012cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012d6:	0f 49 c8             	cmovns %eax,%ecx
  8012d9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012df:	eb 8c                	jmp    80126d <vprintfmt+0x59>
  8012e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012e4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012eb:	eb 80                	jmp    80126d <vprintfmt+0x59>
  8012ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012f0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012f3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012f7:	0f 89 70 ff ff ff    	jns    80126d <vprintfmt+0x59>
				width = precision, precision = -1;
  8012fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801300:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801303:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80130a:	e9 5e ff ff ff       	jmp    80126d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80130f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801315:	e9 53 ff ff ff       	jmp    80126d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80131a:	8b 45 14             	mov    0x14(%ebp),%eax
  80131d:	8d 50 04             	lea    0x4(%eax),%edx
  801320:	89 55 14             	mov    %edx,0x14(%ebp)
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	53                   	push   %ebx
  801327:	ff 30                	pushl  (%eax)
  801329:	ff d6                	call   *%esi
			break;
  80132b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801331:	e9 04 ff ff ff       	jmp    80123a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801336:	8b 45 14             	mov    0x14(%ebp),%eax
  801339:	8d 50 04             	lea    0x4(%eax),%edx
  80133c:	89 55 14             	mov    %edx,0x14(%ebp)
  80133f:	8b 00                	mov    (%eax),%eax
  801341:	99                   	cltd   
  801342:	31 d0                	xor    %edx,%eax
  801344:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801346:	83 f8 0f             	cmp    $0xf,%eax
  801349:	7f 0b                	jg     801356 <vprintfmt+0x142>
  80134b:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  801352:	85 d2                	test   %edx,%edx
  801354:	75 18                	jne    80136e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801356:	50                   	push   %eax
  801357:	68 fb 1e 80 00       	push   $0x801efb
  80135c:	53                   	push   %ebx
  80135d:	56                   	push   %esi
  80135e:	e8 94 fe ff ff       	call   8011f7 <printfmt>
  801363:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801369:	e9 cc fe ff ff       	jmp    80123a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80136e:	52                   	push   %edx
  80136f:	68 86 1e 80 00       	push   $0x801e86
  801374:	53                   	push   %ebx
  801375:	56                   	push   %esi
  801376:	e8 7c fe ff ff       	call   8011f7 <printfmt>
  80137b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801381:	e9 b4 fe ff ff       	jmp    80123a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801386:	8b 45 14             	mov    0x14(%ebp),%eax
  801389:	8d 50 04             	lea    0x4(%eax),%edx
  80138c:	89 55 14             	mov    %edx,0x14(%ebp)
  80138f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801391:	85 ff                	test   %edi,%edi
  801393:	b8 f4 1e 80 00       	mov    $0x801ef4,%eax
  801398:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80139b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80139f:	0f 8e 94 00 00 00    	jle    801439 <vprintfmt+0x225>
  8013a5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013a9:	0f 84 98 00 00 00    	je     801447 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b5:	57                   	push   %edi
  8013b6:	e8 86 02 00 00       	call   801641 <strnlen>
  8013bb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013be:	29 c1                	sub    %eax,%ecx
  8013c0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013c3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013c6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013cd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013d0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d2:	eb 0f                	jmp    8013e3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	53                   	push   %ebx
  8013d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8013db:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013dd:	83 ef 01             	sub    $0x1,%edi
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	85 ff                	test   %edi,%edi
  8013e5:	7f ed                	jg     8013d4 <vprintfmt+0x1c0>
  8013e7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013ea:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8013ed:	85 c9                	test   %ecx,%ecx
  8013ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f4:	0f 49 c1             	cmovns %ecx,%eax
  8013f7:	29 c1                	sub    %eax,%ecx
  8013f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8013fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801402:	89 cb                	mov    %ecx,%ebx
  801404:	eb 4d                	jmp    801453 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801406:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80140a:	74 1b                	je     801427 <vprintfmt+0x213>
  80140c:	0f be c0             	movsbl %al,%eax
  80140f:	83 e8 20             	sub    $0x20,%eax
  801412:	83 f8 5e             	cmp    $0x5e,%eax
  801415:	76 10                	jbe    801427 <vprintfmt+0x213>
					putch('?', putdat);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	ff 75 0c             	pushl  0xc(%ebp)
  80141d:	6a 3f                	push   $0x3f
  80141f:	ff 55 08             	call   *0x8(%ebp)
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	eb 0d                	jmp    801434 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	ff 75 0c             	pushl  0xc(%ebp)
  80142d:	52                   	push   %edx
  80142e:	ff 55 08             	call   *0x8(%ebp)
  801431:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801434:	83 eb 01             	sub    $0x1,%ebx
  801437:	eb 1a                	jmp    801453 <vprintfmt+0x23f>
  801439:	89 75 08             	mov    %esi,0x8(%ebp)
  80143c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80143f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801442:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801445:	eb 0c                	jmp    801453 <vprintfmt+0x23f>
  801447:	89 75 08             	mov    %esi,0x8(%ebp)
  80144a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801450:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801453:	83 c7 01             	add    $0x1,%edi
  801456:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80145a:	0f be d0             	movsbl %al,%edx
  80145d:	85 d2                	test   %edx,%edx
  80145f:	74 23                	je     801484 <vprintfmt+0x270>
  801461:	85 f6                	test   %esi,%esi
  801463:	78 a1                	js     801406 <vprintfmt+0x1f2>
  801465:	83 ee 01             	sub    $0x1,%esi
  801468:	79 9c                	jns    801406 <vprintfmt+0x1f2>
  80146a:	89 df                	mov    %ebx,%edi
  80146c:	8b 75 08             	mov    0x8(%ebp),%esi
  80146f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801472:	eb 18                	jmp    80148c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	53                   	push   %ebx
  801478:	6a 20                	push   $0x20
  80147a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80147c:	83 ef 01             	sub    $0x1,%edi
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	eb 08                	jmp    80148c <vprintfmt+0x278>
  801484:	89 df                	mov    %ebx,%edi
  801486:	8b 75 08             	mov    0x8(%ebp),%esi
  801489:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80148c:	85 ff                	test   %edi,%edi
  80148e:	7f e4                	jg     801474 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801493:	e9 a2 fd ff ff       	jmp    80123a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801498:	83 fa 01             	cmp    $0x1,%edx
  80149b:	7e 16                	jle    8014b3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80149d:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a0:	8d 50 08             	lea    0x8(%eax),%edx
  8014a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014a6:	8b 50 04             	mov    0x4(%eax),%edx
  8014a9:	8b 00                	mov    (%eax),%eax
  8014ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014b1:	eb 32                	jmp    8014e5 <vprintfmt+0x2d1>
	else if (lflag)
  8014b3:	85 d2                	test   %edx,%edx
  8014b5:	74 18                	je     8014cf <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ba:	8d 50 04             	lea    0x4(%eax),%edx
  8014bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c0:	8b 00                	mov    (%eax),%eax
  8014c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c5:	89 c1                	mov    %eax,%ecx
  8014c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014cd:	eb 16                	jmp    8014e5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d2:	8d 50 04             	lea    0x4(%eax),%edx
  8014d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d8:	8b 00                	mov    (%eax),%eax
  8014da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014dd:	89 c1                	mov    %eax,%ecx
  8014df:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014f4:	79 74                	jns    80156a <vprintfmt+0x356>
				putch('-', putdat);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	53                   	push   %ebx
  8014fa:	6a 2d                	push   $0x2d
  8014fc:	ff d6                	call   *%esi
				num = -(long long) num;
  8014fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801501:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801504:	f7 d8                	neg    %eax
  801506:	83 d2 00             	adc    $0x0,%edx
  801509:	f7 da                	neg    %edx
  80150b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80150e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801513:	eb 55                	jmp    80156a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801515:	8d 45 14             	lea    0x14(%ebp),%eax
  801518:	e8 83 fc ff ff       	call   8011a0 <getuint>
			base = 10;
  80151d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801522:	eb 46                	jmp    80156a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801524:	8d 45 14             	lea    0x14(%ebp),%eax
  801527:	e8 74 fc ff ff       	call   8011a0 <getuint>
			base = 8;
  80152c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801531:	eb 37                	jmp    80156a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	53                   	push   %ebx
  801537:	6a 30                	push   $0x30
  801539:	ff d6                	call   *%esi
			putch('x', putdat);
  80153b:	83 c4 08             	add    $0x8,%esp
  80153e:	53                   	push   %ebx
  80153f:	6a 78                	push   $0x78
  801541:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801543:	8b 45 14             	mov    0x14(%ebp),%eax
  801546:	8d 50 04             	lea    0x4(%eax),%edx
  801549:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80154c:	8b 00                	mov    (%eax),%eax
  80154e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801553:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801556:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80155b:	eb 0d                	jmp    80156a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80155d:	8d 45 14             	lea    0x14(%ebp),%eax
  801560:	e8 3b fc ff ff       	call   8011a0 <getuint>
			base = 16;
  801565:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801571:	57                   	push   %edi
  801572:	ff 75 e0             	pushl  -0x20(%ebp)
  801575:	51                   	push   %ecx
  801576:	52                   	push   %edx
  801577:	50                   	push   %eax
  801578:	89 da                	mov    %ebx,%edx
  80157a:	89 f0                	mov    %esi,%eax
  80157c:	e8 70 fb ff ff       	call   8010f1 <printnum>
			break;
  801581:	83 c4 20             	add    $0x20,%esp
  801584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801587:	e9 ae fc ff ff       	jmp    80123a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	53                   	push   %ebx
  801590:	51                   	push   %ecx
  801591:	ff d6                	call   *%esi
			break;
  801593:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801599:	e9 9c fc ff ff       	jmp    80123a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	53                   	push   %ebx
  8015a2:	6a 25                	push   $0x25
  8015a4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	eb 03                	jmp    8015ae <vprintfmt+0x39a>
  8015ab:	83 ef 01             	sub    $0x1,%edi
  8015ae:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015b2:	75 f7                	jne    8015ab <vprintfmt+0x397>
  8015b4:	e9 81 fc ff ff       	jmp    80123a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015bc:	5b                   	pop    %ebx
  8015bd:	5e                   	pop    %esi
  8015be:	5f                   	pop    %edi
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    

008015c1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	83 ec 18             	sub    $0x18,%esp
  8015c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015d0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015d4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	74 26                	je     801608 <vsnprintf+0x47>
  8015e2:	85 d2                	test   %edx,%edx
  8015e4:	7e 22                	jle    801608 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015e6:	ff 75 14             	pushl  0x14(%ebp)
  8015e9:	ff 75 10             	pushl  0x10(%ebp)
  8015ec:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	68 da 11 80 00       	push   $0x8011da
  8015f5:	e8 1a fc ff ff       	call   801214 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015fd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801600:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	eb 05                	jmp    80160d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801608:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801615:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801618:	50                   	push   %eax
  801619:	ff 75 10             	pushl  0x10(%ebp)
  80161c:	ff 75 0c             	pushl  0xc(%ebp)
  80161f:	ff 75 08             	pushl  0x8(%ebp)
  801622:	e8 9a ff ff ff       	call   8015c1 <vsnprintf>
	va_end(ap);

	return rc;
}
  801627:	c9                   	leave  
  801628:	c3                   	ret    

00801629 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80162f:	b8 00 00 00 00       	mov    $0x0,%eax
  801634:	eb 03                	jmp    801639 <strlen+0x10>
		n++;
  801636:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801639:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80163d:	75 f7                	jne    801636 <strlen+0xd>
		n++;
	return n;
}
  80163f:	5d                   	pop    %ebp
  801640:	c3                   	ret    

00801641 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801647:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80164a:	ba 00 00 00 00       	mov    $0x0,%edx
  80164f:	eb 03                	jmp    801654 <strnlen+0x13>
		n++;
  801651:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801654:	39 c2                	cmp    %eax,%edx
  801656:	74 08                	je     801660 <strnlen+0x1f>
  801658:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80165c:	75 f3                	jne    801651 <strnlen+0x10>
  80165e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	53                   	push   %ebx
  801666:	8b 45 08             	mov    0x8(%ebp),%eax
  801669:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	83 c2 01             	add    $0x1,%edx
  801671:	83 c1 01             	add    $0x1,%ecx
  801674:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801678:	88 5a ff             	mov    %bl,-0x1(%edx)
  80167b:	84 db                	test   %bl,%bl
  80167d:	75 ef                	jne    80166e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80167f:	5b                   	pop    %ebx
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801689:	53                   	push   %ebx
  80168a:	e8 9a ff ff ff       	call   801629 <strlen>
  80168f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801692:	ff 75 0c             	pushl  0xc(%ebp)
  801695:	01 d8                	add    %ebx,%eax
  801697:	50                   	push   %eax
  801698:	e8 c5 ff ff ff       	call   801662 <strcpy>
	return dst;
}
  80169d:	89 d8                	mov    %ebx,%eax
  80169f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	56                   	push   %esi
  8016a8:	53                   	push   %ebx
  8016a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016af:	89 f3                	mov    %esi,%ebx
  8016b1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016b4:	89 f2                	mov    %esi,%edx
  8016b6:	eb 0f                	jmp    8016c7 <strncpy+0x23>
		*dst++ = *src;
  8016b8:	83 c2 01             	add    $0x1,%edx
  8016bb:	0f b6 01             	movzbl (%ecx),%eax
  8016be:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016c1:	80 39 01             	cmpb   $0x1,(%ecx)
  8016c4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c7:	39 da                	cmp    %ebx,%edx
  8016c9:	75 ed                	jne    8016b8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016cb:	89 f0                	mov    %esi,%eax
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5d                   	pop    %ebp
  8016d0:	c3                   	ret    

008016d1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	56                   	push   %esi
  8016d5:	53                   	push   %ebx
  8016d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8016d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016dc:	8b 55 10             	mov    0x10(%ebp),%edx
  8016df:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016e1:	85 d2                	test   %edx,%edx
  8016e3:	74 21                	je     801706 <strlcpy+0x35>
  8016e5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8016e9:	89 f2                	mov    %esi,%edx
  8016eb:	eb 09                	jmp    8016f6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016ed:	83 c2 01             	add    $0x1,%edx
  8016f0:	83 c1 01             	add    $0x1,%ecx
  8016f3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016f6:	39 c2                	cmp    %eax,%edx
  8016f8:	74 09                	je     801703 <strlcpy+0x32>
  8016fa:	0f b6 19             	movzbl (%ecx),%ebx
  8016fd:	84 db                	test   %bl,%bl
  8016ff:	75 ec                	jne    8016ed <strlcpy+0x1c>
  801701:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801703:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801706:	29 f0                	sub    %esi,%eax
}
  801708:	5b                   	pop    %ebx
  801709:	5e                   	pop    %esi
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801712:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801715:	eb 06                	jmp    80171d <strcmp+0x11>
		p++, q++;
  801717:	83 c1 01             	add    $0x1,%ecx
  80171a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80171d:	0f b6 01             	movzbl (%ecx),%eax
  801720:	84 c0                	test   %al,%al
  801722:	74 04                	je     801728 <strcmp+0x1c>
  801724:	3a 02                	cmp    (%edx),%al
  801726:	74 ef                	je     801717 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801728:	0f b6 c0             	movzbl %al,%eax
  80172b:	0f b6 12             	movzbl (%edx),%edx
  80172e:	29 d0                	sub    %edx,%eax
}
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	53                   	push   %ebx
  801736:	8b 45 08             	mov    0x8(%ebp),%eax
  801739:	8b 55 0c             	mov    0xc(%ebp),%edx
  80173c:	89 c3                	mov    %eax,%ebx
  80173e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801741:	eb 06                	jmp    801749 <strncmp+0x17>
		n--, p++, q++;
  801743:	83 c0 01             	add    $0x1,%eax
  801746:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801749:	39 d8                	cmp    %ebx,%eax
  80174b:	74 15                	je     801762 <strncmp+0x30>
  80174d:	0f b6 08             	movzbl (%eax),%ecx
  801750:	84 c9                	test   %cl,%cl
  801752:	74 04                	je     801758 <strncmp+0x26>
  801754:	3a 0a                	cmp    (%edx),%cl
  801756:	74 eb                	je     801743 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801758:	0f b6 00             	movzbl (%eax),%eax
  80175b:	0f b6 12             	movzbl (%edx),%edx
  80175e:	29 d0                	sub    %edx,%eax
  801760:	eb 05                	jmp    801767 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801762:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801767:	5b                   	pop    %ebx
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	8b 45 08             	mov    0x8(%ebp),%eax
  801770:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801774:	eb 07                	jmp    80177d <strchr+0x13>
		if (*s == c)
  801776:	38 ca                	cmp    %cl,%dl
  801778:	74 0f                	je     801789 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80177a:	83 c0 01             	add    $0x1,%eax
  80177d:	0f b6 10             	movzbl (%eax),%edx
  801780:	84 d2                	test   %dl,%dl
  801782:	75 f2                	jne    801776 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    

0080178b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801795:	eb 03                	jmp    80179a <strfind+0xf>
  801797:	83 c0 01             	add    $0x1,%eax
  80179a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80179d:	38 ca                	cmp    %cl,%dl
  80179f:	74 04                	je     8017a5 <strfind+0x1a>
  8017a1:	84 d2                	test   %dl,%dl
  8017a3:	75 f2                	jne    801797 <strfind+0xc>
			break;
	return (char *) s;
}
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	57                   	push   %edi
  8017ab:	56                   	push   %esi
  8017ac:	53                   	push   %ebx
  8017ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017b3:	85 c9                	test   %ecx,%ecx
  8017b5:	74 36                	je     8017ed <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017b7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017bd:	75 28                	jne    8017e7 <memset+0x40>
  8017bf:	f6 c1 03             	test   $0x3,%cl
  8017c2:	75 23                	jne    8017e7 <memset+0x40>
		c &= 0xFF;
  8017c4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017c8:	89 d3                	mov    %edx,%ebx
  8017ca:	c1 e3 08             	shl    $0x8,%ebx
  8017cd:	89 d6                	mov    %edx,%esi
  8017cf:	c1 e6 18             	shl    $0x18,%esi
  8017d2:	89 d0                	mov    %edx,%eax
  8017d4:	c1 e0 10             	shl    $0x10,%eax
  8017d7:	09 f0                	or     %esi,%eax
  8017d9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8017db:	89 d8                	mov    %ebx,%eax
  8017dd:	09 d0                	or     %edx,%eax
  8017df:	c1 e9 02             	shr    $0x2,%ecx
  8017e2:	fc                   	cld    
  8017e3:	f3 ab                	rep stos %eax,%es:(%edi)
  8017e5:	eb 06                	jmp    8017ed <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ea:	fc                   	cld    
  8017eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017ed:	89 f8                	mov    %edi,%eax
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5f                   	pop    %edi
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	57                   	push   %edi
  8017f8:	56                   	push   %esi
  8017f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801802:	39 c6                	cmp    %eax,%esi
  801804:	73 35                	jae    80183b <memmove+0x47>
  801806:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801809:	39 d0                	cmp    %edx,%eax
  80180b:	73 2e                	jae    80183b <memmove+0x47>
		s += n;
		d += n;
  80180d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801810:	89 d6                	mov    %edx,%esi
  801812:	09 fe                	or     %edi,%esi
  801814:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80181a:	75 13                	jne    80182f <memmove+0x3b>
  80181c:	f6 c1 03             	test   $0x3,%cl
  80181f:	75 0e                	jne    80182f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801821:	83 ef 04             	sub    $0x4,%edi
  801824:	8d 72 fc             	lea    -0x4(%edx),%esi
  801827:	c1 e9 02             	shr    $0x2,%ecx
  80182a:	fd                   	std    
  80182b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80182d:	eb 09                	jmp    801838 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80182f:	83 ef 01             	sub    $0x1,%edi
  801832:	8d 72 ff             	lea    -0x1(%edx),%esi
  801835:	fd                   	std    
  801836:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801838:	fc                   	cld    
  801839:	eb 1d                	jmp    801858 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80183b:	89 f2                	mov    %esi,%edx
  80183d:	09 c2                	or     %eax,%edx
  80183f:	f6 c2 03             	test   $0x3,%dl
  801842:	75 0f                	jne    801853 <memmove+0x5f>
  801844:	f6 c1 03             	test   $0x3,%cl
  801847:	75 0a                	jne    801853 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801849:	c1 e9 02             	shr    $0x2,%ecx
  80184c:	89 c7                	mov    %eax,%edi
  80184e:	fc                   	cld    
  80184f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801851:	eb 05                	jmp    801858 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801853:	89 c7                	mov    %eax,%edi
  801855:	fc                   	cld    
  801856:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801858:	5e                   	pop    %esi
  801859:	5f                   	pop    %edi
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80185f:	ff 75 10             	pushl  0x10(%ebp)
  801862:	ff 75 0c             	pushl  0xc(%ebp)
  801865:	ff 75 08             	pushl  0x8(%ebp)
  801868:	e8 87 ff ff ff       	call   8017f4 <memmove>
}
  80186d:	c9                   	leave  
  80186e:	c3                   	ret    

0080186f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	56                   	push   %esi
  801873:	53                   	push   %ebx
  801874:	8b 45 08             	mov    0x8(%ebp),%eax
  801877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187a:	89 c6                	mov    %eax,%esi
  80187c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80187f:	eb 1a                	jmp    80189b <memcmp+0x2c>
		if (*s1 != *s2)
  801881:	0f b6 08             	movzbl (%eax),%ecx
  801884:	0f b6 1a             	movzbl (%edx),%ebx
  801887:	38 d9                	cmp    %bl,%cl
  801889:	74 0a                	je     801895 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80188b:	0f b6 c1             	movzbl %cl,%eax
  80188e:	0f b6 db             	movzbl %bl,%ebx
  801891:	29 d8                	sub    %ebx,%eax
  801893:	eb 0f                	jmp    8018a4 <memcmp+0x35>
		s1++, s2++;
  801895:	83 c0 01             	add    $0x1,%eax
  801898:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80189b:	39 f0                	cmp    %esi,%eax
  80189d:	75 e2                	jne    801881 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a4:	5b                   	pop    %ebx
  8018a5:	5e                   	pop    %esi
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    

008018a8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	53                   	push   %ebx
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018af:	89 c1                	mov    %eax,%ecx
  8018b1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018b4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018b8:	eb 0a                	jmp    8018c4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018ba:	0f b6 10             	movzbl (%eax),%edx
  8018bd:	39 da                	cmp    %ebx,%edx
  8018bf:	74 07                	je     8018c8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018c1:	83 c0 01             	add    $0x1,%eax
  8018c4:	39 c8                	cmp    %ecx,%eax
  8018c6:	72 f2                	jb     8018ba <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018c8:	5b                   	pop    %ebx
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	57                   	push   %edi
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018d7:	eb 03                	jmp    8018dc <strtol+0x11>
		s++;
  8018d9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018dc:	0f b6 01             	movzbl (%ecx),%eax
  8018df:	3c 20                	cmp    $0x20,%al
  8018e1:	74 f6                	je     8018d9 <strtol+0xe>
  8018e3:	3c 09                	cmp    $0x9,%al
  8018e5:	74 f2                	je     8018d9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8018e7:	3c 2b                	cmp    $0x2b,%al
  8018e9:	75 0a                	jne    8018f5 <strtol+0x2a>
		s++;
  8018eb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8018ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8018f3:	eb 11                	jmp    801906 <strtol+0x3b>
  8018f5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8018fa:	3c 2d                	cmp    $0x2d,%al
  8018fc:	75 08                	jne    801906 <strtol+0x3b>
		s++, neg = 1;
  8018fe:	83 c1 01             	add    $0x1,%ecx
  801901:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801906:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80190c:	75 15                	jne    801923 <strtol+0x58>
  80190e:	80 39 30             	cmpb   $0x30,(%ecx)
  801911:	75 10                	jne    801923 <strtol+0x58>
  801913:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801917:	75 7c                	jne    801995 <strtol+0xca>
		s += 2, base = 16;
  801919:	83 c1 02             	add    $0x2,%ecx
  80191c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801921:	eb 16                	jmp    801939 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801923:	85 db                	test   %ebx,%ebx
  801925:	75 12                	jne    801939 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801927:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80192c:	80 39 30             	cmpb   $0x30,(%ecx)
  80192f:	75 08                	jne    801939 <strtol+0x6e>
		s++, base = 8;
  801931:	83 c1 01             	add    $0x1,%ecx
  801934:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801939:	b8 00 00 00 00       	mov    $0x0,%eax
  80193e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801941:	0f b6 11             	movzbl (%ecx),%edx
  801944:	8d 72 d0             	lea    -0x30(%edx),%esi
  801947:	89 f3                	mov    %esi,%ebx
  801949:	80 fb 09             	cmp    $0x9,%bl
  80194c:	77 08                	ja     801956 <strtol+0x8b>
			dig = *s - '0';
  80194e:	0f be d2             	movsbl %dl,%edx
  801951:	83 ea 30             	sub    $0x30,%edx
  801954:	eb 22                	jmp    801978 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801956:	8d 72 9f             	lea    -0x61(%edx),%esi
  801959:	89 f3                	mov    %esi,%ebx
  80195b:	80 fb 19             	cmp    $0x19,%bl
  80195e:	77 08                	ja     801968 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801960:	0f be d2             	movsbl %dl,%edx
  801963:	83 ea 57             	sub    $0x57,%edx
  801966:	eb 10                	jmp    801978 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801968:	8d 72 bf             	lea    -0x41(%edx),%esi
  80196b:	89 f3                	mov    %esi,%ebx
  80196d:	80 fb 19             	cmp    $0x19,%bl
  801970:	77 16                	ja     801988 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801972:	0f be d2             	movsbl %dl,%edx
  801975:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801978:	3b 55 10             	cmp    0x10(%ebp),%edx
  80197b:	7d 0b                	jge    801988 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80197d:	83 c1 01             	add    $0x1,%ecx
  801980:	0f af 45 10          	imul   0x10(%ebp),%eax
  801984:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801986:	eb b9                	jmp    801941 <strtol+0x76>

	if (endptr)
  801988:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80198c:	74 0d                	je     80199b <strtol+0xd0>
		*endptr = (char *) s;
  80198e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801991:	89 0e                	mov    %ecx,(%esi)
  801993:	eb 06                	jmp    80199b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801995:	85 db                	test   %ebx,%ebx
  801997:	74 98                	je     801931 <strtol+0x66>
  801999:	eb 9e                	jmp    801939 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80199b:	89 c2                	mov    %eax,%edx
  80199d:	f7 da                	neg    %edx
  80199f:	85 ff                	test   %edi,%edi
  8019a1:	0f 45 c2             	cmovne %edx,%eax
}
  8019a4:	5b                   	pop    %ebx
  8019a5:	5e                   	pop    %esi
  8019a6:	5f                   	pop    %edi
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    

008019a9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	56                   	push   %esi
  8019ad:	53                   	push   %ebx
  8019ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8019b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019b7:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019b9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019be:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019c1:	83 ec 0c             	sub    $0xc,%esp
  8019c4:	50                   	push   %eax
  8019c5:	e8 3b e9 ff ff       	call   800305 <sys_ipc_recv>

	if (from_env_store != NULL)
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	85 f6                	test   %esi,%esi
  8019cf:	74 14                	je     8019e5 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	78 09                	js     8019e3 <ipc_recv+0x3a>
  8019da:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019e0:	8b 52 74             	mov    0x74(%edx),%edx
  8019e3:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8019e5:	85 db                	test   %ebx,%ebx
  8019e7:	74 14                	je     8019fd <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8019e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 09                	js     8019fb <ipc_recv+0x52>
  8019f2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019f8:	8b 52 78             	mov    0x78(%edx),%edx
  8019fb:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 08                	js     801a09 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a01:	a1 04 40 80 00       	mov    0x804004,%eax
  801a06:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0c:	5b                   	pop    %ebx
  801a0d:	5e                   	pop    %esi
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	57                   	push   %edi
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a22:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a24:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a29:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a2c:	ff 75 14             	pushl  0x14(%ebp)
  801a2f:	53                   	push   %ebx
  801a30:	56                   	push   %esi
  801a31:	57                   	push   %edi
  801a32:	e8 ab e8 ff ff       	call   8002e2 <sys_ipc_try_send>

		if (err < 0) {
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	79 1e                	jns    801a5c <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a3e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a41:	75 07                	jne    801a4a <ipc_send+0x3a>
				sys_yield();
  801a43:	e8 ee e6 ff ff       	call   800136 <sys_yield>
  801a48:	eb e2                	jmp    801a2c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a4a:	50                   	push   %eax
  801a4b:	68 e0 21 80 00       	push   $0x8021e0
  801a50:	6a 49                	push   $0x49
  801a52:	68 ed 21 80 00       	push   $0x8021ed
  801a57:	e8 a8 f5 ff ff       	call   801004 <_panic>
		}

	} while (err < 0);

}
  801a5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5e                   	pop    %esi
  801a61:	5f                   	pop    %edi
  801a62:	5d                   	pop    %ebp
  801a63:	c3                   	ret    

00801a64 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a6a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a6f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a72:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a78:	8b 52 50             	mov    0x50(%edx),%edx
  801a7b:	39 ca                	cmp    %ecx,%edx
  801a7d:	75 0d                	jne    801a8c <ipc_find_env+0x28>
			return envs[i].env_id;
  801a7f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a82:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a87:	8b 40 48             	mov    0x48(%eax),%eax
  801a8a:	eb 0f                	jmp    801a9b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a8c:	83 c0 01             	add    $0x1,%eax
  801a8f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a94:	75 d9                	jne    801a6f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801a96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    

00801a9d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aa3:	89 d0                	mov    %edx,%eax
  801aa5:	c1 e8 16             	shr    $0x16,%eax
  801aa8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801aaf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ab4:	f6 c1 01             	test   $0x1,%cl
  801ab7:	74 1d                	je     801ad6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ab9:	c1 ea 0c             	shr    $0xc,%edx
  801abc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ac3:	f6 c2 01             	test   $0x1,%dl
  801ac6:	74 0e                	je     801ad6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ac8:	c1 ea 0c             	shr    $0xc,%edx
  801acb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ad2:	ef 
  801ad3:	0f b7 c0             	movzwl %ax,%eax
}
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    
  801ad8:	66 90                	xchg   %ax,%ax
  801ada:	66 90                	xchg   %ax,%ax
  801adc:	66 90                	xchg   %ax,%ax
  801ade:	66 90                	xchg   %ax,%ax

00801ae0 <__udivdi3>:
  801ae0:	55                   	push   %ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 1c             	sub    $0x1c,%esp
  801ae7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801aeb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801aef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801af3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801af7:	85 f6                	test   %esi,%esi
  801af9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801afd:	89 ca                	mov    %ecx,%edx
  801aff:	89 f8                	mov    %edi,%eax
  801b01:	75 3d                	jne    801b40 <__udivdi3+0x60>
  801b03:	39 cf                	cmp    %ecx,%edi
  801b05:	0f 87 c5 00 00 00    	ja     801bd0 <__udivdi3+0xf0>
  801b0b:	85 ff                	test   %edi,%edi
  801b0d:	89 fd                	mov    %edi,%ebp
  801b0f:	75 0b                	jne    801b1c <__udivdi3+0x3c>
  801b11:	b8 01 00 00 00       	mov    $0x1,%eax
  801b16:	31 d2                	xor    %edx,%edx
  801b18:	f7 f7                	div    %edi
  801b1a:	89 c5                	mov    %eax,%ebp
  801b1c:	89 c8                	mov    %ecx,%eax
  801b1e:	31 d2                	xor    %edx,%edx
  801b20:	f7 f5                	div    %ebp
  801b22:	89 c1                	mov    %eax,%ecx
  801b24:	89 d8                	mov    %ebx,%eax
  801b26:	89 cf                	mov    %ecx,%edi
  801b28:	f7 f5                	div    %ebp
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	89 d8                	mov    %ebx,%eax
  801b2e:	89 fa                	mov    %edi,%edx
  801b30:	83 c4 1c             	add    $0x1c,%esp
  801b33:	5b                   	pop    %ebx
  801b34:	5e                   	pop    %esi
  801b35:	5f                   	pop    %edi
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    
  801b38:	90                   	nop
  801b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b40:	39 ce                	cmp    %ecx,%esi
  801b42:	77 74                	ja     801bb8 <__udivdi3+0xd8>
  801b44:	0f bd fe             	bsr    %esi,%edi
  801b47:	83 f7 1f             	xor    $0x1f,%edi
  801b4a:	0f 84 98 00 00 00    	je     801be8 <__udivdi3+0x108>
  801b50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b55:	89 f9                	mov    %edi,%ecx
  801b57:	89 c5                	mov    %eax,%ebp
  801b59:	29 fb                	sub    %edi,%ebx
  801b5b:	d3 e6                	shl    %cl,%esi
  801b5d:	89 d9                	mov    %ebx,%ecx
  801b5f:	d3 ed                	shr    %cl,%ebp
  801b61:	89 f9                	mov    %edi,%ecx
  801b63:	d3 e0                	shl    %cl,%eax
  801b65:	09 ee                	or     %ebp,%esi
  801b67:	89 d9                	mov    %ebx,%ecx
  801b69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b6d:	89 d5                	mov    %edx,%ebp
  801b6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b73:	d3 ed                	shr    %cl,%ebp
  801b75:	89 f9                	mov    %edi,%ecx
  801b77:	d3 e2                	shl    %cl,%edx
  801b79:	89 d9                	mov    %ebx,%ecx
  801b7b:	d3 e8                	shr    %cl,%eax
  801b7d:	09 c2                	or     %eax,%edx
  801b7f:	89 d0                	mov    %edx,%eax
  801b81:	89 ea                	mov    %ebp,%edx
  801b83:	f7 f6                	div    %esi
  801b85:	89 d5                	mov    %edx,%ebp
  801b87:	89 c3                	mov    %eax,%ebx
  801b89:	f7 64 24 0c          	mull   0xc(%esp)
  801b8d:	39 d5                	cmp    %edx,%ebp
  801b8f:	72 10                	jb     801ba1 <__udivdi3+0xc1>
  801b91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801b95:	89 f9                	mov    %edi,%ecx
  801b97:	d3 e6                	shl    %cl,%esi
  801b99:	39 c6                	cmp    %eax,%esi
  801b9b:	73 07                	jae    801ba4 <__udivdi3+0xc4>
  801b9d:	39 d5                	cmp    %edx,%ebp
  801b9f:	75 03                	jne    801ba4 <__udivdi3+0xc4>
  801ba1:	83 eb 01             	sub    $0x1,%ebx
  801ba4:	31 ff                	xor    %edi,%edi
  801ba6:	89 d8                	mov    %ebx,%eax
  801ba8:	89 fa                	mov    %edi,%edx
  801baa:	83 c4 1c             	add    $0x1c,%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5f                   	pop    %edi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    
  801bb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bb8:	31 ff                	xor    %edi,%edi
  801bba:	31 db                	xor    %ebx,%ebx
  801bbc:	89 d8                	mov    %ebx,%eax
  801bbe:	89 fa                	mov    %edi,%edx
  801bc0:	83 c4 1c             	add    $0x1c,%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5f                   	pop    %edi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    
  801bc8:	90                   	nop
  801bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	89 d8                	mov    %ebx,%eax
  801bd2:	f7 f7                	div    %edi
  801bd4:	31 ff                	xor    %edi,%edi
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	89 d8                	mov    %ebx,%eax
  801bda:	89 fa                	mov    %edi,%edx
  801bdc:	83 c4 1c             	add    $0x1c,%esp
  801bdf:	5b                   	pop    %ebx
  801be0:	5e                   	pop    %esi
  801be1:	5f                   	pop    %edi
  801be2:	5d                   	pop    %ebp
  801be3:	c3                   	ret    
  801be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be8:	39 ce                	cmp    %ecx,%esi
  801bea:	72 0c                	jb     801bf8 <__udivdi3+0x118>
  801bec:	31 db                	xor    %ebx,%ebx
  801bee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801bf2:	0f 87 34 ff ff ff    	ja     801b2c <__udivdi3+0x4c>
  801bf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801bfd:	e9 2a ff ff ff       	jmp    801b2c <__udivdi3+0x4c>
  801c02:	66 90                	xchg   %ax,%ax
  801c04:	66 90                	xchg   %ax,%ax
  801c06:	66 90                	xchg   %ax,%ax
  801c08:	66 90                	xchg   %ax,%ax
  801c0a:	66 90                	xchg   %ax,%ax
  801c0c:	66 90                	xchg   %ax,%ax
  801c0e:	66 90                	xchg   %ax,%ax

00801c10 <__umoddi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 1c             	sub    $0x1c,%esp
  801c17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c27:	85 d2                	test   %edx,%edx
  801c29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c31:	89 f3                	mov    %esi,%ebx
  801c33:	89 3c 24             	mov    %edi,(%esp)
  801c36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c3a:	75 1c                	jne    801c58 <__umoddi3+0x48>
  801c3c:	39 f7                	cmp    %esi,%edi
  801c3e:	76 50                	jbe    801c90 <__umoddi3+0x80>
  801c40:	89 c8                	mov    %ecx,%eax
  801c42:	89 f2                	mov    %esi,%edx
  801c44:	f7 f7                	div    %edi
  801c46:	89 d0                	mov    %edx,%eax
  801c48:	31 d2                	xor    %edx,%edx
  801c4a:	83 c4 1c             	add    $0x1c,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
  801c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c58:	39 f2                	cmp    %esi,%edx
  801c5a:	89 d0                	mov    %edx,%eax
  801c5c:	77 52                	ja     801cb0 <__umoddi3+0xa0>
  801c5e:	0f bd ea             	bsr    %edx,%ebp
  801c61:	83 f5 1f             	xor    $0x1f,%ebp
  801c64:	75 5a                	jne    801cc0 <__umoddi3+0xb0>
  801c66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c6a:	0f 82 e0 00 00 00    	jb     801d50 <__umoddi3+0x140>
  801c70:	39 0c 24             	cmp    %ecx,(%esp)
  801c73:	0f 86 d7 00 00 00    	jbe    801d50 <__umoddi3+0x140>
  801c79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c81:	83 c4 1c             	add    $0x1c,%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5f                   	pop    %edi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	85 ff                	test   %edi,%edi
  801c92:	89 fd                	mov    %edi,%ebp
  801c94:	75 0b                	jne    801ca1 <__umoddi3+0x91>
  801c96:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9b:	31 d2                	xor    %edx,%edx
  801c9d:	f7 f7                	div    %edi
  801c9f:	89 c5                	mov    %eax,%ebp
  801ca1:	89 f0                	mov    %esi,%eax
  801ca3:	31 d2                	xor    %edx,%edx
  801ca5:	f7 f5                	div    %ebp
  801ca7:	89 c8                	mov    %ecx,%eax
  801ca9:	f7 f5                	div    %ebp
  801cab:	89 d0                	mov    %edx,%eax
  801cad:	eb 99                	jmp    801c48 <__umoddi3+0x38>
  801caf:	90                   	nop
  801cb0:	89 c8                	mov    %ecx,%eax
  801cb2:	89 f2                	mov    %esi,%edx
  801cb4:	83 c4 1c             	add    $0x1c,%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5f                   	pop    %edi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    
  801cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	8b 34 24             	mov    (%esp),%esi
  801cc3:	bf 20 00 00 00       	mov    $0x20,%edi
  801cc8:	89 e9                	mov    %ebp,%ecx
  801cca:	29 ef                	sub    %ebp,%edi
  801ccc:	d3 e0                	shl    %cl,%eax
  801cce:	89 f9                	mov    %edi,%ecx
  801cd0:	89 f2                	mov    %esi,%edx
  801cd2:	d3 ea                	shr    %cl,%edx
  801cd4:	89 e9                	mov    %ebp,%ecx
  801cd6:	09 c2                	or     %eax,%edx
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	89 14 24             	mov    %edx,(%esp)
  801cdd:	89 f2                	mov    %esi,%edx
  801cdf:	d3 e2                	shl    %cl,%edx
  801ce1:	89 f9                	mov    %edi,%ecx
  801ce3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ce7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ceb:	d3 e8                	shr    %cl,%eax
  801ced:	89 e9                	mov    %ebp,%ecx
  801cef:	89 c6                	mov    %eax,%esi
  801cf1:	d3 e3                	shl    %cl,%ebx
  801cf3:	89 f9                	mov    %edi,%ecx
  801cf5:	89 d0                	mov    %edx,%eax
  801cf7:	d3 e8                	shr    %cl,%eax
  801cf9:	89 e9                	mov    %ebp,%ecx
  801cfb:	09 d8                	or     %ebx,%eax
  801cfd:	89 d3                	mov    %edx,%ebx
  801cff:	89 f2                	mov    %esi,%edx
  801d01:	f7 34 24             	divl   (%esp)
  801d04:	89 d6                	mov    %edx,%esi
  801d06:	d3 e3                	shl    %cl,%ebx
  801d08:	f7 64 24 04          	mull   0x4(%esp)
  801d0c:	39 d6                	cmp    %edx,%esi
  801d0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d12:	89 d1                	mov    %edx,%ecx
  801d14:	89 c3                	mov    %eax,%ebx
  801d16:	72 08                	jb     801d20 <__umoddi3+0x110>
  801d18:	75 11                	jne    801d2b <__umoddi3+0x11b>
  801d1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d1e:	73 0b                	jae    801d2b <__umoddi3+0x11b>
  801d20:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d24:	1b 14 24             	sbb    (%esp),%edx
  801d27:	89 d1                	mov    %edx,%ecx
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d2f:	29 da                	sub    %ebx,%edx
  801d31:	19 ce                	sbb    %ecx,%esi
  801d33:	89 f9                	mov    %edi,%ecx
  801d35:	89 f0                	mov    %esi,%eax
  801d37:	d3 e0                	shl    %cl,%eax
  801d39:	89 e9                	mov    %ebp,%ecx
  801d3b:	d3 ea                	shr    %cl,%edx
  801d3d:	89 e9                	mov    %ebp,%ecx
  801d3f:	d3 ee                	shr    %cl,%esi
  801d41:	09 d0                	or     %edx,%eax
  801d43:	89 f2                	mov    %esi,%edx
  801d45:	83 c4 1c             	add    $0x1c,%esp
  801d48:	5b                   	pop    %ebx
  801d49:	5e                   	pop    %esi
  801d4a:	5f                   	pop    %edi
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    
  801d4d:	8d 76 00             	lea    0x0(%esi),%esi
  801d50:	29 f9                	sub    %edi,%ecx
  801d52:	19 d6                	sbb    %edx,%esi
  801d54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d5c:	e9 18 ff ff ff       	jmp    801c79 <__umoddi3+0x69>
