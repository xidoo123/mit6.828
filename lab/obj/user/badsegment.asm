
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
  800103:	68 aa 1d 80 00       	push   $0x801daa
  800108:	6a 23                	push   $0x23
  80010a:	68 c7 1d 80 00       	push   $0x801dc7
  80010f:	e8 14 0f 00 00       	call   801028 <_panic>

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
  800184:	68 aa 1d 80 00       	push   $0x801daa
  800189:	6a 23                	push   $0x23
  80018b:	68 c7 1d 80 00       	push   $0x801dc7
  800190:	e8 93 0e 00 00       	call   801028 <_panic>

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
  8001c6:	68 aa 1d 80 00       	push   $0x801daa
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 c7 1d 80 00       	push   $0x801dc7
  8001d2:	e8 51 0e 00 00       	call   801028 <_panic>

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
  800208:	68 aa 1d 80 00       	push   $0x801daa
  80020d:	6a 23                	push   $0x23
  80020f:	68 c7 1d 80 00       	push   $0x801dc7
  800214:	e8 0f 0e 00 00       	call   801028 <_panic>

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
  80024a:	68 aa 1d 80 00       	push   $0x801daa
  80024f:	6a 23                	push   $0x23
  800251:	68 c7 1d 80 00       	push   $0x801dc7
  800256:	e8 cd 0d 00 00       	call   801028 <_panic>

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
  80028c:	68 aa 1d 80 00       	push   $0x801daa
  800291:	6a 23                	push   $0x23
  800293:	68 c7 1d 80 00       	push   $0x801dc7
  800298:	e8 8b 0d 00 00       	call   801028 <_panic>

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
  8002ce:	68 aa 1d 80 00       	push   $0x801daa
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 c7 1d 80 00       	push   $0x801dc7
  8002da:	e8 49 0d 00 00       	call   801028 <_panic>

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
  800332:	68 aa 1d 80 00       	push   $0x801daa
  800337:	6a 23                	push   $0x23
  800339:	68 c7 1d 80 00       	push   $0x801dc7
  80033e:	e8 e5 0c 00 00       	call   801028 <_panic>

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
  800420:	ba 54 1e 80 00       	mov    $0x801e54,%edx
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
  80044d:	68 d8 1d 80 00       	push   $0x801dd8
  800452:	e8 aa 0c 00 00       	call   801101 <cprintf>
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
  800677:	68 19 1e 80 00       	push   $0x801e19
  80067c:	e8 80 0a 00 00       	call   801101 <cprintf>
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
  80074c:	68 35 1e 80 00       	push   $0x801e35
  800751:	e8 ab 09 00 00       	call   801101 <cprintf>
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
  800801:	68 f8 1d 80 00       	push   $0x801df8
  800806:	e8 f6 08 00 00       	call   801101 <cprintf>
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
  8008ca:	e8 d6 01 00 00       	call   800aa5 <open>
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
  800911:	e8 72 11 00 00       	call   801a88 <ipc_find_env>
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
  80092c:	e8 03 11 00 00       	call   801a34 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800931:	83 c4 0c             	add    $0xc,%esp
  800934:	6a 00                	push   $0x0
  800936:	53                   	push   %ebx
  800937:	6a 00                	push   $0x0
  800939:	e8 8f 10 00 00       	call   8019cd <ipc_recv>
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
  8009c2:	e8 bf 0c 00 00       	call   801686 <strcpy>
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
  8009f0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009ff:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a04:	50                   	push   %eax
  800a05:	ff 75 0c             	pushl  0xc(%ebp)
  800a08:	68 08 50 80 00       	push   $0x805008
  800a0d:	e8 06 0e 00 00       	call   801818 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a12:	ba 00 00 00 00       	mov    $0x0,%edx
  800a17:	b8 04 00 00 00       	mov    $0x4,%eax
  800a1c:	e8 d9 fe ff ff       	call   8008fa <fsipc>

}
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a31:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a36:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a41:	b8 03 00 00 00       	mov    $0x3,%eax
  800a46:	e8 af fe ff ff       	call   8008fa <fsipc>
  800a4b:	89 c3                	mov    %eax,%ebx
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	78 4b                	js     800a9c <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a51:	39 c6                	cmp    %eax,%esi
  800a53:	73 16                	jae    800a6b <devfile_read+0x48>
  800a55:	68 64 1e 80 00       	push   $0x801e64
  800a5a:	68 6b 1e 80 00       	push   $0x801e6b
  800a5f:	6a 7c                	push   $0x7c
  800a61:	68 80 1e 80 00       	push   $0x801e80
  800a66:	e8 bd 05 00 00       	call   801028 <_panic>
	assert(r <= PGSIZE);
  800a6b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a70:	7e 16                	jle    800a88 <devfile_read+0x65>
  800a72:	68 8b 1e 80 00       	push   $0x801e8b
  800a77:	68 6b 1e 80 00       	push   $0x801e6b
  800a7c:	6a 7d                	push   $0x7d
  800a7e:	68 80 1e 80 00       	push   $0x801e80
  800a83:	e8 a0 05 00 00       	call   801028 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a88:	83 ec 04             	sub    $0x4,%esp
  800a8b:	50                   	push   %eax
  800a8c:	68 00 50 80 00       	push   $0x805000
  800a91:	ff 75 0c             	pushl  0xc(%ebp)
  800a94:	e8 7f 0d 00 00       	call   801818 <memmove>
	return r;
  800a99:	83 c4 10             	add    $0x10,%esp
}
  800a9c:	89 d8                	mov    %ebx,%eax
  800a9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	53                   	push   %ebx
  800aa9:	83 ec 20             	sub    $0x20,%esp
  800aac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aaf:	53                   	push   %ebx
  800ab0:	e8 98 0b 00 00       	call   80164d <strlen>
  800ab5:	83 c4 10             	add    $0x10,%esp
  800ab8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800abd:	7f 67                	jg     800b26 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac5:	50                   	push   %eax
  800ac6:	e8 a7 f8 ff ff       	call   800372 <fd_alloc>
  800acb:	83 c4 10             	add    $0x10,%esp
		return r;
  800ace:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	78 57                	js     800b2b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ad4:	83 ec 08             	sub    $0x8,%esp
  800ad7:	53                   	push   %ebx
  800ad8:	68 00 50 80 00       	push   $0x805000
  800add:	e8 a4 0b 00 00       	call   801686 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	e8 03 fe ff ff       	call   8008fa <fsipc>
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	83 c4 10             	add    $0x10,%esp
  800afc:	85 c0                	test   %eax,%eax
  800afe:	79 14                	jns    800b14 <open+0x6f>
		fd_close(fd, 0);
  800b00:	83 ec 08             	sub    $0x8,%esp
  800b03:	6a 00                	push   $0x0
  800b05:	ff 75 f4             	pushl  -0xc(%ebp)
  800b08:	e8 5d f9 ff ff       	call   80046a <fd_close>
		return r;
  800b0d:	83 c4 10             	add    $0x10,%esp
  800b10:	89 da                	mov    %ebx,%edx
  800b12:	eb 17                	jmp    800b2b <open+0x86>
	}

	return fd2num(fd);
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1a:	e8 2c f8 ff ff       	call   80034b <fd2num>
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	83 c4 10             	add    $0x10,%esp
  800b24:	eb 05                	jmp    800b2b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b26:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b2b:	89 d0                	mov    %edx,%eax
  800b2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b30:	c9                   	leave  
  800b31:	c3                   	ret    

