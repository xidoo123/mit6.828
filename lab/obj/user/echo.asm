
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 c0 22 80 00       	push   $0x8022c0
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 c3 01 00 00       	call   800221 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 c3 22 80 00       	push   $0x8022c3
  80008f:	6a 01                	push   $0x1
  800091:	e8 aa 0a 00 00       	call   800b40 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 8e 0a 00 00       	call   800b40 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 d7 23 80 00       	push   $0x8023d7
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 6d 0a 00 00       	call   800b40 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e9:	e8 4e 04 00 00       	call   80053c <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x2d>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 26 08 00 00       	call   800955 <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 c2 03 00 00       	call   8004fb <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800144:	b8 00 00 00 00       	mov    $0x0,%eax
  800149:	eb 03                	jmp    80014e <strlen+0x10>
		n++;
  80014b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80014e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800152:	75 f7                	jne    80014b <strlen+0xd>
		n++;
	return n;
}
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	eb 03                	jmp    800169 <strnlen+0x13>
		n++;
  800166:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800169:	39 c2                	cmp    %eax,%edx
  80016b:	74 08                	je     800175 <strnlen+0x1f>
  80016d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800171:	75 f3                	jne    800166 <strnlen+0x10>
  800173:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800181:	89 c2                	mov    %eax,%edx
  800183:	83 c2 01             	add    $0x1,%edx
  800186:	83 c1 01             	add    $0x1,%ecx
  800189:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80018d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800190:	84 db                	test   %bl,%bl
  800192:	75 ef                	jne    800183 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800194:	5b                   	pop    %ebx
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80019e:	53                   	push   %ebx
  80019f:	e8 9a ff ff ff       	call   80013e <strlen>
  8001a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	01 d8                	add    %ebx,%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 c5 ff ff ff       	call   800177 <strcpy>
	return dst;
}
  8001b2:	89 d8                	mov    %ebx,%eax
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	89 f3                	mov    %esi,%ebx
  8001c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	eb 0f                	jmp    8001dc <strncpy+0x23>
		*dst++ = *src;
  8001cd:	83 c2 01             	add    $0x1,%edx
  8001d0:	0f b6 01             	movzbl (%ecx),%eax
  8001d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8001d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001dc:	39 da                	cmp    %ebx,%edx
  8001de:	75 ed                	jne    8001cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001e0:	89 f0                	mov    %esi,%eax
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8001f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001f6:	85 d2                	test   %edx,%edx
  8001f8:	74 21                	je     80021b <strlcpy+0x35>
  8001fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	eb 09                	jmp    80020b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800202:	83 c2 01             	add    $0x1,%edx
  800205:	83 c1 01             	add    $0x1,%ecx
  800208:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80020b:	39 c2                	cmp    %eax,%edx
  80020d:	74 09                	je     800218 <strlcpy+0x32>
  80020f:	0f b6 19             	movzbl (%ecx),%ebx
  800212:	84 db                	test   %bl,%bl
  800214:	75 ec                	jne    800202 <strlcpy+0x1c>
  800216:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 15                	je     800277 <strncmp+0x30>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
  800275:	eb 05                	jmp    80027c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800277:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80027c:	5b                   	pop    %ebx
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	eb 07                	jmp    800292 <strchr+0x13>
		if (*s == c)
  80028b:	38 ca                	cmp    %cl,%dl
  80028d:	74 0f                	je     80029e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80028f:	83 c0 01             	add    $0x1,%eax
  800292:	0f b6 10             	movzbl (%eax),%edx
  800295:	84 d2                	test   %dl,%dl
  800297:	75 f2                	jne    80028b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	38 ca                	cmp    %cl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	84 d2                	test   %dl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 36                	je     800302 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 28                	jne    8002fc <memset+0x40>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	75 23                	jne    8002fc <memset+0x40>
		c &= 0xFF;
  8002d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002dd:	89 d3                	mov    %edx,%ebx
  8002df:	c1 e3 08             	shl    $0x8,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	c1 e6 18             	shl    $0x18,%esi
  8002e7:	89 d0                	mov    %edx,%eax
  8002e9:	c1 e0 10             	shl    $0x10,%eax
  8002ec:	09 f0                	or     %esi,%eax
  8002ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8002f0:	89 d8                	mov    %ebx,%eax
  8002f2:	09 d0                	or     %edx,%eax
  8002f4:	c1 e9 02             	shr    $0x2,%ecx
  8002f7:	fc                   	cld    
  8002f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8002fa:	eb 06                	jmp    800302 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	fc                   	cld    
  800300:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800302:	89 f8                	mov    %edi,%eax
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 d0                	cmp    %edx,%eax
  800320:	73 2e                	jae    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	75 13                	jne    800344 <memmove+0x3b>
  800331:	f6 c1 03             	test   $0x3,%cl
  800334:	75 0e                	jne    800344 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800336:	83 ef 04             	sub    $0x4,%edi
  800339:	8d 72 fc             	lea    -0x4(%edx),%esi
  80033c:	c1 e9 02             	shr    $0x2,%ecx
  80033f:	fd                   	std    
  800340:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800342:	eb 09                	jmp    80034d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800344:	83 ef 01             	sub    $0x1,%edi
  800347:	8d 72 ff             	lea    -0x1(%edx),%esi
  80034a:	fd                   	std    
  80034b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80034d:	fc                   	cld    
  80034e:	eb 1d                	jmp    80036d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	75 0f                	jne    800368 <memmove+0x5f>
  800359:	f6 c1 03             	test   $0x3,%cl
  80035c:	75 0a                	jne    800368 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80035e:	c1 e9 02             	shr    $0x2,%ecx
  800361:	89 c7                	mov    %eax,%edi
  800363:	fc                   	cld    
  800364:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800366:	eb 05                	jmp    80036d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800368:	89 c7                	mov    %eax,%edi
  80036a:	fc                   	cld    
  80036b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	eb 1a                	jmp    8003b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800396:	0f b6 08             	movzbl (%eax),%ecx
  800399:	0f b6 1a             	movzbl (%edx),%ebx
  80039c:	38 d9                	cmp    %bl,%cl
  80039e:	74 0a                	je     8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003a0:	0f b6 c1             	movzbl %cl,%eax
  8003a3:	0f b6 db             	movzbl %bl,%ebx
  8003a6:	29 d8                	sub    %ebx,%eax
  8003a8:	eb 0f                	jmp    8003b9 <memcmp+0x35>
		s1++, s2++;
  8003aa:	83 c0 01             	add    $0x1,%eax
  8003ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b0:	39 f0                	cmp    %esi,%eax
  8003b2:	75 e2                	jne    800396 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	53                   	push   %ebx
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003c4:	89 c1                	mov    %eax,%ecx
  8003c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003cd:	eb 0a                	jmp    8003d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cf:	0f b6 10             	movzbl (%eax),%edx
  8003d2:	39 da                	cmp    %ebx,%edx
  8003d4:	74 07                	je     8003dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d6:	83 c0 01             	add    $0x1,%eax
  8003d9:	39 c8                	cmp    %ecx,%eax
  8003db:	72 f2                	jb     8003cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003dd:	5b                   	pop    %ebx
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ec:	eb 03                	jmp    8003f1 <strtol+0x11>
		s++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003f1:	0f b6 01             	movzbl (%ecx),%eax
  8003f4:	3c 20                	cmp    $0x20,%al
  8003f6:	74 f6                	je     8003ee <strtol+0xe>
  8003f8:	3c 09                	cmp    $0x9,%al
  8003fa:	74 f2                	je     8003ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003fc:	3c 2b                	cmp    $0x2b,%al
  8003fe:	75 0a                	jne    80040a <strtol+0x2a>
		s++;
  800400:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800403:	bf 00 00 00 00       	mov    $0x0,%edi
  800408:	eb 11                	jmp    80041b <strtol+0x3b>
  80040a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80040f:	3c 2d                	cmp    $0x2d,%al
  800411:	75 08                	jne    80041b <strtol+0x3b>
		s++, neg = 1;
  800413:	83 c1 01             	add    $0x1,%ecx
  800416:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80041b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800421:	75 15                	jne    800438 <strtol+0x58>
  800423:	80 39 30             	cmpb   $0x30,(%ecx)
  800426:	75 10                	jne    800438 <strtol+0x58>
  800428:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80042c:	75 7c                	jne    8004aa <strtol+0xca>
		s += 2, base = 16;
  80042e:	83 c1 02             	add    $0x2,%ecx
  800431:	bb 10 00 00 00       	mov    $0x10,%ebx
  800436:	eb 16                	jmp    80044e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800438:	85 db                	test   %ebx,%ebx
  80043a:	75 12                	jne    80044e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80043c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800441:	80 39 30             	cmpb   $0x30,(%ecx)
  800444:	75 08                	jne    80044e <strtol+0x6e>
		s++, base = 8;
  800446:	83 c1 01             	add    $0x1,%ecx
  800449:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800456:	0f b6 11             	movzbl (%ecx),%edx
  800459:	8d 72 d0             	lea    -0x30(%edx),%esi
  80045c:	89 f3                	mov    %esi,%ebx
  80045e:	80 fb 09             	cmp    $0x9,%bl
  800461:	77 08                	ja     80046b <strtol+0x8b>
			dig = *s - '0';
  800463:	0f be d2             	movsbl %dl,%edx
  800466:	83 ea 30             	sub    $0x30,%edx
  800469:	eb 22                	jmp    80048d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80046b:	8d 72 9f             	lea    -0x61(%edx),%esi
  80046e:	89 f3                	mov    %esi,%ebx
  800470:	80 fb 19             	cmp    $0x19,%bl
  800473:	77 08                	ja     80047d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800475:	0f be d2             	movsbl %dl,%edx
  800478:	83 ea 57             	sub    $0x57,%edx
  80047b:	eb 10                	jmp    80048d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80047d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800480:	89 f3                	mov    %esi,%ebx
  800482:	80 fb 19             	cmp    $0x19,%bl
  800485:	77 16                	ja     80049d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800487:	0f be d2             	movsbl %dl,%edx
  80048a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80048d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800490:	7d 0b                	jge    80049d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800492:	83 c1 01             	add    $0x1,%ecx
  800495:	0f af 45 10          	imul   0x10(%ebp),%eax
  800499:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80049b:	eb b9                	jmp    800456 <strtol+0x76>

	if (endptr)
  80049d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a1:	74 0d                	je     8004b0 <strtol+0xd0>
		*endptr = (char *) s;
  8004a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a6:	89 0e                	mov    %ecx,(%esi)
  8004a8:	eb 06                	jmp    8004b0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	74 98                	je     800446 <strtol+0x66>
  8004ae:	eb 9e                	jmp    80044e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004b0:	89 c2                	mov    %eax,%edx
  8004b2:	f7 da                	neg    %edx
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	0f 45 c2             	cmovne %edx,%eax
}
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	57                   	push   %edi
  8004c2:	56                   	push   %esi
  8004c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	89 c7                	mov    %eax,%edi
  8004d3:	89 c6                	mov    %eax,%esi
  8004d5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d7:	5b                   	pop    %ebx
  8004d8:	5e                   	pop    %esi
  8004d9:	5f                   	pop    %edi
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ec:	89 d1                	mov    %edx,%ecx
  8004ee:	89 d3                	mov    %edx,%ebx
  8004f0:	89 d7                	mov    %edx,%edi
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f6:	5b                   	pop    %ebx
  8004f7:	5e                   	pop    %esi
  8004f8:	5f                   	pop    %edi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
  800501:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800504:	b9 00 00 00 00       	mov    $0x0,%ecx
  800509:	b8 03 00 00 00       	mov    $0x3,%eax
  80050e:	8b 55 08             	mov    0x8(%ebp),%edx
  800511:	89 cb                	mov    %ecx,%ebx
  800513:	89 cf                	mov    %ecx,%edi
  800515:	89 ce                	mov    %ecx,%esi
  800517:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800519:	85 c0                	test   %eax,%eax
  80051b:	7e 17                	jle    800534 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	50                   	push   %eax
  800521:	6a 03                	push   $0x3
  800523:	68 cf 22 80 00       	push   $0x8022cf
  800528:	6a 23                	push   $0x23
  80052a:	68 ec 22 80 00       	push   $0x8022ec
  80052f:	e8 9a 13 00 00       	call   8018ce <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800534:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800537:	5b                   	pop    %ebx
  800538:	5e                   	pop    %esi
  800539:	5f                   	pop    %edi
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800542:	ba 00 00 00 00       	mov    $0x0,%edx
  800547:	b8 02 00 00 00       	mov    $0x2,%eax
  80054c:	89 d1                	mov    %edx,%ecx
  80054e:	89 d3                	mov    %edx,%ebx
  800550:	89 d7                	mov    %edx,%edi
  800552:	89 d6                	mov    %edx,%esi
  800554:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800556:	5b                   	pop    %ebx
  800557:	5e                   	pop    %esi
  800558:	5f                   	pop    %edi
  800559:	5d                   	pop    %ebp
  80055a:	c3                   	ret    

0080055b <sys_yield>:

