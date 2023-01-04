
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 87 04 00 00       	call   800516 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 8a 1d 80 00       	push   $0x801d8a
  800108:	6a 23                	push   $0x23
  80010a:	68 a7 1d 80 00       	push   $0x801da7
  80010f:	e8 f5 0e 00 00       	call   801009 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 8a 1d 80 00       	push   $0x801d8a
  800189:	6a 23                	push   $0x23
  80018b:	68 a7 1d 80 00       	push   $0x801da7
  800190:	e8 74 0e 00 00       	call   801009 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 8a 1d 80 00       	push   $0x801d8a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 a7 1d 80 00       	push   $0x801da7
  8001d2:	e8 32 0e 00 00       	call   801009 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 8a 1d 80 00       	push   $0x801d8a
  80020d:	6a 23                	push   $0x23
  80020f:	68 a7 1d 80 00       	push   $0x801da7
  800214:	e8 f0 0d 00 00       	call   801009 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 8a 1d 80 00       	push   $0x801d8a
  80024f:	6a 23                	push   $0x23
  800251:	68 a7 1d 80 00       	push   $0x801da7
  800256:	e8 ae 0d 00 00       	call   801009 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 8a 1d 80 00       	push   $0x801d8a
  800291:	6a 23                	push   $0x23
  800293:	68 a7 1d 80 00       	push   $0x801da7
  800298:	e8 6c 0d 00 00       	call   801009 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 8a 1d 80 00       	push   $0x801d8a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 a7 1d 80 00       	push   $0x801da7
  8002da:	e8 2a 0d 00 00       	call   801009 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 8a 1d 80 00       	push   $0x801d8a
  800337:	6a 23                	push   $0x23
  800339:	68 a7 1d 80 00       	push   $0x801da7
  80033e:	e8 c6 0c 00 00       	call   801009 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 11                	je     80039f <fd_alloc+0x2d>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	75 09                	jne    8003a8 <fd_alloc+0x36>
			*fd_store = fd;
  80039f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	eb 17                	jmp    8003bf <fd_alloc+0x4d>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 c9                	jne    80037d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 13                	jmp    800415 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb 0c                	jmp    800415 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb 05                	jmp    800415 <fd_lookup+0x54>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba 34 1e 80 00       	mov    $0x801e34,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	eb 13                	jmp    80043a <dev_lookup+0x23>
  800427:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	75 0c                	jne    80043a <dev_lookup+0x23>
			*dev = devtab[i];
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 01                	mov    %eax,(%ecx)
			return 0;
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	eb 2e                	jmp    800468 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 e7                	jne    800427 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 b8 1d 80 00       	push   $0x801db8
  800452:	e8 8b 0c 00 00       	call   8010e2 <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 10             	sub    $0x10,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047b:	50                   	push   %eax
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
  800485:	50                   	push   %eax
  800486:	e8 36 ff ff ff       	call   8003c1 <fd_lookup>
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	85 c0                	test   %eax,%eax
  800490:	78 05                	js     800497 <fd_close+0x2d>
	    || fd != fd2)
  800492:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800495:	74 0c                	je     8004a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800497:	84 db                	test   %bl,%bl
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	0f 44 c2             	cmove  %edx,%eax
  8004a1:	eb 41                	jmp    8004e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff 36                	pushl  (%esi)
  8004ac:	e8 66 ff ff ff       	call   800417 <dev_lookup>
  8004b1:	89 c3                	mov    %eax,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 1a                	js     8004d4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	74 0b                	je     8004d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff d0                	call   *%eax
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	56                   	push   %esi
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 00 fd ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	89 d8                	mov    %ebx,%eax
}
  8004e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 08             	pushl  0x8(%ebp)
  8004f8:	e8 c4 fe ff ff       	call   8003c1 <fd_lookup>
  8004fd:	83 c4 08             	add    $0x8,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 10                	js     800514 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	6a 01                	push   $0x1
  800509:	ff 75 f4             	pushl  -0xc(%ebp)
  80050c:	e8 59 ff ff ff       	call   80046a <fd_close>
  800511:	83 c4 10             	add    $0x10,%esp
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <close_all>:

void
close_all(void)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	53                   	push   %ebx
  80051a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800522:	83 ec 0c             	sub    $0xc,%esp
  800525:	53                   	push   %ebx
  800526:	e8 c0 ff ff ff       	call   8004eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052b:	83 c3 01             	add    $0x1,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	83 fb 20             	cmp    $0x20,%ebx
  800534:	75 ec                	jne    800522 <close_all+0xc>
		close(i);
}
  800536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 2c             	sub    $0x2c,%esp
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800547:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 6e fe ff ff       	call   8003c1 <fd_lookup>
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 88 c1 00 00 00    	js     80061f <dup+0xe4>
		return r;
	close(newfdnum);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	56                   	push   %esi
  800562:	e8 84 ff ff ff       	call   8004eb <close>

	newfd = INDEX2FD(newfdnum);
  800567:	89 f3                	mov    %esi,%ebx
  800569:	c1 e3 0c             	shl    $0xc,%ebx
  80056c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800572:	83 c4 04             	add    $0x4,%esp
  800575:	ff 75 e4             	pushl  -0x1c(%ebp)
  800578:	e8 de fd ff ff       	call   80035b <fd2data>
  80057d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057f:	89 1c 24             	mov    %ebx,(%esp)
  800582:	e8 d4 fd ff ff       	call   80035b <fd2data>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058d:	89 f8                	mov    %edi,%eax
  80058f:	c1 e8 16             	shr    $0x16,%eax
  800592:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800599:	a8 01                	test   $0x1,%al
  80059b:	74 37                	je     8005d4 <dup+0x99>
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 0c             	shr    $0xc,%eax
  8005a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a9:	f6 c2 01             	test   $0x1,%dl
  8005ac:	74 26                	je     8005d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c1:	6a 00                	push   $0x0
  8005c3:	57                   	push   %edi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 d2 fb ff ff       	call   80019d <sys_page_map>
  8005cb:	89 c7                	mov    %eax,%edi
  8005cd:	83 c4 20             	add    $0x20,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	78 2e                	js     800602 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	53                   	push   %ebx
  8005ed:	6a 00                	push   $0x0
  8005ef:	52                   	push   %edx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 a6 fb ff ff       	call   80019d <sys_page_map>
  8005f7:	89 c7                	mov    %eax,%edi
  8005f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fe:	85 ff                	test   %edi,%edi
  800600:	79 1d                	jns    80061f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 00                	push   $0x0
  800608:	e8 d2 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	ff 75 d4             	pushl  -0x2c(%ebp)
  800613:	6a 00                	push   $0x0
  800615:	e8 c5 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	89 f8                	mov    %edi,%eax
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	53                   	push   %ebx
  80062b:	83 ec 14             	sub    $0x14,%esp
  80062e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	53                   	push   %ebx
  800636:	e8 86 fd ff ff       	call   8003c1 <fd_lookup>
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	89 c2                	mov    %eax,%edx
  800640:	85 c0                	test   %eax,%eax
  800642:	78 6d                	js     8006b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064a:	50                   	push   %eax
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	ff 30                	pushl  (%eax)
  800650:	e8 c2 fd ff ff       	call   800417 <dev_lookup>
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 c0                	test   %eax,%eax
  80065a:	78 4c                	js     8006a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065f:	8b 42 08             	mov    0x8(%edx),%eax
  800662:	83 e0 03             	and    $0x3,%eax
  800665:	83 f8 01             	cmp    $0x1,%eax
  800668:	75 21                	jne    80068b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 04 40 80 00       	mov    0x804004,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 f9 1d 80 00       	push   $0x801df9
  80067c:	e8 61 0a 00 00       	call   8010e2 <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800689:	eb 26                	jmp    8006b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	8b 40 08             	mov    0x8(%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	74 17                	je     8006ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	52                   	push   %edx
  80069f:	ff d0                	call   *%eax
  8006a1:	89 c2                	mov    %eax,%edx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 09                	jmp    8006b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	eb 05                	jmp    8006b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b1:	89 d0                	mov    %edx,%eax
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cc:	eb 21                	jmp    8006ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	29 d8                	sub    %ebx,%eax
  8006d5:	50                   	push   %eax
  8006d6:	89 d8                	mov    %ebx,%eax
  8006d8:	03 45 0c             	add    0xc(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	57                   	push   %edi
  8006dd:	e8 45 ff ff ff       	call   800627 <read>
		if (m < 0)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 10                	js     8006f9 <readn+0x41>
			return m;
		if (m == 0)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 0a                	je     8006f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ed:	01 c3                	add    %eax,%ebx
  8006ef:	39 f3                	cmp    %esi,%ebx
  8006f1:	72 db                	jb     8006ce <readn+0x16>
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	eb 02                	jmp    8006f9 <readn+0x41>
  8006f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	53                   	push   %ebx
  800705:	83 ec 14             	sub    $0x14,%esp
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	53                   	push   %ebx
  800710:	e8 ac fc ff ff       	call   8003c1 <fd_lookup>
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	89 c2                	mov    %eax,%edx
  80071a:	85 c0                	test   %eax,%eax
  80071c:	78 68                	js     800786 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800728:	ff 30                	pushl  (%eax)
  80072a:	e8 e8 fc ff ff       	call   800417 <dev_lookup>
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 c0                	test   %eax,%eax
  800734:	78 47                	js     80077d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073d:	75 21                	jne    800760 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 04 40 80 00       	mov    0x804004,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 15 1e 80 00       	push   $0x801e15
  800751:	e8 8c 09 00 00       	call   8010e2 <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075e:	eb 26                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800763:	8b 52 0c             	mov    0xc(%edx),%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	74 17                	je     800781 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	50                   	push   %eax
  800774:	ff d2                	call   *%edx
  800776:	89 c2                	mov    %eax,%edx
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 09                	jmp    800786 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	eb 05                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800786:	89 d0                	mov    %edx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <seek>:

int
seek(int fdnum, off_t offset)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800793:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 22 fc ff ff       	call   8003c1 <fd_lookup>
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 0e                	js     8007b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 14             	sub    $0x14,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	53                   	push   %ebx
  8007c5:	e8 f7 fb ff ff       	call   8003c1 <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 65                	js     800838 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	ff 30                	pushl  (%eax)
  8007df:	e8 33 fc ff ff       	call   800417 <dev_lookup>
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 44                	js     80082f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f2:	75 21                	jne    800815 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f9:	8b 40 48             	mov    0x48(%eax),%eax
  8007fc:	83 ec 04             	sub    $0x4,%esp
  8007ff:	53                   	push   %ebx
  800800:	50                   	push   %eax
  800801:	68 d8 1d 80 00       	push   $0x801dd8
  800806:	e8 d7 08 00 00       	call   8010e2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800813:	eb 23                	jmp    800838 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 18             	mov    0x18(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 14                	je     800833 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff d2                	call   *%edx
  800828:	89 c2                	mov    %eax,%edx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb 09                	jmp    800838 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 05                	jmp    800838 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800838:	89 d0                	mov    %edx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	83 ec 14             	sub    $0x14,%esp
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 6c fb ff ff       	call   8003c1 <fd_lookup>
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	89 c2                	mov    %eax,%edx
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 58                	js     8008b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800868:	ff 30                	pushl  (%eax)
  80086a:	e8 a8 fb ff ff       	call   800417 <dev_lookup>
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	85 c0                	test   %eax,%eax
  800874:	78 37                	js     8008ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800879:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087d:	74 32                	je     8008b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800882:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800889:	00 00 00 
	stat->st_isdir = 0;
  80088c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800893:	00 00 00 
	stat->st_dev = dev;
  800896:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a3:	ff 50 14             	call   *0x14(%eax)
  8008a6:	89 c2                	mov    %eax,%edx
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	eb 09                	jmp    8008b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	eb 05                	jmp    8008b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	6a 00                	push   $0x0
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 b7 01 00 00       	call   800a86 <open>
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	78 1b                	js     8008f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	50                   	push   %eax
  8008df:	e8 5b ff ff ff       	call   80083f <fstat>
  8008e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 fd fb ff ff       	call   8004eb <close>
	return r;
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	89 f0                	mov    %esi,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800903:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090a:	75 12                	jne    80091e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	6a 01                	push   $0x1
  800911:	e8 53 11 00 00       	call   801a69 <ipc_find_env>
  800916:	a3 00 40 80 00       	mov    %eax,0x804000
  80091b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091e:	6a 07                	push   $0x7
  800920:	68 00 50 80 00       	push   $0x805000
  800925:	56                   	push   %esi
  800926:	ff 35 00 40 80 00    	pushl  0x804000
  80092c:	e8 e4 10 00 00       	call   801a15 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800931:	83 c4 0c             	add    $0xc,%esp
  800934:	6a 00                	push   $0x0
  800936:	53                   	push   %ebx
  800937:	6a 00                	push   $0x0
  800939:	e8 70 10 00 00       	call   8019ae <ipc_recv>
}
  80093e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 40 0c             	mov    0xc(%eax),%eax
  800951:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 02 00 00 00       	mov    $0x2,%eax
  800968:	e8 8d ff ff ff       	call   8008fa <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 06 00 00 00       	mov    $0x6,%eax
  80098a:	e8 6b ff ff ff       	call   8008fa <fsipc>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	83 ec 04             	sub    $0x4,%esp
  800998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b0:	e8 45 ff ff ff       	call   8008fa <fsipc>
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 2c                	js     8009e5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	68 00 50 80 00       	push   $0x805000
  8009c1:	53                   	push   %ebx
  8009c2:	e8 a0 0c 00 00       	call   801667 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009f0:	68 44 1e 80 00       	push   $0x801e44
  8009f5:	68 90 00 00 00       	push   $0x90
  8009fa:	68 62 1e 80 00       	push   $0x801e62
  8009ff:	e8 05 06 00 00       	call   801009 <_panic>

00800a04 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a12:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a17:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a22:	b8 03 00 00 00       	mov    $0x3,%eax
  800a27:	e8 ce fe ff ff       	call   8008fa <fsipc>
  800a2c:	89 c3                	mov    %eax,%ebx
  800a2e:	85 c0                	test   %eax,%eax
  800a30:	78 4b                	js     800a7d <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a32:	39 c6                	cmp    %eax,%esi
  800a34:	73 16                	jae    800a4c <devfile_read+0x48>
  800a36:	68 6d 1e 80 00       	push   $0x801e6d
  800a3b:	68 74 1e 80 00       	push   $0x801e74
  800a40:	6a 7c                	push   $0x7c
  800a42:	68 62 1e 80 00       	push   $0x801e62
  800a47:	e8 bd 05 00 00       	call   801009 <_panic>
	assert(r <= PGSIZE);
  800a4c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a51:	7e 16                	jle    800a69 <devfile_read+0x65>
  800a53:	68 89 1e 80 00       	push   $0x801e89
  800a58:	68 74 1e 80 00       	push   $0x801e74
  800a5d:	6a 7d                	push   $0x7d
  800a5f:	68 62 1e 80 00       	push   $0x801e62
  800a64:	e8 a0 05 00 00       	call   801009 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a69:	83 ec 04             	sub    $0x4,%esp
  800a6c:	50                   	push   %eax
  800a6d:	68 00 50 80 00       	push   $0x805000
  800a72:	ff 75 0c             	pushl  0xc(%ebp)
  800a75:	e8 7f 0d 00 00       	call   8017f9 <memmove>
	return r;
  800a7a:	83 c4 10             	add    $0x10,%esp
}
  800a7d:	89 d8                	mov    %ebx,%eax
  800a7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	53                   	push   %ebx
  800a8a:	83 ec 20             	sub    $0x20,%esp
  800a8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a90:	53                   	push   %ebx
  800a91:	e8 98 0b 00 00       	call   80162e <strlen>
  800a96:	83 c4 10             	add    $0x10,%esp
  800a99:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a9e:	7f 67                	jg     800b07 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aa0:	83 ec 0c             	sub    $0xc,%esp
  800aa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa6:	50                   	push   %eax
  800aa7:	e8 c6 f8 ff ff       	call   800372 <fd_alloc>
  800aac:	83 c4 10             	add    $0x10,%esp
		return r;
  800aaf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	78 57                	js     800b0c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ab5:	83 ec 08             	sub    $0x8,%esp
  800ab8:	53                   	push   %ebx
  800ab9:	68 00 50 80 00       	push   $0x805000
  800abe:	e8 a4 0b 00 00       	call   801667 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ace:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad3:	e8 22 fe ff ff       	call   8008fa <fsipc>
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	85 c0                	test   %eax,%eax
  800adf:	79 14                	jns    800af5 <open+0x6f>
		fd_close(fd, 0);
  800ae1:	83 ec 08             	sub    $0x8,%esp
  800ae4:	6a 00                	push   $0x0
  800ae6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae9:	e8 7c f9 ff ff       	call   80046a <fd_close>
		return r;
  800aee:	83 c4 10             	add    $0x10,%esp
  800af1:	89 da                	mov    %ebx,%edx
  800af3:	eb 17                	jmp    800b0c <open+0x86>
	}

	return fd2num(fd);
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	ff 75 f4             	pushl  -0xc(%ebp)
  800afb:	e8 4b f8 ff ff       	call   80034b <fd2num>
  800b00:	89 c2                	mov    %eax,%edx
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	eb 05                	jmp    800b0c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b07:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b0c:	89 d0                	mov    %edx,%eax
  800b0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b23:	e8 d2 fd ff ff       	call   8008fa <fsipc>
}
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 08             	pushl  0x8(%ebp)
  800b38:	e8 1e f8 ff ff       	call   80035b <fd2data>
  800b3d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b3f:	83 c4 08             	add    $0x8,%esp
  800b42:	68 95 1e 80 00       	push   $0x801e95
  800b47:	53                   	push   %ebx
  800b48:	e8 1a 0b 00 00       	call   801667 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b4d:	8b 46 04             	mov    0x4(%esi),%eax
  800b50:	2b 06                	sub    (%esi),%eax
  800b52:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b58:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b5f:	00 00 00 
	stat->st_dev = &devpipe;
  800b62:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b69:	30 80 00 
	return 0;
}
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b82:	53                   	push   %ebx
  800b83:	6a 00                	push   $0x0
  800b85:	e8 55 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b8a:	89 1c 24             	mov    %ebx,(%esp)
  800b8d:	e8 c9 f7 ff ff       	call   80035b <fd2data>
  800b92:	83 c4 08             	add    $0x8,%esp
  800b95:	50                   	push   %eax
  800b96:	6a 00                	push   $0x0
  800b98:	e8 42 f6 ff ff       	call   8001df <sys_page_unmap>
}
  800b9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 1c             	sub    $0x1c,%esp
  800bab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bae:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bb0:	a1 04 40 80 00       	mov    0x804004,%eax
  800bb5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	ff 75 e0             	pushl  -0x20(%ebp)
  800bbe:	e8 df 0e 00 00       	call   801aa2 <pageref>
  800bc3:	89 c3                	mov    %eax,%ebx
  800bc5:	89 3c 24             	mov    %edi,(%esp)
  800bc8:	e8 d5 0e 00 00       	call   801aa2 <pageref>
  800bcd:	83 c4 10             	add    $0x10,%esp
  800bd0:	39 c3                	cmp    %eax,%ebx
  800bd2:	0f 94 c1             	sete   %cl
  800bd5:	0f b6 c9             	movzbl %cl,%ecx
  800bd8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bdb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800be1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be4:	39 ce                	cmp    %ecx,%esi
  800be6:	74 1b                	je     800c03 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800be8:	39 c3                	cmp    %eax,%ebx
  800bea:	75 c4                	jne    800bb0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bec:	8b 42 58             	mov    0x58(%edx),%eax
  800bef:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bf2:	50                   	push   %eax
  800bf3:	56                   	push   %esi
  800bf4:	68 9c 1e 80 00       	push   $0x801e9c
  800bf9:	e8 e4 04 00 00       	call   8010e2 <cprintf>
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	eb ad                	jmp    800bb0 <_pipeisclosed+0xe>
	}
}
  800c03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 28             	sub    $0x28,%esp
  800c17:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c1a:	56                   	push   %esi
  800c1b:	e8 3b f7 ff ff       	call   80035b <fd2data>
  800c20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2a:	eb 4b                	jmp    800c77 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c2c:	89 da                	mov    %ebx,%edx
  800c2e:	89 f0                	mov    %esi,%eax
  800c30:	e8 6d ff ff ff       	call   800ba2 <_pipeisclosed>
  800c35:	85 c0                	test   %eax,%eax
  800c37:	75 48                	jne    800c81 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c39:	e8 fd f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c3e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c41:	8b 0b                	mov    (%ebx),%ecx
  800c43:	8d 51 20             	lea    0x20(%ecx),%edx
  800c46:	39 d0                	cmp    %edx,%eax
  800c48:	73 e2                	jae    800c2c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c51:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c54:	89 c2                	mov    %eax,%edx
  800c56:	c1 fa 1f             	sar    $0x1f,%edx
  800c59:	89 d1                	mov    %edx,%ecx
  800c5b:	c1 e9 1b             	shr    $0x1b,%ecx
  800c5e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c61:	83 e2 1f             	and    $0x1f,%edx
  800c64:	29 ca                	sub    %ecx,%edx
  800c66:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c6a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c6e:	83 c0 01             	add    $0x1,%eax
  800c71:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c74:	83 c7 01             	add    $0x1,%edi
  800c77:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c7a:	75 c2                	jne    800c3e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7f:	eb 05                	jmp    800c86 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c81:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 18             	sub    $0x18,%esp
  800c97:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c9a:	57                   	push   %edi
  800c9b:	e8 bb f6 ff ff       	call   80035b <fd2data>
  800ca0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caa:	eb 3d                	jmp    800ce9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cac:	85 db                	test   %ebx,%ebx
  800cae:	74 04                	je     800cb4 <devpipe_read+0x26>
				return i;
  800cb0:	89 d8                	mov    %ebx,%eax
  800cb2:	eb 44                	jmp    800cf8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cb4:	89 f2                	mov    %esi,%edx
  800cb6:	89 f8                	mov    %edi,%eax
  800cb8:	e8 e5 fe ff ff       	call   800ba2 <_pipeisclosed>
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	75 32                	jne    800cf3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cc1:	e8 75 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cc6:	8b 06                	mov    (%esi),%eax
  800cc8:	3b 46 04             	cmp    0x4(%esi),%eax
  800ccb:	74 df                	je     800cac <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ccd:	99                   	cltd   
  800cce:	c1 ea 1b             	shr    $0x1b,%edx
  800cd1:	01 d0                	add    %edx,%eax
  800cd3:	83 e0 1f             	and    $0x1f,%eax
  800cd6:	29 d0                	sub    %edx,%eax
  800cd8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800ce3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce6:	83 c3 01             	add    $0x1,%ebx
  800ce9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800cec:	75 d8                	jne    800cc6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cee:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf1:	eb 05                	jmp    800cf8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d0b:	50                   	push   %eax
  800d0c:	e8 61 f6 ff ff       	call   800372 <fd_alloc>
  800d11:	83 c4 10             	add    $0x10,%esp
  800d14:	89 c2                	mov    %eax,%edx
  800d16:	85 c0                	test   %eax,%eax
  800d18:	0f 88 2c 01 00 00    	js     800e4a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d1e:	83 ec 04             	sub    $0x4,%esp
  800d21:	68 07 04 00 00       	push   $0x407
  800d26:	ff 75 f4             	pushl  -0xc(%ebp)
  800d29:	6a 00                	push   $0x0
  800d2b:	e8 2a f4 ff ff       	call   80015a <sys_page_alloc>
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	89 c2                	mov    %eax,%edx
  800d35:	85 c0                	test   %eax,%eax
  800d37:	0f 88 0d 01 00 00    	js     800e4a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d43:	50                   	push   %eax
  800d44:	e8 29 f6 ff ff       	call   800372 <fd_alloc>
  800d49:	89 c3                	mov    %eax,%ebx
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	0f 88 e2 00 00 00    	js     800e38 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	68 07 04 00 00       	push   $0x407
  800d5e:	ff 75 f0             	pushl  -0x10(%ebp)
  800d61:	6a 00                	push   $0x0
  800d63:	e8 f2 f3 ff ff       	call   80015a <sys_page_alloc>
  800d68:	89 c3                	mov    %eax,%ebx
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	0f 88 c3 00 00 00    	js     800e38 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7b:	e8 db f5 ff ff       	call   80035b <fd2data>
  800d80:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d82:	83 c4 0c             	add    $0xc,%esp
  800d85:	68 07 04 00 00       	push   $0x407
  800d8a:	50                   	push   %eax
  800d8b:	6a 00                	push   $0x0
  800d8d:	e8 c8 f3 ff ff       	call   80015a <sys_page_alloc>
  800d92:	89 c3                	mov    %eax,%ebx
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	0f 88 89 00 00 00    	js     800e28 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	ff 75 f0             	pushl  -0x10(%ebp)
  800da5:	e8 b1 f5 ff ff       	call   80035b <fd2data>
  800daa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800db1:	50                   	push   %eax
  800db2:	6a 00                	push   $0x0
  800db4:	56                   	push   %esi
  800db5:	6a 00                	push   $0x0
  800db7:	e8 e1 f3 ff ff       	call   80019d <sys_page_map>
  800dbc:	89 c3                	mov    %eax,%ebx
  800dbe:	83 c4 20             	add    $0x20,%esp
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	78 55                	js     800e1a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dc5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dce:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dda:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	ff 75 f4             	pushl  -0xc(%ebp)
  800df5:	e8 51 f5 ff ff       	call   80034b <fd2num>
  800dfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dff:	83 c4 04             	add    $0x4,%esp
  800e02:	ff 75 f0             	pushl  -0x10(%ebp)
  800e05:	e8 41 f5 ff ff       	call   80034b <fd2num>
  800e0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	ba 00 00 00 00       	mov    $0x0,%edx
  800e18:	eb 30                	jmp    800e4a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	56                   	push   %esi
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 ba f3 ff ff       	call   8001df <sys_page_unmap>
  800e25:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 aa f3 ff ff       	call   8001df <sys_page_unmap>
  800e35:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 9a f3 ff ff       	call   8001df <sys_page_unmap>
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e4a:	89 d0                	mov    %edx,%eax
  800e4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5c:	50                   	push   %eax
  800e5d:	ff 75 08             	pushl  0x8(%ebp)
  800e60:	e8 5c f5 ff ff       	call   8003c1 <fd_lookup>
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	78 18                	js     800e84 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e72:	e8 e4 f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800e77:	89 c2                	mov    %eax,%edx
  800e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7c:	e8 21 fd ff ff       	call   800ba2 <_pipeisclosed>
  800e81:	83 c4 10             	add    $0x10,%esp
}
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e96:	68 b4 1e 80 00       	push   $0x801eb4
  800e9b:	ff 75 0c             	pushl  0xc(%ebp)
  800e9e:	e8 c4 07 00 00       	call   801667 <strcpy>
	return 0;
}
  800ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ebb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec1:	eb 2d                	jmp    800ef0 <devcons_write+0x46>
		m = n - tot;
  800ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ec8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ecb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ed0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ed3:	83 ec 04             	sub    $0x4,%esp
  800ed6:	53                   	push   %ebx
  800ed7:	03 45 0c             	add    0xc(%ebp),%eax
  800eda:	50                   	push   %eax
  800edb:	57                   	push   %edi
  800edc:	e8 18 09 00 00       	call   8017f9 <memmove>
		sys_cputs(buf, m);
  800ee1:	83 c4 08             	add    $0x8,%esp
  800ee4:	53                   	push   %ebx
  800ee5:	57                   	push   %edi
  800ee6:	e8 b3 f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eeb:	01 de                	add    %ebx,%esi
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	89 f0                	mov    %esi,%eax
  800ef2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef5:	72 cc                	jb     800ec3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ef7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 08             	sub    $0x8,%esp
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f0e:	74 2a                	je     800f3a <devcons_read+0x3b>
  800f10:	eb 05                	jmp    800f17 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f12:	e8 24 f2 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f17:	e8 a0 f1 ff ff       	call   8000bc <sys_cgetc>
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	74 f2                	je     800f12 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 16                	js     800f3a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f24:	83 f8 04             	cmp    $0x4,%eax
  800f27:	74 0c                	je     800f35 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2c:	88 02                	mov    %al,(%edx)
	return 1;
  800f2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f33:	eb 05                	jmp    800f3a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
  800f45:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f48:	6a 01                	push   $0x1
  800f4a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f4d:	50                   	push   %eax
  800f4e:	e8 4b f1 ff ff       	call   80009e <sys_cputs>
}
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <getchar>:

int
getchar(void)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f5e:	6a 01                	push   $0x1
  800f60:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	6a 00                	push   $0x0
  800f66:	e8 bc f6 ff ff       	call   800627 <read>
	if (r < 0)
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 0f                	js     800f81 <getchar+0x29>
		return r;
	if (r < 1)
  800f72:	85 c0                	test   %eax,%eax
  800f74:	7e 06                	jle    800f7c <getchar+0x24>
		return -E_EOF;
	return c;
  800f76:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f7a:	eb 05                	jmp    800f81 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f7c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8c:	50                   	push   %eax
  800f8d:	ff 75 08             	pushl  0x8(%ebp)
  800f90:	e8 2c f4 ff ff       	call   8003c1 <fd_lookup>
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 11                	js     800fad <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa5:	39 10                	cmp    %edx,(%eax)
  800fa7:	0f 94 c0             	sete   %al
  800faa:	0f b6 c0             	movzbl %al,%eax
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    

00800faf <opencons>:

int
opencons(void)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb8:	50                   	push   %eax
  800fb9:	e8 b4 f3 ff ff       	call   800372 <fd_alloc>
  800fbe:	83 c4 10             	add    $0x10,%esp
		return r;
  800fc1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 3e                	js     801005 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	68 07 04 00 00       	push   $0x407
  800fcf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 81 f1 ff ff       	call   80015a <sys_page_alloc>
  800fd9:	83 c4 10             	add    $0x10,%esp
		return r;
  800fdc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 23                	js     801005 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fe2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800feb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff7:	83 ec 0c             	sub    $0xc,%esp
  800ffa:	50                   	push   %eax
  800ffb:	e8 4b f3 ff ff       	call   80034b <fd2num>
  801000:	89 c2                	mov    %eax,%edx
  801002:	83 c4 10             	add    $0x10,%esp
}
  801005:	89 d0                	mov    %edx,%eax
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80100e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801011:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801017:	e8 00 f1 ff ff       	call   80011c <sys_getenvid>
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	ff 75 0c             	pushl  0xc(%ebp)
  801022:	ff 75 08             	pushl  0x8(%ebp)
  801025:	56                   	push   %esi
  801026:	50                   	push   %eax
  801027:	68 c0 1e 80 00       	push   $0x801ec0
  80102c:	e8 b1 00 00 00       	call   8010e2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801031:	83 c4 18             	add    $0x18,%esp
  801034:	53                   	push   %ebx
  801035:	ff 75 10             	pushl  0x10(%ebp)
  801038:	e8 54 00 00 00       	call   801091 <vcprintf>
	cprintf("\n");
  80103d:	c7 04 24 ad 1e 80 00 	movl   $0x801ead,(%esp)
  801044:	e8 99 00 00 00       	call   8010e2 <cprintf>
  801049:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80104c:	cc                   	int3   
  80104d:	eb fd                	jmp    80104c <_panic+0x43>