00800b32 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b42:	e8 b3 fd ff ff       	call   8008fa <fsipc>
}
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	ff 75 08             	pushl  0x8(%ebp)
  800b57:	e8 ff f7 ff ff       	call   80035b <fd2data>
  800b5c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b5e:	83 c4 08             	add    $0x8,%esp
  800b61:	68 97 1e 80 00       	push   $0x801e97
  800b66:	53                   	push   %ebx
  800b67:	e8 1a 0b 00 00       	call   801686 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b6c:	8b 46 04             	mov    0x4(%esi),%eax
  800b6f:	2b 06                	sub    (%esi),%eax
  800b71:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b77:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b7e:	00 00 00 
	stat->st_dev = &devpipe;
  800b81:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b88:	30 80 00 
	return 0;
}
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba1:	53                   	push   %ebx
  800ba2:	6a 00                	push   $0x0
  800ba4:	e8 36 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800ba9:	89 1c 24             	mov    %ebx,(%esp)
  800bac:	e8 aa f7 ff ff       	call   80035b <fd2data>
  800bb1:	83 c4 08             	add    $0x8,%esp
  800bb4:	50                   	push   %eax
  800bb5:	6a 00                	push   $0x0
  800bb7:	e8 23 f6 ff ff       	call   8001df <sys_page_unmap>
}
  800bbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 1c             	sub    $0x1c,%esp
  800bca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bcd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bcf:	a1 04 40 80 00       	mov    0x804004,%eax
  800bd4:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	ff 75 e0             	pushl  -0x20(%ebp)
  800bdd:	e8 df 0e 00 00       	call   801ac1 <pageref>
  800be2:	89 c3                	mov    %eax,%ebx
  800be4:	89 3c 24             	mov    %edi,(%esp)
  800be7:	e8 d5 0e 00 00       	call   801ac1 <pageref>
  800bec:	83 c4 10             	add    $0x10,%esp
  800bef:	39 c3                	cmp    %eax,%ebx
  800bf1:	0f 94 c1             	sete   %cl
  800bf4:	0f b6 c9             	movzbl %cl,%ecx
  800bf7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bfa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c00:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c03:	39 ce                	cmp    %ecx,%esi
  800c05:	74 1b                	je     800c22 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c07:	39 c3                	cmp    %eax,%ebx
  800c09:	75 c4                	jne    800bcf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c0b:	8b 42 58             	mov    0x58(%edx),%eax
  800c0e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c11:	50                   	push   %eax
  800c12:	56                   	push   %esi
  800c13:	68 9e 1e 80 00       	push   $0x801e9e
  800c18:	e8 e4 04 00 00       	call   801101 <cprintf>
  800c1d:	83 c4 10             	add    $0x10,%esp
  800c20:	eb ad                	jmp    800bcf <_pipeisclosed+0xe>
	}
}
  800c22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 28             	sub    $0x28,%esp
  800c36:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c39:	56                   	push   %esi
  800c3a:	e8 1c f7 ff ff       	call   80035b <fd2data>
  800c3f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	bf 00 00 00 00       	mov    $0x0,%edi
  800c49:	eb 4b                	jmp    800c96 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c4b:	89 da                	mov    %ebx,%edx
  800c4d:	89 f0                	mov    %esi,%eax
  800c4f:	e8 6d ff ff ff       	call   800bc1 <_pipeisclosed>
  800c54:	85 c0                	test   %eax,%eax
  800c56:	75 48                	jne    800ca0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c58:	e8 de f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c5d:	8b 43 04             	mov    0x4(%ebx),%eax
  800c60:	8b 0b                	mov    (%ebx),%ecx
  800c62:	8d 51 20             	lea    0x20(%ecx),%edx
  800c65:	39 d0                	cmp    %edx,%eax
  800c67:	73 e2                	jae    800c4b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c70:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c73:	89 c2                	mov    %eax,%edx
  800c75:	c1 fa 1f             	sar    $0x1f,%edx
  800c78:	89 d1                	mov    %edx,%ecx
  800c7a:	c1 e9 1b             	shr    $0x1b,%ecx
  800c7d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c80:	83 e2 1f             	and    $0x1f,%edx
  800c83:	29 ca                	sub    %ecx,%edx
  800c85:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c89:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c8d:	83 c0 01             	add    $0x1,%eax
  800c90:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c93:	83 c7 01             	add    $0x1,%edi
  800c96:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c99:	75 c2                	jne    800c5d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c9b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9e:	eb 05                	jmp    800ca5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 18             	sub    $0x18,%esp
  800cb6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cb9:	57                   	push   %edi
  800cba:	e8 9c f6 ff ff       	call   80035b <fd2data>
  800cbf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc1:	83 c4 10             	add    $0x10,%esp
  800cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc9:	eb 3d                	jmp    800d08 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ccb:	85 db                	test   %ebx,%ebx
  800ccd:	74 04                	je     800cd3 <devpipe_read+0x26>
				return i;
  800ccf:	89 d8                	mov    %ebx,%eax
  800cd1:	eb 44                	jmp    800d17 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cd3:	89 f2                	mov    %esi,%edx
  800cd5:	89 f8                	mov    %edi,%eax
  800cd7:	e8 e5 fe ff ff       	call   800bc1 <_pipeisclosed>
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	75 32                	jne    800d12 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ce0:	e8 56 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ce5:	8b 06                	mov    (%esi),%eax
  800ce7:	3b 46 04             	cmp    0x4(%esi),%eax
  800cea:	74 df                	je     800ccb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cec:	99                   	cltd   
  800ced:	c1 ea 1b             	shr    $0x1b,%edx
  800cf0:	01 d0                	add    %edx,%eax
  800cf2:	83 e0 1f             	and    $0x1f,%eax
  800cf5:	29 d0                	sub    %edx,%eax
  800cf7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d02:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d05:	83 c3 01             	add    $0x1,%ebx
  800d08:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d0b:	75 d8                	jne    800ce5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d0d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d10:	eb 05                	jmp    800d17 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d2a:	50                   	push   %eax
  800d2b:	e8 42 f6 ff ff       	call   800372 <fd_alloc>
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	89 c2                	mov    %eax,%edx
  800d35:	85 c0                	test   %eax,%eax
  800d37:	0f 88 2c 01 00 00    	js     800e69 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d3d:	83 ec 04             	sub    $0x4,%esp
  800d40:	68 07 04 00 00       	push   $0x407
  800d45:	ff 75 f4             	pushl  -0xc(%ebp)
  800d48:	6a 00                	push   $0x0
  800d4a:	e8 0b f4 ff ff       	call   80015a <sys_page_alloc>
  800d4f:	83 c4 10             	add    $0x10,%esp
  800d52:	89 c2                	mov    %eax,%edx
  800d54:	85 c0                	test   %eax,%eax
  800d56:	0f 88 0d 01 00 00    	js     800e69 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d62:	50                   	push   %eax
  800d63:	e8 0a f6 ff ff       	call   800372 <fd_alloc>
  800d68:	89 c3                	mov    %eax,%ebx
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	0f 88 e2 00 00 00    	js     800e57 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d75:	83 ec 04             	sub    $0x4,%esp
  800d78:	68 07 04 00 00       	push   $0x407
  800d7d:	ff 75 f0             	pushl  -0x10(%ebp)
  800d80:	6a 00                	push   $0x0
  800d82:	e8 d3 f3 ff ff       	call   80015a <sys_page_alloc>
  800d87:	89 c3                	mov    %eax,%ebx
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	0f 88 c3 00 00 00    	js     800e57 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	ff 75 f4             	pushl  -0xc(%ebp)
  800d9a:	e8 bc f5 ff ff       	call   80035b <fd2data>
  800d9f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da1:	83 c4 0c             	add    $0xc,%esp
  800da4:	68 07 04 00 00       	push   $0x407
  800da9:	50                   	push   %eax
  800daa:	6a 00                	push   $0x0
  800dac:	e8 a9 f3 ff ff       	call   80015a <sys_page_alloc>
  800db1:	89 c3                	mov    %eax,%ebx
  800db3:	83 c4 10             	add    $0x10,%esp
  800db6:	85 c0                	test   %eax,%eax
  800db8:	0f 88 89 00 00 00    	js     800e47 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc4:	e8 92 f5 ff ff       	call   80035b <fd2data>
  800dc9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd0:	50                   	push   %eax
  800dd1:	6a 00                	push   $0x0
  800dd3:	56                   	push   %esi
  800dd4:	6a 00                	push   $0x0
  800dd6:	e8 c2 f3 ff ff       	call   80019d <sys_page_map>
  800ddb:	89 c3                	mov    %eax,%ebx
  800ddd:	83 c4 20             	add    $0x20,%esp
  800de0:	85 c0                	test   %eax,%eax
  800de2:	78 55                	js     800e39 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800de4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ded:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800def:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800df9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e02:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e07:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	ff 75 f4             	pushl  -0xc(%ebp)
  800e14:	e8 32 f5 ff ff       	call   80034b <fd2num>
  800e19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e1e:	83 c4 04             	add    $0x4,%esp
  800e21:	ff 75 f0             	pushl  -0x10(%ebp)
  800e24:	e8 22 f5 ff ff       	call   80034b <fd2num>
  800e29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	ba 00 00 00 00       	mov    $0x0,%edx
  800e37:	eb 30                	jmp    800e69 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	56                   	push   %esi
  800e3d:	6a 00                	push   $0x0
  800e3f:	e8 9b f3 ff ff       	call   8001df <sys_page_unmap>
  800e44:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e47:	83 ec 08             	sub    $0x8,%esp
  800e4a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4d:	6a 00                	push   $0x0
  800e4f:	e8 8b f3 ff ff       	call   8001df <sys_page_unmap>
  800e54:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e57:	83 ec 08             	sub    $0x8,%esp
  800e5a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5d:	6a 00                	push   $0x0
  800e5f:	e8 7b f3 ff ff       	call   8001df <sys_page_unmap>
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e69:	89 d0                	mov    %edx,%eax
  800e6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7b:	50                   	push   %eax
  800e7c:	ff 75 08             	pushl  0x8(%ebp)
  800e7f:	e8 3d f5 ff ff       	call   8003c1 <fd_lookup>
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	85 c0                	test   %eax,%eax
  800e89:	78 18                	js     800ea3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e8b:	83 ec 0c             	sub    $0xc,%esp
  800e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e91:	e8 c5 f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800e96:	89 c2                	mov    %eax,%edx
  800e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e9b:	e8 21 fd ff ff       	call   800bc1 <_pipeisclosed>
  800ea0:	83 c4 10             	add    $0x10,%esp
}
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ea8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eb5:	68 b6 1e 80 00       	push   $0x801eb6
  800eba:	ff 75 0c             	pushl  0xc(%ebp)
  800ebd:	e8 c4 07 00 00       	call   801686 <strcpy>
	return 0;
}
  800ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ed5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eda:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee0:	eb 2d                	jmp    800f0f <devcons_write+0x46>
		m = n - tot;
  800ee2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ee7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800eea:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800eef:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef2:	83 ec 04             	sub    $0x4,%esp
  800ef5:	53                   	push   %ebx
  800ef6:	03 45 0c             	add    0xc(%ebp),%eax
  800ef9:	50                   	push   %eax
  800efa:	57                   	push   %edi
  800efb:	e8 18 09 00 00       	call   801818 <memmove>
		sys_cputs(buf, m);
  800f00:	83 c4 08             	add    $0x8,%esp
  800f03:	53                   	push   %ebx
  800f04:	57                   	push   %edi
  800f05:	e8 94 f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0a:	01 de                	add    %ebx,%esi
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	89 f0                	mov    %esi,%eax
  800f11:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f14:	72 cc                	jb     800ee2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	83 ec 08             	sub    $0x8,%esp
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f2d:	74 2a                	je     800f59 <devcons_read+0x3b>
  800f2f:	eb 05                	jmp    800f36 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f31:	e8 05 f2 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f36:	e8 81 f1 ff ff       	call   8000bc <sys_cgetc>
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	74 f2                	je     800f31 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 16                	js     800f59 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f43:	83 f8 04             	cmp    $0x4,%eax
  800f46:	74 0c                	je     800f54 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4b:	88 02                	mov    %al,(%edx)
	return 1;
  800f4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f52:	eb 05                	jmp    800f59 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f61:	8b 45 08             	mov    0x8(%ebp),%eax
  800f64:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f67:	6a 01                	push   $0x1
  800f69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f6c:	50                   	push   %eax
  800f6d:	e8 2c f1 ff ff       	call   80009e <sys_cputs>
}
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <getchar>:

int
getchar(void)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f7d:	6a 01                	push   $0x1
  800f7f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f82:	50                   	push   %eax
  800f83:	6a 00                	push   $0x0
  800f85:	e8 9d f6 ff ff       	call   800627 <read>
	if (r < 0)
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 0f                	js     800fa0 <getchar+0x29>
		return r;
	if (r < 1)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	7e 06                	jle    800f9b <getchar+0x24>
		return -E_EOF;
	return c;
  800f95:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f99:	eb 05                	jmp    800fa0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f9b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fab:	50                   	push   %eax
  800fac:	ff 75 08             	pushl  0x8(%ebp)
  800faf:	e8 0d f4 ff ff       	call   8003c1 <fd_lookup>
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	78 11                	js     800fcc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fc4:	39 10                	cmp    %edx,(%eax)
  800fc6:	0f 94 c0             	sete   %al
  800fc9:	0f b6 c0             	movzbl %al,%eax
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <opencons>:

int
opencons(void)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	e8 95 f3 ff ff       	call   800372 <fd_alloc>
  800fdd:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 3e                	js     801024 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	68 07 04 00 00       	push   $0x407
  800fee:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff1:	6a 00                	push   $0x0
  800ff3:	e8 62 f1 ff ff       	call   80015a <sys_page_alloc>
  800ff8:	83 c4 10             	add    $0x10,%esp
		return r;
  800ffb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	78 23                	js     801024 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801001:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801007:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80100c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	50                   	push   %eax
  80101a:	e8 2c f3 ff ff       	call   80034b <fd2num>
  80101f:	89 c2                	mov    %eax,%edx
  801021:	83 c4 10             	add    $0x10,%esp
}
  801024:	89 d0                	mov    %edx,%eax
  801026:	c9                   	leave  
  801027:	c3                   	ret    

00801028 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80102d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801030:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801036:	e8 e1 f0 ff ff       	call   80011c <sys_getenvid>
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	ff 75 0c             	pushl  0xc(%ebp)
  801041:	ff 75 08             	pushl  0x8(%ebp)
  801044:	56                   	push   %esi
  801045:	50                   	push   %eax
  801046:	68 c4 1e 80 00       	push   $0x801ec4
  80104b:	e8 b1 00 00 00       	call   801101 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801050:	83 c4 18             	add    $0x18,%esp
  801053:	53                   	push   %ebx
  801054:	ff 75 10             	pushl  0x10(%ebp)
  801057:	e8 54 00 00 00       	call   8010b0 <vcprintf>
	cprintf("\n");
  80105c:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  801063:	e8 99 00 00 00       	call   801101 <cprintf>
  801068:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80106b:	cc                   	int3   
  80106c:	eb fd                	jmp    80106b <_panic+0x43>

