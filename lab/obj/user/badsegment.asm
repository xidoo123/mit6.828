
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
  80005b:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80008a:	e8 a6 04 00 00       	call   800535 <close_all>
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
  800103:	68 2a 22 80 00       	push   $0x80222a
  800108:	6a 23                	push   $0x23
  80010a:	68 47 22 80 00       	push   $0x802247
  80010f:	e8 9a 13 00 00       	call   8014ae <_panic>

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
  800184:	68 2a 22 80 00       	push   $0x80222a
  800189:	6a 23                	push   $0x23
  80018b:	68 47 22 80 00       	push   $0x802247
  800190:	e8 19 13 00 00       	call   8014ae <_panic>

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
  8001c6:	68 2a 22 80 00       	push   $0x80222a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 47 22 80 00       	push   $0x802247
  8001d2:	e8 d7 12 00 00       	call   8014ae <_panic>

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
  800208:	68 2a 22 80 00       	push   $0x80222a
  80020d:	6a 23                	push   $0x23
  80020f:	68 47 22 80 00       	push   $0x802247
  800214:	e8 95 12 00 00       	call   8014ae <_panic>

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
  80024a:	68 2a 22 80 00       	push   $0x80222a
  80024f:	6a 23                	push   $0x23
  800251:	68 47 22 80 00       	push   $0x802247
  800256:	e8 53 12 00 00       	call   8014ae <_panic>

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
  80028c:	68 2a 22 80 00       	push   $0x80222a
  800291:	6a 23                	push   $0x23
  800293:	68 47 22 80 00       	push   $0x802247
  800298:	e8 11 12 00 00       	call   8014ae <_panic>

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
  8002ce:	68 2a 22 80 00       	push   $0x80222a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 47 22 80 00       	push   $0x802247
  8002da:	e8 cf 11 00 00       	call   8014ae <_panic>

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
  800332:	68 2a 22 80 00       	push   $0x80222a
  800337:	6a 23                	push   $0x23
  800339:	68 47 22 80 00       	push   $0x802247
  80033e:	e8 6b 11 00 00       	call   8014ae <_panic>

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

0080034b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035b:	89 d1                	mov    %edx,%ecx
  80035d:	89 d3                	mov    %edx,%ebx
  80035f:	89 d7                	mov    %edx,%edi
  800361:	89 d6                	mov    %edx,%esi
  800363:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	05 00 00 00 30       	add    $0x30000000,%eax
  800375:	c1 e8 0c             	shr    $0xc,%eax
}
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	05 00 00 00 30       	add    $0x30000000,%eax
  800385:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80038a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80039c:	89 c2                	mov    %eax,%edx
  80039e:	c1 ea 16             	shr    $0x16,%edx
  8003a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a8:	f6 c2 01             	test   $0x1,%dl
  8003ab:	74 11                	je     8003be <fd_alloc+0x2d>
  8003ad:	89 c2                	mov    %eax,%edx
  8003af:	c1 ea 0c             	shr    $0xc,%edx
  8003b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b9:	f6 c2 01             	test   $0x1,%dl
  8003bc:	75 09                	jne    8003c7 <fd_alloc+0x36>
			*fd_store = fd;
  8003be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	eb 17                	jmp    8003de <fd_alloc+0x4d>
  8003c7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003cc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d1:	75 c9                	jne    80039c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e6:	83 f8 1f             	cmp    $0x1f,%eax
  8003e9:	77 36                	ja     800421 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003eb:	c1 e0 0c             	shl    $0xc,%eax
  8003ee:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003f3:	89 c2                	mov    %eax,%edx
  8003f5:	c1 ea 16             	shr    $0x16,%edx
  8003f8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ff:	f6 c2 01             	test   $0x1,%dl
  800402:	74 24                	je     800428 <fd_lookup+0x48>
  800404:	89 c2                	mov    %eax,%edx
  800406:	c1 ea 0c             	shr    $0xc,%edx
  800409:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800410:	f6 c2 01             	test   $0x1,%dl
  800413:	74 1a                	je     80042f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800415:	8b 55 0c             	mov    0xc(%ebp),%edx
  800418:	89 02                	mov    %eax,(%edx)
	return 0;
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	eb 13                	jmp    800434 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800421:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800426:	eb 0c                	jmp    800434 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800428:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042d:	eb 05                	jmp    800434 <fd_lookup+0x54>
  80042f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043f:	ba d4 22 80 00       	mov    $0x8022d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800444:	eb 13                	jmp    800459 <dev_lookup+0x23>
  800446:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800449:	39 08                	cmp    %ecx,(%eax)
  80044b:	75 0c                	jne    800459 <dev_lookup+0x23>
			*dev = devtab[i];
  80044d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800450:	89 01                	mov    %eax,(%ecx)
			return 0;
  800452:	b8 00 00 00 00       	mov    $0x0,%eax
  800457:	eb 2e                	jmp    800487 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800459:	8b 02                	mov    (%edx),%eax
  80045b:	85 c0                	test   %eax,%eax
  80045d:	75 e7                	jne    800446 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045f:	a1 08 40 80 00       	mov    0x804008,%eax
  800464:	8b 40 48             	mov    0x48(%eax),%eax
  800467:	83 ec 04             	sub    $0x4,%esp
  80046a:	51                   	push   %ecx
  80046b:	50                   	push   %eax
  80046c:	68 58 22 80 00       	push   $0x802258
  800471:	e8 11 11 00 00       	call   801587 <cprintf>
	*dev = 0;
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800487:	c9                   	leave  
  800488:	c3                   	ret    

00800489 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 10             	sub    $0x10,%esp
  800491:	8b 75 08             	mov    0x8(%ebp),%esi
  800494:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800497:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80049a:	50                   	push   %eax
  80049b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a1:	c1 e8 0c             	shr    $0xc,%eax
  8004a4:	50                   	push   %eax
  8004a5:	e8 36 ff ff ff       	call   8003e0 <fd_lookup>
  8004aa:	83 c4 08             	add    $0x8,%esp
  8004ad:	85 c0                	test   %eax,%eax
  8004af:	78 05                	js     8004b6 <fd_close+0x2d>
	    || fd != fd2)
  8004b1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b4:	74 0c                	je     8004c2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004b6:	84 db                	test   %bl,%bl
  8004b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004bd:	0f 44 c2             	cmove  %edx,%eax
  8004c0:	eb 41                	jmp    800503 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c8:	50                   	push   %eax
  8004c9:	ff 36                	pushl  (%esi)
  8004cb:	e8 66 ff ff ff       	call   800436 <dev_lookup>
  8004d0:	89 c3                	mov    %eax,%ebx
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	78 1a                	js     8004f3 <fd_close+0x6a>
		if (dev->dev_close)
  8004d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004dc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004df:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	74 0b                	je     8004f3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004e8:	83 ec 0c             	sub    $0xc,%esp
  8004eb:	56                   	push   %esi
  8004ec:	ff d0                	call   *%eax
  8004ee:	89 c3                	mov    %eax,%ebx
  8004f0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	56                   	push   %esi
  8004f7:	6a 00                	push   $0x0
  8004f9:	e8 e1 fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	89 d8                	mov    %ebx,%eax
}
  800503:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800506:	5b                   	pop    %ebx
  800507:	5e                   	pop    %esi
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800510:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800513:	50                   	push   %eax
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	e8 c4 fe ff ff       	call   8003e0 <fd_lookup>
  80051c:	83 c4 08             	add    $0x8,%esp
  80051f:	85 c0                	test   %eax,%eax
  800521:	78 10                	js     800533 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	6a 01                	push   $0x1
  800528:	ff 75 f4             	pushl  -0xc(%ebp)
  80052b:	e8 59 ff ff ff       	call   800489 <fd_close>
  800530:	83 c4 10             	add    $0x10,%esp
}
  800533:	c9                   	leave  
  800534:	c3                   	ret    

00800535 <close_all>:

void
close_all(void)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	53                   	push   %ebx
  800539:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80053c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800541:	83 ec 0c             	sub    $0xc,%esp
  800544:	53                   	push   %ebx
  800545:	e8 c0 ff ff ff       	call   80050a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80054a:	83 c3 01             	add    $0x1,%ebx
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	83 fb 20             	cmp    $0x20,%ebx
  800553:	75 ec                	jne    800541 <close_all+0xc>
		close(i);
}
  800555:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800558:	c9                   	leave  
  800559:	c3                   	ret    

0080055a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	57                   	push   %edi
  80055e:	56                   	push   %esi
  80055f:	53                   	push   %ebx
  800560:	83 ec 2c             	sub    $0x2c,%esp
  800563:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800566:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800569:	50                   	push   %eax
  80056a:	ff 75 08             	pushl  0x8(%ebp)
  80056d:	e8 6e fe ff ff       	call   8003e0 <fd_lookup>
  800572:	83 c4 08             	add    $0x8,%esp
  800575:	85 c0                	test   %eax,%eax
  800577:	0f 88 c1 00 00 00    	js     80063e <dup+0xe4>
		return r;
	close(newfdnum);
  80057d:	83 ec 0c             	sub    $0xc,%esp
  800580:	56                   	push   %esi
  800581:	e8 84 ff ff ff       	call   80050a <close>

	newfd = INDEX2FD(newfdnum);
  800586:	89 f3                	mov    %esi,%ebx
  800588:	c1 e3 0c             	shl    $0xc,%ebx
  80058b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800591:	83 c4 04             	add    $0x4,%esp
  800594:	ff 75 e4             	pushl  -0x1c(%ebp)
  800597:	e8 de fd ff ff       	call   80037a <fd2data>
  80059c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80059e:	89 1c 24             	mov    %ebx,(%esp)
  8005a1:	e8 d4 fd ff ff       	call   80037a <fd2data>
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ac:	89 f8                	mov    %edi,%eax
  8005ae:	c1 e8 16             	shr    $0x16,%eax
  8005b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b8:	a8 01                	test   $0x1,%al
  8005ba:	74 37                	je     8005f3 <dup+0x99>
  8005bc:	89 f8                	mov    %edi,%eax
  8005be:	c1 e8 0c             	shr    $0xc,%eax
  8005c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c8:	f6 c2 01             	test   $0x1,%dl
  8005cb:	74 26                	je     8005f3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d4:	83 ec 0c             	sub    $0xc,%esp
  8005d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005dc:	50                   	push   %eax
  8005dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e0:	6a 00                	push   $0x0
  8005e2:	57                   	push   %edi
  8005e3:	6a 00                	push   $0x0
  8005e5:	e8 b3 fb ff ff       	call   80019d <sys_page_map>
  8005ea:	89 c7                	mov    %eax,%edi
  8005ec:	83 c4 20             	add    $0x20,%esp
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	78 2e                	js     800621 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f6:	89 d0                	mov    %edx,%eax
  8005f8:	c1 e8 0c             	shr    $0xc,%eax
  8005fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800602:	83 ec 0c             	sub    $0xc,%esp
  800605:	25 07 0e 00 00       	and    $0xe07,%eax
  80060a:	50                   	push   %eax
  80060b:	53                   	push   %ebx
  80060c:	6a 00                	push   $0x0
  80060e:	52                   	push   %edx
  80060f:	6a 00                	push   $0x0
  800611:	e8 87 fb ff ff       	call   80019d <sys_page_map>
  800616:	89 c7                	mov    %eax,%edi
  800618:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80061b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061d:	85 ff                	test   %edi,%edi
  80061f:	79 1d                	jns    80063e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 00                	push   $0x0
  800627:	e8 b3 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800632:	6a 00                	push   $0x0
  800634:	e8 a6 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	89 f8                	mov    %edi,%eax
}
  80063e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800641:	5b                   	pop    %ebx
  800642:	5e                   	pop    %esi
  800643:	5f                   	pop    %edi
  800644:	5d                   	pop    %ebp
  800645:	c3                   	ret    