void
sys_yield(void)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	57                   	push   %edi
  80055f:	56                   	push   %esi
  800560:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800561:	ba 00 00 00 00       	mov    $0x0,%edx
  800566:	b8 0b 00 00 00       	mov    $0xb,%eax
  80056b:	89 d1                	mov    %edx,%ecx
  80056d:	89 d3                	mov    %edx,%ebx
  80056f:	89 d7                	mov    %edx,%edi
  800571:	89 d6                	mov    %edx,%esi
  800573:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800575:	5b                   	pop    %ebx
  800576:	5e                   	pop    %esi
  800577:	5f                   	pop    %edi
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	57                   	push   %edi
  80057e:	56                   	push   %esi
  80057f:	53                   	push   %ebx
  800580:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800583:	be 00 00 00 00       	mov    $0x0,%esi
  800588:	b8 04 00 00 00       	mov    $0x4,%eax
  80058d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800590:	8b 55 08             	mov    0x8(%ebp),%edx
  800593:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800596:	89 f7                	mov    %esi,%edi
  800598:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80059a:	85 c0                	test   %eax,%eax
  80059c:	7e 17                	jle    8005b5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80059e:	83 ec 0c             	sub    $0xc,%esp
  8005a1:	50                   	push   %eax
  8005a2:	6a 04                	push   $0x4
  8005a4:	68 cf 22 80 00       	push   $0x8022cf
  8005a9:	6a 23                	push   $0x23
  8005ab:	68 ec 22 80 00       	push   $0x8022ec
  8005b0:	e8 19 13 00 00       	call   8018ce <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b8:	5b                   	pop    %ebx
  8005b9:	5e                   	pop    %esi
  8005ba:	5f                   	pop    %edi
  8005bb:	5d                   	pop    %ebp
  8005bc:	c3                   	ret    

008005bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	57                   	push   %edi
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8005cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8005da:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	7e 17                	jle    8005f7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	50                   	push   %eax
  8005e4:	6a 05                	push   $0x5
  8005e6:	68 cf 22 80 00       	push   $0x8022cf
  8005eb:	6a 23                	push   $0x23
  8005ed:	68 ec 22 80 00       	push   $0x8022ec
  8005f2:	e8 d7 12 00 00       	call   8018ce <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	57                   	push   %edi
  800603:	56                   	push   %esi
  800604:	53                   	push   %ebx
  800605:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800608:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060d:	b8 06 00 00 00       	mov    $0x6,%eax
  800612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800615:	8b 55 08             	mov    0x8(%ebp),%edx
  800618:	89 df                	mov    %ebx,%edi
  80061a:	89 de                	mov    %ebx,%esi
  80061c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80061e:	85 c0                	test   %eax,%eax
  800620:	7e 17                	jle    800639 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	50                   	push   %eax
  800626:	6a 06                	push   $0x6
  800628:	68 cf 22 80 00       	push   $0x8022cf
  80062d:	6a 23                	push   $0x23
  80062f:	68 ec 22 80 00       	push   $0x8022ec
  800634:	e8 95 12 00 00       	call   8018ce <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	57                   	push   %edi
  800645:	56                   	push   %esi
  800646:	53                   	push   %ebx
  800647:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80064a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800657:	8b 55 08             	mov    0x8(%ebp),%edx
  80065a:	89 df                	mov    %ebx,%edi
  80065c:	89 de                	mov    %ebx,%esi
  80065e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800660:	85 c0                	test   %eax,%eax
  800662:	7e 17                	jle    80067b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	50                   	push   %eax
  800668:	6a 08                	push   $0x8
  80066a:	68 cf 22 80 00       	push   $0x8022cf
  80066f:	6a 23                	push   $0x23
  800671:	68 ec 22 80 00       	push   $0x8022ec
  800676:	e8 53 12 00 00       	call   8018ce <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80067b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5e                   	pop    %esi
  800680:	5f                   	pop    %edi
  800681:	5d                   	pop    %ebp
  800682:	c3                   	ret    

00800683 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	57                   	push   %edi
  800687:	56                   	push   %esi
  800688:	53                   	push   %ebx
  800689:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80068c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800691:	b8 09 00 00 00       	mov    $0x9,%eax
  800696:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800699:	8b 55 08             	mov    0x8(%ebp),%edx
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	89 de                	mov    %ebx,%esi
  8006a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	7e 17                	jle    8006bd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a6:	83 ec 0c             	sub    $0xc,%esp
  8006a9:	50                   	push   %eax
  8006aa:	6a 09                	push   $0x9
  8006ac:	68 cf 22 80 00       	push   $0x8022cf
  8006b1:	6a 23                	push   $0x23
  8006b3:	68 ec 22 80 00       	push   $0x8022ec
  8006b8:	e8 11 12 00 00       	call   8018ce <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c0:	5b                   	pop    %ebx
  8006c1:	5e                   	pop    %esi
  8006c2:	5f                   	pop    %edi
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	57                   	push   %edi
  8006c9:	56                   	push   %esi
  8006ca:	53                   	push   %ebx
  8006cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
  8006de:	89 df                	mov    %ebx,%edi
  8006e0:	89 de                	mov    %ebx,%esi
  8006e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	7e 17                	jle    8006ff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	50                   	push   %eax
  8006ec:	6a 0a                	push   $0xa
  8006ee:	68 cf 22 80 00       	push   $0x8022cf
  8006f3:	6a 23                	push   $0x23
  8006f5:	68 ec 22 80 00       	push   $0x8022ec
  8006fa:	e8 cf 11 00 00       	call   8018ce <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80070d:	be 00 00 00 00       	mov    $0x0,%esi
  800712:	b8 0c 00 00 00       	mov    $0xc,%eax
  800717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071a:	8b 55 08             	mov    0x8(%ebp),%edx
  80071d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800720:	8b 7d 14             	mov    0x14(%ebp),%edi
  800723:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	57                   	push   %edi
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
  800730:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	b8 0d 00 00 00       	mov    $0xd,%eax
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
  800740:	89 cb                	mov    %ecx,%ebx
  800742:	89 cf                	mov    %ecx,%edi
  800744:	89 ce                	mov    %ecx,%esi
  800746:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800748:	85 c0                	test   %eax,%eax
  80074a:	7e 17                	jle    800763 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80074c:	83 ec 0c             	sub    $0xc,%esp
  80074f:	50                   	push   %eax
  800750:	6a 0d                	push   $0xd
  800752:	68 cf 22 80 00       	push   $0x8022cf
  800757:	6a 23                	push   $0x23
  800759:	68 ec 22 80 00       	push   $0x8022ec
  80075e:	e8 6b 11 00 00       	call   8018ce <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	57                   	push   %edi
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800771:	ba 00 00 00 00       	mov    $0x0,%edx
  800776:	b8 0e 00 00 00       	mov    $0xe,%eax
  80077b:	89 d1                	mov    %edx,%ecx
  80077d:	89 d3                	mov    %edx,%ebx
  80077f:	89 d7                	mov    %edx,%edi
  800781:	89 d6                	mov    %edx,%esi
  800783:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800785:	5b                   	pop    %ebx
  800786:	5e                   	pop    %esi
  800787:	5f                   	pop    %edi
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	05 00 00 00 30       	add    $0x30000000,%eax
  800795:	c1 e8 0c             	shr    $0xc,%eax
}
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80079d:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a0:	05 00 00 00 30       	add    $0x30000000,%eax
  8007a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8007aa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007bc:	89 c2                	mov    %eax,%edx
  8007be:	c1 ea 16             	shr    $0x16,%edx
  8007c1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007c8:	f6 c2 01             	test   $0x1,%dl
  8007cb:	74 11                	je     8007de <fd_alloc+0x2d>
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	c1 ea 0c             	shr    $0xc,%edx
  8007d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007d9:	f6 c2 01             	test   $0x1,%dl
  8007dc:	75 09                	jne    8007e7 <fd_alloc+0x36>
			*fd_store = fd;
  8007de:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e5:	eb 17                	jmp    8007fe <fd_alloc+0x4d>
  8007e7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8007ec:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007f1:	75 c9                	jne    8007bc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007f3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8007f9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800806:	83 f8 1f             	cmp    $0x1f,%eax
  800809:	77 36                	ja     800841 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80080b:	c1 e0 0c             	shl    $0xc,%eax
  80080e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800813:	89 c2                	mov    %eax,%edx
  800815:	c1 ea 16             	shr    $0x16,%edx
  800818:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80081f:	f6 c2 01             	test   $0x1,%dl
  800822:	74 24                	je     800848 <fd_lookup+0x48>
  800824:	89 c2                	mov    %eax,%edx
  800826:	c1 ea 0c             	shr    $0xc,%edx
  800829:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800830:	f6 c2 01             	test   $0x1,%dl
  800833:	74 1a                	je     80084f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
  800838:	89 02                	mov    %eax,(%edx)
	return 0;
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
  80083f:	eb 13                	jmp    800854 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800841:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800846:	eb 0c                	jmp    800854 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800848:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084d:	eb 05                	jmp    800854 <fd_lookup+0x54>
  80084f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085f:	ba 78 23 80 00       	mov    $0x802378,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800864:	eb 13                	jmp    800879 <dev_lookup+0x23>
  800866:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800869:	39 08                	cmp    %ecx,(%eax)
  80086b:	75 0c                	jne    800879 <dev_lookup+0x23>
			*dev = devtab[i];
  80086d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800870:	89 01                	mov    %eax,(%ecx)
			return 0;
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
  800877:	eb 2e                	jmp    8008a7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800879:	8b 02                	mov    (%edx),%eax
  80087b:	85 c0                	test   %eax,%eax
  80087d:	75 e7                	jne    800866 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80087f:	a1 08 40 80 00       	mov    0x804008,%eax
  800884:	8b 40 48             	mov    0x48(%eax),%eax
  800887:	83 ec 04             	sub    $0x4,%esp
  80088a:	51                   	push   %ecx
  80088b:	50                   	push   %eax
  80088c:	68 fc 22 80 00       	push   $0x8022fc
  800891:	e8 11 11 00 00       	call   8019a7 <cprintf>
	*dev = 0;
  800896:	8b 45 0c             	mov    0xc(%ebp),%eax
  800899:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	56                   	push   %esi
  8008ad:	53                   	push   %ebx
  8008ae:	83 ec 10             	sub    $0x10,%esp
  8008b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ba:	50                   	push   %eax
  8008bb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008c1:	c1 e8 0c             	shr    $0xc,%eax
  8008c4:	50                   	push   %eax
  8008c5:	e8 36 ff ff ff       	call   800800 <fd_lookup>
  8008ca:	83 c4 08             	add    $0x8,%esp
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	78 05                	js     8008d6 <fd_close+0x2d>
	    || fd != fd2)
  8008d1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008d4:	74 0c                	je     8008e2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8008d6:	84 db                	test   %bl,%bl
  8008d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008dd:	0f 44 c2             	cmove  %edx,%eax
  8008e0:	eb 41                	jmp    800923 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008e2:	83 ec 08             	sub    $0x8,%esp
  8008e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008e8:	50                   	push   %eax
  8008e9:	ff 36                	pushl  (%esi)
  8008eb:	e8 66 ff ff ff       	call   800856 <dev_lookup>
  8008f0:	89 c3                	mov    %eax,%ebx
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	85 c0                	test   %eax,%eax
  8008f7:	78 1a                	js     800913 <fd_close+0x6a>
		if (dev->dev_close)
  8008f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008fc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8008ff:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800904:	85 c0                	test   %eax,%eax
  800906:	74 0b                	je     800913 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	56                   	push   %esi
  80090c:	ff d0                	call   *%eax
  80090e:	89 c3                	mov    %eax,%ebx
  800910:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	56                   	push   %esi
  800917:	6a 00                	push   $0x0
  800919:	e8 e1 fc ff ff       	call   8005ff <sys_page_unmap>
	return r;
  80091e:	83 c4 10             	add    $0x10,%esp
  800921:	89 d8                	mov    %ebx,%eax
}
  800923:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800930:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800933:	50                   	push   %eax
  800934:	ff 75 08             	pushl  0x8(%ebp)
  800937:	e8 c4 fe ff ff       	call   800800 <fd_lookup>
  80093c:	83 c4 08             	add    $0x8,%esp
  80093f:	85 c0                	test   %eax,%eax
  800941:	78 10                	js     800953 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800943:	83 ec 08             	sub    $0x8,%esp
  800946:	6a 01                	push   $0x1
  800948:	ff 75 f4             	pushl  -0xc(%ebp)
  80094b:	e8 59 ff ff ff       	call   8008a9 <fd_close>
  800950:	83 c4 10             	add    $0x10,%esp
}
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <close_all>:

void
close_all(void)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	53                   	push   %ebx
  800959:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80095c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800961:	83 ec 0c             	sub    $0xc,%esp
  800964:	53                   	push   %ebx
  800965:	e8 c0 ff ff ff       	call   80092a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80096a:	83 c3 01             	add    $0x1,%ebx
  80096d:	83 c4 10             	add    $0x10,%esp
  800970:	83 fb 20             	cmp    $0x20,%ebx
  800973:	75 ec                	jne    800961 <close_all+0xc>
		close(i);
}
  800975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	83 ec 2c             	sub    $0x2c,%esp
  800983:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800986:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800989:	50                   	push   %eax
  80098a:	ff 75 08             	pushl  0x8(%ebp)
  80098d:	e8 6e fe ff ff       	call   800800 <fd_lookup>
  800992:	83 c4 08             	add    $0x8,%esp
  800995:	85 c0                	test   %eax,%eax
  800997:	0f 88 c1 00 00 00    	js     800a5e <dup+0xe4>
		return r;
	close(newfdnum);
  80099d:	83 ec 0c             	sub    $0xc,%esp
  8009a0:	56                   	push   %esi
  8009a1:	e8 84 ff ff ff       	call   80092a <close>

	newfd = INDEX2FD(newfdnum);
  8009a6:	89 f3                	mov    %esi,%ebx
  8009a8:	c1 e3 0c             	shl    $0xc,%ebx
  8009ab:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8009b1:	83 c4 04             	add    $0x4,%esp
  8009b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009b7:	e8 de fd ff ff       	call   80079a <fd2data>
  8009bc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8009be:	89 1c 24             	mov    %ebx,(%esp)
  8009c1:	e8 d4 fd ff ff       	call   80079a <fd2data>
  8009c6:	83 c4 10             	add    $0x10,%esp
  8009c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009cc:	89 f8                	mov    %edi,%eax
  8009ce:	c1 e8 16             	shr    $0x16,%eax
  8009d1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009d8:	a8 01                	test   $0x1,%al
  8009da:	74 37                	je     800a13 <dup+0x99>
  8009dc:	89 f8                	mov    %edi,%eax
  8009de:	c1 e8 0c             	shr    $0xc,%eax
  8009e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009e8:	f6 c2 01             	test   $0x1,%dl
  8009eb:	74 26                	je     800a13 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009f4:	83 ec 0c             	sub    $0xc,%esp
  8009f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8009fc:	50                   	push   %eax
  8009fd:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a00:	6a 00                	push   $0x0
  800a02:	57                   	push   %edi
  800a03:	6a 00                	push   $0x0
  800a05:	e8 b3 fb ff ff       	call   8005bd <sys_page_map>
  800a0a:	89 c7                	mov    %eax,%edi
  800a0c:	83 c4 20             	add    $0x20,%esp
  800a0f:	85 c0                	test   %eax,%eax
  800a11:	78 2e                	js     800a41 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a13:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a16:	89 d0                	mov    %edx,%eax
  800a18:	c1 e8 0c             	shr    $0xc,%eax
  800a1b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a22:	83 ec 0c             	sub    $0xc,%esp
  800a25:	25 07 0e 00 00       	and    $0xe07,%eax
  800a2a:	50                   	push   %eax
  800a2b:	53                   	push   %ebx
  800a2c:	6a 00                	push   $0x0
  800a2e:	52                   	push   %edx
  800a2f:	6a 00                	push   $0x0
  800a31:	e8 87 fb ff ff       	call   8005bd <sys_page_map>
  800a36:	89 c7                	mov    %eax,%edi
  800a38:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a3b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a3d:	85 ff                	test   %edi,%edi
  800a3f:	79 1d                	jns    800a5e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a41:	83 ec 08             	sub    $0x8,%esp
  800a44:	53                   	push   %ebx
  800a45:	6a 00                	push   $0x0
  800a47:	e8 b3 fb ff ff       	call   8005ff <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a4c:	83 c4 08             	add    $0x8,%esp
  800a4f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a52:	6a 00                	push   $0x0
  800a54:	e8 a6 fb ff ff       	call   8005ff <sys_page_unmap>
	return r;
  800a59:	83 c4 10             	add    $0x10,%esp
  800a5c:	89 f8                	mov    %edi,%eax
}
  800a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	53                   	push   %ebx
  800a6a:	83 ec 14             	sub    $0x14,%esp
  800a6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a70:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a73:	50                   	push   %eax
  800a74:	53                   	push   %ebx
  800a75:	e8 86 fd ff ff       	call   800800 <fd_lookup>
  800a7a:	83 c4 08             	add    $0x8,%esp
  800a7d:	89 c2                	mov    %eax,%edx
  800a7f:	85 c0                	test   %eax,%eax
  800a81:	78 6d                	js     800af0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a83:	83 ec 08             	sub    $0x8,%esp
  800a86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a89:	50                   	push   %eax
  800a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8d:	ff 30                	pushl  (%eax)
  800a8f:	e8 c2 fd ff ff       	call   800856 <dev_lookup>
  800a94:	83 c4 10             	add    $0x10,%esp
  800a97:	85 c0                	test   %eax,%eax
  800a99:	78 4c                	js     800ae7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a9e:	8b 42 08             	mov    0x8(%edx),%eax
  800aa1:	83 e0 03             	and    $0x3,%eax
  800aa4:	83 f8 01             	cmp    $0x1,%eax
  800aa7:	75 21                	jne    800aca <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800aa9:	a1 08 40 80 00       	mov    0x804008,%eax
  800aae:	8b 40 48             	mov    0x48(%eax),%eax
  800ab1:	83 ec 04             	sub    $0x4,%esp
  800ab4:	53                   	push   %ebx
  800ab5:	50                   	push   %eax
  800ab6:	68 3d 23 80 00       	push   $0x80233d
  800abb:	e8 e7 0e 00 00       	call   8019a7 <cprintf>
		return -E_INVAL;
  800ac0:	83 c4 10             	add    $0x10,%esp
  800ac3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ac8:	eb 26                	jmp    800af0 <read+0x8a>
	}
	if (!dev->dev_read)
  800aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800acd:	8b 40 08             	mov    0x8(%eax),%eax
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	74 17                	je     800aeb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800ad4:	83 ec 04             	sub    $0x4,%esp
  800ad7:	ff 75 10             	pushl  0x10(%ebp)
  800ada:	ff 75 0c             	pushl  0xc(%ebp)
  800add:	52                   	push   %edx
  800ade:	ff d0                	call   *%eax
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	83 c4 10             	add    $0x10,%esp
  800ae5:	eb 09                	jmp    800af0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ae7:	89 c2                	mov    %eax,%edx
  800ae9:	eb 05                	jmp    800af0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800aeb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800af0:	89 d0                	mov    %edx,%eax
  800af2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b03:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b0b:	eb 21                	jmp    800b2e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b0d:	83 ec 04             	sub    $0x4,%esp
  800b10:	89 f0                	mov    %esi,%eax
  800b12:	29 d8                	sub    %ebx,%eax
  800b14:	50                   	push   %eax
  800b15:	89 d8                	mov    %ebx,%eax
  800b17:	03 45 0c             	add    0xc(%ebp),%eax
  800b1a:	50                   	push   %eax
  800b1b:	57                   	push   %edi
  800b1c:	e8 45 ff ff ff       	call   800a66 <read>
		if (m < 0)
  800b21:	83 c4 10             	add    $0x10,%esp
  800b24:	85 c0                	test   %eax,%eax
  800b26:	78 10                	js     800b38 <readn+0x41>
			return m;
		if (m == 0)
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	74 0a                	je     800b36 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b2c:	01 c3                	add    %eax,%ebx
  800b2e:	39 f3                	cmp    %esi,%ebx
  800b30:	72 db                	jb     800b0d <readn+0x16>
  800b32:	89 d8                	mov    %ebx,%eax
  800b34:	eb 02                	jmp    800b38 <readn+0x41>
  800b36:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	53                   	push   %ebx
  800b44:	83 ec 14             	sub    $0x14,%esp
  800b47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b4d:	50                   	push   %eax
  800b4e:	53                   	push   %ebx
  800b4f:	e8 ac fc ff ff       	call   800800 <fd_lookup>
  800b54:	83 c4 08             	add    $0x8,%esp
  800b57:	89 c2                	mov    %eax,%edx
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	78 68                	js     800bc5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b5d:	83 ec 08             	sub    $0x8,%esp
  800b60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b63:	50                   	push   %eax
  800b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b67:	ff 30                	pushl  (%eax)
  800b69:	e8 e8 fc ff ff       	call   800856 <dev_lookup>
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	85 c0                	test   %eax,%eax
  800b73:	78 47                	js     800bbc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b78:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b7c:	75 21                	jne    800b9f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b7e:	a1 08 40 80 00       	mov    0x804008,%eax
  800b83:	8b 40 48             	mov    0x48(%eax),%eax
  800b86:	83 ec 04             	sub    $0x4,%esp
  800b89:	53                   	push   %ebx
  800b8a:	50                   	push   %eax
  800b8b:	68 59 23 80 00       	push   $0x802359
  800b90:	e8 12 0e 00 00       	call   8019a7 <cprintf>
		return -E_INVAL;
  800b95:	83 c4 10             	add    $0x10,%esp
  800b98:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b9d:	eb 26                	jmp    800bc5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ba2:	8b 52 0c             	mov    0xc(%edx),%edx
  800ba5:	85 d2                	test   %edx,%edx
  800ba7:	74 17                	je     800bc0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ba9:	83 ec 04             	sub    $0x4,%esp
  800bac:	ff 75 10             	pushl  0x10(%ebp)
  800baf:	ff 75 0c             	pushl  0xc(%ebp)
  800bb2:	50                   	push   %eax
  800bb3:	ff d2                	call   *%edx
  800bb5:	89 c2                	mov    %eax,%edx
  800bb7:	83 c4 10             	add    $0x10,%esp
  800bba:	eb 09                	jmp    800bc5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bbc:	89 c2                	mov    %eax,%edx
  800bbe:	eb 05                	jmp    800bc5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800bc0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800bc5:	89 d0                	mov    %edx,%eax
  800bc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bca:	c9                   	leave  
  800bcb:	c3                   	ret    

00800bcc <seek>:

int
seek(int fdnum, off_t offset)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bd2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800bd5:	50                   	push   %eax
  800bd6:	ff 75 08             	pushl  0x8(%ebp)
  800bd9:	e8 22 fc ff ff       	call   800800 <fd_lookup>
  800bde:	83 c4 08             	add    $0x8,%esp
  800be1:	85 c0                	test   %eax,%eax
  800be3:	78 0e                	js     800bf3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800be5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800be8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800beb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 14             	sub    $0x14,%esp
  800bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c02:	50                   	push   %eax
  800c03:	53                   	push   %ebx
  800c04:	e8 f7 fb ff ff       	call   800800 <fd_lookup>
  800c09:	83 c4 08             	add    $0x8,%esp
  800c0c:	89 c2                	mov    %eax,%edx
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	78 65                	js     800c77 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c12:	83 ec 08             	sub    $0x8,%esp
  800c15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c18:	50                   	push   %eax
  800c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1c:	ff 30                	pushl  (%eax)
  800c1e:	e8 33 fc ff ff       	call   800856 <dev_lookup>
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	85 c0                	test   %eax,%eax
  800c28:	78 44                	js     800c6e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c31:	75 21                	jne    800c54 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c33:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c38:	8b 40 48             	mov    0x48(%eax),%eax
  800c3b:	83 ec 04             	sub    $0x4,%esp
  800c3e:	53                   	push   %ebx
  800c3f:	50                   	push   %eax
  800c40:	68 1c 23 80 00       	push   $0x80231c
  800c45:	e8 5d 0d 00 00       	call   8019a7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c52:	eb 23                	jmp    800c77 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c57:	8b 52 18             	mov    0x18(%edx),%edx
  800c5a:	85 d2                	test   %edx,%edx
  800c5c:	74 14                	je     800c72 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c5e:	83 ec 08             	sub    $0x8,%esp
  800c61:	ff 75 0c             	pushl  0xc(%ebp)
  800c64:	50                   	push   %eax
  800c65:	ff d2                	call   *%edx
  800c67:	89 c2                	mov    %eax,%edx
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	eb 09                	jmp    800c77 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c6e:	89 c2                	mov    %eax,%edx
  800c70:	eb 05                	jmp    800c77 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c72:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800c77:	89 d0                	mov    %edx,%eax
  800c79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	53                   	push   %ebx
  800c82:	83 ec 14             	sub    $0x14,%esp
  800c85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c8b:	50                   	push   %eax
  800c8c:	ff 75 08             	pushl  0x8(%ebp)
  800c8f:	e8 6c fb ff ff       	call   800800 <fd_lookup>
  800c94:	83 c4 08             	add    $0x8,%esp
  800c97:	89 c2                	mov    %eax,%edx
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	78 58                	js     800cf5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c9d:	83 ec 08             	sub    $0x8,%esp
  800ca0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca3:	50                   	push   %eax
  800ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca7:	ff 30                	pushl  (%eax)
  800ca9:	e8 a8 fb ff ff       	call   800856 <dev_lookup>
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	78 37                	js     800cec <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800cbc:	74 32                	je     800cf0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800cbe:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800cc1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cc8:	00 00 00 
	stat->st_isdir = 0;
  800ccb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cd2:	00 00 00 
	stat->st_dev = dev;
  800cd5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800cdb:	83 ec 08             	sub    $0x8,%esp
  800cde:	53                   	push   %ebx
  800cdf:	ff 75 f0             	pushl  -0x10(%ebp)
  800ce2:	ff 50 14             	call   *0x14(%eax)
  800ce5:	89 c2                	mov    %eax,%edx
  800ce7:	83 c4 10             	add    $0x10,%esp
  800cea:	eb 09                	jmp    800cf5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cec:	89 c2                	mov    %eax,%edx
  800cee:	eb 05                	jmp    800cf5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800cf0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800cf5:	89 d0                	mov    %edx,%eax
  800cf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d01:	83 ec 08             	sub    $0x8,%esp
  800d04:	6a 00                	push   $0x0
  800d06:	ff 75 08             	pushl  0x8(%ebp)
  800d09:	e8 d6 01 00 00       	call   800ee4 <open>
  800d0e:	89 c3                	mov    %eax,%ebx
  800d10:	83 c4 10             	add    $0x10,%esp
  800d13:	85 c0                	test   %eax,%eax
  800d15:	78 1b                	js     800d32 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d17:	83 ec 08             	sub    $0x8,%esp
  800d1a:	ff 75 0c             	pushl  0xc(%ebp)
  800d1d:	50                   	push   %eax
  800d1e:	e8 5b ff ff ff       	call   800c7e <fstat>
  800d23:	89 c6                	mov    %eax,%esi
	close(fd);
  800d25:	89 1c 24             	mov    %ebx,(%esp)
  800d28:	e8 fd fb ff ff       	call   80092a <close>
	return r;
  800d2d:	83 c4 10             	add    $0x10,%esp
  800d30:	89 f0                	mov    %esi,%eax
}
  800d32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	89 c6                	mov    %eax,%esi
  800d40:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d42:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d49:	75 12                	jne    800d5d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	6a 01                	push   $0x1
  800d50:	e8 59 12 00 00       	call   801fae <ipc_find_env>
  800d55:	a3 00 40 80 00       	mov    %eax,0x804000
  800d5a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d5d:	6a 07                	push   $0x7
  800d5f:	68 00 50 80 00       	push   $0x805000
  800d64:	56                   	push   %esi
  800d65:	ff 35 00 40 80 00    	pushl  0x804000
  800d6b:	e8 ea 11 00 00       	call   801f5a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d70:	83 c4 0c             	add    $0xc,%esp
  800d73:	6a 00                	push   $0x0
  800d75:	53                   	push   %ebx
  800d76:	6a 00                	push   $0x0
  800d78:	e8 76 11 00 00       	call   801ef3 <ipc_recv>
}
  800d7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800d90:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d98:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800da2:	b8 02 00 00 00       	mov    $0x2,%eax
  800da7:	e8 8d ff ff ff       	call   800d39 <fsipc>
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
  800db7:	8b 40 0c             	mov    0xc(%eax),%eax
  800dba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800dbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc4:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc9:	e8 6b ff ff ff       	call   800d39 <fsipc>
}
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 04             	sub    $0x4,%esp
  800dd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	8b 40 0c             	mov    0xc(%eax),%eax
  800de0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800de5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dea:	b8 05 00 00 00       	mov    $0x5,%eax
  800def:	e8 45 ff ff ff       	call   800d39 <fsipc>
  800df4:	85 c0                	test   %eax,%eax
  800df6:	78 2c                	js     800e24 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800df8:	83 ec 08             	sub    $0x8,%esp
  800dfb:	68 00 50 80 00       	push   $0x805000
  800e00:	53                   	push   %ebx
  800e01:	e8 71 f3 ff ff       	call   800177 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e06:	a1 80 50 80 00       	mov    0x805080,%eax
  800e0b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e11:	a1 84 50 80 00       	mov    0x805084,%eax
  800e16:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e27:	c9                   	leave  
  800e28:	c3                   	ret    