0080104f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	53                   	push   %ebx
  801053:	83 ec 04             	sub    $0x4,%esp
  801056:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801059:	8b 13                	mov    (%ebx),%edx
  80105b:	8d 42 01             	lea    0x1(%edx),%eax
  80105e:	89 03                	mov    %eax,(%ebx)
  801060:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801063:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801067:	3d ff 00 00 00       	cmp    $0xff,%eax
  80106c:	75 1a                	jne    801088 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80106e:	83 ec 08             	sub    $0x8,%esp
  801071:	68 ff 00 00 00       	push   $0xff
  801076:	8d 43 08             	lea    0x8(%ebx),%eax
  801079:	50                   	push   %eax
  80107a:	e8 1f f0 ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  80107f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801085:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801088:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80108c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80109a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010a1:	00 00 00 
	b.cnt = 0;
  8010a4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ab:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ae:	ff 75 0c             	pushl  0xc(%ebp)
  8010b1:	ff 75 08             	pushl  0x8(%ebp)
  8010b4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ba:	50                   	push   %eax
  8010bb:	68 4f 10 80 00       	push   $0x80104f
  8010c0:	e8 54 01 00 00       	call   801219 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c5:	83 c4 08             	add    $0x8,%esp
  8010c8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010ce:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010d4:	50                   	push   %eax
  8010d5:	e8 c4 ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  8010da:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010eb:	50                   	push   %eax
  8010ec:	ff 75 08             	pushl  0x8(%ebp)
  8010ef:	e8 9d ff ff ff       	call   801091 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010f4:	c9                   	leave  
  8010f5:	c3                   	ret    