00800646 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
  800649:	53                   	push   %ebx
  80064a:	83 ec 14             	sub    $0x14,%esp
  80064d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	53                   	push   %ebx
  800655:	e8 86 fd ff ff       	call   8003e0 <fd_lookup>
  80065a:	83 c4 08             	add    $0x8,%esp
  80065d:	89 c2                	mov    %eax,%edx
  80065f:	85 c0                	test   %eax,%eax
  800661:	78 6d                	js     8006d0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800669:	50                   	push   %eax
  80066a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80066d:	ff 30                	pushl  (%eax)
  80066f:	e8 c2 fd ff ff       	call   800436 <dev_lookup>
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 c0                	test   %eax,%eax
  800679:	78 4c                	js     8006c7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80067b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80067e:	8b 42 08             	mov    0x8(%edx),%eax
  800681:	83 e0 03             	and    $0x3,%eax
  800684:	83 f8 01             	cmp    $0x1,%eax
  800687:	75 21                	jne    8006aa <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800689:	a1 08 40 80 00       	mov    0x804008,%eax
  80068e:	8b 40 48             	mov    0x48(%eax),%eax
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	53                   	push   %ebx
  800695:	50                   	push   %eax
  800696:	68 99 22 80 00       	push   $0x802299
  80069b:	e8 e7 0e 00 00       	call   801587 <cprintf>
		return -E_INVAL;
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a8:	eb 26                	jmp    8006d0 <read+0x8a>
	}
	if (!dev->dev_read)
  8006aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ad:	8b 40 08             	mov    0x8(%eax),%eax
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	74 17                	je     8006cb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b4:	83 ec 04             	sub    $0x4,%esp
  8006b7:	ff 75 10             	pushl  0x10(%ebp)
  8006ba:	ff 75 0c             	pushl  0xc(%ebp)
  8006bd:	52                   	push   %edx
  8006be:	ff d0                	call   *%eax
  8006c0:	89 c2                	mov    %eax,%edx
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 09                	jmp    8006d0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c7:	89 c2                	mov    %eax,%edx
  8006c9:	eb 05                	jmp    8006d0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d0:	89 d0                	mov    %edx,%eax
  8006d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	57                   	push   %edi
  8006db:	56                   	push   %esi
  8006dc:	53                   	push   %ebx
  8006dd:	83 ec 0c             	sub    $0xc,%esp
  8006e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006eb:	eb 21                	jmp    80070e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ed:	83 ec 04             	sub    $0x4,%esp
  8006f0:	89 f0                	mov    %esi,%eax
  8006f2:	29 d8                	sub    %ebx,%eax
  8006f4:	50                   	push   %eax
  8006f5:	89 d8                	mov    %ebx,%eax
  8006f7:	03 45 0c             	add    0xc(%ebp),%eax
  8006fa:	50                   	push   %eax
  8006fb:	57                   	push   %edi
  8006fc:	e8 45 ff ff ff       	call   800646 <read>
		if (m < 0)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	85 c0                	test   %eax,%eax
  800706:	78 10                	js     800718 <readn+0x41>
			return m;
		if (m == 0)
  800708:	85 c0                	test   %eax,%eax
  80070a:	74 0a                	je     800716 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070c:	01 c3                	add    %eax,%ebx
  80070e:	39 f3                	cmp    %esi,%ebx
  800710:	72 db                	jb     8006ed <readn+0x16>
  800712:	89 d8                	mov    %ebx,%eax
  800714:	eb 02                	jmp    800718 <readn+0x41>
  800716:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5f                   	pop    %edi
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	53                   	push   %ebx
  800724:	83 ec 14             	sub    $0x14,%esp
  800727:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	53                   	push   %ebx
  80072f:	e8 ac fc ff ff       	call   8003e0 <fd_lookup>
  800734:	83 c4 08             	add    $0x8,%esp
  800737:	89 c2                	mov    %eax,%edx
  800739:	85 c0                	test   %eax,%eax
  80073b:	78 68                	js     8007a5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800747:	ff 30                	pushl  (%eax)
  800749:	e8 e8 fc ff ff       	call   800436 <dev_lookup>
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	85 c0                	test   %eax,%eax
  800753:	78 47                	js     80079c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800755:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800758:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80075c:	75 21                	jne    80077f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075e:	a1 08 40 80 00       	mov    0x804008,%eax
  800763:	8b 40 48             	mov    0x48(%eax),%eax
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	53                   	push   %ebx
  80076a:	50                   	push   %eax
  80076b:	68 b5 22 80 00       	push   $0x8022b5
  800770:	e8 12 0e 00 00       	call   801587 <cprintf>
		return -E_INVAL;
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80077d:	eb 26                	jmp    8007a5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800782:	8b 52 0c             	mov    0xc(%edx),%edx
  800785:	85 d2                	test   %edx,%edx
  800787:	74 17                	je     8007a0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800789:	83 ec 04             	sub    $0x4,%esp
  80078c:	ff 75 10             	pushl  0x10(%ebp)
  80078f:	ff 75 0c             	pushl  0xc(%ebp)
  800792:	50                   	push   %eax
  800793:	ff d2                	call   *%edx
  800795:	89 c2                	mov    %eax,%edx
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	eb 09                	jmp    8007a5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079c:	89 c2                	mov    %eax,%edx
  80079e:	eb 05                	jmp    8007a5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a5:	89 d0                	mov    %edx,%eax
  8007a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007b2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b5:	50                   	push   %eax
  8007b6:	ff 75 08             	pushl  0x8(%ebp)
  8007b9:	e8 22 fc ff ff       	call   8003e0 <fd_lookup>
  8007be:	83 c4 08             	add    $0x8,%esp
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	78 0e                	js     8007d3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	83 ec 14             	sub    $0x14,%esp
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	53                   	push   %ebx
  8007e4:	e8 f7 fb ff ff       	call   8003e0 <fd_lookup>
  8007e9:	83 c4 08             	add    $0x8,%esp
  8007ec:	89 c2                	mov    %eax,%edx
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	78 65                	js     800857 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f2:	83 ec 08             	sub    $0x8,%esp
  8007f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f8:	50                   	push   %eax
  8007f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fc:	ff 30                	pushl  (%eax)
  8007fe:	e8 33 fc ff ff       	call   800436 <dev_lookup>
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	85 c0                	test   %eax,%eax
  800808:	78 44                	js     80084e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80080a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800811:	75 21                	jne    800834 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800813:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800818:	8b 40 48             	mov    0x48(%eax),%eax
  80081b:	83 ec 04             	sub    $0x4,%esp
  80081e:	53                   	push   %ebx
  80081f:	50                   	push   %eax
  800820:	68 78 22 80 00       	push   $0x802278
  800825:	e8 5d 0d 00 00       	call   801587 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800832:	eb 23                	jmp    800857 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800834:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800837:	8b 52 18             	mov    0x18(%edx),%edx
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 14                	je     800852 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	50                   	push   %eax
  800845:	ff d2                	call   *%edx
  800847:	89 c2                	mov    %eax,%edx
  800849:	83 c4 10             	add    $0x10,%esp
  80084c:	eb 09                	jmp    800857 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084e:	89 c2                	mov    %eax,%edx
  800850:	eb 05                	jmp    800857 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800852:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800857:	89 d0                	mov    %edx,%eax
  800859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	53                   	push   %ebx
  800862:	83 ec 14             	sub    $0x14,%esp
  800865:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800868:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086b:	50                   	push   %eax
  80086c:	ff 75 08             	pushl  0x8(%ebp)
  80086f:	e8 6c fb ff ff       	call   8003e0 <fd_lookup>
  800874:	83 c4 08             	add    $0x8,%esp
  800877:	89 c2                	mov    %eax,%edx
  800879:	85 c0                	test   %eax,%eax
  80087b:	78 58                	js     8008d5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800887:	ff 30                	pushl  (%eax)
  800889:	e8 a8 fb ff ff       	call   800436 <dev_lookup>
  80088e:	83 c4 10             	add    $0x10,%esp
  800891:	85 c0                	test   %eax,%eax
  800893:	78 37                	js     8008cc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800895:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800898:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80089c:	74 32                	je     8008d0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80089e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a8:	00 00 00 
	stat->st_isdir = 0;
  8008ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008b2:	00 00 00 
	stat->st_dev = dev;
  8008b5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	53                   	push   %ebx
  8008bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8008c2:	ff 50 14             	call   *0x14(%eax)
  8008c5:	89 c2                	mov    %eax,%edx
  8008c7:	83 c4 10             	add    $0x10,%esp
  8008ca:	eb 09                	jmp    8008d5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cc:	89 c2                	mov    %eax,%edx
  8008ce:	eb 05                	jmp    8008d5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d5:	89 d0                	mov    %edx,%eax
  8008d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	6a 00                	push   $0x0
  8008e6:	ff 75 08             	pushl  0x8(%ebp)
  8008e9:	e8 d6 01 00 00       	call   800ac4 <open>
  8008ee:	89 c3                	mov    %eax,%ebx
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	85 c0                	test   %eax,%eax
  8008f5:	78 1b                	js     800912 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	50                   	push   %eax
  8008fe:	e8 5b ff ff ff       	call   80085e <fstat>
  800903:	89 c6                	mov    %eax,%esi
	close(fd);
  800905:	89 1c 24             	mov    %ebx,(%esp)
  800908:	e8 fd fb ff ff       	call   80050a <close>
	return r;
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	89 f0                	mov    %esi,%eax
}
  800912:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
  80091e:	89 c6                	mov    %eax,%esi
  800920:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800922:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800929:	75 12                	jne    80093d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80092b:	83 ec 0c             	sub    $0xc,%esp
  80092e:	6a 01                	push   $0x1
  800930:	e8 d9 15 00 00       	call   801f0e <ipc_find_env>
  800935:	a3 00 40 80 00       	mov    %eax,0x804000
  80093a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80093d:	6a 07                	push   $0x7
  80093f:	68 00 50 80 00       	push   $0x805000
  800944:	56                   	push   %esi
  800945:	ff 35 00 40 80 00    	pushl  0x804000
  80094b:	e8 6a 15 00 00       	call   801eba <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800950:	83 c4 0c             	add    $0xc,%esp
  800953:	6a 00                	push   $0x0
  800955:	53                   	push   %ebx
  800956:	6a 00                	push   $0x0
  800958:	e8 f6 14 00 00       	call   801e53 <ipc_recv>
}
  80095d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 40 0c             	mov    0xc(%eax),%eax
  800970:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80097d:	ba 00 00 00 00       	mov    $0x0,%edx
  800982:	b8 02 00 00 00       	mov    $0x2,%eax
  800987:	e8 8d ff ff ff       	call   800919 <fsipc>
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 40 0c             	mov    0xc(%eax),%eax
  80099a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099f:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a9:	e8 6b ff ff ff       	call   800919 <fsipc>
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	53                   	push   %ebx
  8009b4:	83 ec 04             	sub    $0x4,%esp
  8009b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8009cf:	e8 45 ff ff ff       	call   800919 <fsipc>
  8009d4:	85 c0                	test   %eax,%eax
  8009d6:	78 2c                	js     800a04 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d8:	83 ec 08             	sub    $0x8,%esp
  8009db:	68 00 50 80 00       	push   $0x805000
  8009e0:	53                   	push   %ebx
  8009e1:	e8 26 11 00 00       	call   801b0c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009fc:	83 c4 10             	add    $0x10,%esp
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	83 ec 0c             	sub    $0xc,%esp
  800a0f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a12:	8b 55 08             	mov    0x8(%ebp),%edx
  800a15:	8b 52 0c             	mov    0xc(%edx),%edx
  800a18:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a1e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a23:	50                   	push   %eax
  800a24:	ff 75 0c             	pushl  0xc(%ebp)
  800a27:	68 08 50 80 00       	push   $0x805008
  800a2c:	e8 6d 12 00 00       	call   801c9e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	b8 04 00 00 00       	mov    $0x4,%eax
  800a3b:	e8 d9 fe ff ff       	call   800919 <fsipc>

}
  800a40:	c9                   	leave  
  800a41:	c3                   	ret    