00800e29 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	8b 52 0c             	mov    0xc(%edx),%edx
  800e38:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800e3e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800e43:	50                   	push   %eax
  800e44:	ff 75 0c             	pushl  0xc(%ebp)
  800e47:	68 08 50 80 00       	push   $0x805008
  800e4c:	e8 b8 f4 ff ff       	call   800309 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800e51:	ba 00 00 00 00       	mov    $0x0,%edx
  800e56:	b8 04 00 00 00       	mov    $0x4,%eax
  800e5b:	e8 d9 fe ff ff       	call   800d39 <fsipc>

}
  800e60:	c9                   	leave  
  800e61:	c3                   	ret    

00800e62 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e70:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e75:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	b8 03 00 00 00       	mov    $0x3,%eax
  800e85:	e8 af fe ff ff       	call   800d39 <fsipc>
  800e8a:	89 c3                	mov    %eax,%ebx
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	78 4b                	js     800edb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e90:	39 c6                	cmp    %eax,%esi
  800e92:	73 16                	jae    800eaa <devfile_read+0x48>
  800e94:	68 8c 23 80 00       	push   $0x80238c
  800e99:	68 93 23 80 00       	push   $0x802393
  800e9e:	6a 7c                	push   $0x7c
  800ea0:	68 a8 23 80 00       	push   $0x8023a8
  800ea5:	e8 24 0a 00 00       	call   8018ce <_panic>
	assert(r <= PGSIZE);
  800eaa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800eaf:	7e 16                	jle    800ec7 <devfile_read+0x65>
  800eb1:	68 b3 23 80 00       	push   $0x8023b3
  800eb6:	68 93 23 80 00       	push   $0x802393
  800ebb:	6a 7d                	push   $0x7d
  800ebd:	68 a8 23 80 00       	push   $0x8023a8
  800ec2:	e8 07 0a 00 00       	call   8018ce <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	50                   	push   %eax
  800ecb:	68 00 50 80 00       	push   $0x805000
  800ed0:	ff 75 0c             	pushl  0xc(%ebp)
  800ed3:	e8 31 f4 ff ff       	call   800309 <memmove>
	return r;
  800ed8:	83 c4 10             	add    $0x10,%esp
}
  800edb:	89 d8                	mov    %ebx,%eax
  800edd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    

00800ee4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 20             	sub    $0x20,%esp
  800eeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800eee:	53                   	push   %ebx
  800eef:	e8 4a f2 ff ff       	call   80013e <strlen>
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800efc:	7f 67                	jg     800f65 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800efe:	83 ec 0c             	sub    $0xc,%esp
  800f01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f04:	50                   	push   %eax
  800f05:	e8 a7 f8 ff ff       	call   8007b1 <fd_alloc>
  800f0a:	83 c4 10             	add    $0x10,%esp
		return r;
  800f0d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	78 57                	js     800f6a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f13:	83 ec 08             	sub    $0x8,%esp
  800f16:	53                   	push   %ebx
  800f17:	68 00 50 80 00       	push   $0x805000
  800f1c:	e8 56 f2 ff ff       	call   800177 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f24:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f31:	e8 03 fe ff ff       	call   800d39 <fsipc>
  800f36:	89 c3                	mov    %eax,%ebx
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	79 14                	jns    800f53 <open+0x6f>
		fd_close(fd, 0);
  800f3f:	83 ec 08             	sub    $0x8,%esp
  800f42:	6a 00                	push   $0x0
  800f44:	ff 75 f4             	pushl  -0xc(%ebp)
  800f47:	e8 5d f9 ff ff       	call   8008a9 <fd_close>
		return r;
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	89 da                	mov    %ebx,%edx
  800f51:	eb 17                	jmp    800f6a <open+0x86>
	}

	return fd2num(fd);
  800f53:	83 ec 0c             	sub    $0xc,%esp
  800f56:	ff 75 f4             	pushl  -0xc(%ebp)
  800f59:	e8 2c f8 ff ff       	call   80078a <fd2num>
  800f5e:	89 c2                	mov    %eax,%edx
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	eb 05                	jmp    800f6a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f65:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f6a:	89 d0                	mov    %edx,%eax
  800f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f77:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800f81:	e8 b3 fd ff ff       	call   800d39 <fsipc>
}
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f90:	83 ec 0c             	sub    $0xc,%esp
  800f93:	ff 75 08             	pushl  0x8(%ebp)
  800f96:	e8 ff f7 ff ff       	call   80079a <fd2data>
  800f9b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f9d:	83 c4 08             	add    $0x8,%esp
  800fa0:	68 bf 23 80 00       	push   $0x8023bf
  800fa5:	53                   	push   %ebx
  800fa6:	e8 cc f1 ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800fab:	8b 46 04             	mov    0x4(%esi),%eax
  800fae:	2b 06                	sub    (%esi),%eax
  800fb0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800fb6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800fbd:	00 00 00 
	stat->st_dev = &devpipe;
  800fc0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800fc7:	30 80 00 
	return 0;
}
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd2:	5b                   	pop    %ebx
  800fd3:	5e                   	pop    %esi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800fe0:	53                   	push   %ebx
  800fe1:	6a 00                	push   $0x0
  800fe3:	e8 17 f6 ff ff       	call   8005ff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800fe8:	89 1c 24             	mov    %ebx,(%esp)
  800feb:	e8 aa f7 ff ff       	call   80079a <fd2data>
  800ff0:	83 c4 08             	add    $0x8,%esp
  800ff3:	50                   	push   %eax
  800ff4:	6a 00                	push   $0x0
  800ff6:	e8 04 f6 ff ff       	call   8005ff <sys_page_unmap>
}
  800ffb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    

00801000 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	57                   	push   %edi
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	83 ec 1c             	sub    $0x1c,%esp
  801009:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80100c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80100e:	a1 08 40 80 00       	mov    0x804008,%eax
  801013:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	ff 75 e0             	pushl  -0x20(%ebp)
  80101c:	e8 c6 0f 00 00       	call   801fe7 <pageref>
  801021:	89 c3                	mov    %eax,%ebx
  801023:	89 3c 24             	mov    %edi,(%esp)
  801026:	e8 bc 0f 00 00       	call   801fe7 <pageref>
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	39 c3                	cmp    %eax,%ebx
  801030:	0f 94 c1             	sete   %cl
  801033:	0f b6 c9             	movzbl %cl,%ecx
  801036:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801039:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80103f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801042:	39 ce                	cmp    %ecx,%esi
  801044:	74 1b                	je     801061 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801046:	39 c3                	cmp    %eax,%ebx
  801048:	75 c4                	jne    80100e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80104a:	8b 42 58             	mov    0x58(%edx),%eax
  80104d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801050:	50                   	push   %eax
  801051:	56                   	push   %esi
  801052:	68 c6 23 80 00       	push   $0x8023c6
  801057:	e8 4b 09 00 00       	call   8019a7 <cprintf>
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	eb ad                	jmp    80100e <_pipeisclosed+0xe>
	}
}
  801061:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801064:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5f                   	pop    %edi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	57                   	push   %edi
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
  801072:	83 ec 28             	sub    $0x28,%esp
  801075:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801078:	56                   	push   %esi
  801079:	e8 1c f7 ff ff       	call   80079a <fd2data>
  80107e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	bf 00 00 00 00       	mov    $0x0,%edi
  801088:	eb 4b                	jmp    8010d5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80108a:	89 da                	mov    %ebx,%edx
  80108c:	89 f0                	mov    %esi,%eax
  80108e:	e8 6d ff ff ff       	call   801000 <_pipeisclosed>
  801093:	85 c0                	test   %eax,%eax
  801095:	75 48                	jne    8010df <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801097:	e8 bf f4 ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80109c:	8b 43 04             	mov    0x4(%ebx),%eax
  80109f:	8b 0b                	mov    (%ebx),%ecx
  8010a1:	8d 51 20             	lea    0x20(%ecx),%edx
  8010a4:	39 d0                	cmp    %edx,%eax
  8010a6:	73 e2                	jae    80108a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ab:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010af:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010b2:	89 c2                	mov    %eax,%edx
  8010b4:	c1 fa 1f             	sar    $0x1f,%edx
  8010b7:	89 d1                	mov    %edx,%ecx
  8010b9:	c1 e9 1b             	shr    $0x1b,%ecx
  8010bc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8010bf:	83 e2 1f             	and    $0x1f,%edx
  8010c2:	29 ca                	sub    %ecx,%edx
  8010c4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8010c8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8010cc:	83 c0 01             	add    $0x1,%eax
  8010cf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010d2:	83 c7 01             	add    $0x1,%edi
  8010d5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010d8:	75 c2                	jne    80109c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8010da:	8b 45 10             	mov    0x10(%ebp),%eax
  8010dd:	eb 05                	jmp    8010e4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010df:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8010e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e7:	5b                   	pop    %ebx
  8010e8:	5e                   	pop    %esi
  8010e9:	5f                   	pop    %edi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	57                   	push   %edi
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 18             	sub    $0x18,%esp
  8010f5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8010f8:	57                   	push   %edi
  8010f9:	e8 9c f6 ff ff       	call   80079a <fd2data>
  8010fe:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	bb 00 00 00 00       	mov    $0x0,%ebx
  801108:	eb 3d                	jmp    801147 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80110a:	85 db                	test   %ebx,%ebx
  80110c:	74 04                	je     801112 <devpipe_read+0x26>
				return i;
  80110e:	89 d8                	mov    %ebx,%eax
  801110:	eb 44                	jmp    801156 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801112:	89 f2                	mov    %esi,%edx
  801114:	89 f8                	mov    %edi,%eax
  801116:	e8 e5 fe ff ff       	call   801000 <_pipeisclosed>
  80111b:	85 c0                	test   %eax,%eax
  80111d:	75 32                	jne    801151 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80111f:	e8 37 f4 ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801124:	8b 06                	mov    (%esi),%eax
  801126:	3b 46 04             	cmp    0x4(%esi),%eax
  801129:	74 df                	je     80110a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80112b:	99                   	cltd   
  80112c:	c1 ea 1b             	shr    $0x1b,%edx
  80112f:	01 d0                	add    %edx,%eax
  801131:	83 e0 1f             	and    $0x1f,%eax
  801134:	29 d0                	sub    %edx,%eax
  801136:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80113b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801141:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801144:	83 c3 01             	add    $0x1,%ebx
  801147:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80114a:	75 d8                	jne    801124 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80114c:	8b 45 10             	mov    0x10(%ebp),%eax
  80114f:	eb 05                	jmp    801156 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801151:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5f                   	pop    %edi
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801166:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801169:	50                   	push   %eax
  80116a:	e8 42 f6 ff ff       	call   8007b1 <fd_alloc>
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	89 c2                	mov    %eax,%edx
  801174:	85 c0                	test   %eax,%eax
  801176:	0f 88 2c 01 00 00    	js     8012a8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	68 07 04 00 00       	push   $0x407
  801184:	ff 75 f4             	pushl  -0xc(%ebp)
  801187:	6a 00                	push   $0x0
  801189:	e8 ec f3 ff ff       	call   80057a <sys_page_alloc>
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	89 c2                	mov    %eax,%edx
  801193:	85 c0                	test   %eax,%eax
  801195:	0f 88 0d 01 00 00    	js     8012a8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80119b:	83 ec 0c             	sub    $0xc,%esp
  80119e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a1:	50                   	push   %eax
  8011a2:	e8 0a f6 ff ff       	call   8007b1 <fd_alloc>
  8011a7:	89 c3                	mov    %eax,%ebx
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	0f 88 e2 00 00 00    	js     801296 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	68 07 04 00 00       	push   $0x407
  8011bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8011bf:	6a 00                	push   $0x0
  8011c1:	e8 b4 f3 ff ff       	call   80057a <sys_page_alloc>
  8011c6:	89 c3                	mov    %eax,%ebx
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	0f 88 c3 00 00 00    	js     801296 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d9:	e8 bc f5 ff ff       	call   80079a <fd2data>
  8011de:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011e0:	83 c4 0c             	add    $0xc,%esp
  8011e3:	68 07 04 00 00       	push   $0x407
  8011e8:	50                   	push   %eax
  8011e9:	6a 00                	push   $0x0
  8011eb:	e8 8a f3 ff ff       	call   80057a <sys_page_alloc>
  8011f0:	89 c3                	mov    %eax,%ebx
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	0f 88 89 00 00 00    	js     801286 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	ff 75 f0             	pushl  -0x10(%ebp)
  801203:	e8 92 f5 ff ff       	call   80079a <fd2data>
  801208:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80120f:	50                   	push   %eax
  801210:	6a 00                	push   $0x0
  801212:	56                   	push   %esi
  801213:	6a 00                	push   $0x0
  801215:	e8 a3 f3 ff ff       	call   8005bd <sys_page_map>
  80121a:	89 c3                	mov    %eax,%ebx
  80121c:	83 c4 20             	add    $0x20,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 55                	js     801278 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801223:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801229:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80122e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801231:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801238:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80123e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801241:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801243:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801246:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80124d:	83 ec 0c             	sub    $0xc,%esp
  801250:	ff 75 f4             	pushl  -0xc(%ebp)
  801253:	e8 32 f5 ff ff       	call   80078a <fd2num>
  801258:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80125d:	83 c4 04             	add    $0x4,%esp
  801260:	ff 75 f0             	pushl  -0x10(%ebp)
  801263:	e8 22 f5 ff ff       	call   80078a <fd2num>
  801268:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	ba 00 00 00 00       	mov    $0x0,%edx
  801276:	eb 30                	jmp    8012a8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	56                   	push   %esi
  80127c:	6a 00                	push   $0x0
  80127e:	e8 7c f3 ff ff       	call   8005ff <sys_page_unmap>
  801283:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	ff 75 f0             	pushl  -0x10(%ebp)
  80128c:	6a 00                	push   $0x0
  80128e:	e8 6c f3 ff ff       	call   8005ff <sys_page_unmap>
  801293:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	ff 75 f4             	pushl  -0xc(%ebp)
  80129c:	6a 00                	push   $0x0
  80129e:	e8 5c f3 ff ff       	call   8005ff <sys_page_unmap>
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8012a8:	89 d0                	mov    %edx,%eax
  8012aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    