008010f6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 1c             	sub    $0x1c,%esp
  8010ff:	89 c7                	mov    %eax,%edi
  801101:	89 d6                	mov    %edx,%esi
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	8b 55 0c             	mov    0xc(%ebp),%edx
  801109:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80110c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801112:	bb 00 00 00 00       	mov    $0x0,%ebx
  801117:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80111a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80111d:	39 d3                	cmp    %edx,%ebx
  80111f:	72 05                	jb     801126 <printnum+0x30>
  801121:	39 45 10             	cmp    %eax,0x10(%ebp)
  801124:	77 45                	ja     80116b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801126:	83 ec 0c             	sub    $0xc,%esp
  801129:	ff 75 18             	pushl  0x18(%ebp)
  80112c:	8b 45 14             	mov    0x14(%ebp),%eax
  80112f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801132:	53                   	push   %ebx
  801133:	ff 75 10             	pushl  0x10(%ebp)
  801136:	83 ec 08             	sub    $0x8,%esp
  801139:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113c:	ff 75 e0             	pushl  -0x20(%ebp)
  80113f:	ff 75 dc             	pushl  -0x24(%ebp)
  801142:	ff 75 d8             	pushl  -0x28(%ebp)
  801145:	e8 96 09 00 00       	call   801ae0 <__udivdi3>
  80114a:	83 c4 18             	add    $0x18,%esp
  80114d:	52                   	push   %edx
  80114e:	50                   	push   %eax
  80114f:	89 f2                	mov    %esi,%edx
  801151:	89 f8                	mov    %edi,%eax
  801153:	e8 9e ff ff ff       	call   8010f6 <printnum>
  801158:	83 c4 20             	add    $0x20,%esp
  80115b:	eb 18                	jmp    801175 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	56                   	push   %esi
  801161:	ff 75 18             	pushl  0x18(%ebp)
  801164:	ff d7                	call   *%edi
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	eb 03                	jmp    80116e <printnum+0x78>
  80116b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80116e:	83 eb 01             	sub    $0x1,%ebx
  801171:	85 db                	test   %ebx,%ebx
  801173:	7f e8                	jg     80115d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801175:	83 ec 08             	sub    $0x8,%esp
  801178:	56                   	push   %esi
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117f:	ff 75 e0             	pushl  -0x20(%ebp)
  801182:	ff 75 dc             	pushl  -0x24(%ebp)
  801185:	ff 75 d8             	pushl  -0x28(%ebp)
  801188:	e8 83 0a 00 00       	call   801c10 <__umoddi3>
  80118d:	83 c4 14             	add    $0x14,%esp
  801190:	0f be 80 e3 1e 80 00 	movsbl 0x801ee3(%eax),%eax
  801197:	50                   	push   %eax
  801198:	ff d7                	call   *%edi
}
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011a8:	83 fa 01             	cmp    $0x1,%edx
  8011ab:	7e 0e                	jle    8011bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011ad:	8b 10                	mov    (%eax),%edx
  8011af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011b2:	89 08                	mov    %ecx,(%eax)
  8011b4:	8b 02                	mov    (%edx),%eax
  8011b6:	8b 52 04             	mov    0x4(%edx),%edx
  8011b9:	eb 22                	jmp    8011dd <getuint+0x38>
	else if (lflag)
  8011bb:	85 d2                	test   %edx,%edx
  8011bd:	74 10                	je     8011cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011bf:	8b 10                	mov    (%eax),%edx
  8011c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c4:	89 08                	mov    %ecx,(%eax)
  8011c6:	8b 02                	mov    (%edx),%eax
  8011c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cd:	eb 0e                	jmp    8011dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011cf:	8b 10                	mov    (%eax),%edx
  8011d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d4:	89 08                	mov    %ecx,(%eax)
  8011d6:	8b 02                	mov    (%edx),%eax
  8011d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e9:	8b 10                	mov    (%eax),%edx
  8011eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ee:	73 0a                	jae    8011fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8011f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011f3:	89 08                	mov    %ecx,(%eax)
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f8:	88 02                	mov    %al,(%edx)
}
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801202:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801205:	50                   	push   %eax
  801206:	ff 75 10             	pushl  0x10(%ebp)
  801209:	ff 75 0c             	pushl  0xc(%ebp)
  80120c:	ff 75 08             	pushl  0x8(%ebp)
  80120f:	e8 05 00 00 00       	call   801219 <vprintfmt>
	va_end(ap);
}
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
  80121f:	83 ec 2c             	sub    $0x2c,%esp
  801222:	8b 75 08             	mov    0x8(%ebp),%esi
  801225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801228:	8b 7d 10             	mov    0x10(%ebp),%edi
  80122b:	eb 12                	jmp    80123f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80122d:	85 c0                	test   %eax,%eax
  80122f:	0f 84 89 03 00 00    	je     8015be <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801235:	83 ec 08             	sub    $0x8,%esp
  801238:	53                   	push   %ebx
  801239:	50                   	push   %eax
  80123a:	ff d6                	call   *%esi
  80123c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80123f:	83 c7 01             	add    $0x1,%edi
  801242:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801246:	83 f8 25             	cmp    $0x25,%eax
  801249:	75 e2                	jne    80122d <vprintfmt+0x14>
  80124b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80124f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801256:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80125d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801264:	ba 00 00 00 00       	mov    $0x0,%edx
  801269:	eb 07                	jmp    801272 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80126e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801272:	8d 47 01             	lea    0x1(%edi),%eax
  801275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801278:	0f b6 07             	movzbl (%edi),%eax
  80127b:	0f b6 c8             	movzbl %al,%ecx
  80127e:	83 e8 23             	sub    $0x23,%eax
  801281:	3c 55                	cmp    $0x55,%al
  801283:	0f 87 1a 03 00 00    	ja     8015a3 <vprintfmt+0x38a>
  801289:	0f b6 c0             	movzbl %al,%eax
  80128c:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  801293:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801296:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80129a:	eb d6                	jmp    801272 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012aa:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012ae:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012b1:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012b4:	83 fa 09             	cmp    $0x9,%edx
  8012b7:	77 39                	ja     8012f2 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012bc:	eb e9                	jmp    8012a7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012be:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c1:	8d 48 04             	lea    0x4(%eax),%ecx
  8012c4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012c7:	8b 00                	mov    (%eax),%eax
  8012c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012cf:	eb 27                	jmp    8012f8 <vprintfmt+0xdf>
  8012d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012db:	0f 49 c8             	cmovns %eax,%ecx
  8012de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e4:	eb 8c                	jmp    801272 <vprintfmt+0x59>
  8012e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012e9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f0:	eb 80                	jmp    801272 <vprintfmt+0x59>
  8012f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012f5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012fc:	0f 89 70 ff ff ff    	jns    801272 <vprintfmt+0x59>
				width = precision, precision = -1;
  801302:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801305:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801308:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80130f:	e9 5e ff ff ff       	jmp    801272 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801314:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80131a:	e9 53 ff ff ff       	jmp    801272 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80131f:	8b 45 14             	mov    0x14(%ebp),%eax
  801322:	8d 50 04             	lea    0x4(%eax),%edx
  801325:	89 55 14             	mov    %edx,0x14(%ebp)
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	53                   	push   %ebx
  80132c:	ff 30                	pushl  (%eax)
  80132e:	ff d6                	call   *%esi
			break;
  801330:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801336:	e9 04 ff ff ff       	jmp    80123f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80133b:	8b 45 14             	mov    0x14(%ebp),%eax
  80133e:	8d 50 04             	lea    0x4(%eax),%edx
  801341:	89 55 14             	mov    %edx,0x14(%ebp)
  801344:	8b 00                	mov    (%eax),%eax
  801346:	99                   	cltd   
  801347:	31 d0                	xor    %edx,%eax
  801349:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80134b:	83 f8 0f             	cmp    $0xf,%eax
  80134e:	7f 0b                	jg     80135b <vprintfmt+0x142>
  801350:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  801357:	85 d2                	test   %edx,%edx
  801359:	75 18                	jne    801373 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80135b:	50                   	push   %eax
  80135c:	68 fb 1e 80 00       	push   $0x801efb
  801361:	53                   	push   %ebx
  801362:	56                   	push   %esi
  801363:	e8 94 fe ff ff       	call   8011fc <printfmt>
  801368:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80136e:	e9 cc fe ff ff       	jmp    80123f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801373:	52                   	push   %edx
  801374:	68 86 1e 80 00       	push   $0x801e86
  801379:	53                   	push   %ebx
  80137a:	56                   	push   %esi
  80137b:	e8 7c fe ff ff       	call   8011fc <printfmt>
  801380:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801386:	e9 b4 fe ff ff       	jmp    80123f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80138b:	8b 45 14             	mov    0x14(%ebp),%eax
  80138e:	8d 50 04             	lea    0x4(%eax),%edx
  801391:	89 55 14             	mov    %edx,0x14(%ebp)
  801394:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801396:	85 ff                	test   %edi,%edi
  801398:	b8 f4 1e 80 00       	mov    $0x801ef4,%eax
  80139d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013a4:	0f 8e 94 00 00 00    	jle    80143e <vprintfmt+0x225>
  8013aa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013ae:	0f 84 98 00 00 00    	je     80144c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8013ba:	57                   	push   %edi
  8013bb:	e8 86 02 00 00       	call   801646 <strnlen>
  8013c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013c3:	29 c1                	sub    %eax,%ecx
  8013c5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013c8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013cb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013d2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013d5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d7:	eb 0f                	jmp    8013e8 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8013e0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e2:	83 ef 01             	sub    $0x1,%edi
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	85 ff                	test   %edi,%edi
  8013ea:	7f ed                	jg     8013d9 <vprintfmt+0x1c0>
  8013ec:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013ef:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8013f2:	85 c9                	test   %ecx,%ecx
  8013f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f9:	0f 49 c1             	cmovns %ecx,%eax
  8013fc:	29 c1                	sub    %eax,%ecx
  8013fe:	89 75 08             	mov    %esi,0x8(%ebp)
  801401:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801404:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801407:	89 cb                	mov    %ecx,%ebx
  801409:	eb 4d                	jmp    801458 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80140b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80140f:	74 1b                	je     80142c <vprintfmt+0x213>
  801411:	0f be c0             	movsbl %al,%eax
  801414:	83 e8 20             	sub    $0x20,%eax
  801417:	83 f8 5e             	cmp    $0x5e,%eax
  80141a:	76 10                	jbe    80142c <vprintfmt+0x213>
					putch('?', putdat);
  80141c:	83 ec 08             	sub    $0x8,%esp
  80141f:	ff 75 0c             	pushl  0xc(%ebp)
  801422:	6a 3f                	push   $0x3f
  801424:	ff 55 08             	call   *0x8(%ebp)
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	eb 0d                	jmp    801439 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	ff 75 0c             	pushl  0xc(%ebp)
  801432:	52                   	push   %edx
  801433:	ff 55 08             	call   *0x8(%ebp)
  801436:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801439:	83 eb 01             	sub    $0x1,%ebx
  80143c:	eb 1a                	jmp    801458 <vprintfmt+0x23f>
  80143e:	89 75 08             	mov    %esi,0x8(%ebp)
  801441:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801444:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801447:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80144a:	eb 0c                	jmp    801458 <vprintfmt+0x23f>
  80144c:	89 75 08             	mov    %esi,0x8(%ebp)
  80144f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801452:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801455:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801458:	83 c7 01             	add    $0x1,%edi
  80145b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80145f:	0f be d0             	movsbl %al,%edx
  801462:	85 d2                	test   %edx,%edx
  801464:	74 23                	je     801489 <vprintfmt+0x270>
  801466:	85 f6                	test   %esi,%esi
  801468:	78 a1                	js     80140b <vprintfmt+0x1f2>
  80146a:	83 ee 01             	sub    $0x1,%esi
  80146d:	79 9c                	jns    80140b <vprintfmt+0x1f2>
  80146f:	89 df                	mov    %ebx,%edi
  801471:	8b 75 08             	mov    0x8(%ebp),%esi
  801474:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801477:	eb 18                	jmp    801491 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	53                   	push   %ebx
  80147d:	6a 20                	push   $0x20
  80147f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801481:	83 ef 01             	sub    $0x1,%edi
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	eb 08                	jmp    801491 <vprintfmt+0x278>
  801489:	89 df                	mov    %ebx,%edi
  80148b:	8b 75 08             	mov    0x8(%ebp),%esi
  80148e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801491:	85 ff                	test   %edi,%edi
  801493:	7f e4                	jg     801479 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801498:	e9 a2 fd ff ff       	jmp    80123f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80149d:	83 fa 01             	cmp    $0x1,%edx
  8014a0:	7e 16                	jle    8014b8 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a5:	8d 50 08             	lea    0x8(%eax),%edx
  8014a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ab:	8b 50 04             	mov    0x4(%eax),%edx
  8014ae:	8b 00                	mov    (%eax),%eax
  8014b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014b6:	eb 32                	jmp    8014ea <vprintfmt+0x2d1>
	else if (lflag)
  8014b8:	85 d2                	test   %edx,%edx
  8014ba:	74 18                	je     8014d4 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bf:	8d 50 04             	lea    0x4(%eax),%edx
  8014c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c5:	8b 00                	mov    (%eax),%eax
  8014c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ca:	89 c1                	mov    %eax,%ecx
  8014cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8014cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014d2:	eb 16                	jmp    8014ea <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d7:	8d 50 04             	lea    0x4(%eax),%edx
  8014da:	89 55 14             	mov    %edx,0x14(%ebp)
  8014dd:	8b 00                	mov    (%eax),%eax
  8014df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e2:	89 c1                	mov    %eax,%ecx
  8014e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014f5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014f9:	79 74                	jns    80156f <vprintfmt+0x356>
				putch('-', putdat);
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	53                   	push   %ebx
  8014ff:	6a 2d                	push   $0x2d
  801501:	ff d6                	call   *%esi
				num = -(long long) num;
  801503:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801506:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801509:	f7 d8                	neg    %eax
  80150b:	83 d2 00             	adc    $0x0,%edx
  80150e:	f7 da                	neg    %edx
  801510:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801513:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801518:	eb 55                	jmp    80156f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80151a:	8d 45 14             	lea    0x14(%ebp),%eax
  80151d:	e8 83 fc ff ff       	call   8011a5 <getuint>
			base = 10;
  801522:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801527:	eb 46                	jmp    80156f <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801529:	8d 45 14             	lea    0x14(%ebp),%eax
  80152c:	e8 74 fc ff ff       	call   8011a5 <getuint>
			base = 8;
  801531:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801536:	eb 37                	jmp    80156f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	53                   	push   %ebx
  80153c:	6a 30                	push   $0x30
  80153e:	ff d6                	call   *%esi
			putch('x', putdat);
  801540:	83 c4 08             	add    $0x8,%esp
  801543:	53                   	push   %ebx
  801544:	6a 78                	push   $0x78
  801546:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801548:	8b 45 14             	mov    0x14(%ebp),%eax
  80154b:	8d 50 04             	lea    0x4(%eax),%edx
  80154e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801551:	8b 00                	mov    (%eax),%eax
  801553:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801558:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80155b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801560:	eb 0d                	jmp    80156f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801562:	8d 45 14             	lea    0x14(%ebp),%eax
  801565:	e8 3b fc ff ff       	call   8011a5 <getuint>
			base = 16;
  80156a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80156f:	83 ec 0c             	sub    $0xc,%esp
  801572:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801576:	57                   	push   %edi
  801577:	ff 75 e0             	pushl  -0x20(%ebp)
  80157a:	51                   	push   %ecx
  80157b:	52                   	push   %edx
  80157c:	50                   	push   %eax
  80157d:	89 da                	mov    %ebx,%edx
  80157f:	89 f0                	mov    %esi,%eax
  801581:	e8 70 fb ff ff       	call   8010f6 <printnum>
			break;
  801586:	83 c4 20             	add    $0x20,%esp
  801589:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80158c:	e9 ae fc ff ff       	jmp    80123f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	53                   	push   %ebx
  801595:	51                   	push   %ecx
  801596:	ff d6                	call   *%esi
			break;
  801598:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80159b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80159e:	e9 9c fc ff ff       	jmp    80123f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	6a 25                	push   $0x25
  8015a9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	eb 03                	jmp    8015b3 <vprintfmt+0x39a>
  8015b0:	83 ef 01             	sub    $0x1,%edi
  8015b3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015b7:	75 f7                	jne    8015b0 <vprintfmt+0x397>
  8015b9:	e9 81 fc ff ff       	jmp    80123f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c1:	5b                   	pop    %ebx
  8015c2:	5e                   	pop    %esi
  8015c3:	5f                   	pop    %edi
  8015c4:	5d                   	pop    %ebp
  8015c5:	c3                   	ret    