00800a42 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a50:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a55:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a60:	b8 03 00 00 00       	mov    $0x3,%eax
  800a65:	e8 af fe ff ff       	call   800919 <fsipc>
  800a6a:	89 c3                	mov    %eax,%ebx
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	78 4b                	js     800abb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a70:	39 c6                	cmp    %eax,%esi
  800a72:	73 16                	jae    800a8a <devfile_read+0x48>
  800a74:	68 e8 22 80 00       	push   $0x8022e8
  800a79:	68 ef 22 80 00       	push   $0x8022ef
  800a7e:	6a 7c                	push   $0x7c
  800a80:	68 04 23 80 00       	push   $0x802304
  800a85:	e8 24 0a 00 00       	call   8014ae <_panic>
	assert(r <= PGSIZE);
  800a8a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a8f:	7e 16                	jle    800aa7 <devfile_read+0x65>
  800a91:	68 0f 23 80 00       	push   $0x80230f
  800a96:	68 ef 22 80 00       	push   $0x8022ef
  800a9b:	6a 7d                	push   $0x7d
  800a9d:	68 04 23 80 00       	push   $0x802304
  800aa2:	e8 07 0a 00 00       	call   8014ae <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa7:	83 ec 04             	sub    $0x4,%esp
  800aaa:	50                   	push   %eax
  800aab:	68 00 50 80 00       	push   $0x805000
  800ab0:	ff 75 0c             	pushl  0xc(%ebp)
  800ab3:	e8 e6 11 00 00       	call   801c9e <memmove>
	return r;
  800ab8:	83 c4 10             	add    $0x10,%esp
}
  800abb:	89 d8                	mov    %ebx,%eax
  800abd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	53                   	push   %ebx
  800ac8:	83 ec 20             	sub    $0x20,%esp
  800acb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ace:	53                   	push   %ebx
  800acf:	e8 ff 0f 00 00       	call   801ad3 <strlen>
  800ad4:	83 c4 10             	add    $0x10,%esp
  800ad7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800adc:	7f 67                	jg     800b45 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae4:	50                   	push   %eax
  800ae5:	e8 a7 f8 ff ff       	call   800391 <fd_alloc>
  800aea:	83 c4 10             	add    $0x10,%esp
		return r;
  800aed:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aef:	85 c0                	test   %eax,%eax
  800af1:	78 57                	js     800b4a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800af3:	83 ec 08             	sub    $0x8,%esp
  800af6:	53                   	push   %ebx
  800af7:	68 00 50 80 00       	push   $0x805000
  800afc:	e8 0b 10 00 00       	call   801b0c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b04:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b11:	e8 03 fe ff ff       	call   800919 <fsipc>
  800b16:	89 c3                	mov    %eax,%ebx
  800b18:	83 c4 10             	add    $0x10,%esp
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	79 14                	jns    800b33 <open+0x6f>
		fd_close(fd, 0);
  800b1f:	83 ec 08             	sub    $0x8,%esp
  800b22:	6a 00                	push   $0x0
  800b24:	ff 75 f4             	pushl  -0xc(%ebp)
  800b27:	e8 5d f9 ff ff       	call   800489 <fd_close>
		return r;
  800b2c:	83 c4 10             	add    $0x10,%esp
  800b2f:	89 da                	mov    %ebx,%edx
  800b31:	eb 17                	jmp    800b4a <open+0x86>
	}

	return fd2num(fd);
  800b33:	83 ec 0c             	sub    $0xc,%esp
  800b36:	ff 75 f4             	pushl  -0xc(%ebp)
  800b39:	e8 2c f8 ff ff       	call   80036a <fd2num>
  800b3e:	89 c2                	mov    %eax,%edx
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	eb 05                	jmp    800b4a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b45:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b4a:	89 d0                	mov    %edx,%eax
  800b4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b61:	e8 b3 fd ff ff       	call   800919 <fsipc>
}
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b6e:	68 1b 23 80 00       	push   $0x80231b
  800b73:	ff 75 0c             	pushl  0xc(%ebp)
  800b76:	e8 91 0f 00 00       	call   801b0c <strcpy>
	return 0;
}
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	53                   	push   %ebx
  800b86:	83 ec 10             	sub    $0x10,%esp
  800b89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b8c:	53                   	push   %ebx
  800b8d:	e8 b5 13 00 00       	call   801f47 <pageref>
  800b92:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800b9a:	83 f8 01             	cmp    $0x1,%eax
  800b9d:	75 10                	jne    800baf <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	ff 73 0c             	pushl  0xc(%ebx)
  800ba5:	e8 c0 02 00 00       	call   800e6a <nsipc_close>
  800baa:	89 c2                	mov    %eax,%edx
  800bac:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800baf:	89 d0                	mov    %edx,%eax
  800bb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bbc:	6a 00                	push   $0x0
  800bbe:	ff 75 10             	pushl  0x10(%ebp)
  800bc1:	ff 75 0c             	pushl  0xc(%ebp)
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc7:	ff 70 0c             	pushl  0xc(%eax)
  800bca:	e8 78 03 00 00       	call   800f47 <nsipc_send>
}
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bd7:	6a 00                	push   $0x0
  800bd9:	ff 75 10             	pushl  0x10(%ebp)
  800bdc:	ff 75 0c             	pushl  0xc(%ebp)
  800bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800be2:	ff 70 0c             	pushl  0xc(%eax)
  800be5:	e8 f1 02 00 00       	call   800edb <nsipc_recv>
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800bf2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800bf5:	52                   	push   %edx
  800bf6:	50                   	push   %eax
  800bf7:	e8 e4 f7 ff ff       	call   8003e0 <fd_lookup>
  800bfc:	83 c4 10             	add    $0x10,%esp
  800bff:	85 c0                	test   %eax,%eax
  800c01:	78 17                	js     800c1a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c06:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c0c:	39 08                	cmp    %ecx,(%eax)
  800c0e:	75 05                	jne    800c15 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c10:	8b 40 0c             	mov    0xc(%eax),%eax
  800c13:	eb 05                	jmp    800c1a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c15:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    

00800c1c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 1c             	sub    $0x1c,%esp
  800c24:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c29:	50                   	push   %eax
  800c2a:	e8 62 f7 ff ff       	call   800391 <fd_alloc>
  800c2f:	89 c3                	mov    %eax,%ebx
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	85 c0                	test   %eax,%eax
  800c36:	78 1b                	js     800c53 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c38:	83 ec 04             	sub    $0x4,%esp
  800c3b:	68 07 04 00 00       	push   $0x407
  800c40:	ff 75 f4             	pushl  -0xc(%ebp)
  800c43:	6a 00                	push   $0x0
  800c45:	e8 10 f5 ff ff       	call   80015a <sys_page_alloc>
  800c4a:	89 c3                	mov    %eax,%ebx
  800c4c:	83 c4 10             	add    $0x10,%esp
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	79 10                	jns    800c63 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	56                   	push   %esi
  800c57:	e8 0e 02 00 00       	call   800e6a <nsipc_close>
		return r;
  800c5c:	83 c4 10             	add    $0x10,%esp
  800c5f:	89 d8                	mov    %ebx,%eax
  800c61:	eb 24                	jmp    800c87 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c63:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c6c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c71:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c78:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	50                   	push   %eax
  800c7f:	e8 e6 f6 ff ff       	call   80036a <fd2num>
  800c84:	83 c4 10             	add    $0x10,%esp
}
  800c87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	e8 50 ff ff ff       	call   800bec <fd2sockid>
		return r;
  800c9c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	78 1f                	js     800cc1 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ca2:	83 ec 04             	sub    $0x4,%esp
  800ca5:	ff 75 10             	pushl  0x10(%ebp)
  800ca8:	ff 75 0c             	pushl  0xc(%ebp)
  800cab:	50                   	push   %eax
  800cac:	e8 12 01 00 00       	call   800dc3 <nsipc_accept>
  800cb1:	83 c4 10             	add    $0x10,%esp
		return r;
  800cb4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	78 07                	js     800cc1 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cba:	e8 5d ff ff ff       	call   800c1c <alloc_sockfd>
  800cbf:	89 c1                	mov    %eax,%ecx
}
  800cc1:	89 c8                	mov    %ecx,%eax
  800cc3:	c9                   	leave  
  800cc4:	c3                   	ret    

00800cc5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	e8 19 ff ff ff       	call   800bec <fd2sockid>
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	78 12                	js     800ce9 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800cd7:	83 ec 04             	sub    $0x4,%esp
  800cda:	ff 75 10             	pushl  0x10(%ebp)
  800cdd:	ff 75 0c             	pushl  0xc(%ebp)
  800ce0:	50                   	push   %eax
  800ce1:	e8 2d 01 00 00       	call   800e13 <nsipc_bind>
  800ce6:	83 c4 10             	add    $0x10,%esp
}
  800ce9:	c9                   	leave  
  800cea:	c3                   	ret    

00800ceb <shutdown>:

int
shutdown(int s, int how)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	e8 f3 fe ff ff       	call   800bec <fd2sockid>
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	78 0f                	js     800d0c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800cfd:	83 ec 08             	sub    $0x8,%esp
  800d00:	ff 75 0c             	pushl  0xc(%ebp)
  800d03:	50                   	push   %eax
  800d04:	e8 3f 01 00 00       	call   800e48 <nsipc_shutdown>
  800d09:	83 c4 10             	add    $0x10,%esp
}
  800d0c:	c9                   	leave  
  800d0d:	c3                   	ret    

00800d0e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	e8 d0 fe ff ff       	call   800bec <fd2sockid>
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	78 12                	js     800d32 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d20:	83 ec 04             	sub    $0x4,%esp
  800d23:	ff 75 10             	pushl  0x10(%ebp)
  800d26:	ff 75 0c             	pushl  0xc(%ebp)
  800d29:	50                   	push   %eax
  800d2a:	e8 55 01 00 00       	call   800e84 <nsipc_connect>
  800d2f:	83 c4 10             	add    $0x10,%esp
}
  800d32:	c9                   	leave  
  800d33:	c3                   	ret    

00800d34 <listen>:

int
listen(int s, int backlog)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3d:	e8 aa fe ff ff       	call   800bec <fd2sockid>
  800d42:	85 c0                	test   %eax,%eax
  800d44:	78 0f                	js     800d55 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d46:	83 ec 08             	sub    $0x8,%esp
  800d49:	ff 75 0c             	pushl  0xc(%ebp)
  800d4c:	50                   	push   %eax
  800d4d:	e8 67 01 00 00       	call   800eb9 <nsipc_listen>
  800d52:	83 c4 10             	add    $0x10,%esp
}
  800d55:	c9                   	leave  
  800d56:	c3                   	ret    

00800d57 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d5d:	ff 75 10             	pushl  0x10(%ebp)
  800d60:	ff 75 0c             	pushl  0xc(%ebp)
  800d63:	ff 75 08             	pushl  0x8(%ebp)
  800d66:	e8 3a 02 00 00       	call   800fa5 <nsipc_socket>
  800d6b:	83 c4 10             	add    $0x10,%esp
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	78 05                	js     800d77 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d72:	e8 a5 fe ff ff       	call   800c1c <alloc_sockfd>
}
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    

00800d79 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 04             	sub    $0x4,%esp
  800d80:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d82:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d89:	75 12                	jne    800d9d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	6a 02                	push   $0x2
  800d90:	e8 79 11 00 00       	call   801f0e <ipc_find_env>
  800d95:	a3 04 40 80 00       	mov    %eax,0x804004
  800d9a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800d9d:	6a 07                	push   $0x7
  800d9f:	68 00 60 80 00       	push   $0x806000
  800da4:	53                   	push   %ebx
  800da5:	ff 35 04 40 80 00    	pushl  0x804004
  800dab:	e8 0a 11 00 00       	call   801eba <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800db0:	83 c4 0c             	add    $0xc,%esp
  800db3:	6a 00                	push   $0x0
  800db5:	6a 00                	push   $0x0
  800db7:	6a 00                	push   $0x0
  800db9:	e8 95 10 00 00       	call   801e53 <ipc_recv>
}
  800dbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dd3:	8b 06                	mov    (%esi),%eax
  800dd5:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800dda:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddf:	e8 95 ff ff ff       	call   800d79 <nsipc>
  800de4:	89 c3                	mov    %eax,%ebx
  800de6:	85 c0                	test   %eax,%eax
  800de8:	78 20                	js     800e0a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	ff 35 10 60 80 00    	pushl  0x806010
  800df3:	68 00 60 80 00       	push   $0x806000
  800df8:	ff 75 0c             	pushl  0xc(%ebp)
  800dfb:	e8 9e 0e 00 00       	call   801c9e <memmove>
		*addrlen = ret->ret_addrlen;
  800e00:	a1 10 60 80 00       	mov    0x806010,%eax
  800e05:	89 06                	mov    %eax,(%esi)
  800e07:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e0a:	89 d8                	mov    %ebx,%eax
  800e0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	53                   	push   %ebx
  800e17:	83 ec 08             	sub    $0x8,%esp
  800e1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e25:	53                   	push   %ebx
  800e26:	ff 75 0c             	pushl  0xc(%ebp)
  800e29:	68 04 60 80 00       	push   $0x806004
  800e2e:	e8 6b 0e 00 00       	call   801c9e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e33:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e39:	b8 02 00 00 00       	mov    $0x2,%eax
  800e3e:	e8 36 ff ff ff       	call   800d79 <nsipc>
}
  800e43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e46:	c9                   	leave  
  800e47:	c3                   	ret    

00800e48 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e59:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800e63:	e8 11 ff ff ff       	call   800d79 <nsipc>
}
  800e68:	c9                   	leave  
  800e69:	c3                   	ret    

00800e6a <nsipc_close>:

int
nsipc_close(int s)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e78:	b8 04 00 00 00       	mov    $0x4,%eax
  800e7d:	e8 f7 fe ff ff       	call   800d79 <nsipc>
}
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	53                   	push   %ebx
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800e96:	53                   	push   %ebx
  800e97:	ff 75 0c             	pushl  0xc(%ebp)
  800e9a:	68 04 60 80 00       	push   $0x806004
  800e9f:	e8 fa 0d 00 00       	call   801c9e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ea4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800eaa:	b8 05 00 00 00       	mov    $0x5,%eax
  800eaf:	e8 c5 fe ff ff       	call   800d79 <nsipc>
}
  800eb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb7:	c9                   	leave  
  800eb8:	c3                   	ret    