008012b1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ba:	50                   	push   %eax
  8012bb:	ff 75 08             	pushl  0x8(%ebp)
  8012be:	e8 3d f5 ff ff       	call   800800 <fd_lookup>
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	78 18                	js     8012e2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d0:	e8 c5 f4 ff ff       	call   80079a <fd2data>
	return _pipeisclosed(fd, p);
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012da:	e8 21 fd ff ff       	call   801000 <_pipeisclosed>
  8012df:	83 c4 10             	add    $0x10,%esp
}
  8012e2:	c9                   	leave  
  8012e3:	c3                   	ret    

008012e4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8012ea:	68 de 23 80 00       	push   $0x8023de
  8012ef:	ff 75 0c             	pushl  0xc(%ebp)
  8012f2:	e8 80 ee ff ff       	call   800177 <strcpy>
	return 0;
}
  8012f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    

008012fe <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	53                   	push   %ebx
  801302:	83 ec 10             	sub    $0x10,%esp
  801305:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801308:	53                   	push   %ebx
  801309:	e8 d9 0c 00 00       	call   801fe7 <pageref>
  80130e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801311:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801316:	83 f8 01             	cmp    $0x1,%eax
  801319:	75 10                	jne    80132b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	ff 73 0c             	pushl  0xc(%ebx)
  801321:	e8 c0 02 00 00       	call   8015e6 <nsipc_close>
  801326:	89 c2                	mov    %eax,%edx
  801328:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80132b:	89 d0                	mov    %edx,%eax
  80132d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801338:	6a 00                	push   $0x0
  80133a:	ff 75 10             	pushl  0x10(%ebp)
  80133d:	ff 75 0c             	pushl  0xc(%ebp)
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	ff 70 0c             	pushl  0xc(%eax)
  801346:	e8 78 03 00 00       	call   8016c3 <nsipc_send>
}
  80134b:	c9                   	leave  
  80134c:	c3                   	ret    

0080134d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801353:	6a 00                	push   $0x0
  801355:	ff 75 10             	pushl  0x10(%ebp)
  801358:	ff 75 0c             	pushl  0xc(%ebp)
  80135b:	8b 45 08             	mov    0x8(%ebp),%eax
  80135e:	ff 70 0c             	pushl  0xc(%eax)
  801361:	e8 f1 02 00 00       	call   801657 <nsipc_recv>
}
  801366:	c9                   	leave  
  801367:	c3                   	ret    

00801368 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80136e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801371:	52                   	push   %edx
  801372:	50                   	push   %eax
  801373:	e8 88 f4 ff ff       	call   800800 <fd_lookup>
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 17                	js     801396 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80137f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801382:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801388:	39 08                	cmp    %ecx,(%eax)
  80138a:	75 05                	jne    801391 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80138c:	8b 40 0c             	mov    0xc(%eax),%eax
  80138f:	eb 05                	jmp    801396 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801391:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	56                   	push   %esi
  80139c:	53                   	push   %ebx
  80139d:	83 ec 1c             	sub    $0x1c,%esp
  8013a0:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8013a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	e8 06 f4 ff ff       	call   8007b1 <fd_alloc>
  8013ab:	89 c3                	mov    %eax,%ebx
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 1b                	js     8013cf <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8013b4:	83 ec 04             	sub    $0x4,%esp
  8013b7:	68 07 04 00 00       	push   $0x407
  8013bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8013bf:	6a 00                	push   $0x0
  8013c1:	e8 b4 f1 ff ff       	call   80057a <sys_page_alloc>
  8013c6:	89 c3                	mov    %eax,%ebx
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	79 10                	jns    8013df <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	56                   	push   %esi
  8013d3:	e8 0e 02 00 00       	call   8015e6 <nsipc_close>
		return r;
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	89 d8                	mov    %ebx,%eax
  8013dd:	eb 24                	jmp    801403 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8013df:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8013ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ed:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8013f4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	50                   	push   %eax
  8013fb:	e8 8a f3 ff ff       	call   80078a <fd2num>
  801400:	83 c4 10             	add    $0x10,%esp
}
  801403:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	e8 50 ff ff ff       	call   801368 <fd2sockid>
		return r;
  801418:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80141a:	85 c0                	test   %eax,%eax
  80141c:	78 1f                	js     80143d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80141e:	83 ec 04             	sub    $0x4,%esp
  801421:	ff 75 10             	pushl  0x10(%ebp)
  801424:	ff 75 0c             	pushl  0xc(%ebp)
  801427:	50                   	push   %eax
  801428:	e8 12 01 00 00       	call   80153f <nsipc_accept>
  80142d:	83 c4 10             	add    $0x10,%esp
		return r;
  801430:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801432:	85 c0                	test   %eax,%eax
  801434:	78 07                	js     80143d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801436:	e8 5d ff ff ff       	call   801398 <alloc_sockfd>
  80143b:	89 c1                	mov    %eax,%ecx
}
  80143d:	89 c8                	mov    %ecx,%eax
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801447:	8b 45 08             	mov    0x8(%ebp),%eax
  80144a:	e8 19 ff ff ff       	call   801368 <fd2sockid>
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 12                	js     801465 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801453:	83 ec 04             	sub    $0x4,%esp
  801456:	ff 75 10             	pushl  0x10(%ebp)
  801459:	ff 75 0c             	pushl  0xc(%ebp)
  80145c:	50                   	push   %eax
  80145d:	e8 2d 01 00 00       	call   80158f <nsipc_bind>
  801462:	83 c4 10             	add    $0x10,%esp
}
  801465:	c9                   	leave  
  801466:	c3                   	ret    

00801467 <shutdown>:

int
shutdown(int s, int how)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80146d:	8b 45 08             	mov    0x8(%ebp),%eax
  801470:	e8 f3 fe ff ff       	call   801368 <fd2sockid>
  801475:	85 c0                	test   %eax,%eax
  801477:	78 0f                	js     801488 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	ff 75 0c             	pushl  0xc(%ebp)
  80147f:	50                   	push   %eax
  801480:	e8 3f 01 00 00       	call   8015c4 <nsipc_shutdown>
  801485:	83 c4 10             	add    $0x10,%esp
}
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801490:	8b 45 08             	mov    0x8(%ebp),%eax
  801493:	e8 d0 fe ff ff       	call   801368 <fd2sockid>
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 12                	js     8014ae <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80149c:	83 ec 04             	sub    $0x4,%esp
  80149f:	ff 75 10             	pushl  0x10(%ebp)
  8014a2:	ff 75 0c             	pushl  0xc(%ebp)
  8014a5:	50                   	push   %eax
  8014a6:	e8 55 01 00 00       	call   801600 <nsipc_connect>
  8014ab:	83 c4 10             	add    $0x10,%esp
}
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <listen>:

int
listen(int s, int backlog)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8014b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b9:	e8 aa fe ff ff       	call   801368 <fd2sockid>
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 0f                	js     8014d1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	ff 75 0c             	pushl  0xc(%ebp)
  8014c8:	50                   	push   %eax
  8014c9:	e8 67 01 00 00       	call   801635 <nsipc_listen>
  8014ce:	83 c4 10             	add    $0x10,%esp
}
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8014d9:	ff 75 10             	pushl  0x10(%ebp)
  8014dc:	ff 75 0c             	pushl  0xc(%ebp)
  8014df:	ff 75 08             	pushl  0x8(%ebp)
  8014e2:	e8 3a 02 00 00       	call   801721 <nsipc_socket>
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 05                	js     8014f3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8014ee:	e8 a5 fe ff ff       	call   801398 <alloc_sockfd>
}
  8014f3:	c9                   	leave  
  8014f4:	c3                   	ret    

008014f5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	53                   	push   %ebx
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8014fe:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801505:	75 12                	jne    801519 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	6a 02                	push   $0x2
  80150c:	e8 9d 0a 00 00       	call   801fae <ipc_find_env>
  801511:	a3 04 40 80 00       	mov    %eax,0x804004
  801516:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801519:	6a 07                	push   $0x7
  80151b:	68 00 60 80 00       	push   $0x806000
  801520:	53                   	push   %ebx
  801521:	ff 35 04 40 80 00    	pushl  0x804004
  801527:	e8 2e 0a 00 00       	call   801f5a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80152c:	83 c4 0c             	add    $0xc,%esp
  80152f:	6a 00                	push   $0x0
  801531:	6a 00                	push   $0x0
  801533:	6a 00                	push   $0x0
  801535:	e8 b9 09 00 00       	call   801ef3 <ipc_recv>
}
  80153a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	56                   	push   %esi
  801543:	53                   	push   %ebx
  801544:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801547:	8b 45 08             	mov    0x8(%ebp),%eax
  80154a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80154f:	8b 06                	mov    (%esi),%eax
  801551:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801556:	b8 01 00 00 00       	mov    $0x1,%eax
  80155b:	e8 95 ff ff ff       	call   8014f5 <nsipc>
  801560:	89 c3                	mov    %eax,%ebx
  801562:	85 c0                	test   %eax,%eax
  801564:	78 20                	js     801586 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801566:	83 ec 04             	sub    $0x4,%esp
  801569:	ff 35 10 60 80 00    	pushl  0x806010
  80156f:	68 00 60 80 00       	push   $0x806000
  801574:	ff 75 0c             	pushl  0xc(%ebp)
  801577:	e8 8d ed ff ff       	call   800309 <memmove>
		*addrlen = ret->ret_addrlen;
  80157c:	a1 10 60 80 00       	mov    0x806010,%eax
  801581:	89 06                	mov    %eax,(%esi)
  801583:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801586:	89 d8                	mov    %ebx,%eax
  801588:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801599:	8b 45 08             	mov    0x8(%ebp),%eax
  80159c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8015a1:	53                   	push   %ebx
  8015a2:	ff 75 0c             	pushl  0xc(%ebp)
  8015a5:	68 04 60 80 00       	push   $0x806004
  8015aa:	e8 5a ed ff ff       	call   800309 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8015af:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8015b5:	b8 02 00 00 00       	mov    $0x2,%eax
  8015ba:	e8 36 ff ff ff       	call   8014f5 <nsipc>
}
  8015bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8015ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8015d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8015da:	b8 03 00 00 00       	mov    $0x3,%eax
  8015df:	e8 11 ff ff ff       	call   8014f5 <nsipc>
}
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    

008015e6 <nsipc_close>:

int
nsipc_close(int s)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8015ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ef:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8015f4:	b8 04 00 00 00       	mov    $0x4,%eax
  8015f9:	e8 f7 fe ff ff       	call   8014f5 <nsipc>
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	53                   	push   %ebx
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80160a:	8b 45 08             	mov    0x8(%ebp),%eax
  80160d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801612:	53                   	push   %ebx
  801613:	ff 75 0c             	pushl  0xc(%ebp)
  801616:	68 04 60 80 00       	push   $0x806004
  80161b:	e8 e9 ec ff ff       	call   800309 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801620:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801626:	b8 05 00 00 00       	mov    $0x5,%eax
  80162b:	e8 c5 fe ff ff       	call   8014f5 <nsipc>
}
  801630:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80163b:	8b 45 08             	mov    0x8(%ebp),%eax
  80163e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801643:	8b 45 0c             	mov    0xc(%ebp),%eax
  801646:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80164b:	b8 06 00 00 00       	mov    $0x6,%eax
  801650:	e8 a0 fe ff ff       	call   8014f5 <nsipc>
}
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	56                   	push   %esi
  80165b:	53                   	push   %ebx
  80165c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80165f:	8b 45 08             	mov    0x8(%ebp),%eax
  801662:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801667:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80166d:	8b 45 14             	mov    0x14(%ebp),%eax
  801670:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801675:	b8 07 00 00 00       	mov    $0x7,%eax
  80167a:	e8 76 fe ff ff       	call   8014f5 <nsipc>
  80167f:	89 c3                	mov    %eax,%ebx
  801681:	85 c0                	test   %eax,%eax
  801683:	78 35                	js     8016ba <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801685:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80168a:	7f 04                	jg     801690 <nsipc_recv+0x39>
  80168c:	39 c6                	cmp    %eax,%esi
  80168e:	7d 16                	jge    8016a6 <nsipc_recv+0x4f>
  801690:	68 ea 23 80 00       	push   $0x8023ea
  801695:	68 93 23 80 00       	push   $0x802393
  80169a:	6a 62                	push   $0x62
  80169c:	68 ff 23 80 00       	push   $0x8023ff
  8016a1:	e8 28 02 00 00       	call   8018ce <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8016a6:	83 ec 04             	sub    $0x4,%esp
  8016a9:	50                   	push   %eax
  8016aa:	68 00 60 80 00       	push   $0x806000
  8016af:	ff 75 0c             	pushl  0xc(%ebp)
  8016b2:	e8 52 ec ff ff       	call   800309 <memmove>
  8016b7:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8016ba:	89 d8                	mov    %ebx,%eax
  8016bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 04             	sub    $0x4,%esp
  8016ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8016d5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8016db:	7e 16                	jle    8016f3 <nsipc_send+0x30>
  8016dd:	68 0b 24 80 00       	push   $0x80240b
  8016e2:	68 93 23 80 00       	push   $0x802393
  8016e7:	6a 6d                	push   $0x6d
  8016e9:	68 ff 23 80 00       	push   $0x8023ff
  8016ee:	e8 db 01 00 00       	call   8018ce <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8016f3:	83 ec 04             	sub    $0x4,%esp
  8016f6:	53                   	push   %ebx
  8016f7:	ff 75 0c             	pushl  0xc(%ebp)
  8016fa:	68 0c 60 80 00       	push   $0x80600c
  8016ff:	e8 05 ec ff ff       	call   800309 <memmove>
	nsipcbuf.send.req_size = size;
  801704:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80170a:	8b 45 14             	mov    0x14(%ebp),%eax
  80170d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801712:	b8 08 00 00 00       	mov    $0x8,%eax
  801717:	e8 d9 fd ff ff       	call   8014f5 <nsipc>
}
  80171c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801727:	8b 45 08             	mov    0x8(%ebp),%eax
  80172a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80172f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801732:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801737:	8b 45 10             	mov    0x10(%ebp),%eax
  80173a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80173f:	b8 09 00 00 00       	mov    $0x9,%eax
  801744:	e8 ac fd ff ff       	call   8014f5 <nsipc>
}
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80174e:	b8 00 00 00 00       	mov    $0x0,%eax
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80175b:	68 17 24 80 00       	push   $0x802417
  801760:	ff 75 0c             	pushl  0xc(%ebp)
  801763:	e8 0f ea ff ff       	call   800177 <strcpy>
	return 0;
}
  801768:	b8 00 00 00 00       	mov    $0x0,%eax
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	57                   	push   %edi
  801773:	56                   	push   %esi
  801774:	53                   	push   %ebx
  801775:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80177b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801780:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801786:	eb 2d                	jmp    8017b5 <devcons_write+0x46>
		m = n - tot;
  801788:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80178b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80178d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801790:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801795:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801798:	83 ec 04             	sub    $0x4,%esp
  80179b:	53                   	push   %ebx
  80179c:	03 45 0c             	add    0xc(%ebp),%eax
  80179f:	50                   	push   %eax
  8017a0:	57                   	push   %edi
  8017a1:	e8 63 eb ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  8017a6:	83 c4 08             	add    $0x8,%esp
  8017a9:	53                   	push   %ebx
  8017aa:	57                   	push   %edi
  8017ab:	e8 0e ed ff ff       	call   8004be <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8017b0:	01 de                	add    %ebx,%esi
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	89 f0                	mov    %esi,%eax
  8017b7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017ba:	72 cc                	jb     801788 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8017bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	5f                   	pop    %edi
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8017cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017d3:	74 2a                	je     8017ff <devcons_read+0x3b>
  8017d5:	eb 05                	jmp    8017dc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8017d7:	e8 7f ed ff ff       	call   80055b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8017dc:	e8 fb ec ff ff       	call   8004dc <sys_cgetc>
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	74 f2                	je     8017d7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 16                	js     8017ff <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8017e9:	83 f8 04             	cmp    $0x4,%eax
  8017ec:	74 0c                	je     8017fa <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8017ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f1:	88 02                	mov    %al,(%edx)
	return 1;
  8017f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8017f8:	eb 05                	jmp    8017ff <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8017ff:	c9                   	leave  
  801800:	c3                   	ret    

00801801 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80180d:	6a 01                	push   $0x1
  80180f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801812:	50                   	push   %eax
  801813:	e8 a6 ec ff ff       	call   8004be <sys_cputs>
}
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    

0080181d <getchar>:

int
getchar(void)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801823:	6a 01                	push   $0x1
  801825:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801828:	50                   	push   %eax
  801829:	6a 00                	push   $0x0
  80182b:	e8 36 f2 ff ff       	call   800a66 <read>
	if (r < 0)
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	78 0f                	js     801846 <getchar+0x29>
		return r;
	if (r < 1)
  801837:	85 c0                	test   %eax,%eax
  801839:	7e 06                	jle    801841 <getchar+0x24>
		return -E_EOF;
	return c;
  80183b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80183f:	eb 05                	jmp    801846 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801841:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80184e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801851:	50                   	push   %eax
  801852:	ff 75 08             	pushl  0x8(%ebp)
  801855:	e8 a6 ef ff ff       	call   800800 <fd_lookup>
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 11                	js     801872 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801861:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801864:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80186a:	39 10                	cmp    %edx,(%eax)
  80186c:	0f 94 c0             	sete   %al
  80186f:	0f b6 c0             	movzbl %al,%eax
}
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <opencons>:

int
opencons(void)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80187a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187d:	50                   	push   %eax
  80187e:	e8 2e ef ff ff       	call   8007b1 <fd_alloc>
  801883:	83 c4 10             	add    $0x10,%esp
		return r;
  801886:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 3e                	js     8018ca <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	68 07 04 00 00       	push   $0x407
  801894:	ff 75 f4             	pushl  -0xc(%ebp)
  801897:	6a 00                	push   $0x0
  801899:	e8 dc ec ff ff       	call   80057a <sys_page_alloc>
  80189e:	83 c4 10             	add    $0x10,%esp
		return r;
  8018a1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 23                	js     8018ca <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8018a7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8018ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8018bc:	83 ec 0c             	sub    $0xc,%esp
  8018bf:	50                   	push   %eax
  8018c0:	e8 c5 ee ff ff       	call   80078a <fd2num>
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	83 c4 10             	add    $0x10,%esp
}
  8018ca:	89 d0                	mov    %edx,%eax
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	56                   	push   %esi
  8018d2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8018d3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018d6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8018dc:	e8 5b ec ff ff       	call   80053c <sys_getenvid>
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	ff 75 08             	pushl  0x8(%ebp)
  8018ea:	56                   	push   %esi
  8018eb:	50                   	push   %eax
  8018ec:	68 24 24 80 00       	push   $0x802424
  8018f1:	e8 b1 00 00 00       	call   8019a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8018f6:	83 c4 18             	add    $0x18,%esp
  8018f9:	53                   	push   %ebx
  8018fa:	ff 75 10             	pushl  0x10(%ebp)
  8018fd:	e8 54 00 00 00       	call   801956 <vcprintf>
	cprintf("\n");
  801902:	c7 04 24 d7 23 80 00 	movl   $0x8023d7,(%esp)
  801909:	e8 99 00 00 00       	call   8019a7 <cprintf>
  80190e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801911:	cc                   	int3   
  801912:	eb fd                	jmp    801911 <_panic+0x43>

00801914 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	53                   	push   %ebx
  801918:	83 ec 04             	sub    $0x4,%esp
  80191b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80191e:	8b 13                	mov    (%ebx),%edx
  801920:	8d 42 01             	lea    0x1(%edx),%eax
  801923:	89 03                	mov    %eax,(%ebx)
  801925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801928:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80192c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801931:	75 1a                	jne    80194d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	68 ff 00 00 00       	push   $0xff
  80193b:	8d 43 08             	lea    0x8(%ebx),%eax
  80193e:	50                   	push   %eax
  80193f:	e8 7a eb ff ff       	call   8004be <sys_cputs>
		b->idx = 0;
  801944:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80194a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80194d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801951:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80195f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801966:	00 00 00 
	b.cnt = 0;
  801969:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801970:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801973:	ff 75 0c             	pushl  0xc(%ebp)
  801976:	ff 75 08             	pushl  0x8(%ebp)
  801979:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	68 14 19 80 00       	push   $0x801914
  801985:	e8 54 01 00 00       	call   801ade <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80198a:	83 c4 08             	add    $0x8,%esp
  80198d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801993:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801999:	50                   	push   %eax
  80199a:	e8 1f eb ff ff       	call   8004be <sys_cputs>

	return b.cnt;
}
  80199f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8019b0:	50                   	push   %eax
  8019b1:	ff 75 08             	pushl  0x8(%ebp)
  8019b4:	e8 9d ff ff ff       	call   801956 <vcprintf>
	va_end(ap);

	return cnt;
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	57                   	push   %edi
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 1c             	sub    $0x1c,%esp
  8019c4:	89 c7                	mov    %eax,%edi
  8019c6:	89 d6                	mov    %edx,%esi
  8019c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8019d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019dc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8019df:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8019e2:	39 d3                	cmp    %edx,%ebx
  8019e4:	72 05                	jb     8019eb <printnum+0x30>
  8019e6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8019e9:	77 45                	ja     801a30 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8019eb:	83 ec 0c             	sub    $0xc,%esp
  8019ee:	ff 75 18             	pushl  0x18(%ebp)
  8019f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8019f7:	53                   	push   %ebx
  8019f8:	ff 75 10             	pushl  0x10(%ebp)
  8019fb:	83 ec 08             	sub    $0x8,%esp
  8019fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a01:	ff 75 e0             	pushl  -0x20(%ebp)
  801a04:	ff 75 dc             	pushl  -0x24(%ebp)
  801a07:	ff 75 d8             	pushl  -0x28(%ebp)
  801a0a:	e8 21 06 00 00       	call   802030 <__udivdi3>
  801a0f:	83 c4 18             	add    $0x18,%esp
  801a12:	52                   	push   %edx
  801a13:	50                   	push   %eax
  801a14:	89 f2                	mov    %esi,%edx
  801a16:	89 f8                	mov    %edi,%eax
  801a18:	e8 9e ff ff ff       	call   8019bb <printnum>
  801a1d:	83 c4 20             	add    $0x20,%esp
  801a20:	eb 18                	jmp    801a3a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801a22:	83 ec 08             	sub    $0x8,%esp
  801a25:	56                   	push   %esi
  801a26:	ff 75 18             	pushl  0x18(%ebp)
  801a29:	ff d7                	call   *%edi
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	eb 03                	jmp    801a33 <printnum+0x78>
  801a30:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801a33:	83 eb 01             	sub    $0x1,%ebx
  801a36:	85 db                	test   %ebx,%ebx
  801a38:	7f e8                	jg     801a22 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801a3a:	83 ec 08             	sub    $0x8,%esp
  801a3d:	56                   	push   %esi
  801a3e:	83 ec 04             	sub    $0x4,%esp
  801a41:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a44:	ff 75 e0             	pushl  -0x20(%ebp)
  801a47:	ff 75 dc             	pushl  -0x24(%ebp)
  801a4a:	ff 75 d8             	pushl  -0x28(%ebp)
  801a4d:	e8 0e 07 00 00       	call   802160 <__umoddi3>
  801a52:	83 c4 14             	add    $0x14,%esp
  801a55:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
  801a5c:	50                   	push   %eax
  801a5d:	ff d7                	call   *%edi
}
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5f                   	pop    %edi
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    

