# clap - CLI 인자 파서

#rust #clap #cli #크레이트

---

커맨드라인 인자를 파싱하는 라이브러리. derive 매크로로 선언적 정의가 가능하다.

## 설치

```toml
[dependencies]
clap = { version = "4", features = ["derive"] }
```

## 기본 사용 (derive)

```rust
use clap::Parser;

#[derive(Parser, Debug)]
#[command(name = "myapp")]
#[command(about = "내 CLI 도구", version)]
struct Args {
    /// 입력 파일 경로
    #[arg(short, long)]
    input: String,

    /// 출력 파일 경로
    #[arg(short, long, default_value = "output.txt")]
    output: String,

    /// 상세 출력
    #[arg(short, long)]
    verbose: bool,

    /// 반복 횟수
    #[arg(short, long, default_value_t = 1)]
    count: u32,
}

fn main() {
    let args = Args::parse();
    println!("입력: {}", args.input);
    println!("출력: {}", args.output);

    if args.verbose {
        println!("상세 모드");
    }
}
```

```bash
$ myapp --input data.txt --verbose --count 3
$ myapp -i data.txt -v -c 3
```

## 서브커맨드

```rust
use clap::{Parser, Subcommand};

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// 새 프로젝트 생성
    New {
        #[arg(short, long)]
        name: String,
    },
    /// 빌드
    Build {
        #[arg(long)]
        release: bool,
    },
}

fn main() {
    let cli = Cli::parse();
    match cli.command {
        Commands::New { name } => println!("생성: {}", name),
        Commands::Build { release } => {
            if release { println!("릴리스 빌드") }
            else { println!("디버그 빌드") }
        }
    }
}
```

## 주요 어트리뷰트

| 어트리뷰트 | 설명 |
|-----------|------|
| `#[arg(short, long)]` | 짧은/긴 플래그 자동 생성 |
| `#[arg(default_value = "...")]` | 기본값 |
| `#[arg(required = true)]` | 필수 인자 |
| `#[arg(value_enum)]` | enum 값 파싱 |
| `#[arg(num_args = 1..)]` | 여러 값 |

> [!info] 자동 기능
> clap은 `--help`, `--version`, 에러 메시지를 자동으로 생성한다.