0080106e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	53                   	push   %ebx
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801078:	8b 13                	mov    (%ebx),%edx
  80107a:	8d 42 01             	lea    0x1(%edx),%eax
  80107d:	89 03                	mov    %eax,(%ebx)
  80107f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801082:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801086:	3d ff 00 00 00       	cmp    $0xff,%eax
  80108b:	75 1a                	jne    8010a7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	68 ff 00 00 00       	push   $0xff
  801095:	8d 43 08             	lea    0x8(%ebx),%eax
  801098:	50                   	push   %eax
  801099:	e8 00 f0 ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  80109e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010a4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010a7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c0:	00 00 00 
	b.cnt = 0;
  8010c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010cd:	ff 75 0c             	pushl  0xc(%ebp)
  8010d0:	ff 75 08             	pushl  0x8(%ebp)
  8010d3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	68 6e 10 80 00       	push   $0x80106e
  8010df:	e8 54 01 00 00       	call   801238 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010e4:	83 c4 08             	add    $0x8,%esp
  8010e7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010f3:	50                   	push   %eax
  8010f4:	e8 a5 ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  8010f9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801107:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80110a:	50                   	push   %eax
  80110b:	ff 75 08             	pushl  0x8(%ebp)
  80110e:	e8 9d ff ff ff       	call   8010b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  801113:	c9                   	leave  
  801114:	c3                   	ret    