00801a6a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801a6d:	83 fa 01             	cmp    $0x1,%edx
  801a70:	7e 0e                	jle    801a80 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801a72:	8b 10                	mov    (%eax),%edx
  801a74:	8d 4a 08             	lea    0x8(%edx),%ecx
  801a77:	89 08                	mov    %ecx,(%eax)
  801a79:	8b 02                	mov    (%edx),%eax
  801a7b:	8b 52 04             	mov    0x4(%edx),%edx
  801a7e:	eb 22                	jmp    801aa2 <getuint+0x38>
	else if (lflag)
  801a80:	85 d2                	test   %edx,%edx
  801a82:	74 10                	je     801a94 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801a84:	8b 10                	mov    (%eax),%edx
  801a86:	8d 4a 04             	lea    0x4(%edx),%ecx
  801a89:	89 08                	mov    %ecx,(%eax)
  801a8b:	8b 02                	mov    (%edx),%eax
  801a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a92:	eb 0e                	jmp    801aa2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801a94:	8b 10                	mov    (%eax),%edx
  801a96:	8d 4a 04             	lea    0x4(%edx),%ecx
  801a99:	89 08                	mov    %ecx,(%eax)
  801a9b:	8b 02                	mov    (%edx),%eax
  801a9d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801aaa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801aae:	8b 10                	mov    (%eax),%edx
  801ab0:	3b 50 04             	cmp    0x4(%eax),%edx
  801ab3:	73 0a                	jae    801abf <sprintputch+0x1b>
		*b->buf++ = ch;
  801ab5:	8d 4a 01             	lea    0x1(%edx),%ecx
  801ab8:	89 08                	mov    %ecx,(%eax)
  801aba:	8b 45 08             	mov    0x8(%ebp),%eax
  801abd:	88 02                	mov    %al,(%edx)
}
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801ac7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801aca:	50                   	push   %eax
  801acb:	ff 75 10             	pushl  0x10(%ebp)
  801ace:	ff 75 0c             	pushl  0xc(%ebp)
  801ad1:	ff 75 08             	pushl  0x8(%ebp)
  801ad4:	e8 05 00 00 00       	call   801ade <vprintfmt>
	va_end(ap);
}
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 2c             	sub    $0x2c,%esp
  801ae7:	8b 75 08             	mov    0x8(%ebp),%esi
  801aea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801aed:	8b 7d 10             	mov    0x10(%ebp),%edi
  801af0:	eb 12                	jmp    801b04 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801af2:	85 c0                	test   %eax,%eax
  801af4:	0f 84 89 03 00 00    	je     801e83 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801afa:	83 ec 08             	sub    $0x8,%esp
  801afd:	53                   	push   %ebx
  801afe:	50                   	push   %eax
  801aff:	ff d6                	call   *%esi
  801b01:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801b04:	83 c7 01             	add    $0x1,%edi
  801b07:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801b0b:	83 f8 25             	cmp    $0x25,%eax
  801b0e:	75 e2                	jne    801af2 <vprintfmt+0x14>
  801b10:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801b14:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801b1b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801b22:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801b29:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2e:	eb 07                	jmp    801b37 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b30:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801b33:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b37:	8d 47 01             	lea    0x1(%edi),%eax
  801b3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b3d:	0f b6 07             	movzbl (%edi),%eax
  801b40:	0f b6 c8             	movzbl %al,%ecx
  801b43:	83 e8 23             	sub    $0x23,%eax
  801b46:	3c 55                	cmp    $0x55,%al
  801b48:	0f 87 1a 03 00 00    	ja     801e68 <vprintfmt+0x38a>
  801b4e:	0f b6 c0             	movzbl %al,%eax
  801b51:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  801b58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801b5b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801b5f:	eb d6                	jmp    801b37 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
  801b69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801b6c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801b6f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801b73:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801b76:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801b79:	83 fa 09             	cmp    $0x9,%edx
  801b7c:	77 39                	ja     801bb7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801b7e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801b81:	eb e9                	jmp    801b6c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801b83:	8b 45 14             	mov    0x14(%ebp),%eax
  801b86:	8d 48 04             	lea    0x4(%eax),%ecx
  801b89:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801b8c:	8b 00                	mov    (%eax),%eax
  801b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801b94:	eb 27                	jmp    801bbd <vprintfmt+0xdf>
  801b96:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ba0:	0f 49 c8             	cmovns %eax,%ecx
  801ba3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ba6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ba9:	eb 8c                	jmp    801b37 <vprintfmt+0x59>
  801bab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801bae:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801bb5:	eb 80                	jmp    801b37 <vprintfmt+0x59>
  801bb7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801bba:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801bbd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801bc1:	0f 89 70 ff ff ff    	jns    801b37 <vprintfmt+0x59>
				width = precision, precision = -1;
  801bc7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801bca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bcd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801bd4:	e9 5e ff ff ff       	jmp    801b37 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801bd9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bdc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801bdf:	e9 53 ff ff ff       	jmp    801b37 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801be4:	8b 45 14             	mov    0x14(%ebp),%eax
  801be7:	8d 50 04             	lea    0x4(%eax),%edx
  801bea:	89 55 14             	mov    %edx,0x14(%ebp)
  801bed:	83 ec 08             	sub    $0x8,%esp
  801bf0:	53                   	push   %ebx
  801bf1:	ff 30                	pushl  (%eax)
  801bf3:	ff d6                	call   *%esi
			break;
  801bf5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bf8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801bfb:	e9 04 ff ff ff       	jmp    801b04 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801c00:	8b 45 14             	mov    0x14(%ebp),%eax
  801c03:	8d 50 04             	lea    0x4(%eax),%edx
  801c06:	89 55 14             	mov    %edx,0x14(%ebp)
  801c09:	8b 00                	mov    (%eax),%eax
  801c0b:	99                   	cltd   
  801c0c:	31 d0                	xor    %edx,%eax
  801c0e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801c10:	83 f8 0f             	cmp    $0xf,%eax
  801c13:	7f 0b                	jg     801c20 <vprintfmt+0x142>
  801c15:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  801c1c:	85 d2                	test   %edx,%edx
  801c1e:	75 18                	jne    801c38 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801c20:	50                   	push   %eax
  801c21:	68 5f 24 80 00       	push   $0x80245f
  801c26:	53                   	push   %ebx
  801c27:	56                   	push   %esi
  801c28:	e8 94 fe ff ff       	call   801ac1 <printfmt>
  801c2d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801c33:	e9 cc fe ff ff       	jmp    801b04 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801c38:	52                   	push   %edx
  801c39:	68 a5 23 80 00       	push   $0x8023a5
  801c3e:	53                   	push   %ebx
  801c3f:	56                   	push   %esi
  801c40:	e8 7c fe ff ff       	call   801ac1 <printfmt>
  801c45:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c4b:	e9 b4 fe ff ff       	jmp    801b04 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801c50:	8b 45 14             	mov    0x14(%ebp),%eax
  801c53:	8d 50 04             	lea    0x4(%eax),%edx
  801c56:	89 55 14             	mov    %edx,0x14(%ebp)
  801c59:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801c5b:	85 ff                	test   %edi,%edi
  801c5d:	b8 58 24 80 00       	mov    $0x802458,%eax
  801c62:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801c65:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c69:	0f 8e 94 00 00 00    	jle    801d03 <vprintfmt+0x225>
  801c6f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801c73:	0f 84 98 00 00 00    	je     801d11 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801c79:	83 ec 08             	sub    $0x8,%esp
  801c7c:	ff 75 d0             	pushl  -0x30(%ebp)
  801c7f:	57                   	push   %edi
  801c80:	e8 d1 e4 ff ff       	call   800156 <strnlen>
  801c85:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801c88:	29 c1                	sub    %eax,%ecx
  801c8a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801c8d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801c90:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801c94:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c97:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801c9a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801c9c:	eb 0f                	jmp    801cad <vprintfmt+0x1cf>
					putch(padc, putdat);
  801c9e:	83 ec 08             	sub    $0x8,%esp
  801ca1:	53                   	push   %ebx
  801ca2:	ff 75 e0             	pushl  -0x20(%ebp)
  801ca5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ca7:	83 ef 01             	sub    $0x1,%edi
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	85 ff                	test   %edi,%edi
  801caf:	7f ed                	jg     801c9e <vprintfmt+0x1c0>
  801cb1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801cb4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801cb7:	85 c9                	test   %ecx,%ecx
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbe:	0f 49 c1             	cmovns %ecx,%eax
  801cc1:	29 c1                	sub    %eax,%ecx
  801cc3:	89 75 08             	mov    %esi,0x8(%ebp)
  801cc6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801cc9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ccc:	89 cb                	mov    %ecx,%ebx
  801cce:	eb 4d                	jmp    801d1d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801cd0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801cd4:	74 1b                	je     801cf1 <vprintfmt+0x213>
  801cd6:	0f be c0             	movsbl %al,%eax
  801cd9:	83 e8 20             	sub    $0x20,%eax
  801cdc:	83 f8 5e             	cmp    $0x5e,%eax
  801cdf:	76 10                	jbe    801cf1 <vprintfmt+0x213>
					putch('?', putdat);
  801ce1:	83 ec 08             	sub    $0x8,%esp
  801ce4:	ff 75 0c             	pushl  0xc(%ebp)
  801ce7:	6a 3f                	push   $0x3f
  801ce9:	ff 55 08             	call   *0x8(%ebp)
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	eb 0d                	jmp    801cfe <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801cf1:	83 ec 08             	sub    $0x8,%esp
  801cf4:	ff 75 0c             	pushl  0xc(%ebp)
  801cf7:	52                   	push   %edx
  801cf8:	ff 55 08             	call   *0x8(%ebp)
  801cfb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801cfe:	83 eb 01             	sub    $0x1,%ebx
  801d01:	eb 1a                	jmp    801d1d <vprintfmt+0x23f>
  801d03:	89 75 08             	mov    %esi,0x8(%ebp)
  801d06:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d09:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d0c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d0f:	eb 0c                	jmp    801d1d <vprintfmt+0x23f>
  801d11:	89 75 08             	mov    %esi,0x8(%ebp)
  801d14:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d17:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d1a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d1d:	83 c7 01             	add    $0x1,%edi
  801d20:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d24:	0f be d0             	movsbl %al,%edx
  801d27:	85 d2                	test   %edx,%edx
  801d29:	74 23                	je     801d4e <vprintfmt+0x270>
  801d2b:	85 f6                	test   %esi,%esi
  801d2d:	78 a1                	js     801cd0 <vprintfmt+0x1f2>
  801d2f:	83 ee 01             	sub    $0x1,%esi
  801d32:	79 9c                	jns    801cd0 <vprintfmt+0x1f2>
  801d34:	89 df                	mov    %ebx,%edi
  801d36:	8b 75 08             	mov    0x8(%ebp),%esi
  801d39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d3c:	eb 18                	jmp    801d56 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801d3e:	83 ec 08             	sub    $0x8,%esp
  801d41:	53                   	push   %ebx
  801d42:	6a 20                	push   $0x20
  801d44:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801d46:	83 ef 01             	sub    $0x1,%edi
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	eb 08                	jmp    801d56 <vprintfmt+0x278>
  801d4e:	89 df                	mov    %ebx,%edi
  801d50:	8b 75 08             	mov    0x8(%ebp),%esi
  801d53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d56:	85 ff                	test   %edi,%edi
  801d58:	7f e4                	jg     801d3e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d5a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d5d:	e9 a2 fd ff ff       	jmp    801b04 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801d62:	83 fa 01             	cmp    $0x1,%edx
  801d65:	7e 16                	jle    801d7d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801d67:	8b 45 14             	mov    0x14(%ebp),%eax
  801d6a:	8d 50 08             	lea    0x8(%eax),%edx
  801d6d:	89 55 14             	mov    %edx,0x14(%ebp)
  801d70:	8b 50 04             	mov    0x4(%eax),%edx
  801d73:	8b 00                	mov    (%eax),%eax
  801d75:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d78:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801d7b:	eb 32                	jmp    801daf <vprintfmt+0x2d1>
	else if (lflag)
  801d7d:	85 d2                	test   %edx,%edx
  801d7f:	74 18                	je     801d99 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801d81:	8b 45 14             	mov    0x14(%ebp),%eax
  801d84:	8d 50 04             	lea    0x4(%eax),%edx
  801d87:	89 55 14             	mov    %edx,0x14(%ebp)
  801d8a:	8b 00                	mov    (%eax),%eax
  801d8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d8f:	89 c1                	mov    %eax,%ecx
  801d91:	c1 f9 1f             	sar    $0x1f,%ecx
  801d94:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801d97:	eb 16                	jmp    801daf <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801d99:	8b 45 14             	mov    0x14(%ebp),%eax
  801d9c:	8d 50 04             	lea    0x4(%eax),%edx
  801d9f:	89 55 14             	mov    %edx,0x14(%ebp)
  801da2:	8b 00                	mov    (%eax),%eax
  801da4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801da7:	89 c1                	mov    %eax,%ecx
  801da9:	c1 f9 1f             	sar    $0x1f,%ecx
  801dac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801daf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801db2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801db5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801dba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801dbe:	79 74                	jns    801e34 <vprintfmt+0x356>
				putch('-', putdat);
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	53                   	push   %ebx
  801dc4:	6a 2d                	push   $0x2d
  801dc6:	ff d6                	call   *%esi
				num = -(long long) num;
  801dc8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801dcb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801dce:	f7 d8                	neg    %eax
  801dd0:	83 d2 00             	adc    $0x0,%edx
  801dd3:	f7 da                	neg    %edx
  801dd5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801dd8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ddd:	eb 55                	jmp    801e34 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ddf:	8d 45 14             	lea    0x14(%ebp),%eax
  801de2:	e8 83 fc ff ff       	call   801a6a <getuint>
			base = 10;
  801de7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801dec:	eb 46                	jmp    801e34 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801dee:	8d 45 14             	lea    0x14(%ebp),%eax
  801df1:	e8 74 fc ff ff       	call   801a6a <getuint>
			base = 8;
  801df6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801dfb:	eb 37                	jmp    801e34 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801dfd:	83 ec 08             	sub    $0x8,%esp
  801e00:	53                   	push   %ebx
  801e01:	6a 30                	push   $0x30
  801e03:	ff d6                	call   *%esi
			putch('x', putdat);
  801e05:	83 c4 08             	add    $0x8,%esp
  801e08:	53                   	push   %ebx
  801e09:	6a 78                	push   $0x78
  801e0b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801e0d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e10:	8d 50 04             	lea    0x4(%eax),%edx
  801e13:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801e16:	8b 00                	mov    (%eax),%eax
  801e18:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801e1d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801e20:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801e25:	eb 0d                	jmp    801e34 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801e27:	8d 45 14             	lea    0x14(%ebp),%eax
  801e2a:	e8 3b fc ff ff       	call   801a6a <getuint>
			base = 16;
  801e2f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801e3b:	57                   	push   %edi
  801e3c:	ff 75 e0             	pushl  -0x20(%ebp)
  801e3f:	51                   	push   %ecx
  801e40:	52                   	push   %edx
  801e41:	50                   	push   %eax
  801e42:	89 da                	mov    %ebx,%edx
  801e44:	89 f0                	mov    %esi,%eax
  801e46:	e8 70 fb ff ff       	call   8019bb <printnum>
			break;
  801e4b:	83 c4 20             	add    $0x20,%esp
  801e4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e51:	e9 ae fc ff ff       	jmp    801b04 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801e56:	83 ec 08             	sub    $0x8,%esp
  801e59:	53                   	push   %ebx
  801e5a:	51                   	push   %ecx
  801e5b:	ff d6                	call   *%esi
			break;
  801e5d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801e63:	e9 9c fc ff ff       	jmp    801b04 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	53                   	push   %ebx
  801e6c:	6a 25                	push   $0x25
  801e6e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	eb 03                	jmp    801e78 <vprintfmt+0x39a>
  801e75:	83 ef 01             	sub    $0x1,%edi
  801e78:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801e7c:	75 f7                	jne    801e75 <vprintfmt+0x397>
  801e7e:	e9 81 fc ff ff       	jmp    801b04 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801e83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e86:	5b                   	pop    %ebx
  801e87:	5e                   	pop    %esi
  801e88:	5f                   	pop    %edi
  801e89:	5d                   	pop    %ebp
  801e8a:	c3                   	ret    