00800eb9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eca:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ecf:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed4:	e8 a0 fe ff ff       	call   800d79 <nsipc>
}
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800eeb:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800ef1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef4:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800ef9:	b8 07 00 00 00       	mov    $0x7,%eax
  800efe:	e8 76 fe ff ff       	call   800d79 <nsipc>
  800f03:	89 c3                	mov    %eax,%ebx
  800f05:	85 c0                	test   %eax,%eax
  800f07:	78 35                	js     800f3e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f09:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f0e:	7f 04                	jg     800f14 <nsipc_recv+0x39>
  800f10:	39 c6                	cmp    %eax,%esi
  800f12:	7d 16                	jge    800f2a <nsipc_recv+0x4f>
  800f14:	68 27 23 80 00       	push   $0x802327
  800f19:	68 ef 22 80 00       	push   $0x8022ef
  800f1e:	6a 62                	push   $0x62
  800f20:	68 3c 23 80 00       	push   $0x80233c
  800f25:	e8 84 05 00 00       	call   8014ae <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	50                   	push   %eax
  800f2e:	68 00 60 80 00       	push   $0x806000
  800f33:	ff 75 0c             	pushl  0xc(%ebp)
  800f36:	e8 63 0d 00 00       	call   801c9e <memmove>
  800f3b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f3e:	89 d8                	mov    %ebx,%eax
  800f40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f51:	8b 45 08             	mov    0x8(%ebp),%eax
  800f54:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f59:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f5f:	7e 16                	jle    800f77 <nsipc_send+0x30>
  800f61:	68 48 23 80 00       	push   $0x802348
  800f66:	68 ef 22 80 00       	push   $0x8022ef
  800f6b:	6a 6d                	push   $0x6d
  800f6d:	68 3c 23 80 00       	push   $0x80233c
  800f72:	e8 37 05 00 00       	call   8014ae <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f77:	83 ec 04             	sub    $0x4,%esp
  800f7a:	53                   	push   %ebx
  800f7b:	ff 75 0c             	pushl  0xc(%ebp)
  800f7e:	68 0c 60 80 00       	push   $0x80600c
  800f83:	e8 16 0d 00 00       	call   801c9e <memmove>
	nsipcbuf.send.req_size = size;
  800f88:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800f8e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f91:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800f96:	b8 08 00 00 00       	mov    $0x8,%eax
  800f9b:	e8 d9 fd ff ff       	call   800d79 <nsipc>
}
  800fa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa3:	c9                   	leave  
  800fa4:	c3                   	ret    

00800fa5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fab:	8b 45 08             	mov    0x8(%ebp),%eax
  800fae:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb6:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fbb:	8b 45 10             	mov    0x10(%ebp),%eax
  800fbe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800fc3:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc8:	e8 ac fd ff ff       	call   800d79 <nsipc>
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	ff 75 08             	pushl  0x8(%ebp)
  800fdd:	e8 98 f3 ff ff       	call   80037a <fd2data>
  800fe2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	68 54 23 80 00       	push   $0x802354
  800fec:	53                   	push   %ebx
  800fed:	e8 1a 0b 00 00       	call   801b0c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ff2:	8b 46 04             	mov    0x4(%esi),%eax
  800ff5:	2b 06                	sub    (%esi),%eax
  800ff7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ffd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801004:	00 00 00 
	stat->st_dev = &devpipe;
  801007:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80100e:	30 80 00 
	return 0;
}
  801011:	b8 00 00 00 00       	mov    $0x0,%eax
  801016:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801019:	5b                   	pop    %ebx
  80101a:	5e                   	pop    %esi
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    

0080101d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	53                   	push   %ebx
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801027:	53                   	push   %ebx
  801028:	6a 00                	push   $0x0
  80102a:	e8 b0 f1 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80102f:	89 1c 24             	mov    %ebx,(%esp)
  801032:	e8 43 f3 ff ff       	call   80037a <fd2data>
  801037:	83 c4 08             	add    $0x8,%esp
  80103a:	50                   	push   %eax
  80103b:	6a 00                	push   $0x0
  80103d:	e8 9d f1 ff ff       	call   8001df <sys_page_unmap>
}
  801042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801045:	c9                   	leave  
  801046:	c3                   	ret    

00801047 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	57                   	push   %edi
  80104b:	56                   	push   %esi
  80104c:	53                   	push   %ebx
  80104d:	83 ec 1c             	sub    $0x1c,%esp
  801050:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801053:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801055:	a1 08 40 80 00       	mov    0x804008,%eax
  80105a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	ff 75 e0             	pushl  -0x20(%ebp)
  801063:	e8 df 0e 00 00       	call   801f47 <pageref>
  801068:	89 c3                	mov    %eax,%ebx
  80106a:	89 3c 24             	mov    %edi,(%esp)
  80106d:	e8 d5 0e 00 00       	call   801f47 <pageref>
  801072:	83 c4 10             	add    $0x10,%esp
  801075:	39 c3                	cmp    %eax,%ebx
  801077:	0f 94 c1             	sete   %cl
  80107a:	0f b6 c9             	movzbl %cl,%ecx
  80107d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801080:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801086:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801089:	39 ce                	cmp    %ecx,%esi
  80108b:	74 1b                	je     8010a8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80108d:	39 c3                	cmp    %eax,%ebx
  80108f:	75 c4                	jne    801055 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801091:	8b 42 58             	mov    0x58(%edx),%eax
  801094:	ff 75 e4             	pushl  -0x1c(%ebp)
  801097:	50                   	push   %eax
  801098:	56                   	push   %esi
  801099:	68 5b 23 80 00       	push   $0x80235b
  80109e:	e8 e4 04 00 00       	call   801587 <cprintf>
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	eb ad                	jmp    801055 <_pipeisclosed+0xe>
	}
}
  8010a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 28             	sub    $0x28,%esp
  8010bc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010bf:	56                   	push   %esi
  8010c0:	e8 b5 f2 ff ff       	call   80037a <fd2data>
  8010c5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8010cf:	eb 4b                	jmp    80111c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010d1:	89 da                	mov    %ebx,%edx
  8010d3:	89 f0                	mov    %esi,%eax
  8010d5:	e8 6d ff ff ff       	call   801047 <_pipeisclosed>
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	75 48                	jne    801126 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8010de:	e8 58 f0 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010e3:	8b 43 04             	mov    0x4(%ebx),%eax
  8010e6:	8b 0b                	mov    (%ebx),%ecx
  8010e8:	8d 51 20             	lea    0x20(%ecx),%edx
  8010eb:	39 d0                	cmp    %edx,%eax
  8010ed:	73 e2                	jae    8010d1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010f6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010f9:	89 c2                	mov    %eax,%edx
  8010fb:	c1 fa 1f             	sar    $0x1f,%edx
  8010fe:	89 d1                	mov    %edx,%ecx
  801100:	c1 e9 1b             	shr    $0x1b,%ecx
  801103:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801106:	83 e2 1f             	and    $0x1f,%edx
  801109:	29 ca                	sub    %ecx,%edx
  80110b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80110f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801113:	83 c0 01             	add    $0x1,%eax
  801116:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801119:	83 c7 01             	add    $0x1,%edi
  80111c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80111f:	75 c2                	jne    8010e3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801121:	8b 45 10             	mov    0x10(%ebp),%eax
  801124:	eb 05                	jmp    80112b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801126:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80112b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 18             	sub    $0x18,%esp
  80113c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80113f:	57                   	push   %edi
  801140:	e8 35 f2 ff ff       	call   80037a <fd2data>
  801145:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114f:	eb 3d                	jmp    80118e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801151:	85 db                	test   %ebx,%ebx
  801153:	74 04                	je     801159 <devpipe_read+0x26>
				return i;
  801155:	89 d8                	mov    %ebx,%eax
  801157:	eb 44                	jmp    80119d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801159:	89 f2                	mov    %esi,%edx
  80115b:	89 f8                	mov    %edi,%eax
  80115d:	e8 e5 fe ff ff       	call   801047 <_pipeisclosed>
  801162:	85 c0                	test   %eax,%eax
  801164:	75 32                	jne    801198 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801166:	e8 d0 ef ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80116b:	8b 06                	mov    (%esi),%eax
  80116d:	3b 46 04             	cmp    0x4(%esi),%eax
  801170:	74 df                	je     801151 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801172:	99                   	cltd   
  801173:	c1 ea 1b             	shr    $0x1b,%edx
  801176:	01 d0                	add    %edx,%eax
  801178:	83 e0 1f             	and    $0x1f,%eax
  80117b:	29 d0                	sub    %edx,%eax
  80117d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801185:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801188:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80118b:	83 c3 01             	add    $0x1,%ebx
  80118e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801191:	75 d8                	jne    80116b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801193:	8b 45 10             	mov    0x10(%ebp),%eax
  801196:	eb 05                	jmp    80119d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801198:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80119d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
  8011aa:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b0:	50                   	push   %eax
  8011b1:	e8 db f1 ff ff       	call   800391 <fd_alloc>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	89 c2                	mov    %eax,%edx
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	0f 88 2c 01 00 00    	js     8012ef <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011c3:	83 ec 04             	sub    $0x4,%esp
  8011c6:	68 07 04 00 00       	push   $0x407
  8011cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ce:	6a 00                	push   $0x0
  8011d0:	e8 85 ef ff ff       	call   80015a <sys_page_alloc>
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	0f 88 0d 01 00 00    	js     8012ef <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011e2:	83 ec 0c             	sub    $0xc,%esp
  8011e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	e8 a3 f1 ff ff       	call   800391 <fd_alloc>
  8011ee:	89 c3                	mov    %eax,%ebx
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	0f 88 e2 00 00 00    	js     8012dd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011fb:	83 ec 04             	sub    $0x4,%esp
  8011fe:	68 07 04 00 00       	push   $0x407
  801203:	ff 75 f0             	pushl  -0x10(%ebp)
  801206:	6a 00                	push   $0x0
  801208:	e8 4d ef ff ff       	call   80015a <sys_page_alloc>
  80120d:	89 c3                	mov    %eax,%ebx
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	0f 88 c3 00 00 00    	js     8012dd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80121a:	83 ec 0c             	sub    $0xc,%esp
  80121d:	ff 75 f4             	pushl  -0xc(%ebp)
  801220:	e8 55 f1 ff ff       	call   80037a <fd2data>
  801225:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801227:	83 c4 0c             	add    $0xc,%esp
  80122a:	68 07 04 00 00       	push   $0x407
  80122f:	50                   	push   %eax
  801230:	6a 00                	push   $0x0
  801232:	e8 23 ef ff ff       	call   80015a <sys_page_alloc>
  801237:	89 c3                	mov    %eax,%ebx
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	0f 88 89 00 00 00    	js     8012cd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801244:	83 ec 0c             	sub    $0xc,%esp
  801247:	ff 75 f0             	pushl  -0x10(%ebp)
  80124a:	e8 2b f1 ff ff       	call   80037a <fd2data>
  80124f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801256:	50                   	push   %eax
  801257:	6a 00                	push   $0x0
  801259:	56                   	push   %esi
  80125a:	6a 00                	push   $0x0
  80125c:	e8 3c ef ff ff       	call   80019d <sys_page_map>
  801261:	89 c3                	mov    %eax,%ebx
  801263:	83 c4 20             	add    $0x20,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 55                	js     8012bf <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80126a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801273:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801275:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801278:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80127f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801288:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801294:	83 ec 0c             	sub    $0xc,%esp
  801297:	ff 75 f4             	pushl  -0xc(%ebp)
  80129a:	e8 cb f0 ff ff       	call   80036a <fd2num>
  80129f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012a4:	83 c4 04             	add    $0x4,%esp
  8012a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8012aa:	e8 bb f0 ff ff       	call   80036a <fd2num>
  8012af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012bd:	eb 30                	jmp    8012ef <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	56                   	push   %esi
  8012c3:	6a 00                	push   $0x0
  8012c5:	e8 15 ef ff ff       	call   8001df <sys_page_unmap>
  8012ca:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d3:	6a 00                	push   $0x0
  8012d5:	e8 05 ef ff ff       	call   8001df <sys_page_unmap>
  8012da:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e3:	6a 00                	push   $0x0
  8012e5:	e8 f5 ee ff ff       	call   8001df <sys_page_unmap>
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8012ef:	89 d0                	mov    %edx,%eax
  8012f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	ff 75 08             	pushl  0x8(%ebp)
  801305:	e8 d6 f0 ff ff       	call   8003e0 <fd_lookup>
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 18                	js     801329 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	ff 75 f4             	pushl  -0xc(%ebp)
  801317:	e8 5e f0 ff ff       	call   80037a <fd2data>
	return _pipeisclosed(fd, p);
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801321:	e8 21 fd ff ff       	call   801047 <_pipeisclosed>
  801326:	83 c4 10             	add    $0x10,%esp
}
  801329:	c9                   	leave  
  80132a:	c3                   	ret    