008015c6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	83 ec 18             	sub    $0x18,%esp
  8015cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015d5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015d9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	74 26                	je     80160d <vsnprintf+0x47>
  8015e7:	85 d2                	test   %edx,%edx
  8015e9:	7e 22                	jle    80160d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015eb:	ff 75 14             	pushl  0x14(%ebp)
  8015ee:	ff 75 10             	pushl  0x10(%ebp)
  8015f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	68 df 11 80 00       	push   $0x8011df
  8015fa:	e8 1a fc ff ff       	call   801219 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801602:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801605:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	eb 05                	jmp    801612 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80160d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80161a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80161d:	50                   	push   %eax
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	ff 75 08             	pushl  0x8(%ebp)
  801627:	e8 9a ff ff ff       	call   8015c6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801634:	b8 00 00 00 00       	mov    $0x0,%eax
  801639:	eb 03                	jmp    80163e <strlen+0x10>
		n++;
  80163b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80163e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801642:	75 f7                	jne    80163b <strlen+0xd>
		n++;
	return n;
}
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80164c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80164f:	ba 00 00 00 00       	mov    $0x0,%edx
  801654:	eb 03                	jmp    801659 <strnlen+0x13>
		n++;
  801656:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801659:	39 c2                	cmp    %eax,%edx
  80165b:	74 08                	je     801665 <strnlen+0x1f>
  80165d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801661:	75 f3                	jne    801656 <strnlen+0x10>
  801663:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	53                   	push   %ebx
  80166b:	8b 45 08             	mov    0x8(%ebp),%eax
  80166e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801671:	89 c2                	mov    %eax,%edx
  801673:	83 c2 01             	add    $0x1,%edx
  801676:	83 c1 01             	add    $0x1,%ecx
  801679:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80167d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801680:	84 db                	test   %bl,%bl
  801682:	75 ef                	jne    801673 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801684:	5b                   	pop    %ebx
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	53                   	push   %ebx
  80168b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80168e:	53                   	push   %ebx
  80168f:	e8 9a ff ff ff       	call   80162e <strlen>
  801694:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801697:	ff 75 0c             	pushl  0xc(%ebp)
  80169a:	01 d8                	add    %ebx,%eax
  80169c:	50                   	push   %eax
  80169d:	e8 c5 ff ff ff       	call   801667 <strcpy>
	return dst;
}
  8016a2:	89 d8                	mov    %ebx,%eax
  8016a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	56                   	push   %esi
  8016ad:	53                   	push   %ebx
  8016ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8016b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b4:	89 f3                	mov    %esi,%ebx
  8016b6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016b9:	89 f2                	mov    %esi,%edx
  8016bb:	eb 0f                	jmp    8016cc <strncpy+0x23>
		*dst++ = *src;
  8016bd:	83 c2 01             	add    $0x1,%edx
  8016c0:	0f b6 01             	movzbl (%ecx),%eax
  8016c3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016c6:	80 39 01             	cmpb   $0x1,(%ecx)
  8016c9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016cc:	39 da                	cmp    %ebx,%edx
  8016ce:	75 ed                	jne    8016bd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016d0:	89 f0                	mov    %esi,%eax
  8016d2:	5b                   	pop    %ebx
  8016d3:	5e                   	pop    %esi
  8016d4:	5d                   	pop    %ebp
  8016d5:	c3                   	ret    