00801e8b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	83 ec 18             	sub    $0x18,%esp
  801e91:	8b 45 08             	mov    0x8(%ebp),%eax
  801e94:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801e97:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e9a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801e9e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ea1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	74 26                	je     801ed2 <vsnprintf+0x47>
  801eac:	85 d2                	test   %edx,%edx
  801eae:	7e 22                	jle    801ed2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801eb0:	ff 75 14             	pushl  0x14(%ebp)
  801eb3:	ff 75 10             	pushl  0x10(%ebp)
  801eb6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801eb9:	50                   	push   %eax
  801eba:	68 a4 1a 80 00       	push   $0x801aa4
  801ebf:	e8 1a fc ff ff       	call   801ade <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ec4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ec7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecd:	83 c4 10             	add    $0x10,%esp
  801ed0:	eb 05                	jmp    801ed7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ed2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801edf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ee2:	50                   	push   %eax
  801ee3:	ff 75 10             	pushl  0x10(%ebp)
  801ee6:	ff 75 0c             	pushl  0xc(%ebp)
  801ee9:	ff 75 08             	pushl  0x8(%ebp)
  801eec:	e8 9a ff ff ff       	call   801e8b <vsnprintf>
	va_end(ap);

	return rc;
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	56                   	push   %esi
  801ef7:	53                   	push   %ebx
  801ef8:	8b 75 08             	mov    0x8(%ebp),%esi
  801efb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801efe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f01:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f03:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f08:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	50                   	push   %eax
  801f0f:	e8 16 e8 ff ff       	call   80072a <sys_ipc_recv>

	if (from_env_store != NULL)
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	85 f6                	test   %esi,%esi
  801f19:	74 14                	je     801f2f <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 09                	js     801f2d <ipc_recv+0x3a>
  801f24:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f2a:	8b 52 74             	mov    0x74(%edx),%edx
  801f2d:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f2f:	85 db                	test   %ebx,%ebx
  801f31:	74 14                	je     801f47 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f33:	ba 00 00 00 00       	mov    $0x0,%edx
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	78 09                	js     801f45 <ipc_recv+0x52>
  801f3c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f42:	8b 52 78             	mov    0x78(%edx),%edx
  801f45:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f47:	85 c0                	test   %eax,%eax
  801f49:	78 08                	js     801f53 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f4b:	a1 08 40 80 00       	mov    0x804008,%eax
  801f50:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f56:	5b                   	pop    %ebx
  801f57:	5e                   	pop    %esi
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	57                   	push   %edi
  801f5e:	56                   	push   %esi
  801f5f:	53                   	push   %ebx
  801f60:	83 ec 0c             	sub    $0xc,%esp
  801f63:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f66:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f6c:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f6e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f73:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f76:	ff 75 14             	pushl  0x14(%ebp)
  801f79:	53                   	push   %ebx
  801f7a:	56                   	push   %esi
  801f7b:	57                   	push   %edi
  801f7c:	e8 86 e7 ff ff       	call   800707 <sys_ipc_try_send>

		if (err < 0) {
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	85 c0                	test   %eax,%eax
  801f86:	79 1e                	jns    801fa6 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f88:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f8b:	75 07                	jne    801f94 <ipc_send+0x3a>
				sys_yield();
  801f8d:	e8 c9 e5 ff ff       	call   80055b <sys_yield>
  801f92:	eb e2                	jmp    801f76 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f94:	50                   	push   %eax
  801f95:	68 40 27 80 00       	push   $0x802740
  801f9a:	6a 49                	push   $0x49
  801f9c:	68 4d 27 80 00       	push   $0x80274d
  801fa1:	e8 28 f9 ff ff       	call   8018ce <_panic>
		}

	} while (err < 0);

}
  801fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa9:	5b                   	pop    %ebx
  801faa:	5e                   	pop    %esi
  801fab:	5f                   	pop    %edi
  801fac:	5d                   	pop    %ebp
  801fad:	c3                   	ret    

00801fae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fb4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fbc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fc2:	8b 52 50             	mov    0x50(%edx),%edx
  801fc5:	39 ca                	cmp    %ecx,%edx
  801fc7:	75 0d                	jne    801fd6 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fc9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fcc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd1:	8b 40 48             	mov    0x48(%eax),%eax
  801fd4:	eb 0f                	jmp    801fe5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd6:	83 c0 01             	add    $0x1,%eax
  801fd9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fde:	75 d9                	jne    801fb9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fe0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    

00801fe7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fed:	89 d0                	mov    %edx,%eax
  801fef:	c1 e8 16             	shr    $0x16,%eax
  801ff2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ff9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ffe:	f6 c1 01             	test   $0x1,%cl
  802001:	74 1d                	je     802020 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802003:	c1 ea 0c             	shr    $0xc,%edx
  802006:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80200d:	f6 c2 01             	test   $0x1,%dl
  802010:	74 0e                	je     802020 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802012:	c1 ea 0c             	shr    $0xc,%edx
  802015:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80201c:	ef 
  80201d:	0f b7 c0             	movzwl %ax,%eax
}
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
  802022:	66 90                	xchg   %ax,%ax
  802024:	66 90                	xchg   %ax,%ax
  802026:	66 90                	xchg   %ax,%ax
  802028:	66 90                	xchg   %ax,%ax
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80203b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80203f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 f6                	test   %esi,%esi
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 ca                	mov    %ecx,%edx
  80204f:	89 f8                	mov    %edi,%eax
  802051:	75 3d                	jne    802090 <__udivdi3+0x60>
  802053:	39 cf                	cmp    %ecx,%edi
  802055:	0f 87 c5 00 00 00    	ja     802120 <__udivdi3+0xf0>
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 fd                	mov    %edi,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f7                	div    %edi
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 c8                	mov    %ecx,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c1                	mov    %eax,%ecx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	89 cf                	mov    %ecx,%edi
  802078:	f7 f5                	div    %ebp
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	39 ce                	cmp    %ecx,%esi
  802092:	77 74                	ja     802108 <__udivdi3+0xd8>
  802094:	0f bd fe             	bsr    %esi,%edi
  802097:	83 f7 1f             	xor    $0x1f,%edi
  80209a:	0f 84 98 00 00 00    	je     802138 <__udivdi3+0x108>
  8020a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	89 c5                	mov    %eax,%ebp
  8020a9:	29 fb                	sub    %edi,%ebx
  8020ab:	d3 e6                	shl    %cl,%esi
  8020ad:	89 d9                	mov    %ebx,%ecx
  8020af:	d3 ed                	shr    %cl,%ebp
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	09 ee                	or     %ebp,%esi
  8020b7:	89 d9                	mov    %ebx,%ecx
  8020b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bd:	89 d5                	mov    %edx,%ebp
  8020bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c3:	d3 ed                	shr    %cl,%ebp
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e2                	shl    %cl,%edx
  8020c9:	89 d9                	mov    %ebx,%ecx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	89 ea                	mov    %ebp,%edx
  8020d3:	f7 f6                	div    %esi
  8020d5:	89 d5                	mov    %edx,%ebp
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	f7 64 24 0c          	mull   0xc(%esp)
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	72 10                	jb     8020f1 <__udivdi3+0xc1>
  8020e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e6                	shl    %cl,%esi
  8020e9:	39 c6                	cmp    %eax,%esi
  8020eb:	73 07                	jae    8020f4 <__udivdi3+0xc4>
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	75 03                	jne    8020f4 <__udivdi3+0xc4>
  8020f1:	83 eb 01             	sub    $0x1,%ebx
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	89 fa                	mov    %edi,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	31 ff                	xor    %edi,%edi
  80210a:	31 db                	xor    %ebx,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d8                	mov    %ebx,%eax
  802122:	f7 f7                	div    %edi
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 c3                	mov    %eax,%ebx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 fa                	mov    %edi,%edx
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 ce                	cmp    %ecx,%esi
  80213a:	72 0c                	jb     802148 <__udivdi3+0x118>
  80213c:	31 db                	xor    %ebx,%ebx
  80213e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802142:	0f 87 34 ff ff ff    	ja     80207c <__udivdi3+0x4c>
  802148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80214d:	e9 2a ff ff ff       	jmp    80207c <__udivdi3+0x4c>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 d2                	test   %edx,%edx
  802179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f3                	mov    %esi,%ebx
  802183:	89 3c 24             	mov    %edi,(%esp)
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	75 1c                	jne    8021a8 <__umoddi3+0x48>
  80218c:	39 f7                	cmp    %esi,%edi
  80218e:	76 50                	jbe    8021e0 <__umoddi3+0x80>
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	f7 f7                	div    %edi
  802196:	89 d0                	mov    %edx,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	77 52                	ja     802200 <__umoddi3+0xa0>
  8021ae:	0f bd ea             	bsr    %edx,%ebp
  8021b1:	83 f5 1f             	xor    $0x1f,%ebp
  8021b4:	75 5a                	jne    802210 <__umoddi3+0xb0>
  8021b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ba:	0f 82 e0 00 00 00    	jb     8022a0 <__umoddi3+0x140>
  8021c0:	39 0c 24             	cmp    %ecx,(%esp)
  8021c3:	0f 86 d7 00 00 00    	jbe    8022a0 <__umoddi3+0x140>
  8021c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	89 fd                	mov    %edi,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x91>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f7                	div    %edi
  8021ef:	89 c5                	mov    %eax,%ebp
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f5                	div    %ebp
  8021f7:	89 c8                	mov    %ecx,%eax
  8021f9:	f7 f5                	div    %ebp
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	eb 99                	jmp    802198 <__umoddi3+0x38>
  8021ff:	90                   	nop
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	8b 34 24             	mov    (%esp),%esi
  802213:	bf 20 00 00 00       	mov    $0x20,%edi
  802218:	89 e9                	mov    %ebp,%ecx
  80221a:	29 ef                	sub    %ebp,%edi
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 f9                	mov    %edi,%ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	d3 ea                	shr    %cl,%edx
  802224:	89 e9                	mov    %ebp,%ecx
  802226:	09 c2                	or     %eax,%edx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 14 24             	mov    %edx,(%esp)
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
  802231:	89 f9                	mov    %edi,%ecx
  802233:	89 54 24 04          	mov    %edx,0x4(%esp)
  802237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	89 c6                	mov    %eax,%esi
  802241:	d3 e3                	shl    %cl,%ebx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 d0                	mov    %edx,%eax
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	09 d8                	or     %ebx,%eax
  80224d:	89 d3                	mov    %edx,%ebx
  80224f:	89 f2                	mov    %esi,%edx
  802251:	f7 34 24             	divl   (%esp)
  802254:	89 d6                	mov    %edx,%esi
  802256:	d3 e3                	shl    %cl,%ebx
  802258:	f7 64 24 04          	mull   0x4(%esp)
  80225c:	39 d6                	cmp    %edx,%esi
  80225e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802262:	89 d1                	mov    %edx,%ecx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	72 08                	jb     802270 <__umoddi3+0x110>
  802268:	75 11                	jne    80227b <__umoddi3+0x11b>
  80226a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80226e:	73 0b                	jae    80227b <__umoddi3+0x11b>
  802270:	2b 44 24 04          	sub    0x4(%esp),%eax
  802274:	1b 14 24             	sbb    (%esp),%edx
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80227f:	29 da                	sub    %ebx,%edx
  802281:	19 ce                	sbb    %ecx,%esi
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 f0                	mov    %esi,%eax
  802287:	d3 e0                	shl    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	d3 ea                	shr    %cl,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 ee                	shr    %cl,%esi
  802291:	09 d0                	or     %edx,%eax
  802293:	89 f2                	mov    %esi,%edx
  802295:	83 c4 1c             	add    $0x1c,%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	29 f9                	sub    %edi,%ecx
  8022a2:	19 d6                	sbb    %edx,%esi
  8022a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ac:	e9 18 ff ff ff       	jmp    8021c9 <__umoddi3+0x69>