00801115 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	57                   	push   %edi
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
  80111b:	83 ec 1c             	sub    $0x1c,%esp
  80111e:	89 c7                	mov    %eax,%edi
  801120:	89 d6                	mov    %edx,%esi
  801122:	8b 45 08             	mov    0x8(%ebp),%eax
  801125:	8b 55 0c             	mov    0xc(%ebp),%edx
  801128:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80112b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80112e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801131:	bb 00 00 00 00       	mov    $0x0,%ebx
  801136:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801139:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80113c:	39 d3                	cmp    %edx,%ebx
  80113e:	72 05                	jb     801145 <printnum+0x30>
  801140:	39 45 10             	cmp    %eax,0x10(%ebp)
  801143:	77 45                	ja     80118a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	ff 75 18             	pushl  0x18(%ebp)
  80114b:	8b 45 14             	mov    0x14(%ebp),%eax
  80114e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801151:	53                   	push   %ebx
  801152:	ff 75 10             	pushl  0x10(%ebp)
  801155:	83 ec 08             	sub    $0x8,%esp
  801158:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115b:	ff 75 e0             	pushl  -0x20(%ebp)
  80115e:	ff 75 dc             	pushl  -0x24(%ebp)
  801161:	ff 75 d8             	pushl  -0x28(%ebp)
  801164:	e8 97 09 00 00       	call   801b00 <__udivdi3>
  801169:	83 c4 18             	add    $0x18,%esp
  80116c:	52                   	push   %edx
  80116d:	50                   	push   %eax
  80116e:	89 f2                	mov    %esi,%edx
  801170:	89 f8                	mov    %edi,%eax
  801172:	e8 9e ff ff ff       	call   801115 <printnum>
  801177:	83 c4 20             	add    $0x20,%esp
  80117a:	eb 18                	jmp    801194 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80117c:	83 ec 08             	sub    $0x8,%esp
  80117f:	56                   	push   %esi
  801180:	ff 75 18             	pushl  0x18(%ebp)
  801183:	ff d7                	call   *%edi
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	eb 03                	jmp    80118d <printnum+0x78>
  80118a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80118d:	83 eb 01             	sub    $0x1,%ebx
  801190:	85 db                	test   %ebx,%ebx
  801192:	7f e8                	jg     80117c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801194:	83 ec 08             	sub    $0x8,%esp
  801197:	56                   	push   %esi
  801198:	83 ec 04             	sub    $0x4,%esp
  80119b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119e:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a7:	e8 84 0a 00 00       	call   801c30 <__umoddi3>
  8011ac:	83 c4 14             	add    $0x14,%esp
  8011af:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  8011b6:	50                   	push   %eax
  8011b7:	ff d7                	call   *%edi
}
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011c7:	83 fa 01             	cmp    $0x1,%edx
  8011ca:	7e 0e                	jle    8011da <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011cc:	8b 10                	mov    (%eax),%edx
  8011ce:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011d1:	89 08                	mov    %ecx,(%eax)
  8011d3:	8b 02                	mov    (%edx),%eax
  8011d5:	8b 52 04             	mov    0x4(%edx),%edx
  8011d8:	eb 22                	jmp    8011fc <getuint+0x38>
	else if (lflag)
  8011da:	85 d2                	test   %edx,%edx
  8011dc:	74 10                	je     8011ee <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011de:	8b 10                	mov    (%eax),%edx
  8011e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011e3:	89 08                	mov    %ecx,(%eax)
  8011e5:	8b 02                	mov    (%edx),%eax
  8011e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ec:	eb 0e                	jmp    8011fc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011ee:	8b 10                	mov    (%eax),%edx
  8011f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f3:	89 08                	mov    %ecx,(%eax)
  8011f5:	8b 02                	mov    (%edx),%eax
  8011f7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801204:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801208:	8b 10                	mov    (%eax),%edx
  80120a:	3b 50 04             	cmp    0x4(%eax),%edx
  80120d:	73 0a                	jae    801219 <sprintputch+0x1b>
		*b->buf++ = ch;
  80120f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801212:	89 08                	mov    %ecx,(%eax)
  801214:	8b 45 08             	mov    0x8(%ebp),%eax
  801217:	88 02                	mov    %al,(%edx)
}
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801221:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801224:	50                   	push   %eax
  801225:	ff 75 10             	pushl  0x10(%ebp)
  801228:	ff 75 0c             	pushl  0xc(%ebp)
  80122b:	ff 75 08             	pushl  0x8(%ebp)
  80122e:	e8 05 00 00 00       	call   801238 <vprintfmt>
	va_end(ap);
}
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	57                   	push   %edi
  80123c:	56                   	push   %esi
  80123d:	53                   	push   %ebx
  80123e:	83 ec 2c             	sub    $0x2c,%esp
  801241:	8b 75 08             	mov    0x8(%ebp),%esi
  801244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801247:	8b 7d 10             	mov    0x10(%ebp),%edi
  80124a:	eb 12                	jmp    80125e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80124c:	85 c0                	test   %eax,%eax
  80124e:	0f 84 89 03 00 00    	je     8015dd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	53                   	push   %ebx
  801258:	50                   	push   %eax
  801259:	ff d6                	call   *%esi
  80125b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80125e:	83 c7 01             	add    $0x1,%edi
  801261:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801265:	83 f8 25             	cmp    $0x25,%eax
  801268:	75 e2                	jne    80124c <vprintfmt+0x14>
  80126a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80126e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801275:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80127c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801283:	ba 00 00 00 00       	mov    $0x0,%edx
  801288:	eb 07                	jmp    801291 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80128d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801291:	8d 47 01             	lea    0x1(%edi),%eax
  801294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801297:	0f b6 07             	movzbl (%edi),%eax
  80129a:	0f b6 c8             	movzbl %al,%ecx
  80129d:	83 e8 23             	sub    $0x23,%eax
  8012a0:	3c 55                	cmp    $0x55,%al
  8012a2:	0f 87 1a 03 00 00    	ja     8015c2 <vprintfmt+0x38a>
  8012a8:	0f b6 c0             	movzbl %al,%eax
  8012ab:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  8012b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012b5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012b9:	eb d6                	jmp    801291 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012be:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012c9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012cd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012d0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012d3:	83 fa 09             	cmp    $0x9,%edx
  8012d6:	77 39                	ja     801311 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012d8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012db:	eb e9                	jmp    8012c6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e0:	8d 48 04             	lea    0x4(%eax),%ecx
  8012e3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012e6:	8b 00                	mov    (%eax),%eax
  8012e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012ee:	eb 27                	jmp    801317 <vprintfmt+0xdf>
  8012f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012fa:	0f 49 c8             	cmovns %eax,%ecx
  8012fd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801303:	eb 8c                	jmp    801291 <vprintfmt+0x59>
  801305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801308:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80130f:	eb 80                	jmp    801291 <vprintfmt+0x59>
  801311:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801314:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801317:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80131b:	0f 89 70 ff ff ff    	jns    801291 <vprintfmt+0x59>
				width = precision, precision = -1;
  801321:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801324:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801327:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80132e:	e9 5e ff ff ff       	jmp    801291 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801333:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801339:	e9 53 ff ff ff       	jmp    801291 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80133e:	8b 45 14             	mov    0x14(%ebp),%eax
  801341:	8d 50 04             	lea    0x4(%eax),%edx
  801344:	89 55 14             	mov    %edx,0x14(%ebp)
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	53                   	push   %ebx
  80134b:	ff 30                	pushl  (%eax)
  80134d:	ff d6                	call   *%esi
			break;
  80134f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801355:	e9 04 ff ff ff       	jmp    80125e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80135a:	8b 45 14             	mov    0x14(%ebp),%eax
  80135d:	8d 50 04             	lea    0x4(%eax),%edx
  801360:	89 55 14             	mov    %edx,0x14(%ebp)
  801363:	8b 00                	mov    (%eax),%eax
  801365:	99                   	cltd   
  801366:	31 d0                	xor    %edx,%eax
  801368:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80136a:	83 f8 0f             	cmp    $0xf,%eax
  80136d:	7f 0b                	jg     80137a <vprintfmt+0x142>
  80136f:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  801376:	85 d2                	test   %edx,%edx
  801378:	75 18                	jne    801392 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80137a:	50                   	push   %eax
  80137b:	68 ff 1e 80 00       	push   $0x801eff
  801380:	53                   	push   %ebx
  801381:	56                   	push   %esi
  801382:	e8 94 fe ff ff       	call   80121b <printfmt>
  801387:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80138d:	e9 cc fe ff ff       	jmp    80125e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801392:	52                   	push   %edx
  801393:	68 7d 1e 80 00       	push   $0x801e7d
  801398:	53                   	push   %ebx
  801399:	56                   	push   %esi
  80139a:	e8 7c fe ff ff       	call   80121b <printfmt>
  80139f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013a5:	e9 b4 fe ff ff       	jmp    80125e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ad:	8d 50 04             	lea    0x4(%eax),%edx
  8013b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013b5:	85 ff                	test   %edi,%edi
  8013b7:	b8 f8 1e 80 00       	mov    $0x801ef8,%eax
  8013bc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013c3:	0f 8e 94 00 00 00    	jle    80145d <vprintfmt+0x225>
  8013c9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013cd:	0f 84 98 00 00 00    	je     80146b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	ff 75 d0             	pushl  -0x30(%ebp)
  8013d9:	57                   	push   %edi
  8013da:	e8 86 02 00 00       	call   801665 <strnlen>
  8013df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013e2:	29 c1                	sub    %eax,%ecx
  8013e4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013e7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013ea:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013f1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013f4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f6:	eb 0f                	jmp    801407 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ff:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801401:	83 ef 01             	sub    $0x1,%edi
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	85 ff                	test   %edi,%edi
  801409:	7f ed                	jg     8013f8 <vprintfmt+0x1c0>
  80140b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80140e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801411:	85 c9                	test   %ecx,%ecx
  801413:	b8 00 00 00 00       	mov    $0x0,%eax
  801418:	0f 49 c1             	cmovns %ecx,%eax
  80141b:	29 c1                	sub    %eax,%ecx
  80141d:	89 75 08             	mov    %esi,0x8(%ebp)
  801420:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801423:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801426:	89 cb                	mov    %ecx,%ebx
  801428:	eb 4d                	jmp    801477 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80142a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80142e:	74 1b                	je     80144b <vprintfmt+0x213>
  801430:	0f be c0             	movsbl %al,%eax
  801433:	83 e8 20             	sub    $0x20,%eax
  801436:	83 f8 5e             	cmp    $0x5e,%eax
  801439:	76 10                	jbe    80144b <vprintfmt+0x213>
					putch('?', putdat);
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	ff 75 0c             	pushl  0xc(%ebp)
  801441:	6a 3f                	push   $0x3f
  801443:	ff 55 08             	call   *0x8(%ebp)
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	eb 0d                	jmp    801458 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	ff 75 0c             	pushl  0xc(%ebp)
  801451:	52                   	push   %edx
  801452:	ff 55 08             	call   *0x8(%ebp)
  801455:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801458:	83 eb 01             	sub    $0x1,%ebx
  80145b:	eb 1a                	jmp    801477 <vprintfmt+0x23f>
  80145d:	89 75 08             	mov    %esi,0x8(%ebp)
  801460:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801463:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801466:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801469:	eb 0c                	jmp    801477 <vprintfmt+0x23f>
  80146b:	89 75 08             	mov    %esi,0x8(%ebp)
  80146e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801471:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801474:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801477:	83 c7 01             	add    $0x1,%edi
  80147a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80147e:	0f be d0             	movsbl %al,%edx
  801481:	85 d2                	test   %edx,%edx
  801483:	74 23                	je     8014a8 <vprintfmt+0x270>
  801485:	85 f6                	test   %esi,%esi
  801487:	78 a1                	js     80142a <vprintfmt+0x1f2>
  801489:	83 ee 01             	sub    $0x1,%esi
  80148c:	79 9c                	jns    80142a <vprintfmt+0x1f2>
  80148e:	89 df                	mov    %ebx,%edi
  801490:	8b 75 08             	mov    0x8(%ebp),%esi
  801493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801496:	eb 18                	jmp    8014b0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	53                   	push   %ebx
  80149c:	6a 20                	push   $0x20
  80149e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014a0:	83 ef 01             	sub    $0x1,%edi
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	eb 08                	jmp    8014b0 <vprintfmt+0x278>
  8014a8:	89 df                	mov    %ebx,%edi
  8014aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b0:	85 ff                	test   %edi,%edi
  8014b2:	7f e4                	jg     801498 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014b7:	e9 a2 fd ff ff       	jmp    80125e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014bc:	83 fa 01             	cmp    $0x1,%edx
  8014bf:	7e 16                	jle    8014d7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c4:	8d 50 08             	lea    0x8(%eax),%edx
  8014c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ca:	8b 50 04             	mov    0x4(%eax),%edx
  8014cd:	8b 00                	mov    (%eax),%eax
  8014cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014d5:	eb 32                	jmp    801509 <vprintfmt+0x2d1>
	else if (lflag)
  8014d7:	85 d2                	test   %edx,%edx
  8014d9:	74 18                	je     8014f3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014db:	8b 45 14             	mov    0x14(%ebp),%eax
  8014de:	8d 50 04             	lea    0x4(%eax),%edx
  8014e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e4:	8b 00                	mov    (%eax),%eax
  8014e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e9:	89 c1                	mov    %eax,%ecx
  8014eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f1:	eb 16                	jmp    801509 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f6:	8d 50 04             	lea    0x4(%eax),%edx
  8014f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8014fc:	8b 00                	mov    (%eax),%eax
  8014fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801501:	89 c1                	mov    %eax,%ecx
  801503:	c1 f9 1f             	sar    $0x1f,%ecx
  801506:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801509:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80150c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80150f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801514:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801518:	79 74                	jns    80158e <vprintfmt+0x356>
				putch('-', putdat);
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	53                   	push   %ebx
  80151e:	6a 2d                	push   $0x2d
  801520:	ff d6                	call   *%esi
				num = -(long long) num;
  801522:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801525:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801528:	f7 d8                	neg    %eax
  80152a:	83 d2 00             	adc    $0x0,%edx
  80152d:	f7 da                	neg    %edx
  80152f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801532:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801537:	eb 55                	jmp    80158e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801539:	8d 45 14             	lea    0x14(%ebp),%eax
  80153c:	e8 83 fc ff ff       	call   8011c4 <getuint>
			base = 10;
  801541:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801546:	eb 46                	jmp    80158e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801548:	8d 45 14             	lea    0x14(%ebp),%eax
  80154b:	e8 74 fc ff ff       	call   8011c4 <getuint>
			base = 8;
  801550:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801555:	eb 37                	jmp    80158e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	53                   	push   %ebx
  80155b:	6a 30                	push   $0x30
  80155d:	ff d6                	call   *%esi
			putch('x', putdat);
  80155f:	83 c4 08             	add    $0x8,%esp
  801562:	53                   	push   %ebx
  801563:	6a 78                	push   $0x78
  801565:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801567:	8b 45 14             	mov    0x14(%ebp),%eax
  80156a:	8d 50 04             	lea    0x4(%eax),%edx
  80156d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801570:	8b 00                	mov    (%eax),%eax
  801572:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801577:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80157a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80157f:	eb 0d                	jmp    80158e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801581:	8d 45 14             	lea    0x14(%ebp),%eax
  801584:	e8 3b fc ff ff       	call   8011c4 <getuint>
			base = 16;
  801589:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801595:	57                   	push   %edi
  801596:	ff 75 e0             	pushl  -0x20(%ebp)
  801599:	51                   	push   %ecx
  80159a:	52                   	push   %edx
  80159b:	50                   	push   %eax
  80159c:	89 da                	mov    %ebx,%edx
  80159e:	89 f0                	mov    %esi,%eax
  8015a0:	e8 70 fb ff ff       	call   801115 <printnum>
			break;
  8015a5:	83 c4 20             	add    $0x20,%esp
  8015a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015ab:	e9 ae fc ff ff       	jmp    80125e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	51                   	push   %ecx
  8015b5:	ff d6                	call   *%esi
			break;
  8015b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015bd:	e9 9c fc ff ff       	jmp    80125e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015c2:	83 ec 08             	sub    $0x8,%esp
  8015c5:	53                   	push   %ebx
  8015c6:	6a 25                	push   $0x25
  8015c8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	eb 03                	jmp    8015d2 <vprintfmt+0x39a>
  8015cf:	83 ef 01             	sub    $0x1,%edi
  8015d2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015d6:	75 f7                	jne    8015cf <vprintfmt+0x397>
  8015d8:	e9 81 fc ff ff       	jmp    80125e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5f                   	pop    %edi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	83 ec 18             	sub    $0x18,%esp
  8015eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801602:	85 c0                	test   %eax,%eax
  801604:	74 26                	je     80162c <vsnprintf+0x47>
  801606:	85 d2                	test   %edx,%edx
  801608:	7e 22                	jle    80162c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80160a:	ff 75 14             	pushl  0x14(%ebp)
  80160d:	ff 75 10             	pushl  0x10(%ebp)
  801610:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	68 fe 11 80 00       	push   $0x8011fe
  801619:	e8 1a fc ff ff       	call   801238 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80161e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801621:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801624:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	eb 05                	jmp    801631 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80162c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801639:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80163c:	50                   	push   %eax
  80163d:	ff 75 10             	pushl  0x10(%ebp)
  801640:	ff 75 0c             	pushl  0xc(%ebp)
  801643:	ff 75 08             	pushl  0x8(%ebp)
  801646:	e8 9a ff ff ff       	call   8015e5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801653:	b8 00 00 00 00       	mov    $0x0,%eax
  801658:	eb 03                	jmp    80165d <strlen+0x10>
		n++;
  80165a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80165d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801661:	75 f7                	jne    80165a <strlen+0xd>
		n++;
	return n;
}
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80166b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80166e:	ba 00 00 00 00       	mov    $0x0,%edx
  801673:	eb 03                	jmp    801678 <strnlen+0x13>
		n++;
  801675:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801678:	39 c2                	cmp    %eax,%edx
  80167a:	74 08                	je     801684 <strnlen+0x1f>
  80167c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801680:	75 f3                	jne    801675 <strnlen+0x10>
  801682:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	8b 45 08             	mov    0x8(%ebp),%eax
  80168d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801690:	89 c2                	mov    %eax,%edx
  801692:	83 c2 01             	add    $0x1,%edx
  801695:	83 c1 01             	add    $0x1,%ecx
  801698:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80169c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80169f:	84 db                	test   %bl,%bl
  8016a1:	75 ef                	jne    801692 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016a3:	5b                   	pop    %ebx
  8016a4:	5d                   	pop    %ebp
  8016a5:	c3                   	ret    