008016d6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	56                   	push   %esi
  8016da:	53                   	push   %ebx
  8016db:	8b 75 08             	mov    0x8(%ebp),%esi
  8016de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e1:	8b 55 10             	mov    0x10(%ebp),%edx
  8016e4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016e6:	85 d2                	test   %edx,%edx
  8016e8:	74 21                	je     80170b <strlcpy+0x35>
  8016ea:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8016ee:	89 f2                	mov    %esi,%edx
  8016f0:	eb 09                	jmp    8016fb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016f2:	83 c2 01             	add    $0x1,%edx
  8016f5:	83 c1 01             	add    $0x1,%ecx
  8016f8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016fb:	39 c2                	cmp    %eax,%edx
  8016fd:	74 09                	je     801708 <strlcpy+0x32>
  8016ff:	0f b6 19             	movzbl (%ecx),%ebx
  801702:	84 db                	test   %bl,%bl
  801704:	75 ec                	jne    8016f2 <strlcpy+0x1c>
  801706:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801708:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80170b:	29 f0                	sub    %esi,%eax
}
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    

00801711 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801717:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80171a:	eb 06                	jmp    801722 <strcmp+0x11>
		p++, q++;
  80171c:	83 c1 01             	add    $0x1,%ecx
  80171f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801722:	0f b6 01             	movzbl (%ecx),%eax
  801725:	84 c0                	test   %al,%al
  801727:	74 04                	je     80172d <strcmp+0x1c>
  801729:	3a 02                	cmp    (%edx),%al
  80172b:	74 ef                	je     80171c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80172d:	0f b6 c0             	movzbl %al,%eax
  801730:	0f b6 12             	movzbl (%edx),%edx
  801733:	29 d0                	sub    %edx,%eax
}
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	8b 45 08             	mov    0x8(%ebp),%eax
  80173e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801741:	89 c3                	mov    %eax,%ebx
  801743:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801746:	eb 06                	jmp    80174e <strncmp+0x17>
		n--, p++, q++;
  801748:	83 c0 01             	add    $0x1,%eax
  80174b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80174e:	39 d8                	cmp    %ebx,%eax
  801750:	74 15                	je     801767 <strncmp+0x30>
  801752:	0f b6 08             	movzbl (%eax),%ecx
  801755:	84 c9                	test   %cl,%cl
  801757:	74 04                	je     80175d <strncmp+0x26>
  801759:	3a 0a                	cmp    (%edx),%cl
  80175b:	74 eb                	je     801748 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80175d:	0f b6 00             	movzbl (%eax),%eax
  801760:	0f b6 12             	movzbl (%edx),%edx
  801763:	29 d0                	sub    %edx,%eax
  801765:	eb 05                	jmp    80176c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80176c:	5b                   	pop    %ebx
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	8b 45 08             	mov    0x8(%ebp),%eax
  801775:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801779:	eb 07                	jmp    801782 <strchr+0x13>
		if (*s == c)
  80177b:	38 ca                	cmp    %cl,%dl
  80177d:	74 0f                	je     80178e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80177f:	83 c0 01             	add    $0x1,%eax
  801782:	0f b6 10             	movzbl (%eax),%edx
  801785:	84 d2                	test   %dl,%dl
  801787:	75 f2                	jne    80177b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80179a:	eb 03                	jmp    80179f <strfind+0xf>
  80179c:	83 c0 01             	add    $0x1,%eax
  80179f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017a2:	38 ca                	cmp    %cl,%dl
  8017a4:	74 04                	je     8017aa <strfind+0x1a>
  8017a6:	84 d2                	test   %dl,%dl
  8017a8:	75 f2                	jne    80179c <strfind+0xc>
			break;
	return (char *) s;
}
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	57                   	push   %edi
  8017b0:	56                   	push   %esi
  8017b1:	53                   	push   %ebx
  8017b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017b8:	85 c9                	test   %ecx,%ecx
  8017ba:	74 36                	je     8017f2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017c2:	75 28                	jne    8017ec <memset+0x40>
  8017c4:	f6 c1 03             	test   $0x3,%cl
  8017c7:	75 23                	jne    8017ec <memset+0x40>
		c &= 0xFF;
  8017c9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017cd:	89 d3                	mov    %edx,%ebx
  8017cf:	c1 e3 08             	shl    $0x8,%ebx
  8017d2:	89 d6                	mov    %edx,%esi
  8017d4:	c1 e6 18             	shl    $0x18,%esi
  8017d7:	89 d0                	mov    %edx,%eax
  8017d9:	c1 e0 10             	shl    $0x10,%eax
  8017dc:	09 f0                	or     %esi,%eax
  8017de:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8017e0:	89 d8                	mov    %ebx,%eax
  8017e2:	09 d0                	or     %edx,%eax
  8017e4:	c1 e9 02             	shr    $0x2,%ecx
  8017e7:	fc                   	cld    
  8017e8:	f3 ab                	rep stos %eax,%es:(%edi)
  8017ea:	eb 06                	jmp    8017f2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ef:	fc                   	cld    
  8017f0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017f2:	89 f8                	mov    %edi,%eax
  8017f4:	5b                   	pop    %ebx
  8017f5:	5e                   	pop    %esi
  8017f6:	5f                   	pop    %edi
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    

008017f9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	57                   	push   %edi
  8017fd:	56                   	push   %esi
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 75 0c             	mov    0xc(%ebp),%esi
  801804:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801807:	39 c6                	cmp    %eax,%esi
  801809:	73 35                	jae    801840 <memmove+0x47>
  80180b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80180e:	39 d0                	cmp    %edx,%eax
  801810:	73 2e                	jae    801840 <memmove+0x47>
		s += n;
		d += n;
  801812:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801815:	89 d6                	mov    %edx,%esi
  801817:	09 fe                	or     %edi,%esi
  801819:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80181f:	75 13                	jne    801834 <memmove+0x3b>
  801821:	f6 c1 03             	test   $0x3,%cl
  801824:	75 0e                	jne    801834 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801826:	83 ef 04             	sub    $0x4,%edi
  801829:	8d 72 fc             	lea    -0x4(%edx),%esi
  80182c:	c1 e9 02             	shr    $0x2,%ecx
  80182f:	fd                   	std    
  801830:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801832:	eb 09                	jmp    80183d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801834:	83 ef 01             	sub    $0x1,%edi
  801837:	8d 72 ff             	lea    -0x1(%edx),%esi
  80183a:	fd                   	std    
  80183b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80183d:	fc                   	cld    
  80183e:	eb 1d                	jmp    80185d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801840:	89 f2                	mov    %esi,%edx
  801842:	09 c2                	or     %eax,%edx
  801844:	f6 c2 03             	test   $0x3,%dl
  801847:	75 0f                	jne    801858 <memmove+0x5f>
  801849:	f6 c1 03             	test   $0x3,%cl
  80184c:	75 0a                	jne    801858 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80184e:	c1 e9 02             	shr    $0x2,%ecx
  801851:	89 c7                	mov    %eax,%edi
  801853:	fc                   	cld    
  801854:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801856:	eb 05                	jmp    80185d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801858:	89 c7                	mov    %eax,%edi
  80185a:	fc                   	cld    
  80185b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80185d:	5e                   	pop    %esi
  80185e:	5f                   	pop    %edi
  80185f:	5d                   	pop    %ebp
  801860:	c3                   	ret    