0080132b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80132e:	b8 00 00 00 00       	mov    $0x0,%eax
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80133b:	68 73 23 80 00       	push   $0x802373
  801340:	ff 75 0c             	pushl  0xc(%ebp)
  801343:	e8 c4 07 00 00       	call   801b0c <strcpy>
	return 0;
}
  801348:	b8 00 00 00 00       	mov    $0x0,%eax
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	57                   	push   %edi
  801353:	56                   	push   %esi
  801354:	53                   	push   %ebx
  801355:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80135b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801360:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801366:	eb 2d                	jmp    801395 <devcons_write+0x46>
		m = n - tot;
  801368:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80136b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80136d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801370:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801375:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801378:	83 ec 04             	sub    $0x4,%esp
  80137b:	53                   	push   %ebx
  80137c:	03 45 0c             	add    0xc(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	57                   	push   %edi
  801381:	e8 18 09 00 00       	call   801c9e <memmove>
		sys_cputs(buf, m);
  801386:	83 c4 08             	add    $0x8,%esp
  801389:	53                   	push   %ebx
  80138a:	57                   	push   %edi
  80138b:	e8 0e ed ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801390:	01 de                	add    %ebx,%esi
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	89 f0                	mov    %esi,%eax
  801397:	3b 75 10             	cmp    0x10(%ebp),%esi
  80139a:	72 cc                	jb     801368 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80139c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013b3:	74 2a                	je     8013df <devcons_read+0x3b>
  8013b5:	eb 05                	jmp    8013bc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013b7:	e8 7f ed ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013bc:	e8 fb ec ff ff       	call   8000bc <sys_cgetc>
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	74 f2                	je     8013b7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 16                	js     8013df <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013c9:	83 f8 04             	cmp    $0x4,%eax
  8013cc:	74 0c                	je     8013da <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d1:	88 02                	mov    %al,(%edx)
	return 1;
  8013d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8013d8:	eb 05                	jmp    8013df <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013da:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013df:	c9                   	leave  
  8013e0:	c3                   	ret    

008013e1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ea:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013ed:	6a 01                	push   $0x1
  8013ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013f2:	50                   	push   %eax
  8013f3:	e8 a6 ec ff ff       	call   80009e <sys_cputs>
}
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	c9                   	leave  
  8013fc:	c3                   	ret    

008013fd <getchar>:

int
getchar(void)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801403:	6a 01                	push   $0x1
  801405:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	6a 00                	push   $0x0
  80140b:	e8 36 f2 ff ff       	call   800646 <read>
	if (r < 0)
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	78 0f                	js     801426 <getchar+0x29>
		return r;
	if (r < 1)
  801417:	85 c0                	test   %eax,%eax
  801419:	7e 06                	jle    801421 <getchar+0x24>
		return -E_EOF;
	return c;
  80141b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80141f:	eb 05                	jmp    801426 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801421:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	ff 75 08             	pushl  0x8(%ebp)
  801435:	e8 a6 ef ff ff       	call   8003e0 <fd_lookup>
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 11                	js     801452 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801441:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801444:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80144a:	39 10                	cmp    %edx,(%eax)
  80144c:	0f 94 c0             	sete   %al
  80144f:	0f b6 c0             	movzbl %al,%eax
}
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <opencons>:

int
opencons(void)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80145a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	e8 2e ef ff ff       	call   800391 <fd_alloc>
  801463:	83 c4 10             	add    $0x10,%esp
		return r;
  801466:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 3e                	js     8014aa <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	68 07 04 00 00       	push   $0x407
  801474:	ff 75 f4             	pushl  -0xc(%ebp)
  801477:	6a 00                	push   $0x0
  801479:	e8 dc ec ff ff       	call   80015a <sys_page_alloc>
  80147e:	83 c4 10             	add    $0x10,%esp
		return r;
  801481:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801483:	85 c0                	test   %eax,%eax
  801485:	78 23                	js     8014aa <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801487:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801490:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801495:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80149c:	83 ec 0c             	sub    $0xc,%esp
  80149f:	50                   	push   %eax
  8014a0:	e8 c5 ee ff ff       	call   80036a <fd2num>
  8014a5:	89 c2                	mov    %eax,%edx
  8014a7:	83 c4 10             	add    $0x10,%esp
}
  8014aa:	89 d0                	mov    %edx,%eax
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    

008014ae <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	56                   	push   %esi
  8014b2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014b3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014b6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014bc:	e8 5b ec ff ff       	call   80011c <sys_getenvid>
  8014c1:	83 ec 0c             	sub    $0xc,%esp
  8014c4:	ff 75 0c             	pushl  0xc(%ebp)
  8014c7:	ff 75 08             	pushl  0x8(%ebp)
  8014ca:	56                   	push   %esi
  8014cb:	50                   	push   %eax
  8014cc:	68 80 23 80 00       	push   $0x802380
  8014d1:	e8 b1 00 00 00       	call   801587 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014d6:	83 c4 18             	add    $0x18,%esp
  8014d9:	53                   	push   %ebx
  8014da:	ff 75 10             	pushl  0x10(%ebp)
  8014dd:	e8 54 00 00 00       	call   801536 <vcprintf>
	cprintf("\n");
  8014e2:	c7 04 24 6c 23 80 00 	movl   $0x80236c,(%esp)
  8014e9:	e8 99 00 00 00       	call   801587 <cprintf>
  8014ee:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014f1:	cc                   	int3   
  8014f2:	eb fd                	jmp    8014f1 <_panic+0x43>

008014f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014fe:	8b 13                	mov    (%ebx),%edx
  801500:	8d 42 01             	lea    0x1(%edx),%eax
  801503:	89 03                	mov    %eax,(%ebx)
  801505:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801508:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80150c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801511:	75 1a                	jne    80152d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	68 ff 00 00 00       	push   $0xff
  80151b:	8d 43 08             	lea    0x8(%ebx),%eax
  80151e:	50                   	push   %eax
  80151f:	e8 7a eb ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  801524:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80152a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80152d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801534:	c9                   	leave  
  801535:	c3                   	ret    

00801536 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80153f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801546:	00 00 00 
	b.cnt = 0;
  801549:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801550:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801553:	ff 75 0c             	pushl  0xc(%ebp)
  801556:	ff 75 08             	pushl  0x8(%ebp)
  801559:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	68 f4 14 80 00       	push   $0x8014f4
  801565:	e8 54 01 00 00       	call   8016be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80156a:	83 c4 08             	add    $0x8,%esp
  80156d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801573:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	e8 1f eb ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  80157f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80158d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801590:	50                   	push   %eax
  801591:	ff 75 08             	pushl  0x8(%ebp)
  801594:	e8 9d ff ff ff       	call   801536 <vcprintf>
	va_end(ap);

	return cnt;
}
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	57                   	push   %edi
  80159f:	56                   	push   %esi
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 1c             	sub    $0x1c,%esp
  8015a4:	89 c7                	mov    %eax,%edi
  8015a6:	89 d6                	mov    %edx,%esi
  8015a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015bc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015bf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015c2:	39 d3                	cmp    %edx,%ebx
  8015c4:	72 05                	jb     8015cb <printnum+0x30>
  8015c6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015c9:	77 45                	ja     801610 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015cb:	83 ec 0c             	sub    $0xc,%esp
  8015ce:	ff 75 18             	pushl  0x18(%ebp)
  8015d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015d7:	53                   	push   %ebx
  8015d8:	ff 75 10             	pushl  0x10(%ebp)
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e4:	ff 75 dc             	pushl  -0x24(%ebp)
  8015e7:	ff 75 d8             	pushl  -0x28(%ebp)
  8015ea:	e8 a1 09 00 00       	call   801f90 <__udivdi3>
  8015ef:	83 c4 18             	add    $0x18,%esp
  8015f2:	52                   	push   %edx
  8015f3:	50                   	push   %eax
  8015f4:	89 f2                	mov    %esi,%edx
  8015f6:	89 f8                	mov    %edi,%eax
  8015f8:	e8 9e ff ff ff       	call   80159b <printnum>
  8015fd:	83 c4 20             	add    $0x20,%esp
  801600:	eb 18                	jmp    80161a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	56                   	push   %esi
  801606:	ff 75 18             	pushl  0x18(%ebp)
  801609:	ff d7                	call   *%edi
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb 03                	jmp    801613 <printnum+0x78>
  801610:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801613:	83 eb 01             	sub    $0x1,%ebx
  801616:	85 db                	test   %ebx,%ebx
  801618:	7f e8                	jg     801602 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	56                   	push   %esi
  80161e:	83 ec 04             	sub    $0x4,%esp
  801621:	ff 75 e4             	pushl  -0x1c(%ebp)
  801624:	ff 75 e0             	pushl  -0x20(%ebp)
  801627:	ff 75 dc             	pushl  -0x24(%ebp)
  80162a:	ff 75 d8             	pushl  -0x28(%ebp)
  80162d:	e8 8e 0a 00 00       	call   8020c0 <__umoddi3>
  801632:	83 c4 14             	add    $0x14,%esp
  801635:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  80163c:	50                   	push   %eax
  80163d:	ff d7                	call   *%edi
}
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	5f                   	pop    %edi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80164d:	83 fa 01             	cmp    $0x1,%edx
  801650:	7e 0e                	jle    801660 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801652:	8b 10                	mov    (%eax),%edx
  801654:	8d 4a 08             	lea    0x8(%edx),%ecx
  801657:	89 08                	mov    %ecx,(%eax)
  801659:	8b 02                	mov    (%edx),%eax
  80165b:	8b 52 04             	mov    0x4(%edx),%edx
  80165e:	eb 22                	jmp    801682 <getuint+0x38>
	else if (lflag)
  801660:	85 d2                	test   %edx,%edx
  801662:	74 10                	je     801674 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801664:	8b 10                	mov    (%eax),%edx
  801666:	8d 4a 04             	lea    0x4(%edx),%ecx
  801669:	89 08                	mov    %ecx,(%eax)
  80166b:	8b 02                	mov    (%edx),%eax
  80166d:	ba 00 00 00 00       	mov    $0x0,%edx
  801672:	eb 0e                	jmp    801682 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801674:	8b 10                	mov    (%eax),%edx
  801676:	8d 4a 04             	lea    0x4(%edx),%ecx
  801679:	89 08                	mov    %ecx,(%eax)
  80167b:	8b 02                	mov    (%edx),%eax
  80167d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80168a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80168e:	8b 10                	mov    (%eax),%edx
  801690:	3b 50 04             	cmp    0x4(%eax),%edx
  801693:	73 0a                	jae    80169f <sprintputch+0x1b>
		*b->buf++ = ch;
  801695:	8d 4a 01             	lea    0x1(%edx),%ecx
  801698:	89 08                	mov    %ecx,(%eax)
  80169a:	8b 45 08             	mov    0x8(%ebp),%eax
  80169d:	88 02                	mov    %al,(%edx)
}
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016a7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016aa:	50                   	push   %eax
  8016ab:	ff 75 10             	pushl  0x10(%ebp)
  8016ae:	ff 75 0c             	pushl  0xc(%ebp)
  8016b1:	ff 75 08             	pushl  0x8(%ebp)
  8016b4:	e8 05 00 00 00       	call   8016be <vprintfmt>
	va_end(ap);
}
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	c9                   	leave  
  8016bd:	c3                   	ret    