008016a6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	53                   	push   %ebx
  8016aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ad:	53                   	push   %ebx
  8016ae:	e8 9a ff ff ff       	call   80164d <strlen>
  8016b3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016b6:	ff 75 0c             	pushl  0xc(%ebp)
  8016b9:	01 d8                	add    %ebx,%eax
  8016bb:	50                   	push   %eax
  8016bc:	e8 c5 ff ff ff       	call   801686 <strcpy>
	return dst;
}
  8016c1:	89 d8                	mov    %ebx,%eax
  8016c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	56                   	push   %esi
  8016cc:	53                   	push   %ebx
  8016cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8016d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d3:	89 f3                	mov    %esi,%ebx
  8016d5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016d8:	89 f2                	mov    %esi,%edx
  8016da:	eb 0f                	jmp    8016eb <strncpy+0x23>
		*dst++ = *src;
  8016dc:	83 c2 01             	add    $0x1,%edx
  8016df:	0f b6 01             	movzbl (%ecx),%eax
  8016e2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016e5:	80 39 01             	cmpb   $0x1,(%ecx)
  8016e8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016eb:	39 da                	cmp    %ebx,%edx
  8016ed:	75 ed                	jne    8016dc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016ef:	89 f0                	mov    %esi,%eax
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
  8016fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801700:	8b 55 10             	mov    0x10(%ebp),%edx
  801703:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801705:	85 d2                	test   %edx,%edx
  801707:	74 21                	je     80172a <strlcpy+0x35>
  801709:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80170d:	89 f2                	mov    %esi,%edx
  80170f:	eb 09                	jmp    80171a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801711:	83 c2 01             	add    $0x1,%edx
  801714:	83 c1 01             	add    $0x1,%ecx
  801717:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80171a:	39 c2                	cmp    %eax,%edx
  80171c:	74 09                	je     801727 <strlcpy+0x32>
  80171e:	0f b6 19             	movzbl (%ecx),%ebx
  801721:	84 db                	test   %bl,%bl
  801723:	75 ec                	jne    801711 <strlcpy+0x1c>
  801725:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801727:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80172a:	29 f0                	sub    %esi,%eax
}
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801736:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801739:	eb 06                	jmp    801741 <strcmp+0x11>
		p++, q++;
  80173b:	83 c1 01             	add    $0x1,%ecx
  80173e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801741:	0f b6 01             	movzbl (%ecx),%eax
  801744:	84 c0                	test   %al,%al
  801746:	74 04                	je     80174c <strcmp+0x1c>
  801748:	3a 02                	cmp    (%edx),%al
  80174a:	74 ef                	je     80173b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80174c:	0f b6 c0             	movzbl %al,%eax
  80174f:	0f b6 12             	movzbl (%edx),%edx
  801752:	29 d0                	sub    %edx,%eax
}
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	53                   	push   %ebx
  80175a:	8b 45 08             	mov    0x8(%ebp),%eax
  80175d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801760:	89 c3                	mov    %eax,%ebx
  801762:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801765:	eb 06                	jmp    80176d <strncmp+0x17>
		n--, p++, q++;
  801767:	83 c0 01             	add    $0x1,%eax
  80176a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80176d:	39 d8                	cmp    %ebx,%eax
  80176f:	74 15                	je     801786 <strncmp+0x30>
  801771:	0f b6 08             	movzbl (%eax),%ecx
  801774:	84 c9                	test   %cl,%cl
  801776:	74 04                	je     80177c <strncmp+0x26>
  801778:	3a 0a                	cmp    (%edx),%cl
  80177a:	74 eb                	je     801767 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80177c:	0f b6 00             	movzbl (%eax),%eax
  80177f:	0f b6 12             	movzbl (%edx),%edx
  801782:	29 d0                	sub    %edx,%eax
  801784:	eb 05                	jmp    80178b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801786:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80178b:	5b                   	pop    %ebx
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
  801794:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801798:	eb 07                	jmp    8017a1 <strchr+0x13>
		if (*s == c)
  80179a:	38 ca                	cmp    %cl,%dl
  80179c:	74 0f                	je     8017ad <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80179e:	83 c0 01             	add    $0x1,%eax
  8017a1:	0f b6 10             	movzbl (%eax),%edx
  8017a4:	84 d2                	test   %dl,%dl
  8017a6:	75 f2                	jne    80179a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017b9:	eb 03                	jmp    8017be <strfind+0xf>
  8017bb:	83 c0 01             	add    $0x1,%eax
  8017be:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017c1:	38 ca                	cmp    %cl,%dl
  8017c3:	74 04                	je     8017c9 <strfind+0x1a>
  8017c5:	84 d2                	test   %dl,%dl
  8017c7:	75 f2                	jne    8017bb <strfind+0xc>
			break;
	return (char *) s;
}
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	57                   	push   %edi
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017d7:	85 c9                	test   %ecx,%ecx
  8017d9:	74 36                	je     801811 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017db:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017e1:	75 28                	jne    80180b <memset+0x40>
  8017e3:	f6 c1 03             	test   $0x3,%cl
  8017e6:	75 23                	jne    80180b <memset+0x40>
		c &= 0xFF;
  8017e8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017ec:	89 d3                	mov    %edx,%ebx
  8017ee:	c1 e3 08             	shl    $0x8,%ebx
  8017f1:	89 d6                	mov    %edx,%esi
  8017f3:	c1 e6 18             	shl    $0x18,%esi
  8017f6:	89 d0                	mov    %edx,%eax
  8017f8:	c1 e0 10             	shl    $0x10,%eax
  8017fb:	09 f0                	or     %esi,%eax
  8017fd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8017ff:	89 d8                	mov    %ebx,%eax
  801801:	09 d0                	or     %edx,%eax
  801803:	c1 e9 02             	shr    $0x2,%ecx
  801806:	fc                   	cld    
  801807:	f3 ab                	rep stos %eax,%es:(%edi)
  801809:	eb 06                	jmp    801811 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80180b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180e:	fc                   	cld    
  80180f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801811:	89 f8                	mov    %edi,%eax
  801813:	5b                   	pop    %ebx
  801814:	5e                   	pop    %esi
  801815:	5f                   	pop    %edi
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	57                   	push   %edi
  80181c:	56                   	push   %esi
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	8b 75 0c             	mov    0xc(%ebp),%esi
  801823:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801826:	39 c6                	cmp    %eax,%esi
  801828:	73 35                	jae    80185f <memmove+0x47>
  80182a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80182d:	39 d0                	cmp    %edx,%eax
  80182f:	73 2e                	jae    80185f <memmove+0x47>
		s += n;
		d += n;
  801831:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801834:	89 d6                	mov    %edx,%esi
  801836:	09 fe                	or     %edi,%esi
  801838:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80183e:	75 13                	jne    801853 <memmove+0x3b>
  801840:	f6 c1 03             	test   $0x3,%cl
  801843:	75 0e                	jne    801853 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801845:	83 ef 04             	sub    $0x4,%edi
  801848:	8d 72 fc             	lea    -0x4(%edx),%esi
  80184b:	c1 e9 02             	shr    $0x2,%ecx
  80184e:	fd                   	std    
  80184f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801851:	eb 09                	jmp    80185c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801853:	83 ef 01             	sub    $0x1,%edi
  801856:	8d 72 ff             	lea    -0x1(%edx),%esi
  801859:	fd                   	std    
  80185a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80185c:	fc                   	cld    
  80185d:	eb 1d                	jmp    80187c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185f:	89 f2                	mov    %esi,%edx
  801861:	09 c2                	or     %eax,%edx
  801863:	f6 c2 03             	test   $0x3,%dl
  801866:	75 0f                	jne    801877 <memmove+0x5f>
  801868:	f6 c1 03             	test   $0x3,%cl
  80186b:	75 0a                	jne    801877 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80186d:	c1 e9 02             	shr    $0x2,%ecx
  801870:	89 c7                	mov    %eax,%edi
  801872:	fc                   	cld    
  801873:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801875:	eb 05                	jmp    80187c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801877:	89 c7                	mov    %eax,%edi
  801879:	fc                   	cld    
  80187a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80187c:	5e                   	pop    %esi
  80187d:	5f                   	pop    %edi
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801883:	ff 75 10             	pushl  0x10(%ebp)
  801886:	ff 75 0c             	pushl  0xc(%ebp)
  801889:	ff 75 08             	pushl  0x8(%ebp)
  80188c:	e8 87 ff ff ff       	call   801818 <memmove>
}
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	56                   	push   %esi
  801897:	53                   	push   %ebx
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189e:	89 c6                	mov    %eax,%esi
  8018a0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a3:	eb 1a                	jmp    8018bf <memcmp+0x2c>
		if (*s1 != *s2)
  8018a5:	0f b6 08             	movzbl (%eax),%ecx
  8018a8:	0f b6 1a             	movzbl (%edx),%ebx
  8018ab:	38 d9                	cmp    %bl,%cl
  8018ad:	74 0a                	je     8018b9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018af:	0f b6 c1             	movzbl %cl,%eax
  8018b2:	0f b6 db             	movzbl %bl,%ebx
  8018b5:	29 d8                	sub    %ebx,%eax
  8018b7:	eb 0f                	jmp    8018c8 <memcmp+0x35>
		s1++, s2++;
  8018b9:	83 c0 01             	add    $0x1,%eax
  8018bc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018bf:	39 f0                	cmp    %esi,%eax
  8018c1:	75 e2                	jne    8018a5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c8:	5b                   	pop    %ebx
  8018c9:	5e                   	pop    %esi
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	53                   	push   %ebx
  8018d0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018d3:	89 c1                	mov    %eax,%ecx
  8018d5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018d8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018dc:	eb 0a                	jmp    8018e8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018de:	0f b6 10             	movzbl (%eax),%edx
  8018e1:	39 da                	cmp    %ebx,%edx
  8018e3:	74 07                	je     8018ec <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018e5:	83 c0 01             	add    $0x1,%eax
  8018e8:	39 c8                	cmp    %ecx,%eax
  8018ea:	72 f2                	jb     8018de <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018ec:	5b                   	pop    %ebx
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	57                   	push   %edi
  8018f3:	56                   	push   %esi
  8018f4:	53                   	push   %ebx
  8018f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018fb:	eb 03                	jmp    801900 <strtol+0x11>
		s++;
  8018fd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801900:	0f b6 01             	movzbl (%ecx),%eax
  801903:	3c 20                	cmp    $0x20,%al
  801905:	74 f6                	je     8018fd <strtol+0xe>
  801907:	3c 09                	cmp    $0x9,%al
  801909:	74 f2                	je     8018fd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80190b:	3c 2b                	cmp    $0x2b,%al
  80190d:	75 0a                	jne    801919 <strtol+0x2a>
		s++;
  80190f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801912:	bf 00 00 00 00       	mov    $0x0,%edi
  801917:	eb 11                	jmp    80192a <strtol+0x3b>
  801919:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80191e:	3c 2d                	cmp    $0x2d,%al
  801920:	75 08                	jne    80192a <strtol+0x3b>
		s++, neg = 1;
  801922:	83 c1 01             	add    $0x1,%ecx
  801925:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80192a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801930:	75 15                	jne    801947 <strtol+0x58>
  801932:	80 39 30             	cmpb   $0x30,(%ecx)
  801935:	75 10                	jne    801947 <strtol+0x58>
  801937:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80193b:	75 7c                	jne    8019b9 <strtol+0xca>
		s += 2, base = 16;
  80193d:	83 c1 02             	add    $0x2,%ecx
  801940:	bb 10 00 00 00       	mov    $0x10,%ebx
  801945:	eb 16                	jmp    80195d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801947:	85 db                	test   %ebx,%ebx
  801949:	75 12                	jne    80195d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80194b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801950:	80 39 30             	cmpb   $0x30,(%ecx)
  801953:	75 08                	jne    80195d <strtol+0x6e>
		s++, base = 8;
  801955:	83 c1 01             	add    $0x1,%ecx
  801958:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
  801962:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801965:	0f b6 11             	movzbl (%ecx),%edx
  801968:	8d 72 d0             	lea    -0x30(%edx),%esi
  80196b:	89 f3                	mov    %esi,%ebx
  80196d:	80 fb 09             	cmp    $0x9,%bl
  801970:	77 08                	ja     80197a <strtol+0x8b>
			dig = *s - '0';
  801972:	0f be d2             	movsbl %dl,%edx
  801975:	83 ea 30             	sub    $0x30,%edx
  801978:	eb 22                	jmp    80199c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80197a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80197d:	89 f3                	mov    %esi,%ebx
  80197f:	80 fb 19             	cmp    $0x19,%bl
  801982:	77 08                	ja     80198c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801984:	0f be d2             	movsbl %dl,%edx
  801987:	83 ea 57             	sub    $0x57,%edx
  80198a:	eb 10                	jmp    80199c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80198c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80198f:	89 f3                	mov    %esi,%ebx
  801991:	80 fb 19             	cmp    $0x19,%bl
  801994:	77 16                	ja     8019ac <strtol+0xbd>
			dig = *s - 'A' + 10;
  801996:	0f be d2             	movsbl %dl,%edx
  801999:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80199c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80199f:	7d 0b                	jge    8019ac <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019a1:	83 c1 01             	add    $0x1,%ecx
  8019a4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019a8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019aa:	eb b9                	jmp    801965 <strtol+0x76>

	if (endptr)
  8019ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019b0:	74 0d                	je     8019bf <strtol+0xd0>
		*endptr = (char *) s;
  8019b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019b5:	89 0e                	mov    %ecx,(%esi)
  8019b7:	eb 06                	jmp    8019bf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019b9:	85 db                	test   %ebx,%ebx
  8019bb:	74 98                	je     801955 <strtol+0x66>
  8019bd:	eb 9e                	jmp    80195d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019bf:	89 c2                	mov    %eax,%edx
  8019c1:	f7 da                	neg    %edx
  8019c3:	85 ff                	test   %edi,%edi
  8019c5:	0f 45 c2             	cmovne %edx,%eax
}
  8019c8:	5b                   	pop    %ebx
  8019c9:	5e                   	pop    %esi
  8019ca:	5f                   	pop    %edi
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    