00801861 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801864:	ff 75 10             	pushl  0x10(%ebp)
  801867:	ff 75 0c             	pushl  0xc(%ebp)
  80186a:	ff 75 08             	pushl  0x8(%ebp)
  80186d:	e8 87 ff ff ff       	call   8017f9 <memmove>
}
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	56                   	push   %esi
  801878:	53                   	push   %ebx
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187f:	89 c6                	mov    %eax,%esi
  801881:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801884:	eb 1a                	jmp    8018a0 <memcmp+0x2c>
		if (*s1 != *s2)
  801886:	0f b6 08             	movzbl (%eax),%ecx
  801889:	0f b6 1a             	movzbl (%edx),%ebx
  80188c:	38 d9                	cmp    %bl,%cl
  80188e:	74 0a                	je     80189a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801890:	0f b6 c1             	movzbl %cl,%eax
  801893:	0f b6 db             	movzbl %bl,%ebx
  801896:	29 d8                	sub    %ebx,%eax
  801898:	eb 0f                	jmp    8018a9 <memcmp+0x35>
		s1++, s2++;
  80189a:	83 c0 01             	add    $0x1,%eax
  80189d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a0:	39 f0                	cmp    %esi,%eax
  8018a2:	75 e2                	jne    801886 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a9:	5b                   	pop    %ebx
  8018aa:	5e                   	pop    %esi
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	53                   	push   %ebx
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018b4:	89 c1                	mov    %eax,%ecx
  8018b6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018b9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018bd:	eb 0a                	jmp    8018c9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018bf:	0f b6 10             	movzbl (%eax),%edx
  8018c2:	39 da                	cmp    %ebx,%edx
  8018c4:	74 07                	je     8018cd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018c6:	83 c0 01             	add    $0x1,%eax
  8018c9:	39 c8                	cmp    %ecx,%eax
  8018cb:	72 f2                	jb     8018bf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018cd:	5b                   	pop    %ebx
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	57                   	push   %edi
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018dc:	eb 03                	jmp    8018e1 <strtol+0x11>
		s++;
  8018de:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018e1:	0f b6 01             	movzbl (%ecx),%eax
  8018e4:	3c 20                	cmp    $0x20,%al
  8018e6:	74 f6                	je     8018de <strtol+0xe>
  8018e8:	3c 09                	cmp    $0x9,%al
  8018ea:	74 f2                	je     8018de <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8018ec:	3c 2b                	cmp    $0x2b,%al
  8018ee:	75 0a                	jne    8018fa <strtol+0x2a>
		s++;
  8018f0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8018f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8018f8:	eb 11                	jmp    80190b <strtol+0x3b>
  8018fa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8018ff:	3c 2d                	cmp    $0x2d,%al
  801901:	75 08                	jne    80190b <strtol+0x3b>
		s++, neg = 1;
  801903:	83 c1 01             	add    $0x1,%ecx
  801906:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80190b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801911:	75 15                	jne    801928 <strtol+0x58>
  801913:	80 39 30             	cmpb   $0x30,(%ecx)
  801916:	75 10                	jne    801928 <strtol+0x58>
  801918:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80191c:	75 7c                	jne    80199a <strtol+0xca>
		s += 2, base = 16;
  80191e:	83 c1 02             	add    $0x2,%ecx
  801921:	bb 10 00 00 00       	mov    $0x10,%ebx
  801926:	eb 16                	jmp    80193e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801928:	85 db                	test   %ebx,%ebx
  80192a:	75 12                	jne    80193e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80192c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801931:	80 39 30             	cmpb   $0x30,(%ecx)
  801934:	75 08                	jne    80193e <strtol+0x6e>
		s++, base = 8;
  801936:	83 c1 01             	add    $0x1,%ecx
  801939:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80193e:	b8 00 00 00 00       	mov    $0x0,%eax
  801943:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801946:	0f b6 11             	movzbl (%ecx),%edx
  801949:	8d 72 d0             	lea    -0x30(%edx),%esi
  80194c:	89 f3                	mov    %esi,%ebx
  80194e:	80 fb 09             	cmp    $0x9,%bl
  801951:	77 08                	ja     80195b <strtol+0x8b>
			dig = *s - '0';
  801953:	0f be d2             	movsbl %dl,%edx
  801956:	83 ea 30             	sub    $0x30,%edx
  801959:	eb 22                	jmp    80197d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80195b:	8d 72 9f             	lea    -0x61(%edx),%esi
  80195e:	89 f3                	mov    %esi,%ebx
  801960:	80 fb 19             	cmp    $0x19,%bl
  801963:	77 08                	ja     80196d <strtol+0x9d>
			dig = *s - 'a' + 10;
  801965:	0f be d2             	movsbl %dl,%edx
  801968:	83 ea 57             	sub    $0x57,%edx
  80196b:	eb 10                	jmp    80197d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80196d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801970:	89 f3                	mov    %esi,%ebx
  801972:	80 fb 19             	cmp    $0x19,%bl
  801975:	77 16                	ja     80198d <strtol+0xbd>
			dig = *s - 'A' + 10;
  801977:	0f be d2             	movsbl %dl,%edx
  80197a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80197d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801980:	7d 0b                	jge    80198d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801982:	83 c1 01             	add    $0x1,%ecx
  801985:	0f af 45 10          	imul   0x10(%ebp),%eax
  801989:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80198b:	eb b9                	jmp    801946 <strtol+0x76>

	if (endptr)
  80198d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801991:	74 0d                	je     8019a0 <strtol+0xd0>
		*endptr = (char *) s;
  801993:	8b 75 0c             	mov    0xc(%ebp),%esi
  801996:	89 0e                	mov    %ecx,(%esi)
  801998:	eb 06                	jmp    8019a0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80199a:	85 db                	test   %ebx,%ebx
  80199c:	74 98                	je     801936 <strtol+0x66>
  80199e:	eb 9e                	jmp    80193e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019a0:	89 c2                	mov    %eax,%edx
  8019a2:	f7 da                	neg    %edx
  8019a4:	85 ff                	test   %edi,%edi
  8019a6:	0f 45 c2             	cmovne %edx,%eax
}
  8019a9:	5b                   	pop    %ebx
  8019aa:	5e                   	pop    %esi
  8019ab:	5f                   	pop    %edi
  8019ac:	5d                   	pop    %ebp
  8019ad:	c3                   	ret    

008019ae <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	56                   	push   %esi
  8019b2:	53                   	push   %ebx
  8019b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8019b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019bc:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019be:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019c3:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	50                   	push   %eax
  8019ca:	e8 3b e9 ff ff       	call   80030a <sys_ipc_recv>

	if (from_env_store != NULL)
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	85 f6                	test   %esi,%esi
  8019d4:	74 14                	je     8019ea <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 09                	js     8019e8 <ipc_recv+0x3a>
  8019df:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019e5:	8b 52 74             	mov    0x74(%edx),%edx
  8019e8:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8019ea:	85 db                	test   %ebx,%ebx
  8019ec:	74 14                	je     801a02 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8019ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 09                	js     801a00 <ipc_recv+0x52>
  8019f7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019fd:	8b 52 78             	mov    0x78(%edx),%edx
  801a00:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a02:	85 c0                	test   %eax,%eax
  801a04:	78 08                	js     801a0e <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a06:	a1 04 40 80 00       	mov    0x804004,%eax
  801a0b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a11:	5b                   	pop    %ebx
  801a12:	5e                   	pop    %esi
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	57                   	push   %edi
  801a19:	56                   	push   %esi
  801a1a:	53                   	push   %ebx
  801a1b:	83 ec 0c             	sub    $0xc,%esp
  801a1e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a21:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a27:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a29:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a2e:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a31:	ff 75 14             	pushl  0x14(%ebp)
  801a34:	53                   	push   %ebx
  801a35:	56                   	push   %esi
  801a36:	57                   	push   %edi
  801a37:	e8 ab e8 ff ff       	call   8002e7 <sys_ipc_try_send>

		if (err < 0) {
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	79 1e                	jns    801a61 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a43:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a46:	75 07                	jne    801a4f <ipc_send+0x3a>
				sys_yield();
  801a48:	e8 ee e6 ff ff       	call   80013b <sys_yield>
  801a4d:	eb e2                	jmp    801a31 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a4f:	50                   	push   %eax
  801a50:	68 e0 21 80 00       	push   $0x8021e0
  801a55:	6a 49                	push   $0x49
  801a57:	68 ed 21 80 00       	push   $0x8021ed
  801a5c:	e8 a8 f5 ff ff       	call   801009 <_panic>
		}

	} while (err < 0);

}
  801a61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5f                   	pop    %edi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a6f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a74:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a77:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a7d:	8b 52 50             	mov    0x50(%edx),%edx
  801a80:	39 ca                	cmp    %ecx,%edx
  801a82:	75 0d                	jne    801a91 <ipc_find_env+0x28>
			return envs[i].env_id;
  801a84:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a87:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a8c:	8b 40 48             	mov    0x48(%eax),%eax
  801a8f:	eb 0f                	jmp    801aa0 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a91:	83 c0 01             	add    $0x1,%eax
  801a94:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a99:	75 d9                	jne    801a74 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801a9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aa8:	89 d0                	mov    %edx,%eax
  801aaa:	c1 e8 16             	shr    $0x16,%eax
  801aad:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ab4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ab9:	f6 c1 01             	test   $0x1,%cl
  801abc:	74 1d                	je     801adb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801abe:	c1 ea 0c             	shr    $0xc,%edx
  801ac1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ac8:	f6 c2 01             	test   $0x1,%dl
  801acb:	74 0e                	je     801adb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801acd:	c1 ea 0c             	shr    $0xc,%edx
  801ad0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ad7:	ef 
  801ad8:	0f b7 c0             	movzwl %ax,%eax
}
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    
  801add:	66 90                	xchg   %ax,%ax
  801adf:	90                   	nop

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