008016be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	57                   	push   %edi
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 2c             	sub    $0x2c,%esp
  8016c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016cd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016d0:	eb 12                	jmp    8016e4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	0f 84 89 03 00 00    	je     801a63 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	53                   	push   %ebx
  8016de:	50                   	push   %eax
  8016df:	ff d6                	call   *%esi
  8016e1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016e4:	83 c7 01             	add    $0x1,%edi
  8016e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016eb:	83 f8 25             	cmp    $0x25,%eax
  8016ee:	75 e2                	jne    8016d2 <vprintfmt+0x14>
  8016f0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801702:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801709:	ba 00 00 00 00       	mov    $0x0,%edx
  80170e:	eb 07                	jmp    801717 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801710:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801713:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801717:	8d 47 01             	lea    0x1(%edi),%eax
  80171a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80171d:	0f b6 07             	movzbl (%edi),%eax
  801720:	0f b6 c8             	movzbl %al,%ecx
  801723:	83 e8 23             	sub    $0x23,%eax
  801726:	3c 55                	cmp    $0x55,%al
  801728:	0f 87 1a 03 00 00    	ja     801a48 <vprintfmt+0x38a>
  80172e:	0f b6 c0             	movzbl %al,%eax
  801731:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  801738:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80173b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80173f:	eb d6                	jmp    801717 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801741:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801744:	b8 00 00 00 00       	mov    $0x0,%eax
  801749:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80174c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80174f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801753:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801756:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801759:	83 fa 09             	cmp    $0x9,%edx
  80175c:	77 39                	ja     801797 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80175e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801761:	eb e9                	jmp    80174c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801763:	8b 45 14             	mov    0x14(%ebp),%eax
  801766:	8d 48 04             	lea    0x4(%eax),%ecx
  801769:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80176c:	8b 00                	mov    (%eax),%eax
  80176e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801771:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801774:	eb 27                	jmp    80179d <vprintfmt+0xdf>
  801776:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801779:	85 c0                	test   %eax,%eax
  80177b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801780:	0f 49 c8             	cmovns %eax,%ecx
  801783:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801786:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801789:	eb 8c                	jmp    801717 <vprintfmt+0x59>
  80178b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80178e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801795:	eb 80                	jmp    801717 <vprintfmt+0x59>
  801797:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80179a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80179d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017a1:	0f 89 70 ff ff ff    	jns    801717 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017b4:	e9 5e ff ff ff       	jmp    801717 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017b9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017bf:	e9 53 ff ff ff       	jmp    801717 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c7:	8d 50 04             	lea    0x4(%eax),%edx
  8017ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8017cd:	83 ec 08             	sub    $0x8,%esp
  8017d0:	53                   	push   %ebx
  8017d1:	ff 30                	pushl  (%eax)
  8017d3:	ff d6                	call   *%esi
			break;
  8017d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017db:	e9 04 ff ff ff       	jmp    8016e4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e3:	8d 50 04             	lea    0x4(%eax),%edx
  8017e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8017e9:	8b 00                	mov    (%eax),%eax
  8017eb:	99                   	cltd   
  8017ec:	31 d0                	xor    %edx,%eax
  8017ee:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017f0:	83 f8 0f             	cmp    $0xf,%eax
  8017f3:	7f 0b                	jg     801800 <vprintfmt+0x142>
  8017f5:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8017fc:	85 d2                	test   %edx,%edx
  8017fe:	75 18                	jne    801818 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801800:	50                   	push   %eax
  801801:	68 bb 23 80 00       	push   $0x8023bb
  801806:	53                   	push   %ebx
  801807:	56                   	push   %esi
  801808:	e8 94 fe ff ff       	call   8016a1 <printfmt>
  80180d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801810:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801813:	e9 cc fe ff ff       	jmp    8016e4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801818:	52                   	push   %edx
  801819:	68 01 23 80 00       	push   $0x802301
  80181e:	53                   	push   %ebx
  80181f:	56                   	push   %esi
  801820:	e8 7c fe ff ff       	call   8016a1 <printfmt>
  801825:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801828:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80182b:	e9 b4 fe ff ff       	jmp    8016e4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801830:	8b 45 14             	mov    0x14(%ebp),%eax
  801833:	8d 50 04             	lea    0x4(%eax),%edx
  801836:	89 55 14             	mov    %edx,0x14(%ebp)
  801839:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80183b:	85 ff                	test   %edi,%edi
  80183d:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  801842:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801845:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801849:	0f 8e 94 00 00 00    	jle    8018e3 <vprintfmt+0x225>
  80184f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801853:	0f 84 98 00 00 00    	je     8018f1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801859:	83 ec 08             	sub    $0x8,%esp
  80185c:	ff 75 d0             	pushl  -0x30(%ebp)
  80185f:	57                   	push   %edi
  801860:	e8 86 02 00 00       	call   801aeb <strnlen>
  801865:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801868:	29 c1                	sub    %eax,%ecx
  80186a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80186d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801870:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801874:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801877:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80187a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80187c:	eb 0f                	jmp    80188d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	53                   	push   %ebx
  801882:	ff 75 e0             	pushl  -0x20(%ebp)
  801885:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801887:	83 ef 01             	sub    $0x1,%edi
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	85 ff                	test   %edi,%edi
  80188f:	7f ed                	jg     80187e <vprintfmt+0x1c0>
  801891:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801894:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801897:	85 c9                	test   %ecx,%ecx
  801899:	b8 00 00 00 00       	mov    $0x0,%eax
  80189e:	0f 49 c1             	cmovns %ecx,%eax
  8018a1:	29 c1                	sub    %eax,%ecx
  8018a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8018a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ac:	89 cb                	mov    %ecx,%ebx
  8018ae:	eb 4d                	jmp    8018fd <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018b4:	74 1b                	je     8018d1 <vprintfmt+0x213>
  8018b6:	0f be c0             	movsbl %al,%eax
  8018b9:	83 e8 20             	sub    $0x20,%eax
  8018bc:	83 f8 5e             	cmp    $0x5e,%eax
  8018bf:	76 10                	jbe    8018d1 <vprintfmt+0x213>
					putch('?', putdat);
  8018c1:	83 ec 08             	sub    $0x8,%esp
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	6a 3f                	push   $0x3f
  8018c9:	ff 55 08             	call   *0x8(%ebp)
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	eb 0d                	jmp    8018de <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018d1:	83 ec 08             	sub    $0x8,%esp
  8018d4:	ff 75 0c             	pushl  0xc(%ebp)
  8018d7:	52                   	push   %edx
  8018d8:	ff 55 08             	call   *0x8(%ebp)
  8018db:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018de:	83 eb 01             	sub    $0x1,%ebx
  8018e1:	eb 1a                	jmp    8018fd <vprintfmt+0x23f>
  8018e3:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ec:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018ef:	eb 0c                	jmp    8018fd <vprintfmt+0x23f>
  8018f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018fa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018fd:	83 c7 01             	add    $0x1,%edi
  801900:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801904:	0f be d0             	movsbl %al,%edx
  801907:	85 d2                	test   %edx,%edx
  801909:	74 23                	je     80192e <vprintfmt+0x270>
  80190b:	85 f6                	test   %esi,%esi
  80190d:	78 a1                	js     8018b0 <vprintfmt+0x1f2>
  80190f:	83 ee 01             	sub    $0x1,%esi
  801912:	79 9c                	jns    8018b0 <vprintfmt+0x1f2>
  801914:	89 df                	mov    %ebx,%edi
  801916:	8b 75 08             	mov    0x8(%ebp),%esi
  801919:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80191c:	eb 18                	jmp    801936 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	53                   	push   %ebx
  801922:	6a 20                	push   $0x20
  801924:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801926:	83 ef 01             	sub    $0x1,%edi
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	eb 08                	jmp    801936 <vprintfmt+0x278>
  80192e:	89 df                	mov    %ebx,%edi
  801930:	8b 75 08             	mov    0x8(%ebp),%esi
  801933:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801936:	85 ff                	test   %edi,%edi
  801938:	7f e4                	jg     80191e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80193a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80193d:	e9 a2 fd ff ff       	jmp    8016e4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801942:	83 fa 01             	cmp    $0x1,%edx
  801945:	7e 16                	jle    80195d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801947:	8b 45 14             	mov    0x14(%ebp),%eax
  80194a:	8d 50 08             	lea    0x8(%eax),%edx
  80194d:	89 55 14             	mov    %edx,0x14(%ebp)
  801950:	8b 50 04             	mov    0x4(%eax),%edx
  801953:	8b 00                	mov    (%eax),%eax
  801955:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801958:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195b:	eb 32                	jmp    80198f <vprintfmt+0x2d1>
	else if (lflag)
  80195d:	85 d2                	test   %edx,%edx
  80195f:	74 18                	je     801979 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801961:	8b 45 14             	mov    0x14(%ebp),%eax
  801964:	8d 50 04             	lea    0x4(%eax),%edx
  801967:	89 55 14             	mov    %edx,0x14(%ebp)
  80196a:	8b 00                	mov    (%eax),%eax
  80196c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80196f:	89 c1                	mov    %eax,%ecx
  801971:	c1 f9 1f             	sar    $0x1f,%ecx
  801974:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801977:	eb 16                	jmp    80198f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801979:	8b 45 14             	mov    0x14(%ebp),%eax
  80197c:	8d 50 04             	lea    0x4(%eax),%edx
  80197f:	89 55 14             	mov    %edx,0x14(%ebp)
  801982:	8b 00                	mov    (%eax),%eax
  801984:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801987:	89 c1                	mov    %eax,%ecx
  801989:	c1 f9 1f             	sar    $0x1f,%ecx
  80198c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80198f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801992:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801995:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80199a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80199e:	79 74                	jns    801a14 <vprintfmt+0x356>
				putch('-', putdat);
  8019a0:	83 ec 08             	sub    $0x8,%esp
  8019a3:	53                   	push   %ebx
  8019a4:	6a 2d                	push   $0x2d
  8019a6:	ff d6                	call   *%esi
				num = -(long long) num;
  8019a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019ae:	f7 d8                	neg    %eax
  8019b0:	83 d2 00             	adc    $0x0,%edx
  8019b3:	f7 da                	neg    %edx
  8019b5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019b8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019bd:	eb 55                	jmp    801a14 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8019c2:	e8 83 fc ff ff       	call   80164a <getuint>
			base = 10;
  8019c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019cc:	eb 46                	jmp    801a14 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8019ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8019d1:	e8 74 fc ff ff       	call   80164a <getuint>
			base = 8;
  8019d6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019db:	eb 37                	jmp    801a14 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8019dd:	83 ec 08             	sub    $0x8,%esp
  8019e0:	53                   	push   %ebx
  8019e1:	6a 30                	push   $0x30
  8019e3:	ff d6                	call   *%esi
			putch('x', putdat);
  8019e5:	83 c4 08             	add    $0x8,%esp
  8019e8:	53                   	push   %ebx
  8019e9:	6a 78                	push   $0x78
  8019eb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f0:	8d 50 04             	lea    0x4(%eax),%edx
  8019f3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019f6:	8b 00                	mov    (%eax),%eax
  8019f8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019fd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a00:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a05:	eb 0d                	jmp    801a14 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a07:	8d 45 14             	lea    0x14(%ebp),%eax
  801a0a:	e8 3b fc ff ff       	call   80164a <getuint>
			base = 16;
  801a0f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a14:	83 ec 0c             	sub    $0xc,%esp
  801a17:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a1b:	57                   	push   %edi
  801a1c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1f:	51                   	push   %ecx
  801a20:	52                   	push   %edx
  801a21:	50                   	push   %eax
  801a22:	89 da                	mov    %ebx,%edx
  801a24:	89 f0                	mov    %esi,%eax
  801a26:	e8 70 fb ff ff       	call   80159b <printnum>
			break;
  801a2b:	83 c4 20             	add    $0x20,%esp
  801a2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a31:	e9 ae fc ff ff       	jmp    8016e4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a36:	83 ec 08             	sub    $0x8,%esp
  801a39:	53                   	push   %ebx
  801a3a:	51                   	push   %ecx
  801a3b:	ff d6                	call   *%esi
			break;
  801a3d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a43:	e9 9c fc ff ff       	jmp    8016e4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a48:	83 ec 08             	sub    $0x8,%esp
  801a4b:	53                   	push   %ebx
  801a4c:	6a 25                	push   $0x25
  801a4e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	eb 03                	jmp    801a58 <vprintfmt+0x39a>
  801a55:	83 ef 01             	sub    $0x1,%edi
  801a58:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a5c:	75 f7                	jne    801a55 <vprintfmt+0x397>
  801a5e:	e9 81 fc ff ff       	jmp    8016e4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5f                   	pop    %edi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 18             	sub    $0x18,%esp
  801a71:	8b 45 08             	mov    0x8(%ebp),%eax
  801a74:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a77:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a7a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a7e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	74 26                	je     801ab2 <vsnprintf+0x47>
  801a8c:	85 d2                	test   %edx,%edx
  801a8e:	7e 22                	jle    801ab2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a90:	ff 75 14             	pushl  0x14(%ebp)
  801a93:	ff 75 10             	pushl  0x10(%ebp)
  801a96:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a99:	50                   	push   %eax
  801a9a:	68 84 16 80 00       	push   $0x801684
  801a9f:	e8 1a fc ff ff       	call   8016be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aa7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	eb 05                	jmp    801ab7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ab2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801abf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ac2:	50                   	push   %eax
  801ac3:	ff 75 10             	pushl  0x10(%ebp)
  801ac6:	ff 75 0c             	pushl  0xc(%ebp)
  801ac9:	ff 75 08             	pushl  0x8(%ebp)
  801acc:	e8 9a ff ff ff       	call   801a6b <vsnprintf>
	va_end(ap);

	return rc;
}
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ade:	eb 03                	jmp    801ae3 <strlen+0x10>
		n++;
  801ae0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ae3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ae7:	75 f7                	jne    801ae0 <strlen+0xd>
		n++;
	return n;
}
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801af4:	ba 00 00 00 00       	mov    $0x0,%edx
  801af9:	eb 03                	jmp    801afe <strnlen+0x13>
		n++;
  801afb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801afe:	39 c2                	cmp    %eax,%edx
  801b00:	74 08                	je     801b0a <strnlen+0x1f>
  801b02:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b06:	75 f3                	jne    801afb <strnlen+0x10>
  801b08:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	53                   	push   %ebx
  801b10:	8b 45 08             	mov    0x8(%ebp),%eax
  801b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	83 c2 01             	add    $0x1,%edx
  801b1b:	83 c1 01             	add    $0x1,%ecx
  801b1e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b22:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b25:	84 db                	test   %bl,%bl
  801b27:	75 ef                	jne    801b18 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b29:	5b                   	pop    %ebx
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    