008019cd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019db:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019dd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019e2:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	50                   	push   %eax
  8019e9:	e8 1c e9 ff ff       	call   80030a <sys_ipc_recv>

	if (from_env_store != NULL)
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	85 f6                	test   %esi,%esi
  8019f3:	74 14                	je     801a09 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 09                	js     801a07 <ipc_recv+0x3a>
  8019fe:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a04:	8b 52 74             	mov    0x74(%edx),%edx
  801a07:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a09:	85 db                	test   %ebx,%ebx
  801a0b:	74 14                	je     801a21 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 09                	js     801a1f <ipc_recv+0x52>
  801a16:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a1c:	8b 52 78             	mov    0x78(%edx),%edx
  801a1f:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a21:	85 c0                	test   %eax,%eax
  801a23:	78 08                	js     801a2d <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a25:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	57                   	push   %edi
  801a38:	56                   	push   %esi
  801a39:	53                   	push   %ebx
  801a3a:	83 ec 0c             	sub    $0xc,%esp
  801a3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a40:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a46:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a48:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a4d:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a50:	ff 75 14             	pushl  0x14(%ebp)
  801a53:	53                   	push   %ebx
  801a54:	56                   	push   %esi
  801a55:	57                   	push   %edi
  801a56:	e8 8c e8 ff ff       	call   8002e7 <sys_ipc_try_send>

		if (err < 0) {
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	79 1e                	jns    801a80 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a62:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a65:	75 07                	jne    801a6e <ipc_send+0x3a>
				sys_yield();
  801a67:	e8 cf e6 ff ff       	call   80013b <sys_yield>
  801a6c:	eb e2                	jmp    801a50 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a6e:	50                   	push   %eax
  801a6f:	68 e0 21 80 00       	push   $0x8021e0
  801a74:	6a 49                	push   $0x49
  801a76:	68 ed 21 80 00       	push   $0x8021ed
  801a7b:	e8 a8 f5 ff ff       	call   801028 <_panic>
		}

	} while (err < 0);

}
  801a80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a83:	5b                   	pop    %ebx
  801a84:	5e                   	pop    %esi
  801a85:	5f                   	pop    %edi
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    