00801b2c <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	53                   	push   %ebx
  801b30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b33:	53                   	push   %ebx
  801b34:	e8 9a ff ff ff       	call   801ad3 <strlen>
  801b39:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b3c:	ff 75 0c             	pushl  0xc(%ebp)
  801b3f:	01 d8                	add    %ebx,%eax
  801b41:	50                   	push   %eax
  801b42:	e8 c5 ff ff ff       	call   801b0c <strcpy>
	return dst;
}
  801b47:	89 d8                	mov    %ebx,%eax
  801b49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    

00801b4e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	56                   	push   %esi
  801b52:	53                   	push   %ebx
  801b53:	8b 75 08             	mov    0x8(%ebp),%esi
  801b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b59:	89 f3                	mov    %esi,%ebx
  801b5b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b5e:	89 f2                	mov    %esi,%edx
  801b60:	eb 0f                	jmp    801b71 <strncpy+0x23>
		*dst++ = *src;
  801b62:	83 c2 01             	add    $0x1,%edx
  801b65:	0f b6 01             	movzbl (%ecx),%eax
  801b68:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b6b:	80 39 01             	cmpb   $0x1,(%ecx)
  801b6e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b71:	39 da                	cmp    %ebx,%edx
  801b73:	75 ed                	jne    801b62 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b75:	89 f0                	mov    %esi,%eax
  801b77:	5b                   	pop    %ebx
  801b78:	5e                   	pop    %esi
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	8b 75 08             	mov    0x8(%ebp),%esi
  801b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b86:	8b 55 10             	mov    0x10(%ebp),%edx
  801b89:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b8b:	85 d2                	test   %edx,%edx
  801b8d:	74 21                	je     801bb0 <strlcpy+0x35>
  801b8f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801b93:	89 f2                	mov    %esi,%edx
  801b95:	eb 09                	jmp    801ba0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801b97:	83 c2 01             	add    $0x1,%edx
  801b9a:	83 c1 01             	add    $0x1,%ecx
  801b9d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ba0:	39 c2                	cmp    %eax,%edx
  801ba2:	74 09                	je     801bad <strlcpy+0x32>
  801ba4:	0f b6 19             	movzbl (%ecx),%ebx
  801ba7:	84 db                	test   %bl,%bl
  801ba9:	75 ec                	jne    801b97 <strlcpy+0x1c>
  801bab:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bad:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bb0:	29 f0                	sub    %esi,%eax
}
  801bb2:	5b                   	pop    %ebx
  801bb3:	5e                   	pop    %esi
  801bb4:	5d                   	pop    %ebp
  801bb5:	c3                   	ret    

00801bb6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bbf:	eb 06                	jmp    801bc7 <strcmp+0x11>
		p++, q++;
  801bc1:	83 c1 01             	add    $0x1,%ecx
  801bc4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bc7:	0f b6 01             	movzbl (%ecx),%eax
  801bca:	84 c0                	test   %al,%al
  801bcc:	74 04                	je     801bd2 <strcmp+0x1c>
  801bce:	3a 02                	cmp    (%edx),%al
  801bd0:	74 ef                	je     801bc1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801bd2:	0f b6 c0             	movzbl %al,%eax
  801bd5:	0f b6 12             	movzbl (%edx),%edx
  801bd8:	29 d0                	sub    %edx,%eax
}
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    

00801bdc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	53                   	push   %ebx
  801be0:	8b 45 08             	mov    0x8(%ebp),%eax
  801be3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801be6:	89 c3                	mov    %eax,%ebx
  801be8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801beb:	eb 06                	jmp    801bf3 <strncmp+0x17>
		n--, p++, q++;
  801bed:	83 c0 01             	add    $0x1,%eax
  801bf0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bf3:	39 d8                	cmp    %ebx,%eax
  801bf5:	74 15                	je     801c0c <strncmp+0x30>
  801bf7:	0f b6 08             	movzbl (%eax),%ecx
  801bfa:	84 c9                	test   %cl,%cl
  801bfc:	74 04                	je     801c02 <strncmp+0x26>
  801bfe:	3a 0a                	cmp    (%edx),%cl
  801c00:	74 eb                	je     801bed <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c02:	0f b6 00             	movzbl (%eax),%eax
  801c05:	0f b6 12             	movzbl (%edx),%edx
  801c08:	29 d0                	sub    %edx,%eax
  801c0a:	eb 05                	jmp    801c11 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c0c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c11:	5b                   	pop    %ebx
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c1e:	eb 07                	jmp    801c27 <strchr+0x13>
		if (*s == c)
  801c20:	38 ca                	cmp    %cl,%dl
  801c22:	74 0f                	je     801c33 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c24:	83 c0 01             	add    $0x1,%eax
  801c27:	0f b6 10             	movzbl (%eax),%edx
  801c2a:	84 d2                	test   %dl,%dl
  801c2c:	75 f2                	jne    801c20 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c3f:	eb 03                	jmp    801c44 <strfind+0xf>
  801c41:	83 c0 01             	add    $0x1,%eax
  801c44:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c47:	38 ca                	cmp    %cl,%dl
  801c49:	74 04                	je     801c4f <strfind+0x1a>
  801c4b:	84 d2                	test   %dl,%dl
  801c4d:	75 f2                	jne    801c41 <strfind+0xc>
			break;
	return (char *) s;
}
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	57                   	push   %edi
  801c55:	56                   	push   %esi
  801c56:	53                   	push   %ebx
  801c57:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c5d:	85 c9                	test   %ecx,%ecx
  801c5f:	74 36                	je     801c97 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c61:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c67:	75 28                	jne    801c91 <memset+0x40>
  801c69:	f6 c1 03             	test   $0x3,%cl
  801c6c:	75 23                	jne    801c91 <memset+0x40>
		c &= 0xFF;
  801c6e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c72:	89 d3                	mov    %edx,%ebx
  801c74:	c1 e3 08             	shl    $0x8,%ebx
  801c77:	89 d6                	mov    %edx,%esi
  801c79:	c1 e6 18             	shl    $0x18,%esi
  801c7c:	89 d0                	mov    %edx,%eax
  801c7e:	c1 e0 10             	shl    $0x10,%eax
  801c81:	09 f0                	or     %esi,%eax
  801c83:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801c85:	89 d8                	mov    %ebx,%eax
  801c87:	09 d0                	or     %edx,%eax
  801c89:	c1 e9 02             	shr    $0x2,%ecx
  801c8c:	fc                   	cld    
  801c8d:	f3 ab                	rep stos %eax,%es:(%edi)
  801c8f:	eb 06                	jmp    801c97 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c91:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c94:	fc                   	cld    
  801c95:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c97:	89 f8                	mov    %edi,%eax
  801c99:	5b                   	pop    %ebx
  801c9a:	5e                   	pop    %esi
  801c9b:	5f                   	pop    %edi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ca9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cac:	39 c6                	cmp    %eax,%esi
  801cae:	73 35                	jae    801ce5 <memmove+0x47>
  801cb0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cb3:	39 d0                	cmp    %edx,%eax
  801cb5:	73 2e                	jae    801ce5 <memmove+0x47>
		s += n;
		d += n;
  801cb7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cba:	89 d6                	mov    %edx,%esi
  801cbc:	09 fe                	or     %edi,%esi
  801cbe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cc4:	75 13                	jne    801cd9 <memmove+0x3b>
  801cc6:	f6 c1 03             	test   $0x3,%cl
  801cc9:	75 0e                	jne    801cd9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801ccb:	83 ef 04             	sub    $0x4,%edi
  801cce:	8d 72 fc             	lea    -0x4(%edx),%esi
  801cd1:	c1 e9 02             	shr    $0x2,%ecx
  801cd4:	fd                   	std    
  801cd5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cd7:	eb 09                	jmp    801ce2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801cd9:	83 ef 01             	sub    $0x1,%edi
  801cdc:	8d 72 ff             	lea    -0x1(%edx),%esi
  801cdf:	fd                   	std    
  801ce0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ce2:	fc                   	cld    
  801ce3:	eb 1d                	jmp    801d02 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ce5:	89 f2                	mov    %esi,%edx
  801ce7:	09 c2                	or     %eax,%edx
  801ce9:	f6 c2 03             	test   $0x3,%dl
  801cec:	75 0f                	jne    801cfd <memmove+0x5f>
  801cee:	f6 c1 03             	test   $0x3,%cl
  801cf1:	75 0a                	jne    801cfd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801cf3:	c1 e9 02             	shr    $0x2,%ecx
  801cf6:	89 c7                	mov    %eax,%edi
  801cf8:	fc                   	cld    
  801cf9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cfb:	eb 05                	jmp    801d02 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801cfd:	89 c7                	mov    %eax,%edi
  801cff:	fc                   	cld    
  801d00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d02:	5e                   	pop    %esi
  801d03:	5f                   	pop    %edi
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    

00801d06 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d09:	ff 75 10             	pushl  0x10(%ebp)
  801d0c:	ff 75 0c             	pushl  0xc(%ebp)
  801d0f:	ff 75 08             	pushl  0x8(%ebp)
  801d12:	e8 87 ff ff ff       	call   801c9e <memmove>
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	56                   	push   %esi
  801d1d:	53                   	push   %ebx
  801d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d21:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d24:	89 c6                	mov    %eax,%esi
  801d26:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d29:	eb 1a                	jmp    801d45 <memcmp+0x2c>
		if (*s1 != *s2)
  801d2b:	0f b6 08             	movzbl (%eax),%ecx
  801d2e:	0f b6 1a             	movzbl (%edx),%ebx
  801d31:	38 d9                	cmp    %bl,%cl
  801d33:	74 0a                	je     801d3f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d35:	0f b6 c1             	movzbl %cl,%eax
  801d38:	0f b6 db             	movzbl %bl,%ebx
  801d3b:	29 d8                	sub    %ebx,%eax
  801d3d:	eb 0f                	jmp    801d4e <memcmp+0x35>
		s1++, s2++;
  801d3f:	83 c0 01             	add    $0x1,%eax
  801d42:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d45:	39 f0                	cmp    %esi,%eax
  801d47:	75 e2                	jne    801d2b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d4e:	5b                   	pop    %ebx
  801d4f:	5e                   	pop    %esi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    

00801d52 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	53                   	push   %ebx
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d59:	89 c1                	mov    %eax,%ecx
  801d5b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d5e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d62:	eb 0a                	jmp    801d6e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d64:	0f b6 10             	movzbl (%eax),%edx
  801d67:	39 da                	cmp    %ebx,%edx
  801d69:	74 07                	je     801d72 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d6b:	83 c0 01             	add    $0x1,%eax
  801d6e:	39 c8                	cmp    %ecx,%eax
  801d70:	72 f2                	jb     801d64 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d72:	5b                   	pop    %ebx
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	57                   	push   %edi
  801d79:	56                   	push   %esi
  801d7a:	53                   	push   %ebx
  801d7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d81:	eb 03                	jmp    801d86 <strtol+0x11>
		s++;
  801d83:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d86:	0f b6 01             	movzbl (%ecx),%eax
  801d89:	3c 20                	cmp    $0x20,%al
  801d8b:	74 f6                	je     801d83 <strtol+0xe>
  801d8d:	3c 09                	cmp    $0x9,%al
  801d8f:	74 f2                	je     801d83 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801d91:	3c 2b                	cmp    $0x2b,%al
  801d93:	75 0a                	jne    801d9f <strtol+0x2a>
		s++;
  801d95:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801d98:	bf 00 00 00 00       	mov    $0x0,%edi
  801d9d:	eb 11                	jmp    801db0 <strtol+0x3b>
  801d9f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801da4:	3c 2d                	cmp    $0x2d,%al
  801da6:	75 08                	jne    801db0 <strtol+0x3b>
		s++, neg = 1;
  801da8:	83 c1 01             	add    $0x1,%ecx
  801dab:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801db0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801db6:	75 15                	jne    801dcd <strtol+0x58>
  801db8:	80 39 30             	cmpb   $0x30,(%ecx)
  801dbb:	75 10                	jne    801dcd <strtol+0x58>
  801dbd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dc1:	75 7c                	jne    801e3f <strtol+0xca>
		s += 2, base = 16;
  801dc3:	83 c1 02             	add    $0x2,%ecx
  801dc6:	bb 10 00 00 00       	mov    $0x10,%ebx
  801dcb:	eb 16                	jmp    801de3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801dcd:	85 db                	test   %ebx,%ebx
  801dcf:	75 12                	jne    801de3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801dd1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801dd6:	80 39 30             	cmpb   $0x30,(%ecx)
  801dd9:	75 08                	jne    801de3 <strtol+0x6e>
		s++, base = 8;
  801ddb:	83 c1 01             	add    $0x1,%ecx
  801dde:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801de3:	b8 00 00 00 00       	mov    $0x0,%eax
  801de8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801deb:	0f b6 11             	movzbl (%ecx),%edx
  801dee:	8d 72 d0             	lea    -0x30(%edx),%esi
  801df1:	89 f3                	mov    %esi,%ebx
  801df3:	80 fb 09             	cmp    $0x9,%bl
  801df6:	77 08                	ja     801e00 <strtol+0x8b>
			dig = *s - '0';
  801df8:	0f be d2             	movsbl %dl,%edx
  801dfb:	83 ea 30             	sub    $0x30,%edx
  801dfe:	eb 22                	jmp    801e22 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e00:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e03:	89 f3                	mov    %esi,%ebx
  801e05:	80 fb 19             	cmp    $0x19,%bl
  801e08:	77 08                	ja     801e12 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e0a:	0f be d2             	movsbl %dl,%edx
  801e0d:	83 ea 57             	sub    $0x57,%edx
  801e10:	eb 10                	jmp    801e22 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e12:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e15:	89 f3                	mov    %esi,%ebx
  801e17:	80 fb 19             	cmp    $0x19,%bl
  801e1a:	77 16                	ja     801e32 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e1c:	0f be d2             	movsbl %dl,%edx
  801e1f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e22:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e25:	7d 0b                	jge    801e32 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e27:	83 c1 01             	add    $0x1,%ecx
  801e2a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e2e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e30:	eb b9                	jmp    801deb <strtol+0x76>

	if (endptr)
  801e32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e36:	74 0d                	je     801e45 <strtol+0xd0>
		*endptr = (char *) s;
  801e38:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e3b:	89 0e                	mov    %ecx,(%esi)
  801e3d:	eb 06                	jmp    801e45 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e3f:	85 db                	test   %ebx,%ebx
  801e41:	74 98                	je     801ddb <strtol+0x66>
  801e43:	eb 9e                	jmp    801de3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e45:	89 c2                	mov    %eax,%edx
  801e47:	f7 da                	neg    %edx
  801e49:	85 ff                	test   %edi,%edi
  801e4b:	0f 45 c2             	cmovne %edx,%eax
}
  801e4e:	5b                   	pop    %ebx
  801e4f:	5e                   	pop    %esi
  801e50:	5f                   	pop    %edi
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    

00801e53 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	8b 75 08             	mov    0x8(%ebp),%esi
  801e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e61:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e63:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e68:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e6b:	83 ec 0c             	sub    $0xc,%esp
  801e6e:	50                   	push   %eax
  801e6f:	e8 96 e4 ff ff       	call   80030a <sys_ipc_recv>

	if (from_env_store != NULL)
  801e74:	83 c4 10             	add    $0x10,%esp
  801e77:	85 f6                	test   %esi,%esi
  801e79:	74 14                	je     801e8f <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e80:	85 c0                	test   %eax,%eax
  801e82:	78 09                	js     801e8d <ipc_recv+0x3a>
  801e84:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e8a:	8b 52 74             	mov    0x74(%edx),%edx
  801e8d:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e8f:	85 db                	test   %ebx,%ebx
  801e91:	74 14                	je     801ea7 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801e93:	ba 00 00 00 00       	mov    $0x0,%edx
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	78 09                	js     801ea5 <ipc_recv+0x52>
  801e9c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ea2:	8b 52 78             	mov    0x78(%edx),%edx
  801ea5:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 08                	js     801eb3 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801eab:	a1 08 40 80 00       	mov    0x804008,%eax
  801eb0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb6:	5b                   	pop    %ebx
  801eb7:	5e                   	pop    %esi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	57                   	push   %edi
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	83 ec 0c             	sub    $0xc,%esp
  801ec3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ec9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ecc:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ece:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ed3:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ed6:	ff 75 14             	pushl  0x14(%ebp)
  801ed9:	53                   	push   %ebx
  801eda:	56                   	push   %esi
  801edb:	57                   	push   %edi
  801edc:	e8 06 e4 ff ff       	call   8002e7 <sys_ipc_try_send>

		if (err < 0) {
  801ee1:	83 c4 10             	add    $0x10,%esp
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	79 1e                	jns    801f06 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ee8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eeb:	75 07                	jne    801ef4 <ipc_send+0x3a>
				sys_yield();
  801eed:	e8 49 e2 ff ff       	call   80013b <sys_yield>
  801ef2:	eb e2                	jmp    801ed6 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801ef4:	50                   	push   %eax
  801ef5:	68 a0 26 80 00       	push   $0x8026a0
  801efa:	6a 49                	push   $0x49
  801efc:	68 ad 26 80 00       	push   $0x8026ad
  801f01:	e8 a8 f5 ff ff       	call   8014ae <_panic>
		}

	} while (err < 0);

}
  801f06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f09:	5b                   	pop    %ebx
  801f0a:	5e                   	pop    %esi
  801f0b:	5f                   	pop    %edi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    

00801f0e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f19:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f1c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f22:	8b 52 50             	mov    0x50(%edx),%edx
  801f25:	39 ca                	cmp    %ecx,%edx
  801f27:	75 0d                	jne    801f36 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f29:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f2c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f31:	8b 40 48             	mov    0x48(%eax),%eax
  801f34:	eb 0f                	jmp    801f45 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f36:	83 c0 01             	add    $0x1,%eax
  801f39:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f3e:	75 d9                	jne    801f19 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    

00801f47 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4d:	89 d0                	mov    %edx,%eax
  801f4f:	c1 e8 16             	shr    $0x16,%eax
  801f52:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5e:	f6 c1 01             	test   $0x1,%cl
  801f61:	74 1d                	je     801f80 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f63:	c1 ea 0c             	shr    $0xc,%edx
  801f66:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f6d:	f6 c2 01             	test   $0x1,%dl
  801f70:	74 0e                	je     801f80 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f72:	c1 ea 0c             	shr    $0xc,%edx
  801f75:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f7c:	ef 
  801f7d:	0f b7 c0             	movzwl %ax,%eax
}
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    
  801f82:	66 90                	xchg   %ax,%ax
  801f84:	66 90                	xchg   %ax,%ax
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 ca                	mov    %ecx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	75 3d                	jne    801ff0 <__udivdi3+0x60>
  801fb3:	39 cf                	cmp    %ecx,%edi
  801fb5:	0f 87 c5 00 00 00    	ja     802080 <__udivdi3+0xf0>
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	89 fd                	mov    %edi,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f7                	div    %edi
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 c8                	mov    %ecx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	89 cf                	mov    %ecx,%edi
  801fd8:	f7 f5                	div    %ebp
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 ce                	cmp    %ecx,%esi
  801ff2:	77 74                	ja     802068 <__udivdi3+0xd8>
  801ff4:	0f bd fe             	bsr    %esi,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0x108>
  802000:	bb 20 00 00 00       	mov    $0x20,%ebx
  802005:	89 f9                	mov    %edi,%ecx
  802007:	89 c5                	mov    %eax,%ebp
  802009:	29 fb                	sub    %edi,%ebx
  80200b:	d3 e6                	shl    %cl,%esi
  80200d:	89 d9                	mov    %ebx,%ecx
  80200f:	d3 ed                	shr    %cl,%ebp
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e0                	shl    %cl,%eax
  802015:	09 ee                	or     %ebp,%esi
  802017:	89 d9                	mov    %ebx,%ecx
  802019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201d:	89 d5                	mov    %edx,%ebp
  80201f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802023:	d3 ed                	shr    %cl,%ebp
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 d9                	mov    %ebx,%ecx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	09 c2                	or     %eax,%edx
  80202f:	89 d0                	mov    %edx,%eax
  802031:	89 ea                	mov    %ebp,%edx
  802033:	f7 f6                	div    %esi
  802035:	89 d5                	mov    %edx,%ebp
  802037:	89 c3                	mov    %eax,%ebx
  802039:	f7 64 24 0c          	mull   0xc(%esp)
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	72 10                	jb     802051 <__udivdi3+0xc1>
  802041:	8b 74 24 08          	mov    0x8(%esp),%esi
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e6                	shl    %cl,%esi
  802049:	39 c6                	cmp    %eax,%esi
  80204b:	73 07                	jae    802054 <__udivdi3+0xc4>
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	75 03                	jne    802054 <__udivdi3+0xc4>
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 d8                	mov    %ebx,%eax
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 db                	xor    %ebx,%ebx
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
  802080:	89 d8                	mov    %ebx,%eax
  802082:	f7 f7                	div    %edi
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 c3                	mov    %eax,%ebx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	39 ce                	cmp    %ecx,%esi
  80209a:	72 0c                	jb     8020a8 <__udivdi3+0x118>
  80209c:	31 db                	xor    %ebx,%ebx
  80209e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020a2:	0f 87 34 ff ff ff    	ja     801fdc <__udivdi3+0x4c>
  8020a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ad:	e9 2a ff ff ff       	jmp    801fdc <__udivdi3+0x4c>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f3                	mov    %esi,%ebx
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	75 1c                	jne    802108 <__umoddi3+0x48>
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	76 50                	jbe    802140 <__umoddi3+0x80>
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	f7 f7                	div    %edi
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	31 d2                	xor    %edx,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	77 52                	ja     802160 <__umoddi3+0xa0>
  80210e:	0f bd ea             	bsr    %edx,%ebp
  802111:	83 f5 1f             	xor    $0x1f,%ebp
  802114:	75 5a                	jne    802170 <__umoddi3+0xb0>
  802116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	39 0c 24             	cmp    %ecx,(%esp)
  802123:	0f 86 d7 00 00 00    	jbe    802200 <__umoddi3+0x140>
  802129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80212d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	85 ff                	test   %edi,%edi
  802142:	89 fd                	mov    %edi,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 c8                	mov    %ecx,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	eb 99                	jmp    8020f8 <__umoddi3+0x38>
  80215f:	90                   	nop
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	8b 34 24             	mov    (%esp),%esi
  802173:	bf 20 00 00 00       	mov    $0x20,%edi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	29 ef                	sub    %ebp,%edi
  80217c:	d3 e0                	shl    %cl,%eax
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	89 f2                	mov    %esi,%edx
  802182:	d3 ea                	shr    %cl,%edx
  802184:	89 e9                	mov    %ebp,%ecx
  802186:	09 c2                	or     %eax,%edx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 14 24             	mov    %edx,(%esp)
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 f9                	mov    %edi,%ecx
  802193:	89 54 24 04          	mov    %edx,0x4(%esp)
  802197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	d3 e3                	shl    %cl,%ebx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	09 d8                	or     %ebx,%eax
  8021ad:	89 d3                	mov    %edx,%ebx
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	f7 34 24             	divl   (%esp)
  8021b4:	89 d6                	mov    %edx,%esi
  8021b6:	d3 e3                	shl    %cl,%ebx
  8021b8:	f7 64 24 04          	mull   0x4(%esp)
  8021bc:	39 d6                	cmp    %edx,%esi
  8021be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c2:	89 d1                	mov    %edx,%ecx
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	72 08                	jb     8021d0 <__umoddi3+0x110>
  8021c8:	75 11                	jne    8021db <__umoddi3+0x11b>
  8021ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ce:	73 0b                	jae    8021db <__umoddi3+0x11b>
  8021d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021d4:	1b 14 24             	sbb    (%esp),%edx
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021df:	29 da                	sub    %ebx,%edx
  8021e1:	19 ce                	sbb    %ecx,%esi
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e0                	shl    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d0                	or     %edx,%eax
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 f9                	sub    %edi,%ecx
  802202:	19 d6                	sbb    %edx,%esi
  802204:	89 74 24 04          	mov    %esi,0x4(%esp)
  802208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220c:	e9 18 ff ff ff       	jmp    802129 <__umoddi3+0x69>