00801a88 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a8e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a93:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a96:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a9c:	8b 52 50             	mov    0x50(%edx),%edx
  801a9f:	39 ca                	cmp    %ecx,%edx
  801aa1:	75 0d                	jne    801ab0 <ipc_find_env+0x28>
			return envs[i].env_id;
  801aa3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aa6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aab:	8b 40 48             	mov    0x48(%eax),%eax
  801aae:	eb 0f                	jmp    801abf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab0:	83 c0 01             	add    $0x1,%eax
  801ab3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ab8:	75 d9                	jne    801a93 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ac7:	89 d0                	mov    %edx,%eax
  801ac9:	c1 e8 16             	shr    $0x16,%eax
  801acc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad8:	f6 c1 01             	test   $0x1,%cl
  801adb:	74 1d                	je     801afa <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801add:	c1 ea 0c             	shr    $0xc,%edx
  801ae0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ae7:	f6 c2 01             	test   $0x1,%dl
  801aea:	74 0e                	je     801afa <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801aec:	c1 ea 0c             	shr    $0xc,%edx
  801aef:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801af6:	ef 
  801af7:	0f b7 c0             	movzwl %ax,%eax
}
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    
  801afc:	66 90                	xchg   %ax,%ax
  801afe:	66 90                	xchg   %ax,%ax

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
